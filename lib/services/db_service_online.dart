
import 'dart:convert';
import 'dart:io';
import 'package:control_inv/models/services/services_model.dart';
import 'package:control_inv/services/db_service_offline.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';

class DbServiceOnline extends ChangeNotifier{

  bool modoApk = kDebugMode?true:false; 
  bool isSaving = true;
  String link = "http://10.0.2.2:8085";
  //late String link = modoApk?'https://www.comunicadosaraiza.com/movil_scan_api_prueba2/API':'https://www.comunicadosaraiza.com/movil_scan_api_prueba2/API';
  final storage =const FlutterSecureStorage();
  Map<String, String> HttpHeaders = {
    "Content-Type": "application/json",
    "Accept": "text/plain"
  };

 Future<void> postCategories(BuildContext context, Categories cat) async {
  
  try {
        isSaving = true;
        notifyListeners();
        Uri url = Uri.parse("$link/api/Categories");
        json.decode((await http.post( url, body: jsonEncode(cat), headers: HttpHeaders)).body);
        isSaving = false;
        notifyListeners();
      } on SocketException {
      // Error de conexión de red (sin conexión a Internet)
      await DBService.db.newCategory(cat);
      // messageError(context,'Error de conexión de red: $e','Error');
    } on HttpException catch (e) {
      // Error de la solicitud HTTP
      messageError(context,'Error de la solicitud HTTP: $e','Error');
    } catch (e) {
      // Otro tipo de error
      messageError(context,'Error inesperado1: $e','Error');
    }
    
  }

  Future<List<Categories>> showCategories(BuildContext context) async {
  try {
        isSaving = true;
        notifyListeners();

        List<dynamic> response = json.decode((await http.get( Uri.parse("$link/api/Categories"))).body);

        if (response.isNotEmpty){  
          List<Categories> arr = [];
          for (var e in response) {
            arr.add(Categories.fromJson(e));
          }
          return arr;
        } else {
          isSaving = false;
          notifyListeners();
          return [];
        }
      } on SocketException {
      // Error de conexión de red (sin conexión a Internet)
      // messageError(context,'Error de conexión de red: $e','Error');
      return await DBService.db.showCategories().then((List<Categories>? res) => res??[]);
    } on HttpException catch (e) {
      // Error de la solicitud HTTP
      messageError(context,'Error de la solicitud HTTP: $e','Error');
      return [];
    } catch (e) {
      // Otro tipo de error
      messageError(context,'Error inesperado2: $e','Error');
      return [];
    }
    
  }

  Future<void> deleteCategories(BuildContext context, int id) async {
  try {
      await http.delete( Uri.parse("$link/api/Categories/$id",));
    } on SocketException {
      // Error de conexión de red (sin conexión a Internet)
      // messageError(context,'Error de conexión de red: $e','Error');
      await DBService.db.deleteCategory(id);
    } on HttpException catch (e) {
      // Error de la solicitud HTTP
      messageError(context,'Error de la solicitud HTTP: $e','Error');
    } catch (e) {
      // Otro tipo de error
      messageError(context,'Error inesperado2: $e','Error');
    }
    
  }

  Future<void> postFood(BuildContext context, ImageData obj) async {
  try {
      List<String> nameImg = obj.imagePath.split('/');
      ImageData obj2 = ImageData(
        active: obj.active,
        cveCategory: obj.cveCategory,
        description: obj.description,
        imagePath: obj.imagePath.split('/')[nameImg.length-1],
        name: obj.name,
        price: obj.price,
        idMenu:  0
      );
      await http.post( Uri.parse("$link/api/Menus"), body: jsonEncode(obj2), headers: HttpHeaders);
    } on SocketException {
      // Error de conexión de red (sin conexión a Internet)
      await DBService.db.newFood(obj);
      // messageError(context,'Error de conexión de red: $e','Error');
    } on HttpException catch (e) {
      // Error de la solicitud HTTP
      messageError(context,'Error de la solicitud HTTP: $e','Error');
    } catch (e) {
      // Otro tipo de error
      messageError(context,'Error inesperado: $e','Error');
    }
    
  }

