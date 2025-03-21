
import 'package:board_datetime_picker/board_datetime_picker.dart';
import 'package:control_inv/models/services/services_model.dart';
import 'package:control_inv/services/db_service_online.dart';
import 'package:control_inv/widgets/indicatorPieChart.dart';
import 'package:control_inv/widgets/widgets.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart';
import 'package:fl_chart/fl_chart.dart';
import '../widgets/pickerItemWidget.dart';
import '../services/reports_tables.dart';
import 'dart:math' as math;



/*
  Esta pantalla nos proporcionara el servicio para poder crear excel, junto con
  los inputs especiales de calendario. Para establecer un rango de fecha
  de los productos registados.
  para poder integrar el piechart se uso el siguiente recurso:
  https://pub.dev/packages/fl_chart
*/
class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
 
 //elige cual sección del piechart, estará seleccionado una por default
 int touchedIndex = 0;
  
 //Estas 2 variables nos ayuda a recuperar y establecer el valor actual o seleccionado del input
 //primer input de izquierda a derecha
 final ValueNotifier<DateTime> dateInitial = ValueNotifier(DateTime.now());
 //segundo input de izquierda a derecha
 final ValueNotifier<DateTime> dateFinal = ValueNotifier(DateTime.now());


  //Son los valores de la grafica
  List<PieDataModel>? valuesPie ;
  List<double> porcent = [];
  List<Color> porcentColor = [];
  List<String> nameColor = [];
  
  int totalAmount = 0;

  bool futureChange = false;

  Future<void> loadingData () async {
    porcent = [];
    totalAmount = 0;
    porcentColor = [];
    nameColor = [];

    List<PieDataModel>? valuesPie = await DbServiceOnline().showSalesPorcent(context, dateInitial.value.toString().split(' ')[0], dateFinal.value.toString().split(' ')[0]);

    if (valuesPie != null) {
      for (var el in valuesPie) {
        totalAmount += el.amount;
      }

      for (var el in valuesPie) {
        porcent.add((el.amount / totalAmount) * 100);
        porcentColor.add(Color.fromRGBO(
          math.Random().nextInt(255),
          math.Random().nextInt(255),
          math.Random().nextInt(255),
          1,
        ));
        nameColor.add(el.name);
      }
    }
    
    futureChange = true;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: !futureChange ? loadingData() : null,
      builder: (context, snapshot) =>  Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text('Reportes'),
            centerTitle: true,
        ),
        body: Container(
          padding: EdgeInsets.only(left: 15, right: 15, top: 0, bottom: 0),
          child: ListView(
            children: [
              Text('Elige un rango de fechas:'),
              SizedBox(height: 10,),
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
                      )
                      ],
                    ),
                  ),
                  SizedBox(width: 10,),
                  //Input donde se ingresara la fecha final
                  Expanded(
                    child: Column(
                      children: [
                        Text('Fin'),
                        PickerItemWidget(
                          pickerType: DateTimePickerType.date,
                          date: dateFinal,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Row(
                  children: [
                    Expanded(child: ElevatedButton(
                      onPressed: () async {
                        await loadingData();
                        // showingSections();
                        setState(() {
                          
                        });
                      }, child: Text('Buscar'))),
                  ],
                ),
              /*El primer aspectratio ayuda a establecer el radio del piechart (desplazara el pie
              chart hacia arriba o hacia abajo similar a un heigth)*/
              
              AspectRatio(
              aspectRatio: 
              MediaQuery.of(context).orientation == Orientation.portrait ?
              MediaQuery.of(context).devicePixelRatio * 0.5 :
              MediaQuery.of(context).devicePixelRatio * 1.2,
              child: AspectRatio(
                aspectRatio: 1,
                child: PieChart(
                  PieChartData(
                    pieTouchData: PieTouchData(
                      touchCallback: (FlTouchEvent event, pieTouchResponse) {
                        setState(() {
                          if (!event.isInterestedForInteractions ||
                              pieTouchResponse == null ||
                              pieTouchResponse.touchedSection == null) {
                            touchedIndex = -1;
                            return;
                          }
                          touchedIndex =
                              pieTouchResponse.touchedSection!.touchedSectionIndex;
                        });
                      },
                    ),
                    borderData: FlBorderData(
                      show: false,
                    ),
                    sectionsSpace: 0,
                    centerSpaceRadius: 0,
                    sections: showingSections(),
                  ),
                ),
              ),
            ),
            Column(
              children: indicators()
              
            ),
            SizedBox(height: 20,),
            Text(
            'Descargaras un excel con la información del rango de fechas que se seleccionó ' 
            'divida en 4 tablas, en la primera tabla se desplegaran todos los productos vendidos, '
            'en la segunda tabla los productos se agruparán por orden, en la tercera tabla se '
            'agruparán por producto y en la cuarta tabla se contabilizará todos los prouctos con '
            'su respectiva ganancia total.',
            style: TextStyle(fontStyle: FontStyle.italic, fontWeight: FontWeight.bold),),
            ElevatedButton.icon(
              onPressed: () async {
              if (!(await Renovation().jwt())) {
                List<Map<String, dynamic>>?  jsonStr = await DbServiceOnline().showSalesReport(context, dateInitial.value.toString().split(' ')[0], dateFinal.value.toString().split(' ')[0]);
                if (jsonStr != null){
                  await createReport(
                    dateInitial.value,
                    dateFinal.value,
                    'report_${DateTime.now().year}${DateTime.now().month}${DateTime.now().day}${DateTime.now().hour}${DateTime.now().minute}${DateTime.now().millisecond}${DateTime.now().microsecond}.xls',
                    jsonStr,
                    context
                  );
                }else{
                showDialog(
                  context: context, 
                  builder: (context) => AlertDialog(
                  title: Text("Lo sentimos, no se encontraron resultados...",style: TextStyle(fontWeight: FontWeight.bold),),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context), 
                      child: Text('Aceptar')
                    )
                  ],
                )
                );
                }
                
              }else{
                Navigator.pushNamed(context, '/renovation');
              } 
              },
              label: Text('Descargar excel'),
              icon: Icon(Icons.download),
            )
            ]
          ),
        ),
      ),
    );
  }

  //Esta funcion nos ayuda a establecer y configurar las secciones del piechart
  //podemos establecer estilos, tamaños, titulos, e incluso agregar mas secciones.
  List<PieChartSectionData> showingSections() {
    return List.generate(porcent.isEmpty ? 1 : porcent.length, (i) {

      double sizeRadious = (MediaQuery.of(context).size.width + MediaQuery.of(context).size.height) / 2;

      final isTouched = i == touchedIndex;
      final fontSize = isTouched ? 20.0 : 16.0;
      final radius = isTouched ? sizeRadious * 0.2 : sizeRadious * 0.18;
      // final widgetSize = isTouched ? 55.0 : 40.0;
      const shadows = [Shadow(color: Colors.black, blurRadius: 2)];

      if(porcent.isNotEmpty) {
      return PieChartSectionData(
        color: porcentColor[i],
        value: porcent[i],
        title: '${porcent[i].toStringAsFixed(2).toString()}%',
        radius: radius,
        titlePositionPercentageOffset: porcent.length == 1 ? 0 : null,
        titleStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: const Color(0xffffffff),
          shadows: shadows,
        ),
      
        badgePositionPercentageOffset: .98,
      );
      } else {
      return PieChartSectionData(
        color: Colors.purple,
        titlePositionPercentageOffset: .0,
        value: 100,
        title: '100%',
        radius: radius,
        titleStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: const Color(0xffffffff),
          shadows: shadows,
        ),
        badgePositionPercentageOffset: .98,
      );
      }
    });
  }

  List<IndicatorPieChart> indicators() {
    return List.generate(porcent.isEmpty ? 1 : porcent.length, (i) {
    if(porcent.isNotEmpty) {  
      return IndicatorPieChart(
        color: porcentColor[i],
        text: nameColor[i],
        isSquare: true,
      );
    } else {
      return IndicatorPieChart(
        color: Colors.purple,
        text: 'No hay resultados',
        isSquare: true,
      );
    }

    });
  }

}