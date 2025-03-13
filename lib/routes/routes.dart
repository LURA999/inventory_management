import 'package:control_inv/screens/settings/settingsCategory.dart';
import 'package:control_inv/widgets/widgets.dart';
// import 'package:flutter/material.dart';

class Routes {

  static final routes =  {
    // When navigating to the "/" route, build the homeScreen widget.
    '/': (context) => const MyHomePage(),
    // when navigating to the other route, then it will go to the nexts wdigets
    '/menu': (context) => const MenuScreen(),
    '/menu/cart': (context) => const CartScreen(),
    '/reports': (context) => const ReportsScreen(),
    '/historial': (context) => const HistorialScreen(),
    '/historial/historialCart': (context) => const CartHistorialScreen(),
    '/historial/historialCart/menuHistorial': (context)=> const MenuHistorialScreen(),
    '/settings': (context) => const SettingsScreen(),
    '/settings/settingsFood': (context) => const SettingsfoodScreen(),
    '/settings/settingsCategory': (context) => const SettingsCategoryScreen(),
    '/renovation': (context) => const RenovationScreen(),
    // '/settings/settingsFood/cameraFood': (context) => const CameraFoodScreen()
  };

}

/* class CustomBackBvuttonInterceptor extends StatelessWidget {

  final Widget child;

  const CustomBackBvuttonInterceptor({super.key, required this.child});
  @override
  Widget build(BuildContext context) {
    return PopScope(canPop:  false, child: child);
  }
} */