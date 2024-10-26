import 'package:flutter/material.dart';
import 'package:n_valid/app_controller.dart';
import 'package:n_valid/app_widget.dart';

class HomePage extends StatefulWidget{
  const HomePage({super.key});


  @override
  State<HomePage> createState() {
    return HomePageState();
  }
}

class HomePageState extends State<HomePage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const OurDrawer(),
      appBar: OurAppBar(textTitle: 'N. Valid',),
      
      body: Stack(
        children: [ 
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Image(
                    image: const AssetImage('assets/images/Logo GFR Transparente.png'),
                    color: AppController.instance.isDarkTheme 
                           ? const Color.fromARGB(24, 255, 255, 255) 
                           : const Color.fromARGB(21, 0, 0, 0) ,
                  ),
            ],
          ),
        ],
      ),
    );
  }

}