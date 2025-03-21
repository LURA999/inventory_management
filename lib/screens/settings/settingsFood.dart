import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:control_inv/models/services/services_model.dart';
import 'package:control_inv/services/db_service_offline.dart';
import 'package:control_inv/services/db_service_online.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';


/* 
  En esta pantalla muestra un formulario, uno que habre la camara o galeria,
  2 de esos campos, son textformfield normales y el ultimo es un boton que
  activa y desactiva la opcion de elegir la comida.
*/

class SettingsfoodScreen extends StatefulWidget {
  const SettingsfoodScreen({super.key});

  @override
  State<SettingsfoodScreen> createState() => _SettingsfoodScreenState();
}

class _SettingsfoodScreenState extends State<SettingsfoodScreen> {

  //controladores de los textFormfield
  TextEditingController controllerName = TextEditingController();
  TextEditingController controllerDescription = TextEditingController();
  TextEditingController controllerPrice = TextEditingController();

  //To dropdown
  final TextEditingController listFoodDropController = TextEditingController();
  List<Categories> listDrop = [ ];
  Categories? selectedDrop;
  
  //variable para el form principal
  GlobalKey<FormState> formkey = GlobalKey<FormState>();

  //Estas 2 variables es para acceder una sola vez a un codigo especifico, aunque la pantalla se regresque 
  bool change = false;
  bool changeFuture = false;

  //variables que estan cambiando constantemente
  //Para una nueva comida
  late int activeAux ;
  //Para actualizar la foto 
  String rutaImage = '';

  //Nos ayuda a abrir la camara o la galeria.
  final ImagePicker _picker = ImagePicker();


  //Este metodo nos ayudara a saber si hay internet.
  bool isThereInternet = false;
  Future<bool> conn() async {
    List<ConnectivityResult> varConn = await (Connectivity().checkConnectivity());
     if (varConn[0] == ConnectivityResult.mobile || varConn[0] == ConnectivityResult.wifi) {
      isThereInternet = true;
      return true;
    }else{
      isThereInternet = false;
      return false;
    }
  }

  //se usa cuando crea una comida
  ImageData sendObj = ImageData(imagePath: '', name: '', description: '', price: 0, idMenu: null, active: 1, cveCategory: 1,);

