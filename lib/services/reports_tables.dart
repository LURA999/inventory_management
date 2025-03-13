import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:universal_platform/universal_platform.dart';
import 'package:download/download.dart';
import 'package:path_provider/path_provider.dart';
// import 'package:intl/intl.dart';

// se utiliza para saber la direccion de la carpeta de descargas, asi sea android o ios (opcion descartada)
  Future<String> getDownloadDirectoryPath() async {
  String path = '';
  if (Platform.isAndroid) {
    const platform = MethodChannel('flutter_android_directory');
    try {
      path = await platform.invokeMethod('getDownloadsDirectory');
    } catch (e) {
      path = (await getExternalStorageDirectory())!.path;
    }
  } else {
    final directory = await getApplicationDocumentsDirectory();
    path = directory.path;
  }
  return path;
}

//escojemos la direccion para ubicar donde descargar el archivo (opcion descartada)
Future<String?> pickDownloadDirectory(BuildContext context) async {
  final result = await FilePicker.platform.getDirectoryPath();
  if (result != null) {
    return result;
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('No se seleccionó ninguna carpeta')),
    );
    return null;
  }
}


// Nos ayuda a darnos permisos para poder descargar el archivo
Future<void> requestPermission(Function(bool) onPermissionResult) async {
 var status = await Permission.storage.status;

  // Si el permiso es permanentemente denegado, se realiza de forma manual la configuracion
  if (status.isPermanentlyDenied) {
    await openAppSettings();
    //throw Exception('El usuario ha denegado permanentemente el permiso de almacenamiento.');
  }
  
  // Si el permiso está denegado, solicítalo
  if (status.isDenied) {
    var status = await Permission.mediaLibrary.status;
    final granted = status.isGranted;
    onPermissionResult(granted);

     if (status.isDenied) {
      // Si el usuario deniega nuevamente, lanza la excepción
      throw Exception('El usuario denegó los permisos de almacenamiento.');
    }
  } else if (status.isGranted) {
    // Si el permiso ya está concedido, simplemente retorna true
    onPermissionResult(true);
  }

}

