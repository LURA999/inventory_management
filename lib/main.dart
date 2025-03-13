import 'package:control_inv/routes/routes.dart';
import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages




void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {  
    return MaterialApp(
      initialRoute: '/',
      routes: Routes.routes,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      )
    );
  }
}

