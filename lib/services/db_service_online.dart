
import 'dart:convert';
import 'dart:io';
import 'package:control_inv/models/services/services_model.dart';
import 'package:control_inv/services/db_service_offline.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class DbServiceOnline extends ChangeNotifier{

  bool modoApk = kDebugMode?true:false; 
  bool isSaving = true;
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
        Uri url = Uri.parse("http://10.0.2.2:8085/api/Categories");
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

        List<dynamic> response = json.decode((await http.get( Uri.parse("http://10.0.2.2:8085/api/Categories"))).body);

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
      await http.delete( Uri.parse("http://10.0.2.2:8085/api/Categories/$id",));
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


  Future<void> updateCategories(BuildContext context, Categories obj) async {
  try {
    
      await http.put( Uri.parse("http://10.0.2.2:8085/api/Categories"), body: jsonEncode(obj), headers: HttpHeaders);
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


