import 'package:control_inv/models/services/services_model.dart';
import 'package:control_inv/services/db_service_online.dart';
import 'package:control_inv/widgets/pickerItemWidget.dart';
import 'package:control_inv/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:board_datetime_picker/board_datetime_picker.dart';

/* Esta pantalla muestra el historial, de todas las compras, pero solamente mostrara por
default las compras del dia actual, si se desea modificar, entonces se modifica el rango
de fechas en los inputs de calendario */

class HistorialScreen extends StatefulWidget {
  const HistorialScreen({super.key});

  @override
  State<HistorialScreen> createState() => _HistorialScreenState();
}

class _HistorialScreenState extends State<HistorialScreen> {
  
  //la variable date, es para definir la fecha de hoy y usarlo por default al iniciar el screen
  DateTime date = DateTime.now();

  //Estas 2 variables nos ayuda a recuperar y establecer el valor actual o seleccionado del input
  //primer input de izquierda a derecha
  final ValueNotifier<DateTime> dateInitial = ValueNotifier(DateTime.now());
  //segundo input de izquierda a derecha
  final ValueNotifier<DateTime> dateFinal = ValueNotifier(DateTime.now());
  

  List<HistorialModel?> listHistorial = [];
  List<HistorialModel> listHistorialToShow = [];
  
  bool futureCharge = false;

  Future<void> loadingData() async {
    List<HistorialModel>? listHistorial = await DbServiceOnline().showSalesDate(context,dateInitial.value.toString().split(' ')[0], dateFinal.value.toString().split(' ')[0]);
    if (listHistorial!.isNotEmpty) {
      listHistorialToShow = listHistorial;
    }else{
      listHistorialToShow = [];
    }
    futureCharge = !futureCharge;
    setState(() { });
  }

  
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: !futureCharge ? loadingData() : null,
      builder: (context, snapshot) =>  Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          leading: IconButton(onPressed: () async {
            if (!(await Renovation().jwt())) {
              Navigator.pushNamed(context,'/');
            }else{
              Navigator.pushNamed(context, '/renovation');
            }
          }, 
          icon: Icon(Icons.arrow_back_sharp)),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text('Historial'),
          centerTitle: true,
        ),
        body: Center(
          child: Container(              
            padding: EdgeInsets.all(15),
            child: Column(
                children: [
                Text('Elige un rango de fechas:'),
                Row(
                  children: [
                    //Input donde se ingresara la fecha inicial
                    Expanded(
                      child: Column(
                        children: [
                          Text('Inicio'),
                          PickerItemWidget(
                            pickerType: DateTimePickerType.date,
                            date: dateInitial,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 10,),
                    //Input donde se ingresara la fecha final
                    Expanded(
                      child: Column(
                        children: [
                          Text('Fin', textAlign: TextAlign.start,),
                          PickerItemWidget(
                            pickerType: DateTimePickerType.date,
                            date: dateFinal,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.search),
                      onPressed: () async {
                        List<HistorialModel>? listHistorial = await DbServiceOnline().showSalesDate(context,dateInitial.value.toString().split(' ')[0], dateFinal.value.toString().split(' ')[0]);
                        if (listHistorial!.isNotEmpty) {
                          listHistorialToShow = listHistorial;
                        }else{
                          listHistorialToShow = [];
                        }
                        setState(() {  });
                      }, 
                    )
                  ],
                ),
                
                SizedBox(height: 10,),
                Expanded(
                  //Utilizamos un gridview builder, para establecer que sera una lista dinamica
                  child: GridView.builder(
                    /*
                      el widget SliverGridDelegateWithFixedCrossAxisCount, nos ayudara a establecer
                      cuantos items se veran en la lista por fila (crossaxiscount),
                      y que tan separado estara una fila hacia la otra fila (childAspectRatio)
                    */
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: MediaQuery.of(context).orientation == Orientation.portrait ? 1 : 2,
                      mainAxisExtent: 230, // 10
                    ),
                    itemCount: listHistorialToShow.length,
                    itemBuilder: (BuildContext context, int index)  { 
                    //Se establece la estructura que tendran todas las filas y/o items de la lista.
                      return Card(
                        /* style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(),
                          side: BorderSide(color: Colors.black)
                        ), */
                        child: Padding(
                          padding: const EdgeInsets.only(left: 10, right: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 30,),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                Text('Order#${1+index}'),
                                ],
                              ),
                              SizedBox(height: 30,),
                              Row(
                                children: [
                                  Text("Fecha: ", style: TextStyle(fontWeight: FontWeight.bold),),
                                  Text(listHistorialToShow[index].date.toString().split('.')[0])
                                ],
                              ),
                               Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Comida: ", style: TextStyle(fontWeight: FontWeight.bold),),
                                  Text(listHistorialToShow[index].name, maxLines: 1, overflow: TextOverflow.ellipsis)
                                ],
                              ),
                               Row(
                                children: [
                                  Text("Total: ", style: TextStyle(fontWeight: FontWeight.bold),),
                                  Text(listHistorialToShow[index].total.toStringAsFixed(2).toString())
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  ElevatedButton.icon(
                                    style: ButtonStyle(
                                      backgroundColor: WidgetStateProperty.fromMap(
                                       <WidgetStatesConstraint, Color>{
                                          WidgetState.focused: const Color.fromARGB(255, 134, 40, 189),
                                          WidgetState.pressed | WidgetState.hovered: const Color.fromARGB(255, 152, 54, 197),
                                          WidgetState.any: const Color.fromARGB(255, 143, 54, 244),
                                        }
                                      )
                                    ),
                                    onPressed: () async {
                                      if (!(await Renovation().jwt())) {
                                        Navigator.pushNamed(context,'/historial/historialCart',arguments: listHistorialToShow[index].id);
                                      }else{
                                        Navigator.pushNamed(context, '/renovation');
                                      }
                                    }, 
                                    label: Text('Editar', style: TextStyle(color: Colors.white)), 
                                    icon: Icon(Icons.edit_outlined, color: Colors.white)),
                                  SizedBox(width: 10,),
                                  ElevatedButton.icon(
                                    style: ButtonStyle(
                                      backgroundColor: WidgetStateProperty.fromMap(
                                       <WidgetStatesConstraint, Color>{
                                          WidgetState.focused: const Color.fromARGB(255, 189, 50, 40),
                                          WidgetState.pressed | WidgetState.hovered: const Color.fromARGB(255, 197, 64, 54),
                                          WidgetState.any: Colors.red,
                                        }
                                      )
                                    ),
                                    onPressed: () {
                                      showDialog(context: context, builder: 
                                        (BuildContext context) {
                                          return AlertDialog(
                                            title: Column(
                                              children: [
                                                Text('¿Está seguro?', style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center,),
                                                Text('Se eliminará permanentemente.', style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center,),
                                              ],
                                            ),
                                            actions: [
                                              TextButton(onPressed: () {
                                                 Navigator.of(context).pop();
                                              }, child: Text('Cancelar')),
                                              TextButton(onPressed: () async {
                                                await DbServiceOnline().deleteFullSale(context, listHistorialToShow[index].id);
                                                await loadingData();
                                                Navigator.of(context).pop();
                                              }, 
                                              child: Text('Aceptar'))
                                            ],
                                          );
                                      });
                                    }, 
                                    label: Text('Borrar', style: TextStyle(color: Colors.white)), 
                                    icon: Icon(Icons.delete_outline, color: Colors.white))
                                ],
                              )
                            ],
                          ),
                        ),
                      );
                      
                    }),
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
