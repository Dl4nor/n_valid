import 'package:flutter/material.dart';
import 'package:n_valid/app_controller.dart';
import 'package:n_valid/login_page.dart';
import 'package:n_valid/storage_page.dart';
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
            '/tinder': (context) => TinderPage(),
            '/storage': (context) => StoragePage()
          }
        )
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

class OurAppBar extends AppBar {

  final String textTitle;

  OurAppBar({super.key, required this.textTitle});

  @override
  State<OurAppBar> createState() => _OurAppBarState(text: textTitle);
}

class _OurAppBarState extends State<OurAppBar> {

  final String text;

  _OurAppBarState({required this.text});

  @override
  Widget build(BuildContext context) {
    return AppBar(
        title: TextWithBorder(text: text, font: 'crash-a-like', size: 50, color: const Color.fromARGB(196, 0, 255, 166)),
        backgroundColor: Colors.green,
        actions: [
          CustomSwitch(),
        ],
      );
  }
}

class OurDrawer extends Drawer {
  const OurDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
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
                Navigator.of(context).pushNamed('/storage');
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
      );
  }
}