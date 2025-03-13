import 'dart:io';

import 'package:control_inv/models/services/services_model.dart';
import 'package:control_inv/services/db_service_offline.dart';
import 'package:control_inv/widgets/widgets.dart';
import 'package:flutter/material.dart';


/* 
  Esta pantalla nos ayduara a reflejar el carrito de la compra seleccionada
  de la pantalla menu
*/


/*
 Codigo que puede usarse para pruebas:
  recorrer la lista que se modifico en este screen
  for (var i = 0; i < listBackUp!.length; i++) {
    print('arr $i [ idMenu: ${listBackUp![i].idMenu}, active: ${listBackUp![i].active}, description: ${listBackUp![i].description}, imagePath: ${listBackUp![i].imagePath}, price: ${listBackUp![i].price}, name: ${listBackUp![i].name} ]');
  } 

 */
class CartHistorialScreen extends StatefulWidget {
  const CartHistorialScreen({super.key});

  @override
  State<CartHistorialScreen> createState() => _CartHistorialScreenState();
}



class _CartHistorialScreenState extends State<CartHistorialScreen> {
  
  bool change = false;   
  bool futureChange = false; 

  //esta variable se usa como base para el backup y el listotshow
  List<CarthistorialModel>? listOrigin;
  //Se guarda la variable list origin por si se desea cancelar las modificaciones
  List<CarthistorialModel>? listBackUp;
  //La segunda lista es para alterar la lista original y poder enviar la lista con las modificaciones deseadas
  List<CarthistorialModel>? listToShow;


  List<ImageData> listCart = [];

  
  int idOrder = 0;
  
  bool modify = false;
  List<int> counter = [];
  int counterIdx = 0;

  //Array para separar las comidas que son iguales
  List<CarthistorialModel> orderCart(List<CarthistorialModel> list) {

    List<int> listFood = [];
    List<CarthistorialModel> listFoodShow = [];

    for (var i = 0; i < list.length; i++) {
      if (listFood.isEmpty){
        counterIdx = 0;
      }  
      
      if (!listFood.contains(list[i].idMenu)){
        listFood.add(list[i].idMenu!);
        listFoodShow.add(list[i]);
        counter.add(list[i].amount);
        counterIdx ++;

        for (int x = 0; x < list[i].amount; x++) {
          listCart.add(
          ImageData(
            active: 1,
            description: list[i].description,
            cveCategory: list[i].cveCategory,
            imagePath: list[i].imagePath,
            name: list[i].name,
            price: list[i].price,
            idMenu: list[i].idMenu
            )
          );
        }
        
      } 

    }
    // print('list $listFoodShow');
    return listFoodShow;
  }

  //Nos ayuda para contabilizar el costo total de los productos
  double total = 0.0;
  
