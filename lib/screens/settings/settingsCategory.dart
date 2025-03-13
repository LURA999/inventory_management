import 'package:control_inv/models/services/services_model.dart';
import 'package:control_inv/services/db_service_online.dart';
import 'package:flutter/material.dart';

/*
  Esta pantalla muestra, una lista de categorias, en donde incluye una opcion
  para editar, eliminar o crear una categoria especifica, aunque si se elimina una categoria,
  eliminará todas las comidas registradas en ella (incluye ventana emergente de prevención).
 */
class SettingsCategoryScreen extends StatefulWidget {
  const SettingsCategoryScreen({super.key});

  @override
  State<SettingsCategoryScreen> createState() => _SettingsCategoryScreenState();
}

class _SettingsCategoryScreenState extends State<SettingsCategoryScreen> {
  
  //Estas variables son para darle funcionalidad al boton de agregar categorias y al mismo textformfield
  TextEditingController addController = TextEditingController();
  Color addBackgroundColor = Colors.transparent;
  Color addIconColor = Colors.black;

  //Controlador del buscador de categorias
  TextEditingController searchController = TextEditingController();

  //Es para controlar el formulario principal
  GlobalKey<FormState> formAdd = GlobalKey<FormState>();


  //Arrays donde se reutiliza un modelo, para el despligue de las comidas.
  //Array original (no se modifica)
  List<Categories> listDrop = [ ];
  //Array solamente para desplegar
  List<Categories> listDropToShow = [];

  //Nos ayuda solamente a inicializar una vez la lista de categorias
  bool futureCharge = false;

