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

class HomePageState extends State<HomePage>{
  int counter = 0;
 
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
          SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Contador $counter'),
              Container(height: 10),
              const CustomSwitch(),
              Container(height: 50),
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.spaceAround,
              //   children: [
              //     Container(
              //       width: 50,
              //       height: 50,
              //       color: Colors.black,
              //     ),
              //     Container(
              //       width: 50,
              //       height: 50,
              //       color: Colors.black,
              //     ),
              //     Container(
              //       width: 50,
              //       height: 50,
              //       color: Colors.black,
              //     ),
              //   ],
              // )
            ],
          ),
        ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: (){
          setState(() {
            counter++;
          });
        } , 
        child: const Icon(Icons.add),
      ),
    );
   
  }

}