
import 'package:control_inv/services/db_service_offline.dart';
import 'package:control_inv/widgets/widgets.dart';
import 'package:flutter/material.dart';

/* Es el screen principal donde se vera reflejado el menu */
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key}); 
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}



class _MyHomePageState extends State<MyHomePage> {

  Future<bool>? _isLoading;

  @override
  void initState() {
    super.initState();

    _isLoading = loadData();
  }

  Future<bool> loadData() async {
    // Completa la carga de datos y devuelve 
    return await Renovation().jwt();
  }

  @override
  Widget build(BuildContext context) {
    DBService.db.database;
    return FutureBuilder(
      future: _isLoading,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
        return  Scaffold(
          body: Center(
            child: Stack(
              children: [
                // Fondo con gradiente morado
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.purple, Colors.deepPurpleAccent],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
                // Indicador de carga centrado
                Center(
                  child: CircularProgressIndicator(
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        );
        
        } else {
          if (!snapshot.data!) {
            return Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
              backgroundColor: Theme.of(context).colorScheme.inversePrimary,
              title: Icon(Icons.home),
              centerTitle: true,
            ),
            body: Center(
              //Es la lista con las opciones y/o funciones de las aplicacion
              child: ListView(
                children: <Widget>[
                  SizedBox(height: 20,),
                  buttonMain(context, 'Menu', '/menu', Icons.fastfood_rounded),
                  SizedBox(height: 20,),
                  buttonMain(context, 'Reportes', '/reports', Icons.dashboard_customize_outlined),
                  SizedBox(height: 20,),
                  buttonMain(context, 'Historial', '/historial', Icons.history),
                  SizedBox(height: 20,),
                  buttonMain(context, 'Ajustes', '/settings', Icons.settings),
                ],
              ),
            ),
          );
          } else{
            return RenovationScreen();
          }
          
        }
        
      }
    );
  }

  //it will be create a method because the styles are the same and function same too
  SizedBox buttonMain(BuildContext context, String text, String navigateName, IconData icon) {
    return SizedBox(
      height: 160,
      width: MediaQuery.of(context).size.width - 20,
      //it'll be modify the styles the button with stylefrom
      child: Container(
        margin: EdgeInsets.only(left: 15, right: 15),
        child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          // side: BorderSide(color: Colors.black),
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0) // Adjust the radius value to change the roundness
          ),
        ),
        onPressed: () async {
          if (!(await Renovation().jwt())) {
            Navigator.pushNamed(context, navigateName);
          }else{
            Navigator.pushNamed(context, '/renovation');
          }
        }, 
        label: Text(text, style: TextStyle(fontSize: 50)),
        icon: Icon(icon, size: 70,),
        ),
      ),
    );
  }

}