   Future<bool> postImageFood(BuildContext context, String f) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse("$link/api/File/uploadDocument"));
       request.files.add(await http.MultipartFile.fromPath('file', f));
       var response =  await request.send();
      if (response.statusCode == 200) {
        print("File uploaded successfully!");
        return true;
      } else {
        print("Failed to upload file. Status code: ${response.statusCode}");
        return false;
      }
      // await http.post( Uri.parse("$link/api/File/uploadDocument"), body: http.MultipartFile.fromPath('file', f).toString(), headers: HttpHeaders);
    } on SocketException {
      // Error de conexión de red (sin conexión a Internet)
      // messageError(context,'Error de conexión de red: $e','Error');
    } on HttpException catch (e) {
      // Error de la solicitud HTTP
      messageError(context,'Error de la solicitud HTTP: $e','Error');
      return false;
    } catch (e) {
      // Otro tipo de error
      messageError(context,'Error inesperadoImage2: $e','Error');
      return false;
    }
    return false;
    
  }

  Future<void> deleteFood(BuildContext context, int i) async {
  try {
      await http.delete( Uri.parse("$link/api/Menus/$i",));
    } on SocketException {
      // Error de conexión de red (sin conexión a Internet)
      await DBService.db.deleteFood(i);
      // messageError(context,'Error de conexión de red: $e','Error');
    } on HttpException catch (e) {
      // Error de la solicitud HTTP
      messageError(context,'Error de la solicitud HTTP: $e','Error');
    } catch (e) {
      // Otro tipo de error
      messageError(context,'Error inesperado: $e','Error');
    }
  }



Future<void> deleteImageFood(BuildContext context, String n) async {
  try {
      await http.delete(Uri.parse("$link/api/File/deleteDocument/$n",));
    } on SocketException {
      // Error de conexión de red (sin conexión a Internet)
      // await DBService.db.deleteFood(i);
      // messageError(context,'Error de conexión de red: $e','Error');
    } on HttpException catch (e) {
      // Error de la solicitud HTTP
      messageError(context,'Error de la solicitud HTTP: $e','Error');
    } catch (e) {
      // Otro tipo de error
      messageError(context,'Error inesperado: $e','Error');
    }
  }


  Future<void> updateCategories(BuildContext context, Categories obj) async {
  try {
    
      await http.put( Uri.parse("$link/api/Categories"), body: jsonEncode(obj), headers: HttpHeaders);
    } on SocketException {
      // Error de conexión de red (sin conexión a Internet)
      // messageError(context,'Error de conexión de red: $e','Error');
      await DBService.db.updateCategory(obj);
    } on HttpException catch (e) {
      // Error de la solicitud HTTP
      messageError(context,'Error de la solicitud HTTP: $e','Error');
    } catch (e) {
      // Otro tipo de error
      messageError(context,'Error inesperado2: $e','Error');
    }
    
  }



  Future<List<ImageData>?> showFoodsCategory(BuildContext context,int value, int active) async {
  try {
    
    List<dynamic> response = json.decode((await http.get( Uri.parse("$link/api/Menus/MenuCategory?id=$value&active=$active"))).body);
     if (response.isNotEmpty){  
          List<ImageData> arr = [];
          for (var e in response) {
            arr.add(ImageData.fromJson(e));
          }
          return arr;
        }else{
          return [];
        }
    } on SocketException {
      // Error de conexión de red (sin conexión a Internet)
      // messageError(context,'Error de conexión de red: $e','Error');
      return await DBService.db.showFoodsCategory(value, 3).then((List<ImageData>? res) => res??[]);
    } on HttpException catch (e) {
      // Error de la solicitud HTTP
      messageError(context,'Error de la solicitud HTTP: $e','Error');
      return [];
    } catch (e) {
      // Otro tipo de error
      messageError(context,'Error inesperado2: $e','Error');
      return [];
    }
    
  }


