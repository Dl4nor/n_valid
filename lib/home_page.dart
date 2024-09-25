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
      drawer: Drawer(
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              decoration: BoxDecoration(color: Color.fromARGB(255, 0, 245, 114)),
              currentAccountPicture: ClipRRect(
                                        borderRadius: BorderRadius.circular(50),
                                        child: Image.asset('../assets/images/ProfilePic.jpg')
                                     ),
              accountName: Text('Dante Espec'), 
              accountEmail: Text('dante_espec@gmail.com')
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text('Home'),
              subtitle: Text('Menu Inicial'),
              onTap: () {
                Navigator.of(context).pushReplacementNamed('/home');
              },
            ),
            ListTile(
              leading: Icon(Icons.storage),
              title: Text('Estoque'),
              subtitle: Text('Estoque de Produtos'),
              onTap: () {
                Navigator.of(context).pushReplacementNamed('/home');
              },
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Configurações'),
              subtitle: Text('Menu de configurações'),
              onTap: () {
                Navigator.of(context).pushReplacementNamed('/home');
              },
            ),
            ListTile(
              leading: Icon(Icons.exit_to_app),
              title: Text('Logout'),
              subtitle: Text('Sair'),
              onTap: () {
                Navigator.of(context).pushReplacementNamed('/');
              },
            )
          ],
        ),
      ),
      appBar: AppBar(
        title: const TextWithBorder(text: 'N. Valid', font: 'crash-a-like', size: 50, color: Color.fromARGB(198, 0, 255, 162)),
        backgroundColor: Colors.green,
        actions: [
          CustomSwitch(),
        ],
      ),
      
      body: Container(
        width: double.infinity,
        height: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Contador $counter'),
            Container(height: 10),
            CustomSwitch(),
            Container(height: 50),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Container(
                  width: 50,
                  height: 50,
                  color: Colors.black,
                ),
                Container(
                  width: 50,
                  height: 50,
                  color: Colors.black,
                ),
                Container(
                  width: 50,
                  height: 50,
                  color: Colors.black,
                ),
              ],
            )
          ],
        ),
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
                                  ..strokeWidth = 2
                                  ..color = borderColor,
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