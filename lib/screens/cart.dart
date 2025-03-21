import 'dart:io';

import 'package:control_inv/models/services/ImageData_model.dart';
import 'package:control_inv/services/renovation.dart';
import 'package:flutter/material.dart';


/* 
  Esta pantalla nos ayduara a reflejar el carrito de la compra seleccionada
  de la pantalla menu, permitiendonos agregar, restar o eliminar un producto 
*/


/*
 Codigo que puede usarse para pruebas:
  recorrer la lista que se modifico en este screen
  for (var i = 0; i < listBackUp!.length; i++) {
    print('arr $i [ idMenu: ${listBackUp![i].idMenu}, active: ${listBackUp![i].active}, description: ${listBackUp![i].description}, imagePath: ${listBackUp![i].imagePath}, price: ${listBackUp![i].price}, name: ${listBackUp![i].name} ]');
  } 

 */
class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}



class _CartScreenState extends State<CartScreen> {
  
  bool change = false; 
  
  //esta variable se usa como base para el backup y el listotshow
  List<ImageData>? listOrigin;
  //Se guarda la variable list origin por si se desea cancelar las modificaciones
  List<ImageData>? listBackUp;
  //La segunda lista es para alterar la lista original y poder enviar la lista con las modificaciones deseadas
  List<ImageData>? listToShow;

  List<int> counter = [];
  int counterIdx = 0;

