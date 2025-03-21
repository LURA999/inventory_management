import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:control_inv/models/services/services_model.dart';
import 'package:control_inv/services/db_service_online.dart';
import 'package:control_inv/widgets/widgets.dart';
import 'package:flutter/material.dart';

/* 
 En esta pantalla se muestran todas las comidas que fueron registradas
 y te permite "ver" la configuracion de cada comida, y acceder a las pantallas para crear,
 editar, o eliminar una categoria/comida.
*/
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {

  //To dropdown
  final TextEditingController listFoodDropController = TextEditingController();
  List<Categories> listDrop = [ ];
  int? saveCategory;
  Categories? selectedCategory;

  //Arrays donde se reutiliza un modelo, para el despligue de las comidas.
  //Array original (no se modifica)
  List<ImageData> imageDataList = [ ];
  //Array solamente para desplegar
  List<ImageData> imageDataListToShow = [];
  
  //Nos ayuda solamente a inicializar una vez la lista de categorias
  bool changeFuture = false;  

  //Nos ayudara a verificar si hay internet
  bool isThereInternet = false;
  
  Future<void> conn() async {
   
    await loadingData();
    
  }

  //Se inicializan las lista de catalogos y la lista del menu
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


  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: !changeFuture ? loadingData() : null,
      builder: (context, snapshot) => Scaffold(
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
        title: listDrop.length > 1 ? null : Text('Ajustes'),
        centerTitle: true,
        actions: listDrop.length == 1 || listDrop.isEmpty ? null : [
          SizedBox(
            child: Icon(Icons.settings)),
          SizedBox( width: 5),
          SizedBox(
            width: MediaQuery.of(context).size.width * .6,
            child: DropdownMenu<Categories>(
              width: double.infinity,
              // se inicializa la categoria seleccionada e inicial
              initialSelection: listDrop.isNotEmpty ? selectedCategory : null,
              enableFilter: true,
              controller: listFoodDropController,
              requestFocusOnTap: true,
              onSelected: (value) async {
                //se busca el objeto que coincida con el idCategory buscado
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
          //unicamente se agrega para señalar que es un buscador
          SizedBox(
            width: MediaQuery.of(context).size.width * .15,
            child: Icon( (Icons.search_sharp)
            )
          )
        ],
        ),
        body: Center(
          child: Container(
            padding: EdgeInsets.all(10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                  children: [
                  //Se hizo con la finalidad de refrescar cuando hay internet o no hay
                  IconButton(onPressed: () async {
                    await conn();
                    setState(() { });
                  }, icon: Icon(Icons.replay_outlined)),
                  ElevatedButton(
                    onPressed: () async {
                      //antes de navegar se verifica la caducidad del jwt
                      if (!(await Renovation().jwt())) {
                        Navigator.pushNamed(context,'/settings/settingsCategory');
                      }else{
                        Navigator.pushNamed(context, '/renovation');
                      }  
                    }, 
                    child: Text('Agregar Categoria')
                  ),
                  Spacer(),
                  ElevatedButton(
                    onPressed: () async {
                      //antes de navegar se verifica la caducidad del jwt
                      if (!(await Renovation().jwt())) {
                        Navigator.pushNamed(context,'/settings/settingsFood');
                      }else{
                        Navigator.pushNamed(context, '/renovation');
                      }  
                    }, 
                    child: Text('Agregar Comida')
                  ),
                  ],
                ),
                SizedBox(height: 10,),
                Text("*nota: si desea editar o eliminar, presiona una comida", textAlign: TextAlign.start, style: TextStyle(fontWeight: FontWeight.bold),),
                Expanded(
                  child: GridView.builder(
                    /*
                      el widget SliverGridDelegateWithFixedCrossAxisCount, nos ayudara a establecer
                      cuantos items se veran en la lista por fila (crossaxiscount),
                      y que tan separado estara una fila hacia la otra fila (mainAxisExtent)
                    */
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: MediaQuery.of(context).orientation == Orientation.portrait ? 1 : 2,
                      mainAxisExtent: 300
                    ),
                    itemCount: imageDataListToShow.length,
                    itemBuilder: (BuildContext context, int index)  { 
                    /*Se establece la estructura que tendran todas las filas y/o items de la lista, todo dentro de un boton
                    el boton te permite entrar a la configuracion de la comida*/
                      return ElevatedButton(
                        onPressed: () async {
                          /*Esta es la accion que realiza cuando presionas una comida, 
                          envia todo el objeto de la comida (arguments), para reutilizarlo en settingsfood*/
                          if (!(await Renovation().jwt())) {
                            Navigator.pushNamed(context,'/settings/settingsFood', arguments: imageDataListToShow[index]);
                          }else{
                            Navigator.pushNamed(context, '/renovation');
                          }                       
                        },
                        style: ElevatedButton.styleFrom(
                          side: BorderSide(color: Colors.black, style: BorderStyle.solid),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(0) // Adjust the radius value to change the roundness
                          ),
                      
                        ),
                        child: Container(
                          padding: EdgeInsets.only(top: 10),
                          alignment: Alignment.bottomCenter,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [ 
                              Text(imageDataListToShow[index].name, style: TextStyle(fontWeight: FontWeight.bold)),
                              Container(
                                alignment: Alignment.center,
                                child: /* Image.file(File(imageDataListToShow[index].imagePath), height: 150,), */
                                isThereInternet ?
                                Image.network('http://10.0.2.2:8085/uploads/${imageDataListToShow[index].imagePath}', height: 150,)
                                :
                                Image.file(File(imageDataListToShow[index].imagePath), height: 150,)
                                
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text("Descripcion:", style: TextStyle(fontWeight: FontWeight.bold),),
                                  Text(imageDataListToShow[index].description, overflow: TextOverflow.ellipsis, maxLines: 2)
                                ]
                              ),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                Text("Costo: ", style: TextStyle(fontWeight: FontWeight.bold)),
                                Text(imageDataListToShow[index].price.toString())
                                ]
                              ),
                              SizedBox(height: 5,),
                               Container(
                                alignment: Alignment.centerLeft,
                                child: Container(
                                  padding: EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                    color:imageDataListToShow[index].active == 1? Colors.green : Colors.red,
                                    borderRadius: BorderRadius.circular(10)
                                  ),
                                  child: Text("Activado", 
                                  style: TextStyle(color: Colors.white),
                                  textAlign: TextAlign.start,)
                                )
                              )
                            ],
                          ),
                        ),
                      );
                      
                    }),
                ),
            
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
}