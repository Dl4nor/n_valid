import 'package:flutter/material.dart';
import 'package:n_valid/app_controller.dart';
import 'package:n_valid/login_page.dart';
import 'package:n_valid/tinder_page.dart';

import 'home_page.dart';

class AppWidget extends StatelessWidget{
  const AppWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
        animation: AppController.instance,
        builder: (context, child) => MaterialApp(
          theme: ThemeData(
            primarySwatch: Colors.green,
            brightness: AppController.instance.isDarkTheme 
              ? Brightness.dark 
              : Brightness.light 
          ),
          initialRoute: '/',
          routes: {
            '/': (context) => LoginPage(),
            '/home': (context) => HomePage(),
            '/tinder': (context) => TinderPage()
          }
        )
    );
  }
}