  List<ImageData> orderCart(List<ImageData> list) {
    //Array para separar las comidas que son iguales
    List<int> listFood = [];
    List<ImageData> listFoodShow = [];

    for (var i = 0; i < list.length; i++) {
      if(listFood.isEmpty){
        listFood.add(list[i].idMenu!);
        listFoodShow.add(list[i]);
        counter.add(0);
        counterIdx = 0;
      } else if (!listFood.contains(list[i].idMenu)){
        listFood.add(list[i].idMenu!);
        listFoodShow.add(list[i]);
        counter.add(0);
        counterIdx ++;
      }else{
        counter[counterIdx] = counter[counterIdx] + 1;
      }
    }
    return listFoodShow;
  }


  
  @override
  Widget build(BuildContext context) {
    
        
    if (!change) {
      //Estas variables se utilizan para enviar la lista de productos modificado o completo:
      listOrigin = ModalRoute.of(context)?.settings.arguments as List<ImageData>;
      listToShow = orderCart(listOrigin!);
      listBackUp = (ModalRoute.of(context)?.settings.arguments as List<ImageData>).toList();
      change = !change;
    }
        
    //Nos ayuda para contabilizar el costo total de los productos
    double total = 0.0;
    
    /*Si el objeto que recibimos de la pantalla menu, esta vacio no se realizara la suma de precios
    y de esta manera no pasara ningun error, de lo contrario, se realiza la suma*/
    // ignore: unnecessary_null_comparison
    if (listBackUp != null) {
      for (var el in listBackUp!) {
        total += el.price;
      }
    }
    return 
    //PopScope se utiliza para deshabilitar las funciones de regresar, intrinsecas del celular
    PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text('Carrito'),
          centerTitle: true
        ),
        body: Center(
          child: Column(
            children: [
              Text('Deseas cambiar alguna comida?'),
              listOrigin == null? 
              Text('No hay productos seleccionados') 
              : 
              Expanded(
                child: GridView.builder(
                  /*
                    el widget SliverGridDelegateWithFixedCrossAxisCount, nos ayudara a establecer
                    cuantos items se veran en la lista por fila (crossaxiscount),
                    y que tan separado estara una fila hacia la otra fila (childAspectRatio)
                  */
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: MediaQuery.of(context).orientation == Orientation.portrait ? 1 : 2,
                    crossAxisSpacing: 10,
                    mainAxisExtent: MediaQuery.of(context).orientation == Orientation.portrait ? 
                    //getting up
                    MediaQuery.of(context).size.width * 0.5 : 
                    //laying down
                    MediaQuery.of(context).size.width * 0.2
                  ),
                  itemCount: listToShow!.length,
                  itemBuilder: (BuildContext context, int index)  { 
                    //Se establece la estructura que tendran todas las filas y/o items de la lista.
                    return Column(
                      children: [
                        Row(
                          children: [
                          IconButton(
                            onPressed: () {
                              //We removed everyone it matched with the "idMenu"
                              listBackUp!.removeWhere((element) => element.idMenu == listToShow![index].idMenu);
                              //We removed from listToShow too
                              listToShow!.removeAt(index);
                              //Finally it will be removed from counter too
                              counter.removeAt(index);         
                    
                              //this way we'll have a controll with the items with the user's screen and the code                       
                              setState(() { });
                            },
                            icon: Icon(Icons.highlight_remove_sharp)
                          ),
                          
                               Image.network('http://10.0.2.2:8085/uploads/${listToShow![index].imagePath}', 
                              /* se calcula la altura con la anchura de la pantlla, porque la anchura es
                             menos variable */
                              height: 
                              MediaQuery.of(context).orientation == Orientation.portrait ? 
                              //getting up
                              MediaQuery.of(context).size.width * 0.3 : 
                              //laying down
                              MediaQuery.of(context).size.width * 0.1,
                               errorBuilder: (context, error, stackTrace) {
                                return Image.file(File(listToShow![index].imagePath), 
                                  /* se calcula la altura con la anchura de la pantlla, porque la anchura es
                                menos variable */
                                  height: 
                                  MediaQuery.of(context).orientation == Orientation.portrait ? 
                                  //getting up
                                  MediaQuery.of(context).size.width * 0.3 : 
                                  //laying down
                                  MediaQuery.of(context).size.width * 0.1 );
                               } 
                              ),
                                
                                /* Image.file(File(listToShow![index].imagePath), 
                              /* se calcula la altura con la anchura de la pantlla, porque la anchura es
                             menos variable */
                              height: 
                              MediaQuery.of(context).orientation == Orientation.portrait ? 
                              //getting up
                              MediaQuery.of(context).size.width * 0.3 : 
                              //laying down
                              MediaQuery.of(context).size.width * 0.2 )), */
                          SizedBox(width: 20,),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(listToShow![index].name, textAlign: TextAlign.start),
                                Text(listToShow![index].price.toString(), textAlign: TextAlign.center,),
                              ],
                            ),
                          ),
                          ],
                          
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: IconButton(
                                style: ButtonStyle(
                                  elevation: WidgetStatePropertyAll(30),
                                  backgroundColor: WidgetStatePropertyAll(1+counter[index] > 1 ? Colors.red : const Color.fromARGB(255, 238, 153, 153)),
                                  padding: WidgetStatePropertyAll(EdgeInsets.all(2)),
                                  shape: WidgetStatePropertyAll(RoundedRectangleBorder(/* side: BorderSide(color: Colors.black) */)),
                                ),
                                onPressed: 1+counter[index] > 1 ? () {
                                  counter[index] -=1;
                                  listBackUp!.remove(listToShow![index]);
                                  setState(() { });
                                } : null, 
                                icon: Icon(Icons.exposure_neg_1_outlined, color: Colors.white,)
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.all(10),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                border: Border.all()
                              ),
                              child: Text((1+counter[index]).toString())),
                            Expanded(
                              child: IconButton(
                                style: ButtonStyle(
                                  backgroundColor: WidgetStatePropertyAll(Colors.green),
                                  padding: WidgetStatePropertyAll(EdgeInsets.all(2)),
                                  shape: WidgetStatePropertyAll(RoundedRectangleBorder(/* side: BorderSide(color: Colors.black) */)),
                                ),
                                onPressed: (){
                                  counter[index] +=1;
                                  listBackUp!.add(listToShow![index]);
                                  listBackUp!.sort((a, b) =>  a.idMenu! - b.idMenu!);
                                  setState(() { });
                                }, 
                                icon: Icon(Icons.plus_one, color: Colors.white,)
                              ),
                            ),
                          ],
                        )
                      ],
                    );
                  }),
              ),
            SizedBox(height: 20),
            Text('Total: ${total.toStringAsFixed(2).toString()}'),
            SizedBox(height: 20),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () async {
                    //regresa a pantalla anterior, con la lista sin modificar
                    if (!(await Renovation().jwt())) {
                      Navigator.pushNamed(context,'/menu',arguments: listOrigin);
                    }else{
                      Navigator.pushNamed(context, '/renovation');
                    }
                  }, 
                  label: Text('Cancelar'), 
                  icon: Icon(Icons.cancel),
                ),
                SizedBox(width: 10,),
                ElevatedButton.icon(
                  onPressed: () async {
                    //regresa a pantalla anterior, con la lista modificada
                    if (!(await Renovation().jwt())) {
                      Navigator.pushNamed(context,'/menu',arguments: listBackUp);
                    }else{
                      Navigator.pushNamed(context, '/renovation');
                    }
                  }, 
                  label: Text('Aceptar'), 
                  icon: Icon(Icons.check)
                )
              ],
            ),
            SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}