Future<int> counterSale(BuildContext context) async {
  try {
    
    int response = json.decode((await http.get( Uri.parse("$link/api/Sales/SalesCounter"))).body);
     return response;
    } on SocketException {
      // Error de conexión de red (sin conexión a Internet)
      // messageError(context,'Error de conexión de red: $e','Error');
      return await DBService.db.counterSale();
    } on HttpException catch (e) {
      // Error de la solicitud HTTP
      messageError(context,'Error de la solicitud HTTP: $e','Error');
      return 0;
    } catch (e) {
      // Otro tipo de error
      messageError(context,'Error inesperado2: $e','Error');
      return 0;
    }
    
  }

  Future<void> insertSale(BuildContext context, SalesModel obj) async {
  try {
     // Formatear en el formato deseado
    String formattedDate = DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'").format(DateTime.parse(obj.date));
    SalesModel obj2 = SalesModel(
      date: formattedDate, 
      amount: obj.amount, 
      cveMenu: obj.cveMenu, 
      id: obj.id,
      idSale: 0
    );
    (await http.post( Uri.parse("$link/api/Sales"),body: jsonEncode(obj2), headers: HttpHeaders));
    } on SocketException {
      // Error de conexión de red (sin conexión a Internet)
      // messageError(context,'Error de conexión de red: $e','Error');
      await DBService.db.insertSale(obj);
    } on HttpException catch (e) {
      // Error de la solicitud HTTP
      messageError(context,'Error de la solicitud HTTP: $e','Error');
    } catch (e) {
      // Otro tipo de error
      messageError(context,'Error inesperado2: $e','Error');
    }
    
  }

  Future<List<HistorialModel>?> showSalesDate(BuildContext context, String datei, String datef) async {
    try {
    print("print $link/api/Sales/SalesDate?dateInitial=$datei&dateFinal=$datef");
    List<dynamic> response = json.decode((await http.get( Uri.parse("$link/api/Sales/SalesDate?dateInitial=$datei&dateFinal=$datef"))).body);
     if (response.isNotEmpty){  
          List<HistorialModel> arr = [];
          for (var e in response) {
            arr.add(HistorialModel.fromJson(e));
          }
          return arr;
        }else{
          return [];
        }
    } on SocketException {
      // Error de conexión de red (sin conexión a Internet)
      // messageError(context,'Error de conexión de red: $e','Error');
      return await DBService.db.showSalesDate(datei, datef);
    } on HttpException catch (e) {
      // Error de la solicitud HTTP
      messageError(context,'Error de la solicitud HTTP: $e','Error');
      return [];
    } catch (e) {
      // Otro tipo de error
      messageError(context,'Error inesperado2: $e','Error');
      return [];
    }
  }
 
 Future<List<CarthistorialModel>?> showFoodsSale(BuildContext context, int id) async {
  try {
    List<dynamic> response = json.decode((await http.get( Uri.parse("$link/api/Menus/MenuSale?id=$id"))).body);
     if (response.isNotEmpty){  
          List<CarthistorialModel> arr = [];
          for (var e in response) {
            arr.add(CarthistorialModel.fromJson(e));
          }
          return arr;
        }else{
          return [];
        }
    } on SocketException {
      // Error de conexión de red (sin conexión a Internet)
      // messageError(context,'Error de conexión de red: $e','Error');
      return await DBService.db.showFoodsSale(id);
    } on HttpException catch (e) {
      // Error de la solicitud HTTP
      messageError(context,'Error de la solicitud HTTP: $e','Error');
      return [];
    } catch (e) {
      // Otro tipo de error
      messageError(context,'Error inesperado2: $e','Error');
      return [];
    }
  }

  Future<void> updateSale(BuildContext context, int idSale, int amount) async {
  try {
     // Formatear en el formato deseado
      await http.put( Uri.parse("$link/api/Sales"),body: '{ "idSale": $idSale, "amount": $amount }', headers: HttpHeaders);
    } on SocketException {
      // Error de conexión de red (sin conexión a Internet)
      // messageError(context,'Error de conexión de red: $e','Error');
      await DBService.db.updateSale(amount, idSale);
    } on HttpException catch (e) {
      // Error de la solicitud HTTP
      messageError(context,'Error de la solicitud HTTP: $e','Error');
    } catch (e) {
      // Otro tipo de error
      messageError(context,'Error inesperado2: $e','Error');
    }
    
  }

  Future<void> deleteOneSale(BuildContext context, int i) async {
  try {
      await http.delete( Uri.parse("$link/api/Sales/one/$i",));
    } on SocketException {
      // Error de conexión de red (sin conexión a Internet)
      await DBService.db.deleteOneSale(i);
      // messageError(context,'Error de conexión de red: $e','Error');
    } on HttpException catch (e) {
      // Error de la solicitud HTTP
      messageError(context,'Error de la solicitud HTTP: $e','Error');
    } catch (e) {
      // Otro tipo de error
      messageError(context,'Error inesperado: $e','Error');
    }
  }