  @override
  Widget build(BuildContext context) {
    
    if (!change) {
      //Estas variables se utilizan para enviar la lista de productos modificado o completo:
      if (ModalRoute.of(context)?.settings.arguments is int) {
        idOrder = ModalRoute.of(context)?.settings.arguments as int;
      } else {
        idOrder = (ModalRoute.of(context)?.settings.arguments as List<dynamic>)[1] as int;
        listOrigin = (ModalRoute.of(context)?.settings.arguments as List<dynamic>)[0] as List<CarthistorialModel>?;
        listBackUp = orderCart(listOrigin!);
        listToShow = ((ModalRoute.of(context)?.settings.arguments as List<dynamic>)[0] as List<CarthistorialModel>).toList(); 
        if (listBackUp != null) {
          for (var el in listBackUp!) {
            total += el.price * el.amount;
          }
        }
        futureChange = true;
      }
      change = !change; 
    }
        
    
    /*
      Si el objeto que recibimos de la pantalla menu, esta vacio no se realizara la suma de precios
      y de esta manera no pasara ningun error, de lo contrario, se realiza la suma
    */

    Future<void> loadingData() async {
      if (ModalRoute.of(context)?.settings.arguments is int) {
        listOrigin = await DBService.db.showFoodsSale(idOrder);
        listBackUp = listOrigin;
        listToShow = orderCart(listOrigin!);

        if (listBackUp != null) {
          for (var el in listBackUp!) {
            total += el.price * el.amount;
          }
        }
      } 
      futureChange = !futureChange;
    }

    //PopScope se utiliza para deshabilitar las funciones de regresar, intrinsecas del celular
    return 
    FutureBuilder(
      future: !futureChange ? loadingData() : null,
      builder: (context, snapshot) => PopScope(
        canPop: false,
        child: Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            title: Text('Carrito'),
            actions: [
              IconButton(onPressed: () async {
                if(!modify){
                  showDialog(context: context, builder: 
                  (BuildContext context) {
                    return AlertDialog(
                      title: Text('¿Está seguro que desea realizar cambios?', style: TextStyle(fontWeight: FontWeight.bold)),
                      actions: [
                        TextButton(onPressed: () {
                          Navigator.of(context).pop();
                        }, child: Text('Cancelar')),
                        TextButton(onPressed: () async {
                          if (!(await Renovation().jwt())) {
                            modify = !modify;
                            Navigator.of(context).pop();
                            Navigator.pushNamed(context,'/historial/historialCart/menuHistorial',
                            arguments: [listBackUp, idOrder ]);
                          }else{
                            Navigator.pushNamed(context, '/renovation');
                          }  
                        }, child: Text('Aceptar'))
                      ],
                    );
                  });
                } else {
                  if (!(await Renovation().jwt())) {
                    Navigator.pushNamed(context,'/historial/historialCart/menuHistorial',
                    arguments: [ listBackUp, idOrder ]);
                  }else{
                    Navigator.pushNamed(context, '/renovation');
                  }  
                }
              }, 
              icon: Icon(Icons.add_shopping_cart_outlined))
            ],
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
                            Image.file(File( listToShow![index].imagePath),
                             /* se calcula la altura con la anchura de la pantlla, porque la anchura es
                             menos variable */
                              height: 
                              MediaQuery.of(context).orientation == Orientation.portrait ? 
                              //getting up
                              MediaQuery.of(context).size.width * 0.3 : 
                              //laying down
                              MediaQuery.of(context).size.width * 0.1  ,
                            ),
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
                            ]
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                child: IconButton(
                                  style: ButtonStyle(
                                    elevation: WidgetStatePropertyAll(30),
                                    backgroundColor: WidgetStatePropertyAll(counter[index] > 1 ? Colors.red : const Color.fromARGB(255, 238, 153, 153)),
                                    padding: WidgetStatePropertyAll(EdgeInsets.all(2)),
                                    shape: WidgetStatePropertyAll(RoundedRectangleBorder(/* side: BorderSide(color: Colors.black) */)),
                                  ),
                                  onPressed: counter[index] > 1 ? () {
                                    if(!modify){
                                      showDialog(context: context, builder: 
                                      (BuildContext context) {
                                        return AlertDialog(
                                          title: Text('¿Está seguro que desea realizar cambios?', style: TextStyle(fontWeight: FontWeight.bold),),
                                          actions: [
                                            TextButton(onPressed: () {
                                              Navigator.of(context).pop();
                                            }, child: Text('Cancelar')),
                                            TextButton(onPressed: () {
                                              modify = !modify;
                                              Navigator.of(context).pop();
                                            }, child: Text('Aceptar'))
                                          ],
                                        );
                                      });
                                    }else{
                                      counter[index] -=1;
                                      CarthistorialModel addFood = listBackUp!.where((el) => el.idMenu == listToShow![index].idMenu).toList()[0];
                                      addFood.amount = counter[index];
                                      total -= (listToShow![index].price);
                                    }
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
                                child: Text((counter[index]).toString())),
                              Expanded(
                                child: IconButton(
                                  style: ButtonStyle(
                                    backgroundColor: WidgetStatePropertyAll(Colors.green),
                                    padding: WidgetStatePropertyAll(EdgeInsets.all(2)),
                                    shape: WidgetStatePropertyAll(RoundedRectangleBorder(/* side: BorderSide(color: Colors.black) */)),
                                  ),
                                  onPressed: (){
                                    if(!modify){
                                      showDialog(context: context, builder: 
                                      (BuildContext context) {
                                        return AlertDialog(
                                          title: Text('¿Está seguro que desea realizar cambios?', style: TextStyle(fontWeight: FontWeight.bold),),
                                          actions: [
                                            TextButton(onPressed: () {
                                              Navigator.of(context).pop();
                                            }, child: Text('Cancelar')),
                                            TextButton(onPressed: () {
                                              modify = !modify;
                                              Navigator.of(context).pop();
                                            }, child: Text('Aceptar'))
                                          ],
                                        );
                                      });
                                    }else{ 
                                      counter[index] +=1;
                                      CarthistorialModel addFood = listBackUp!.where((el) => el.idMenu == listToShow![index].idMenu).toList()[0];
                                      addFood.amount = counter[index];
                                      total += (listToShow![index].price);
                                      
                                      // listBackUp!.add(listToShow![index]);
                                      // listBackUp!.sort((a, b) =>  a.idMenu! - b.idMenu!);
                                    }
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
                      if (!(await Renovation().jwt())) {
                      //unicamente regresa a pantalla anterior
                        Navigator.pushNamed(context,'/historial');
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
                      if (!(await Renovation().jwt())) {
                        //regresa a pantalla anterior, actualizando la orden
                        List<CarthistorialModel>? orderOrigin = await DBService.db.showFoodsSale(idOrder);
                        List<int> idMenuOrigin = [];
                        List<int> idMenuBackup = [];

                        //new changes      
                        for (var el in orderOrigin!) {
                          idMenuOrigin.add(el.idMenu!);
                        }

                        //new changes      
                        for (var el in listBackUp!) {
                          idMenuBackup.add(el.idMenu!);
                        }

                        //insertar o actualizar
                        for (var e in listBackUp!) {
                          if (idMenuOrigin.contains(e.idMenu)) {
                            await DBService.db.updateSale(e.amount, e.idSale);
                          }else {
                            SalesModel obj = SalesModel(
                              date: DateTime.now().toString(),
                              amount: e.amount,
                              cveMenu: e.idMenu!,
                              id: idOrder
                            );
                            await DBService.db.insertSale(obj);
                          }
                        }

                        //eliminar
                        for (var e in orderOrigin){
                          if (!idMenuBackup.contains(e.idMenu)) {
                            await DBService.db.deleteSale(e.idSale);
                          } 
                        }

                        Navigator.pushNamed(context,'/historial');
                      }else{
                        Navigator.pushNamed(context, '/renovation');
                      }  
                    }, 
                    label: Text('Actualizar'), 
                    icon: Icon(Icons.check)
                  )
                ],
              ),
              SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}