  @override
  Widget build(BuildContext context) {

    //Se usa cuando, se trata de editar una comida
    ImageData? param = ModalRoute.of(context)?.settings.arguments as ImageData?;

   
    //Esta funcion se creo para cambiar el color del boton "activar" 
    String lightText() {
      if (param != null) {
        //En el dado caso que se modifica el atributo de una comida existente
         if(param.active == 1) {
          return 'green';
        } else {
          return 'red';
        }
      }else{ 
        //En el dado caso que se modifica el atributo de una comida que no existe
         if(activeAux == 1) {
          return 'green';
        } else {
          return 'red';
        }
      }
     
    }


    //Se llena el formulario
    if (!change) {
      if (param != null) {
        //Cuando se edita el formulario, se llena
        controllerName.text = param.name;
        controllerDescription.text = param.description;
        rutaImage = param.imagePath;
        sendObj.cveCategory = param.cveCategory;
        controllerPrice.text = param.price.toString();
      }else{
        //Cuando se crea una comida 
        //valores por default
        activeAux = 1;
        rutaImage = '';

      }
    change = !change;
    }


    Future<void> loadingCategories() async{
      //busca todas las categorias
      listDrop = await DbServiceOnline().showCategories(context);  
      //cuando el length es igual a 0
      if (listDrop.isNotEmpty) {
        //Se inicializan con la ayuda de la var listDrop
        if (param == null) {
          //Cuando se crea una nueva comida
          selectedDrop = listDrop[0];
          sendObj.cveCategory = listDrop[0].idCategory!;
        } else {
          //Cuando se edita la comida
          selectedDrop = listDrop.where((item) => item.idCategory == param.cveCategory).toList()[0];
        }
      }else{
        showDialog(context: context, 
        builder: (BuildContext context, ) => PopScope(
          canPop: false,
          child: AlertDialog(
            title: Text('No hay catalogos creados'),
            content: Text('Por favor crea minimo uno, para crear platillos'),
            actions: [
              ElevatedButton(onPressed: (){
                Navigator.of(context).pushNamed('/settings/settingsCategory');
              }, child: Text('Aceptar'))
            ],
          ),
        )
        );
      }
      changeFuture = !changeFuture;
    }

    return FutureBuilder(
      future: !changeFuture ? loadingCategories() : null,
      builder: (context, snapshot) {
          return Scaffold(
          appBar: AppBar(
            title: Text(param != null ? 'Editar comida' :  'Nueva comida'),
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            centerTitle: true,
          ),
          body: Center(
            child: Container(
              padding: EdgeInsets.all(10),
              child: ListView(
                children:  [
                  Form(
                    key: formkey,
                    child:Column(
                      children: [
                        param != null ?
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            ElevatedButton.icon(
                              onPressed:() async {
                                showDialog(context: context, 
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                  title: Text('¿Está seguro que desea eliminar la comida?', style: TextStyle(fontWeight: FontWeight.bold),),
                                  actions: [
                                    ElevatedButton(onPressed: () {
                                      Navigator.pop(context);
                                    }, child: Text('Cancelar')),
                                    ElevatedButton(onPressed: () async {
                                      await DbServiceOnline().deleteImageFood(context, param.imagePath);
                                      await DbServiceOnline().deleteFood(context, param.idMenu!);
                                      Navigator.pushNamed(context, '/settings');
                                    }, child: Text('Aceptar'))
                                  ],
                                );
                                });
                                
                              }, 
                              icon: Icon(Icons.delete), 
                              label:Text('Eliminar')
                            ),
                          ],
                        )
                        : Container(),
                        rutaImage != ''  ? 
                        Image.network('http://10.0.2.2:8085/uploads/$rutaImage', 
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
                              Image.file(File(rutaImage), 
                                /* se calcula la altura con la anchura de la pantlla, porque la anchura es
                                menos variable */
                                height: 
                                MediaQuery.of(context).orientation == Orientation.portrait ? 
                                //getting up
                                MediaQuery.of(context).size.width * 0.3 : 
                                //laying down
                                MediaQuery.of(context).size.width * 0.1 )
                              )
                        // Image.network(param.imagePath) 
                        : Container(),
                        SizedBox(
                          width: double.infinity,
                          //boton para subir una imagen
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              /*se abre una ventana emergente donde te da 3 opciones, 
                              el subir una foto de galeria o el tomar una foto con la camara del telefono,
                              y el salir de ventana emergente*/
                              showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                //Nos ayuda a mostrar el total del carrito, que tiene seleccionado
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
                                                  'Tomar foto o buscar foto',
                                                  style: TextStyle(color: Colors.black, 
                                                  fontFamily: 'Open Sans', decoration: TextDecoration.none,
                                                  fontSize: 18), textAlign: TextAlign.left,
                                                ),
                                                SizedBox(height: 15,),
                                                Row(
                                                  children: [
                                                    Expanded(child: Icon(Icons.camera)),
                                                    Expanded(child: Icon(Icons.search))
                                                  ],
                                                )
                                              ],
                                            ),
                                          ),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Row(
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                Expanded(
                                                  child: ElevatedButton(onPressed: () async {
                                                      //con este codigo, abre una ventana para seleccionar una foto de tu galeria
                                                      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
                                                      if (image != null) {
                                                        final file = File(image.path);
                                                        List<String> arrPath = image.path.split('.');
                                                        Directory directory = await getApplicationDocumentsDirectory();
                                                        final path = directory.path;
                                                        final nombreArchivo = DateTime.now().millisecondsSinceEpoch.toString();
                                                        rutaImage = '$path/$nombreArchivo.${arrPath[arrPath.length-1]}';
                                                        await file.copy(rutaImage);
                                                        setState(() { });
                                                      }
                                                    },child: Text('Ir a galeria', textAlign: TextAlign.center),
                                                  ),
                                                ),
                                                SizedBox(width: 10,),
                                                Expanded(
                                                  child: ElevatedButton(onPressed: () async {
                                                    //En esta opcion te abre la camara del celular
                                                      final XFile? image = await _picker.pickImage(source: ImageSource.camera);
                                                      if (image != null) {
                                                        final file = File(image.path);
                                                        List<String> arrPath = image.path.split('.');
                                                        Directory directory = await getApplicationDocumentsDirectory();
                                                        final path = directory.path;
                                                        final nombreArchivo = DateTime.now().millisecondsSinceEpoch.toString();
                                                        rutaImage = '$path/$nombreArchivo.${arrPath[arrPath.length-1]}';
                                                        await file.copy(rutaImage);
                                                        setState(() { });
                                                      }
                                                    }, child: Text('Ir a la camara', textAlign: TextAlign.center,)
                                                  ),
                                                ),
                                                ],
                                              ),
                                              ElevatedButton(onPressed:  (){
                                                  Navigator.of(context).pop(context);
                                                },child: Text('Salir', style: TextStyle(color: Colors.red),),
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
                            }, 
                            label: Text(param != null  ? 'Reemplazar' : 'Subir'),
                            icon: Icon(Icons.camera_alt),
                          ),
                        ),
                        Padding(padding: EdgeInsets.only(top: 8),
                          child:  DropdownMenu<Categories>(
                          width: double.infinity,
                          initialSelection: selectedDrop,
                          enableFilter: true,
                          controller: listFoodDropController,
                          requestFocusOnTap: true,
                          onSelected: (value) {
                            sendObj.cveCategory = (value as Categories).idCategory!;
                            print('select ${sendObj.cveCategory}');
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
                        Padding(padding: EdgeInsets.only(top: 8),
                          child: TextFormField(
                            controller: controllerName,
                            decoration: InputDecoration(
                              labelText: 'Nombre',
                            ),
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Este campo es obligatorio';
                              }
                              return null;
                            },
                          ),
                        ),
                        Padding(padding: EdgeInsets.only(top: 8),
                          child: TextFormField(
                            controller: controllerDescription,
                            minLines: 1,
                            maxLines: null,
                            decoration: InputDecoration(
                              labelText: 'Descripcion',
                            ),
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Este campo es obligatorio';
                              }
                              return null;
                            },
                          ),
                        ),
                        Padding(padding: EdgeInsets.only(top: 8),
                          child: TextFormField(
                            controller: controllerPrice,
                            decoration: InputDecoration(
                              labelText: 'Precio',
                            ),
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Este campo es obligatorio';
                              }
                              return null;
                            },
                          ),
                        ),
                        SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: lightText() == 'green' ? Colors.green : Colors.red
                            ),
                            onPressed: () {
                              //sentencias ternarias para cambiar el color del boton
                              if(param != null){
                                param.active = param.active == 0 ? 1 : 0;
                              }else {
                                activeAux = activeAux == 0 ? 1 : 0;
                              }
                              lightText();
                              setState(() { });
                              
                            }, 
                            child: const Text( 'Activar', style: TextStyle(color: Colors.white),),
                          ),
                        ),
                        SizedBox(height: 10,),
                        ElevatedButton(
                          onPressed: () async {
                            if (formkey.currentState!.validate() && rutaImage != '')  {
                                // Si el formulario es válido, se puede enviar
                                // variables por default:
                                sendObj.imagePath = rutaImage;
                                sendObj.price = double.parse(controllerPrice.text);
                                sendObj.description = controllerDescription.text;
                                sendObj.name =controllerName.text;
                                if (param == null) {
                                  //cuando crearas una nueva comida
                                  sendObj.active = activeAux;
                                  await DbServiceOnline().postImageFood(context,rutaImage).then((bool arr) async {
                                   if (arr) {
                                    await DbServiceOnline().postFood(context,sendObj);
                                   } else {
                                    
                                   }
                                  });
                                  
                                }else{
                                  //cuando se editas la comida
                                  sendObj.active = param.active;
                                  sendObj.idMenu = param.idMenu;
                                  await DbServiceOnline().updateFood(context, sendObj);
                                  Navigator.pushNamed(context, '/settings');
                                }
                              }
                            }, 
                          child: const Text('Enviar'),
                        ),
                      ],
        
                    ) 
                  )
                ]
              ),
            ),
          ),
        );
        
      } 
    );
  }

}