Future<void> deleteFullSale(BuildContext context, int i) async {
  try {
      await http.delete( Uri.parse("$link/api/Sales/full/$i",));
    } on SocketException {
      // Error de conexión de red (sin conexión a Internet)
      await DBService.db.deleteFullSale(i);
      // messageError(context,'Error de conexión de red: $e','Error');
    } on HttpException catch (e) {
      // Error de la solicitud HTTP
      messageError(context,'Error de la solicitud HTTP: $e','Error');
    } catch (e) {
      // Otro tipo de error
      messageError(context,'Error inesperado: $e','Error');
    }
  }


  Future<List<PieDataModel>?> showSalesPorcent(context, String datei, String datef) async{
    try {
    List<dynamic> response = json.decode((await http.get( Uri.parse("$link/api/Sales/SalesPorcent?dateInitial=$datei&dateFinal=$datef"))).body);
    if (response.isNotEmpty){  
          List<PieDataModel> arr = [];
          for (var e in response) {
            arr.add(PieDataModel.fromJson(e));
          }
          return arr;
        }else{
          return [];
        }
    } on SocketException {
      // Error de conexión de red (sin conexión a Internet)
      // messageError(context,'Error de conexión de red: $e','Error');
      return await DBService.db.showSalesPorcent(datei, datef);
    } on HttpException catch (e) {
      // Error de la solicitud HTTP
      messageError(context,'Error de la solicitud HTTP: $e','Error');
      return [];
    } catch (e) {
      // Otro tipo de error
      messageError(context,'Error inesperado2: $e','Error');
      return [];
    }
  } 

  Future<List<Map<String, dynamic>>?>showSalesReport(context, String datei, String datef) async{
    try {
    List<dynamic> response = json.decode((await http.get( Uri.parse("$link/api/Sales/SalesReport?dateInitial=$datei&dateFinal=$datef"))).body);
    if (response.isNotEmpty){  
          List<Map<String, dynamic>> arr = [];
          for (var e in response) {
            arr.add(e);
          }
          return arr;
        }else{
          return [];
        }
    } on SocketException {
      // Error de conexión de red (sin conexión a Internet)
      // messageError(context,'Error de conexión de red: $e','Error');
      return await DBService.db.showSalesReport(datei, datef);
    } on HttpException catch (e) {
      // Error de la solicitud HTTP
      messageError(context,'Error de la solicitud HTTP: $e','Error');
      return [];
    } catch (e) {
      // Otro tipo de error
      messageError(context,'Error inesperado2: $e','Error');
      return [];
    }
  }

  Future<void> updateFood(BuildContext context, ImageData obj) async {
    try {
      print('print ${jsonEncode(obj)}');
      await http.put( Uri.parse("$link/api/Menus"), body: jsonEncode(obj), headers: HttpHeaders);
    } on SocketException {
      // Error de conexión de red (sin conexión a Internet)
      // messageError(context,'Error de conexión de red: $e','Error');
      await DBService.db.updateFood(obj);
    } on HttpException catch (e) {
      // Error de la solicitud HTTP
      messageError(context,'Error de la solicitud HTTP: $e','Error');
    } catch (e) {
      // Otro tipo de error
      messageError(context,'Error inesperado2: $e','Error');
    }
  }

  messageError(BuildContext context, String msg, String title){
  return showDialog(
    context: context, // Accede al contexto del widget actual
    builder: (BuildContext context) {
      return AlertDialog(
        title:  Text(title,style: getTextStyleText(context,FontWeight.bold,null),),
        content: Text(msg, style: getTextStyleText(context,null,null)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Cierra el diálogo
            },
            child:  Text('Cerrar', style: getTextStyleButtonField(context),),
          ),
        ],
      );
    });
 }
  TextStyle getTextStyleText(BuildContext context, FontWeight? bold, param2) {
    return TextStyle(
      fontWeight: bold,
      fontSize: 12
    );
  }
  
  TextStyle getTextStyleButtonField(BuildContext context) {
    return TextStyle(
      fontSize: 12
    );
  }
}


