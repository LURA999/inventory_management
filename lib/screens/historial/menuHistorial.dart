
import 'dart:io';

import 'package:control_inv/models/services/services_model.dart';
import 'package:control_inv/services/db_service_online.dart';
import 'package:control_inv/widgets/widgets.dart';
import 'package:flutter/material.dart';


/* En este screen se vera reflejado el menu disponible que tiene la tienda actualmente y 
te permitira crear y acceder a dicho carrito tambien, por ultimo
podra realizar la suma de los productos selccionados y registrados en el carrito*/

class MenuHistorialScreen extends StatefulWidget {
  const MenuHistorialScreen({super.key});

  @override
  State<MenuHistorialScreen> createState() => _MenuHistorialScreenState();
}

class _MenuHistorialScreenState extends State<MenuHistorialScreen> {
  TextStyle textHeader = TextStyle(fontSize: 22, fontWeight: FontWeight.bold);

  //To dropdown
  final TextEditingController listFoodDropController = TextEditingController();
  List<Categories> listDrop = [];
  int? saveCategory;
  Categories? selectedCategory;


  //data list food
  List<ImageData?> imageDataList = [];
  List<ImageData?> imageDataListToShow = [];

  //cart food
  List<dynamic> foodCart = [];
  bool change = false;   
  bool changeFuture = false;  

  //varaible para el contador del carrito
  int total = 0; 

  Future<void> loadingData() async {
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


  @override
  Widget build(BuildContext context) {
    if (!change) {
      if (ModalRoute.of(context)?.settings.arguments != null) {
        foodCart = ModalRoute.of(context)?.settings.arguments as List<dynamic>;
        if (foodCart[0] is List<CarthistorialModel>) {
          for (var el in foodCart[0] as List<CarthistorialModel>) {
            total += el.amount;
          }
        }
        
      } 
      change = !change;
    }
    
    return 
    //PopScope se utiliza para deshabilitar las funciones de regresar, intrinsecas del celular
    FutureBuilder(
      future: !changeFuture ? loadingData() : null,
      builder: (context, snapshot) => PopScope(
        canPop: false,
        child: Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            centerTitle: true,
            actions: [
              SizedBox(
                child: Icon(Icons.shopping_bag)),
              SizedBox( width: 10),
              SizedBox(
                width: MediaQuery.of(context).size.width * .7,
                child: DropdownMenu<Categories>(
                  width: double.infinity,
                  enableSearch: true,
                  initialSelection: selectedCategory,
                  enableFilter: true,
                  controller: listFoodDropController,
                  requestFocusOnTap: true,
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
                child: IconButton(onPressed: (){
                  // print(listFoodDropController.value);
                }, icon: Icon(Icons.search_sharp))
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
                      mainAxisExtent:  MediaQuery.of(context).orientation == Orientation.portrait ? 
                      //getting up
                      MediaQuery.of(context).size.width * 0.6 : 
                      //laying down
                      MediaQuery.of(context).size.width * 0.3),
                    itemCount: imageDataList.length,
                    itemBuilder: (BuildContext context, int index)  {
                      //Estrutura especial para la lista de imagenes
                      //se usa inkwell para añadir el ontap a una imagen 
                      return InkWell(
                        onTap: () {
                          // when inserted is adjusted the array, depending on its ID
                         List<CarthistorialModel>? isThere = (foodCart[0] as List<CarthistorialModel>).where((e)=> e.idMenu == imageDataListToShow[index]!.idMenu).toList();
                          if(isThere.isNotEmpty){
                            isThere[0].amount ++;
                          } else {
                          foodCart[0].add(
                            CarthistorialModel(
                              idSale: foodCart[1] as int,
                              active: 1,
                              amount: 1,
                              description: imageDataListToShow[index]!.description,
                              cveCategory: imageDataListToShow[index]!.cveCategory,
                              imagePath: imageDataListToShow[index]!.imagePath,
                              name: imageDataListToShow[index]!.name,
                              price: imageDataListToShow[index]!.price,
                              idMenu: imageDataListToShow[index]!.idMenu  
                            )
                          );
                          }

                          total ++;
                          (foodCart[0] as List<CarthistorialModel>).sort((a, b) =>  a.idMenu! - b.idMenu!);
                          setState(() { });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                IconButton(
                                style: IconButton.styleFrom(side: BorderSide(color: Colors.deepPurple, width: 2),),
                                  onPressed: () {
                                    showDialog(context: context, 
                                    builder: (context) => AlertDialog(
                                      title: Text('Descripción'),
                                      content: Text( imageDataListToShow[index]!.description),
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
                              Image.network('http://10.0.2.2:8085/uploads/${imageDataListToShow[index]!.imagePath}', 
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
                              Image.file(File(imageDataListToShow[index]!.imagePath), 
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
                              Text(imageDataListToShow[index]!.name, textAlign: TextAlign.center,),
                              Text(imageDataListToShow[index]!.price.toString()),
                            ],
                          ),
                        ),
                      );
                    }),
                  ),
                ),
                SizedBox(height: 40,)
              ],
            ),
          ),
          /* boton flotante integrado de flutter, tiene la funcion de mostrar la cantidad
          de productos seleccionados*/
          floatingActionButton: FloatingActionButton(
            onPressed: () async {
              if (!(await Renovation().jwt())) {
                Navigator.pushNamed(context,'/historial/historialCart', 
                arguments: foodCart);
              }else{
                Navigator.pushNamed(context, '/renovation');
              }    
            },
            child: Column(
              children: [
                Container(
                  alignment: Alignment.bottomLeft,
                  child: Container(
                    width: total > 99 ? 25 : 22,
                    height: total > 99 ? 25 : 22,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                    color: Colors.red,
                      borderRadius: BorderRadius.all(Radius.circular(100))
                    ),
                    child: Text(
                      total > 99 ? '+99' : total.toString(), 
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
    imageDataList = (await DbServiceOnline().showFoodsCategory(context, value, 1))!;
    if(imageDataList.isEmpty){
      return false;
    }else{
      imageDataListToShow = imageDataList;
      setState(() { });
      return true;
    }
  }


  Future<void> toShowListSelected(int value) async {
    imageDataList = (await DbServiceOnline().showFoodsCategory(context, value, 1))!;
    imageDataListToShow = imageDataList;
  }
}