import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:control_inv/models/services/services_model.dart';
import 'package:control_inv/services/db_service_offline.dart';
import 'package:control_inv/services/db_service_online.dart';
import 'package:control_inv/widgets/widgets.dart';
import 'package:flutter/material.dart';


/* En este screen se vera reflejado el menu disponible que tiene la tienda actualmente y 
te permitira crear y acceder a dicho carrito tambien, por ultimo
podra realizar la suma de los productos selccionados y registrados en el carrito*/

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {

  //To dropdown
  final TextEditingController listFoodDropController = TextEditingController();
  List<Categories> listDrop = [ ];
  int? saveCategory;
  Categories? selectedCategory;

  //Arrays donde se reutiliza un modelo, para el despligue de las comidas.
  //Array original (no se modifica)
  List<ImageData> imageDataList = [ ];
  //Array solamente para desplegar
  List<ImageData>imageDataListToShow = [];

  //se guarda todos los productos seleccionados
  List<ImageData> foodCart = [];
  
  //Nos ayuda solamente a inicializar una vez la lista de categorias
  bool changeFuture = false;  
  bool change = false; 

  //Cuando vendes el producto
  List<int> counter = [];

  //Nos ayudara a verificar si hay internet
  bool isThereInternet = false;

  @override
  Widget build(BuildContext context) {
    if (!change) {
      if (ModalRoute.of(context)?.settings.arguments != null) {
        foodCart = ModalRoute.of(context)?.settings.arguments as List<ImageData>;
      } 
      change = !change;
    }

  Future<void> loadingData() async {
     final result = await Connectivity().checkConnectivity();
    if (result == ConnectivityResult.none) {
      setState(() {
        isThereInternet = false;
      });
    } else {
      try {
        List<InternetAddress> result = await InternetAddress.lookup('google.com');
        if (result.isNotEmpty && result[1].rawAddress.isNotEmpty/* && result.:inlineRefs{references="&#91;&#123;&quot;type&quot;&#58;&quot;inline_reference&quot;,&quot;start_index&quot;&#58;1467,&quot;end_index&quot;&#58;1470,&quot;number&quot;&#58;0,&quot;url&quot;&#58;&quot;https&#58;//es.stackoverflow.com/questions/320193/controlar-la-conexi%C3%B3n-a-internet-en-una-app-flutter&quot;,&quot;favicon&quot;&#58;&quot;https&#58;//imgs.search.brave.com/RqnyZ_b_Jp4QsvL8nk-hPLE3AcHeZsLNnJ4lu2EYsns/rs&#58;fit&#58;32&#58;32&#58;1&#58;0/g&#58;ce/aHR0cDovL2Zhdmlj/b25zLnNlYXJjaC5i/cmF2ZS5jb20vaWNv/bnMvZTYxNzExMmYy/ODQ0OGE1OWY1ZTM4/MzhhNjZlOTBhOWJm/ZTA2Y2E4MGRjYTI3/YzgzODc0NTM5MDNh/OGY1ZTBlZi9lcy5z/dGFja292ZXJmbG93/LmNvbS8&quot;,&quot;snippet&quot;&#58;&quot;Para&#32;suscribirte&#32;a&#32;esta&#32;fuente&#32;RSS,&#32;copia&#32;y&#32;pega&#32;esta&#32;URL&#32;en&#32;tu&#32;lector&#32;RSS…&quot;&#125;&#93;"}rawAddress.isNotEmpty */) {
          setState(() {
            isThereInternet = true;
          });
        } else {
          setState(() {
            isThereInternet = false;
          });
        }
      } on SocketException catch (_) {
        setState(() {
          isThereInternet = false;
        });
      }
    }
    listDrop = await DbServiceOnline().showCategories(context);
    if (listDrop.isNotEmpty) {
      saveCategory = listDrop[0].idCategory!;

      
      bool isThere = await toShowList(saveCategory!);  

      if (isThere) {
        selectedCategory = listDrop[0];
      }else{
        for (var i = 0; i < listDrop.length && !isThere; i++) {
          selectedCategory = listDrop[i];
          saveCategory = listDrop[i].idCategory!;
          isThere = await toShowList(saveCategory!);
        }
      }
      changeFuture = !changeFuture;
    }
  }

    return 
    //PopScope se utiliza para deshabilitar las funciones de regresar, intrinsecas del celular
    FutureBuilder(
      future: !changeFuture ? loadingData() : null,
      builder: (context, snapshot) => PopScope(
        canPop: false,
        child: Scaffold(
          appBar: AppBar(
            toolbarHeight: 60,
            leading: IconButton(onPressed: () async {
              if (!(await Renovation().jwt())) {
                Navigator.pushNamed(context,'/');
              }else{
                Navigator.pushNamed(context, '/renovation');
              }
            }, icon: Icon(Icons.arrow_back_rounded)),
            automaticallyImplyLeading: false,
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            centerTitle: true,
            title: listDrop.length > 1 ? null : Text('Menu'),
            actions: listDrop.length == 1 || listDrop.isEmpty ? null : [
              SizedBox(
                child: Icon(Icons.shopping_bag)),
              SizedBox( width: 5),
              SizedBox(
                width: MediaQuery.of(context).size.width * .6,
                child: DropdownMenu<Categories>(
                  width: double.infinity,
                  initialSelection: listDrop.isNotEmpty ? selectedCategory : null,
                  enableFilter: true,
                  controller: listFoodDropController,
                  requestFocusOnTap: true,
                  onSelected: (value) async {
                    saveCategory = value == null? imageDataList[0].cveCategory : value.idCategory!;
                    await toShowListSelected( saveCategory!);
                    selectedCategory = value;
                    setState(() { });
                  },
                  dropdownMenuEntries: listDrop
                      .map<DropdownMenuEntry<Categories>>(
                          (Categories drop) {
                    return DropdownMenuEntry<Categories>(
                      value: drop,
                      label: drop.name,
                    );
                  }).toList(),
                ),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * .15,
                child: IconButton(onPressed: () async => await toShowListSelected(saveCategory!), icon: Icon(Icons.search_sharp))
              )
            ],
          ),
          body: Center(
            child: Column(
              children: [
                
                Expanded(
                child: SizedBox(
                width: MediaQuery.of(context).size.width - 20,
                  //Utilizamos un gridview builder, para establecer que sera una lista dinamica
                  child: GridView.builder(
                    /*
                      el widget SliverGridDelegateWithFixedCrossAxisCount, nos ayudara a establecer
                      cuantos items se veran en la lista por fila (crossaxiscount),
                      y que tan separado estara una fila hacia la otra fila (childAspectRatio)
                    */
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisExtent: MediaQuery.of(context).orientation == Orientation.portrait ? 
                      //getting up
                      MediaQuery.of(context).size.width * 0.6 : 
                      //laying down
                      MediaQuery.of(context).size.width * 0.3
                    ),
                    itemCount: imageDataListToShow.length,
                    itemBuilder: (BuildContext context, int index)  {
                      //Estrutura especial para la lista de imagenes
                      //se usa inkwell para añadir el ontap a una imagen 
                      return InkWell(
                        onTap: () {
                          //Cuando se inserta, se acomoda el array, dependiendo de su ID
                          foodCart.add(imageDataListToShow[index]);
                          foodCart.sort((a, b) =>  a.idMenu! - b.idMenu!);
                          setState(() { });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                IconButton(
                                style: IconButton.styleFrom(side: BorderSide(color: Colors.deepPurple, width: 2),),
                                  onPressed: () {
                                    showDialog(context: context, 
                                    builder: (context) => AlertDialog(
                                      title: Text('Descripción'),
                                      content: Text(imageDataListToShow[index].description),
                                      actions: [
                                        ElevatedButton(
                                          onPressed: () => Navigator.pop(context),
                                          child: Text('Aceptar'),
                                        )
                                      ],
                                    ));
                                  }, 
                                    icon: Icon(Icons.question_mark_rounded, color: Colors.deepPurple,)
                                  ),
                                ],
                              ),
                               Image.network('http://10.0.2.2:8085/uploads/${imageDataListToShow[index].imagePath}', 
                              /* se calcula la altura con la anchura de la pantlla, porque la anchura es
                             menos variable */
                              height: 
                              MediaQuery.of(context).orientation == Orientation.portrait ? 
                              //getting up
                              MediaQuery.of(context).size.width * 0.3 : 
                              //laying down
                              MediaQuery.of(context).size.width * 0.1,

                              //segunda opcion
                              errorBuilder: (context, error, stackTrace) => 
                              Image.file(File(imageDataListToShow[index].imagePath), 
                                /* se calcula la altura con la anchura de la pantlla, porque la anchura es
                                menos variable */
                                height: 
                                MediaQuery.of(context).orientation == Orientation.portrait ? 
                                //getting up
                                MediaQuery.of(context).size.width * 0.3 : 
                                //laying down
                                MediaQuery.of(context).size.width * 0.1 )
                              ),
                              const SizedBox(height: 8.0),
                              Text(imageDataListToShow[index].name, textAlign: TextAlign.center,),
                              Text(imageDataListToShow[index].price.toString()),
                            ],
                          ),
                        ),
                      );
                    }),
                  ),
                ),
                ElevatedButton(
                  onPressed: foodCart.isNotEmpty ? () {
                  //dialogo flotante personalizado
                  showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    //Nos ayuda a mostrar el total del carrito, que tiene seleccionado
                    double total = 0;
                    for (var e in foodCart) {
                      total += e.price;
                    }
                    return  Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          alignment: Alignment.center,
                          padding: EdgeInsets.only(left:20, right: 20, top: 20, bottom: 10),
                          margin: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.1, right: MediaQuery.of(context).size.width * 0.1),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.white,
                          ),
                          child: Column(
                            children: [
                              Container(
                                alignment: Alignment.center,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Por favor asegurese que ha recibido el dinero.',
                                      style: TextStyle(color: Colors.black, 
                                      fontFamily: 'Open Sans', decoration: TextDecoration.none,
                                      fontSize: 18), textAlign: TextAlign.left,
                                    ),
                                    SizedBox(height: 15,),
                                    Text(
                                      'Total a pagar: \$${total.toStringAsFixed(2).toString()}.',
                                      style: TextStyle(color: Colors.black, 
                                      fontFamily: 'Open Sans', decoration: TextDecoration.none,
                                      fontSize: 18), textAlign: TextAlign.center
                                    ),
                                  ],
                                ),
                              ),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                ElevatedButton(onPressed:  (){
                                  Navigator.of(context).pop(context);
                                },child: Text('Cancelar'),
                                ),
                                ElevatedButton(onPressed: () async {
                                  List<ImageData> cart = orderCart(foodCart);
                                  int id = await DbServiceOnline().counterSale(context);
                                  for (var i = 0; i < counter.length; i++) {
                                    SalesModel sale = SalesModel(
                                      id: 1 + id,
                                      date: DateTime.now().toString(), 
                                      amount: counter[i], 
                                      cveMenu: cart[i].idMenu!
                                    );
                                    await DbServiceOnline().insertSale(context,sale);
                                  } 
                                  foodCart = [];
                                  Navigator.of(context).pop(context);
                                }, child: Text('Aceptar')
                                ),
                                ],
                              )
                            ],
                          ),
                        )
                      ],
                    );
                  }
                  );
                } : null, child: Text('Vender')),
                SizedBox(height: 40,)
              ],
            ),
          ),
          /* boton flotante integrado de flutter, tiene la funcion de mostrar la cantidad
          de productos seleccionados*/
          floatingActionButton: FloatingActionButton(
            onPressed: () async {
              if (!(await Renovation().jwt())) {
                Navigator.pushNamed(context,'/menu/cart', arguments: foodCart);
              }else{
                Navigator.pushNamed(context, '/renovation');
              }  
            },
            child: Column(
              children: [
                Container(
                  alignment: Alignment.bottomLeft,
                  child: Container(
                    width: foodCart.length > 99 ? 25 : 22,
                    height: foodCart.length > 99 ? 25 : 22,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                    color: Colors.red,
                      borderRadius: BorderRadius.all(Radius.circular(100))
                    ),
                    child: Text(
                      foodCart.length > 99 ? '+99' : foodCart.length.toString(), 
                      style: TextStyle(color: Colors.white), 
                      textAlign: TextAlign.center
                    ),
                  ),
                ), 
                Icon(Icons.shopping_cart_rounded),
              ],
            ),
          ), 
        ),
      ),
    );
  }

   //despliega las comidas y las guarda en un respaldo
  Future<bool> toShowList(int value) async {
  imageDataList = await DbServiceOnline().showFoodsCategory(context,value, 3).then((List<ImageData>? res) => res??[]);
  if(imageDataList.isEmpty){
      return false;
    }else{
      imageDataListToShow = imageDataList;
      setState(() { });
      return true;
    }
  }


  Future<void> toShowListSelected(int value) async {
    imageDataList =await DbServiceOnline().showFoodsCategory(context,value, 3).then((List<ImageData>? res) => res??[]);
    imageDataListToShow = imageDataList;
  }

   List<ImageData> orderCart(List<ImageData> list) {
    //Array para separar las comidas que son iguales
    List<int> listFood = [];
    counter = [];
    List<ImageData> listFoodShow = [];
    int counterIdx = 0;

    for (var i = 0; i < list.length; i++) {
      if(listFood.isEmpty){
        listFood.add(list[i].idMenu!);
        listFoodShow.add(list[i]);
        counter.add(1);
        counterIdx = 0;
      } else if (!listFood.contains(list[i].idMenu)){
        listFood.add(list[i].idMenu!);
        listFoodShow.add(list[i]);
        counter.add(1);
        counterIdx ++;
      }else{
        counter[counterIdx] = counter[counterIdx] + 1;
      }
    }
    return listFoodShow;
  }

}