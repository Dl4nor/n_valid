import 'package:flutter/material.dart';

import 'app_controller.dart';

class HomePage extends StatefulWidget{

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
      appBar: AppBar(
        title: const TextWithBorder(text: 'N. Valid', font: 'crash-a-like', size: 40, color: Colors.orange),
        backgroundColor: Colors.green,
      ),
      
      body: Center(
        child: CustomSwitch()
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

class CustomSwitch extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Switch(
            value: AppController.instance.isDarkTheme, 
            onChanged: (value) {
              AppController.instance.changeTheme();
            },
           );
  }
}

class TextWithBorder extends StatelessWidget {
  
  final String text;
  final String font;
  final double size;
  final Color color;
  final Color borderColor;

  const TextWithBorder({super.key, required this.text, 
                                   this.font = '', 
                                   required this.size, 
                                   this.color = Colors.black, 
                                   this.borderColor = Colors.black});

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
                  Text(text, 
                        style: TextStyle(
                                fontFamily: font, 
                                fontSize: size,
                                foreground: Paint()
                                  ..style = PaintingStyle.stroke
                                  ..strokeWidth = 2 // Tamanho da borda
                                  ..color = borderColor, // Cor da borda
                                )
                  ),
                  Text(text, 
                        style: TextStyle(
                                  fontFamily: font, 
                                  fontSize: size,
                                  color: color
                                ),
                  )
                ]
    );
  }
}