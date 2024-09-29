import 'package:flutter/material.dart';
import 'package:n_valid/app_controller.dart';
import 'package:n_valid/app_widget.dart';

class StoragePage extends StatefulWidget {
  const StoragePage({super.key});

  @override
  State<StoragePage> createState() => _StoragePageState();
}

class _StoragePageState extends State<StoragePage> {
  List<bool> pressed = [false, false, false];

  @override
  Widget build(BuildContext context) {
    
    List<Color> pressedColors = [
      const Color.fromARGB(255, 96, 26, 21), 
      const Color.fromARGB(255, 111, 102, 26), 
      const Color.fromARGB(255, 35, 80, 36)
    ];

    return Scaffold(
      drawer: const OurDrawer(),
      appBar: OurAppBar(textTitle: 'N. Stock'),
      body: Column(
        children: [
          Container(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20), 
                  color: pressed[0] 
                        ? pressedColors[0] 
                        : Colors.red
                ),
                width: 100,
                height: 50,
                child: TextButton(
                  onPressed: (){
                    setState(() {
                      pressed[0] = true;
                      pressed[1] = false;
                      pressed[2] = false;
                    });
                  }, 
                  child: const Text("❗Danger", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold))
                ),
              ),
              Container(
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), color: pressed[1] ? pressedColors[1] : Colors.yellow),
                width: 100,
                height: 50,
                child: TextButton(
                  onPressed: (){
                    setState(() {
                      pressed[0] = false;
                      pressed[1] = true;
                      pressed[2] = false;
                    });
                  }, 
                  child: const Text("⚠️Caution", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold))
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20), 
                  color: pressed[2] 
                        ? pressedColors[2] 
                        : Colors.green,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      offset: const Offset(0, 0),
                      blurRadius: 8,
                      spreadRadius: 2,
                    )
                  ]
                ),
                width: 100,
                height: 50,
                child: TextButton(
                  
                  onPressed: (){
                    setState(() {
                      pressed[0] = false;
                      pressed[1] = false;
                      pressed[2] = true;
                    });
                  }, 
                  child: const Text("✅Fine", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold))
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}