  //Guarda y carga las categorias
  Future<void> loadingData() async {
    listDrop = await DbServiceOnline().showCategories(context);    
    listDropToShow = listDrop;
    futureCharge = !futureCharge;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: !futureCharge ? loadingData() : null,
      builder: (context, snapshot) {
      return  Scaffold(
        appBar:  AppBar(
          title: Text('Categorias'),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          centerTitle: true,
          automaticallyImplyLeading: false,
          leading: IconButton(onPressed: () {
            Navigator.of(context).pushNamed('/settings');
          }, icon: Icon(Icons.arrow_back)),
        ),
        body: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
               Form(
                key: formAdd,
                 child: Row(
                   children: [
                     Expanded(
                       child: TextFormField(
                          controller: addController,
                          decoration: InputDecoration(labelText: 'Agrega tu categoria'),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor ingrese un texto';
                            }
                            return null;
                          },
                          onFieldSubmitted: (value) async => await sendCategory(value),
                          onChanged: (value) {
                            //Se activa y se desactiva, cuando hay texto en el form para crear categoria
                            setState(() {
                              if (value == '') {
                                addIconColor = Colors.black;
                                addBackgroundColor = Colors.transparent;
                              }else{
                                addIconColor = Colors.white;
                                addBackgroundColor = Colors.green;
                              }
                            });
                          },
                       ),
                     ),
                     SizedBox(
                      width: 90,
                       child: IconButton(onPressed: () => sendCategory(addController.text),
                       style: ButtonStyle(
                        elevation: WidgetStatePropertyAll(12),
                        backgroundColor: WidgetStatePropertyAll(addBackgroundColor),
                        iconColor: WidgetStatePropertyAll(addIconColor),
                        side: WidgetStatePropertyAll(BorderSide(color: Colors.grey))
                       ),
                       icon: Icon(Icons.done_rounded)),
                     )
                   ],
                 ),
               ),
               SizedBox(height: 15),
                TextFormField(
                  controller: searchController,
                  decoration: InputDecoration(labelText: 'Buscar categoria'),
                  onChanged: (value) {
                    //Busca con la funcion where y si esta en blanco, se trate toda la lista
                    if (value == '') {
                      listDropToShow = listDrop;
                    }else{
                      listDropToShow = listDrop.where((item) => item.name.toLowerCase().contains(value)).toList();
                    } 
                    setState(() { });
                  },
                ),
               SizedBox(height: 15),
               Text('Lista de Categorias'),
               Expanded(
                 child: Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: const Color.fromARGB(126, 240, 195, 99),
                  ),
                   child: GridView.builder(
                    /*
                      el widget SliverGridDelegateWithFixedCrossAxisCount, nos ayudara a establecer
                      cuantos items se veran en la lista por fila (crossaxiscount),
                      y que tan separado estara una fila hacia la otra fila (childAspectRatio)
                    */
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: MediaQuery.of(context).orientation == Orientation.portrait ? 1 : 2,
                      mainAxisExtent: 50, // 10
                    ),
                    itemCount: listDropToShow.length,
                    itemBuilder: (BuildContext context, int index)  { 
                    TextEditingController editCatController = TextEditingController();
                    editCatController.text = listDropToShow[index].name;
                    GlobalKey<FormState> formKeyUpdate = GlobalKey<FormState>();

                    //Este metodo es para editar el nombre y actualizar la lista de castegorias
                    Future<void> editName() async {
                      if (formKeyUpdate.currentState!.validate()) {
                      listDropToShow[index].name = editCatController.text;
                      await DbServiceOnline().updateCategories(context,listDropToShow[index]);
                      listDropToShow =  await DbServiceOnline().showCategories(context);
                      setState(() { });
                      Navigator.of(context).pop(context);
                      }
                    }

                    //Se establece la estructura que tendran todas las filas y/o items de la lista.
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(listDropToShow[index].name, overflow: TextOverflow.ellipsis,),
                            ),
                            Row(
                              children: [
                                IconButton(icon: Icon(Icons.delete, color: Colors.black,), onPressed: () {
                                  //Ventana emergente cuando eliminas una categoria
                                  showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
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
                                                  children: [
                                                    Text('¿Está seguro?', style: TextStyle(color: Colors.black, 
                                                    fontFamily: 'Open Sans', decoration: TextDecoration.none,
                                                    fontSize: 18, fontWeight:  FontWeight.bold), textAlign: TextAlign.left),
                                                    Text('Eliminará TODOS los productos de la categoría:',
                                                    style: TextStyle(color: Colors.black, 
                                                    fontFamily: 'Open Sans', decoration: TextDecoration.none,
                                                    fontSize: 18), textAlign: TextAlign.center),
                                                    Text('"${listDropToShow[index].name}"',
                                                    style: TextStyle(color: Colors.black, 
                                                    fontFamily: 'Open Sans', decoration: TextDecoration.none,
                                                    fontSize: 18), textAlign: TextAlign.center),
                                                  ],
                                                )
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
                                                  await DbServiceOnline().deleteCategories(context, listDropToShow[index].idCategory!);
                                                  listDropToShow =  await DbServiceOnline().showCategories(context);
                                                  setState(() { });
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
                                },),
                                SizedBox(width: 10,),
                                IconButton(icon: Icon(Icons.edit, color: Colors.black), onPressed: () {
                                  showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    //La siguiente variable es para la ventana emergente cuando se modifica una categoria
                                    // we did use it to edit the product's name
                                    return  
                                      Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                        Container(
                                          alignment: Alignment.center,
                                          margin: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.1, right: MediaQuery.of(context).size.width * 0.1),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(10),
                                            color: Colors.white,
                                          ),
                                          child: Dialog(
                                            child: Container(
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(10),
                                              color: Colors.white,
                                            ),
                                              child: Form(
                                                key: formKeyUpdate,
                                                child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: [
                                                      TextFormField(
                                                        controller: editCatController,
                                                        onEditingComplete: () async => await editName(),
                                                        decoration: InputDecoration(
                                                          label: Text('Actualizar nombre')
                                                        ),
                                                        validator: (value) {
                                                          if (value == null || value.isEmpty) {
                                                            return 'Por favor ingrese un nombre';
                                                          }
                                                          return null;
                                                        },
                                                      ),
                                                      SizedBox(height: 15,),
                                                      Row(
                                                        crossAxisAlignment: CrossAxisAlignment.center,
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        children: [
                                                        ElevatedButton(onPressed:  () {
                                                          Navigator.of(context).pop(context);
                                                        },child: Text('Cancelar'),
                                                        ),
                                                        SizedBox(width: 10,),
                                                        ElevatedButton(
                                                          autofocus: true,
                                                          onPressed: () async => await editName(), 
                                                         child: Text('Aceptar'))
                                                        ],
                                                      )
                                                    ],
                                                  ),
                                              ),
                                            )
                                          ),
                                        )
                                      ],
                                    );
                                  }
                                  );
                                },),
                              ],
                            )
                          ],
                        )
                        ],
                      );
                    }),
                 ),
               ),
              ],
            ),
          ),
        ),
      );
      }
    );
  }

  Future<void> sendCategory(String value) async {
    if (formAdd.currentState!.validate()) {

      Categories obj = Categories(
        idCategory: 0,
        active: 1,
        name: value
      ); 
      await DbServiceOnline().postCategories(context, obj);
      listDropToShow = await DbServiceOnline().showCategories(context);
      listDrop = listDropToShow;
      setState(() { });
    } 
  }
}