//Creacion de reporte para el control de inventarios
Future<void> createReport(
  DateTime dateS,
  DateTime dateF,
  String fileName, 
  List<Map<String, dynamic>> jsonStr,
  BuildContext context
) async {

  bool storagePermissionGranted = false;
  if (!UniversalPlatform.isWeb) {
    if (Platform.isAndroid || Platform.isIOS) {
    await requestPermission((bool granted) {
      storagePermissionGranted = granted;
    });  
    
    if (!storagePermissionGranted) {
      throw Exception('No se han concedido los permisos de almacenamiento.');
    }
    } 
  }

    // Crea el archivo Excel
  final workbook = Workbook();
  final sheet = workbook.worksheets[0];
  // DateTime dateToday = DateTime.now();
  // var formatter =  DateFormat("yyyy-MM-dd");
  // String formattedDate = formatter.format(dateToday);

  //utilizamos variables para representar la fila y la columna que se usara para insertar en la tabla
  int beginRowT1 = 5;
  int beginColumnT1 = 2;

  int beginRowT2 = 5;
  int beginColumnT2 = 2;

  int beginRowT3 = 5;
  int beginColumnT3 = 2;

  int beginRowT4 = 5;
  int beginColumnT4 = 2;

  //Array para imprimir los meses en letra
  List<String> months = [
    'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio', 
    'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
  ];

  //Prueba
  /* List<Map<String, dynamic>> jsonStr = [
  {
    "idSale" : 1,
    "date": "2023-12-02",
    "idMenu": 1,
    "name": "Pizza",
    "cantidad" : 3,
    "price": 38.97,
  }
  ]; */

  List<String> headers ;
  List<List<String>> headersPerso =[
    [
      'Orden', 'Fecha', 'Num', 'Nombre', 'Cantidad', 'Precio'
    ],
    [
      'Orden', 'Total'
    ],
    [
      'Producto', 'Cantidad', 'Total'
    ],
    [
      'Productos','Ganancias Totales'
    ]
  ];

  /*En las siguientes 3 variables, la primera variable guarda las diferentes ordenes que existen 
  (arrayorders, sin repetir) y en el arraytotal se suman todos los precios de todos 
  las ordenes por separado (sin repetir), en la variable indexArrayTotal, es un ayudante 
  para la lista arraytotal (se explica mas adelante su funcion).
  Estas 3 variables se usan para creacion de la tabla 1 y 2 del excel*/

  /*todas las variables que se inicializan con -1, 
  es porque en la primera vuelta se contabiliza y empieza a sumar, iniciando con 0 realmente*/

  //1 Variables para la tabla 1
  List<int> arrayOrders = [];

  //2 Variables para la tabla 2
  List<double> arrayTotal = [];
  int indexArrayTotal = -1; //index que pertenece a la variable arrayototal

  //4 variables es para la tabla 3
  List<String> arrayFood = [];
  List<int> arrayAmount = [];
  List<int> arrayAmountAux = [];
  List<double> arrayTotalF = [];


  //FECHA TITULO
  final Range dateRange = sheet.getRangeByIndex(2,2);
  dateRange.merge();

  if (dateS.day == dateF.day && dateS.year == dateF.year && dateS.month == dateF.month) {
    dateRange.setText(
      'Reporte del día ${dateS.day} de ${months[dateS.month-1]} del año ${dateS.year} '
    );
  } else {
    dateRange.setText(
      'Reporte desde el día ${dateS.day} de ${months[dateS.month-1]} del año ${dateS.year}, '
      'hasta el día ${dateF.day} de ${months[dateF.month-1]} del año ${dateF.year}'
    );
  }

  dateRange.cellStyle.bold = true;
  dateRange.cellStyle.fontSize = 18;



  //La siguiente variable es para la tabla 4
  double sumaGananTotal = 0;
  int sumaProdTotal = 0;

  final Range titleTable1 = sheet.getRangeByIndex(beginRowT1 - 1, beginColumnT1);
  titleTable1.setText("TODOS LOS PRODUCTOS");
  //Primera tabla 
  headers = jsonStr[0].keys.toList(); // Agregando las celdas de encabezado original
  for (var i = 0; i < headers.length; i++) {
   final Range header = sheet.getRangeByIndex(beginRowT1, i+beginColumnT1);
   header.setText(headersPerso[0][i]);
   header.cellStyle.bold = true;
  }

  /* Este for se reutiliza para todas las tablas, para no volver a crear for por separado, pero principalmente
  es para la primera tabla que tiene todo la informacion, que se usa para las otras 3 tablas*/

  //Contenido de las cabeceras agregadas
  
  for (var i = 0; i < jsonStr.length; i++) { //se empieza a ciclar cuantas filas tendra la tabla
    var keys = jsonStr[i].keys.toList();
    var values = jsonStr[i].values.toList();

    //la variable J representa las columnas de la tabla
    for (var j = 0; j < keys.length; j++) { // incrusta la cantidad de celdas que tiene una fila completa

      //Estas variable es para la primera tabla
      var cell = sheet.getRangeByIndex(i + 1 + beginRowT1, j + beginColumnT1); // encuentra la celda que sigue, ubicando la fila y columna
      cell.setText( j == 5? '\$${values[j].toString()}': values[j].toString()); //inserta el elemento en la celda encontrada
      
      //Aislamos todas las ordenes  en un array, 0 = orden (creacion para la 2 tabla)
      if(j == 0 && !arrayOrders.contains(values[j])){
        arrayOrders.add(values[j]);
        //la variable indexArrayTotal, ayuda a separar la suma que le pertenece a cada orden
        indexArrayTotal ++;
        //se inserta un elemento 0, para proseguir en un orden consecutivo
        arrayTotal.add(0);
      }

      //Sumamos todos los precios de una orden especifica, para la tabla 2 del excel, 4 = precio
      if (j == 4) {
        sumaProdTotal += values[j] as int;
        arrayTotal[indexArrayTotal] += values[5]; 
      }

      /* En este punto miraremos codigo muy parecido pero diferente, para la tabla 3 */

      //Almacenamos todas las comidas sin repetir en el array, 3 = nombre de comida
      if (j == 3 && !arrayFood.contains(values[j])) { 
        arrayFood.add(values[j]); // guardamos la comida
        arrayTotalF.add(0);
      } 

      /** El auxiliar funciona, para guardar el id de la comida y no la cantidad como tal de la columna */
      if (j == 2 && !arrayAmountAux.contains(values[j])) {
        arrayAmount.add(0);
        arrayAmountAux.add(values[j]);
      }

      //Incrementamos 1, cuando la comida se repita, 2 = num
      if (j == 2) {
        arrayAmount[arrayAmountAux.indexOf(values[j])] += int.parse(values[4].toString()); 
      }

      //Sumamos todos los precios de una comida especifica, 5 = precio
      if (j == 3) {
        arrayTotalF[arrayFood.indexOf(values[j])] += values[5]; 
      }

      /* El siguiente codigo es para la tabla 4 */

      //Iniciamos con la suma total
      if (j == 5) {
       sumaGananTotal += values[j];
      }

    }
  }

  
  //estableciendo valores
  beginRowT2 = 5;
  beginColumnT2 = 9;

  //Segunda Tabla
  final Range textTable2 = sheet.getRangeByIndex(beginRowT2 - 1, beginColumnT2);
  textTable2.setText("AGRUPADO POR ORDEN");
  for (var i = 0; i < headersPerso[1].length; i++) {
   final Range header = sheet.getRangeByIndex(beginRowT2, i+beginColumnT2);
   header.setText(headersPerso[1][i]);
   header.cellStyle.bold = true;
  }

  //Contenido de las cabeceras agregadas
  for (var i = 0; i < arrayTotal.length; i++) { // se establece cuantas filas y vueltas se insertaran en la tabla
    
    //En este caso no se hace un segundo for porque se usan dos arrays al mismo tiempo
    var cell = sheet.getRangeByIndex(i + 1 + beginRowT2, 0 + beginColumnT2);
    cell.setText(arrayOrders[i].toString());
    var cell2 = sheet.getRangeByIndex(i + 1 + beginRowT2, 1 + beginColumnT2);
    cell2.setText('\$${arrayTotal[i].toString()}');
  }
  
 
  //estableciendo valores
  beginRowT3 = 5;
  beginColumnT3 = 12;

  //Tercera Tabla
  final Range textTable3 = sheet.getRangeByIndex(beginRowT3 - 1, beginColumnT3);
  textTable3.setText("AGRUPADO POR PRODUCTO");
  // Agrega las celdas de encabezado
  for (var i = 0; i < headersPerso[2].length; i++) {
   final Range header = sheet.getRangeByIndex(beginRowT3, i+beginColumnT3);
   header.setText(headersPerso[2][i]);
   header.cellStyle.bold = true;
  }

  //Contenido de las cabeceras agregadas
  for (var i = 0; i < arrayTotalF.length; i++) {
    //se hace lo mismo que en la segunda tabla, pero, en este caso son 3 columnas
    var cell = sheet.getRangeByIndex(i + 1 + beginRowT3, 0 + beginColumnT3); 
    cell.setText(arrayFood[i].toString());

    var cell2 = sheet.getRangeByIndex(i + 1 + beginRowT3, 1 + beginColumnT3);
    cell2.setText(arrayAmount[i].toString());

    var cell3 = sheet.getRangeByIndex(i + 1 + beginRowT3, 2 + beginColumnT3);
    cell3.setText('\$${arrayTotalF[i].toString()}');
  }

  //estableciendo valores
  beginRowT4 = 5;
  beginColumnT4 = 16;

  //Cuarta Tabla  
  final Range textTable4 = sheet.getRangeByIndex(beginRowT4 - 1, beginColumnT4);
  textTable4.setText("GANANCIAS TOTALES");
  // Agrega las celdas de encabezado
  for (var i = 0; i < headersPerso[3].length; i++) {
   final Range header = sheet.getRangeByIndex(beginRowT4, i+beginColumnT4);
   header.setText(headersPerso[3][i]);
   header.cellStyle.bold = true;
  }

  var cell2 = sheet.getRangeByIndex(1 + beginRowT4, 0 + beginColumnT4); 
  cell2.setText(sumaProdTotal.toString());

  //Contenido de las cabeceras agregadas
  var cell = sheet.getRangeByIndex(1 + beginRowT4, 1 + beginColumnT4); 
  cell.setText('\$${sumaGananTotal.toString()}');

  

  //Configurando tablas

  // Primera tabla
  final Range table1 = sheet.getRangeByName('B5:G5');
  table1.cellStyle.backColorRgb = const Color.fromARGB(255, 121, 184, 236);
  table1.cellStyle.borders.all.lineStyle = LineStyle.thin;

  final Range table1_ = sheet.getRangeByName('B6:G${jsonStr.length + beginRowT1}');
  table1_.cellStyle.borders.all.lineStyle = LineStyle.thin;


// Segunda tabla
  final Range table2 = sheet.getRangeByName('I5:J5');
  table2.cellStyle.backColorRgb = const Color.fromARGB(255, 121, 184, 236);
  table2.cellStyle.borders.all.lineStyle = LineStyle.thin;
  
  final Range table2_ = sheet.getRangeByName('I6:J${arrayOrders.length + beginRowT2}');
  table2_.cellStyle.borders.all.lineStyle = LineStyle.thin;

// Tercera tabla
  final Range table3 = sheet.getRangeByName('L5:N5');
  table3.cellStyle.backColorRgb = const Color.fromARGB(255, 121, 184, 236);
  table3.cellStyle.borders.all.lineStyle = LineStyle.thin;

  final Range table3_ = sheet.getRangeByName('L6:N${arrayAmount.length + beginRowT3}');
  table3_.cellStyle.borders.all.lineStyle = LineStyle.thin;

// Cuarta tabla
  final Range table4 = sheet.getRangeByName('P5:Q5');
  table4.cellStyle.backColorRgb = const Color.fromARGB(255, 121, 184, 236);
  table4.cellStyle.borders.all.lineStyle = LineStyle.thin;

  final Range table4_ = sheet.getRangeByName('P6:Q6');
  table4_.cellStyle.borders.all.lineStyle = LineStyle.thin;


  //Descargar
  if (UniversalPlatform.isWeb) {
    Stream<int> excel = Stream.fromIterable(workbook.saveAsStream());
    download(excel, fileName); 
  } else{
  // String? path =  await pickDownloadDirectory(context);
  Directory directory = Directory('/storage/emulated/0/Download/');
    if (await directory.exists()) {
    final file = File('/storage/emulated/0/Download/$fileName');  
    try {
      await file.writeAsBytes(workbook.saveAsStream());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Archivo guardado en $file')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$e')),
      );
    }
    
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('La carpeta seleccionada no existe')),
    );
      //path = await getDownloadDirectoryPath(); 
    }
  }

}




