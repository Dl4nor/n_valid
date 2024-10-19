import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:n_valid/app_controller.dart';
import 'package:n_valid/home_page.dart';
import 'package:n_valid/login_page.dart';
import 'package:n_valid/register_page.dart';
import 'package:n_valid/settings_page.dart';
import 'package:n_valid/storage_page.dart';

class AppWidget extends StatelessWidget{
  const AppWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
        animation: AppController.instance,
        builder: (context, child) => MaterialApp(
          theme: ThemeData(
            fontFamily: 'carving_soft',
            primarySwatch: Colors.green,
            brightness: AppController.instance.isDarkTheme 
              ? Brightness.dark 
              : Brightness.light
          ),
          initialRoute: '/',
          routes: {
            '/': (context) => const LoginPage(),
            '/register': (context) => const RegisterPage(),
            '/home': (context) => const HomePage(),
            '/storage': (context) => const StoragePage(),
            '/settings': (context) => const SettingsPage()
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
  final FontWeight weight;
  final Color borderColor;

  const TextWithBorder({super.key, required this.text, 
                                   this.font = '', 
                                   required this.size, 
                                   this.color = Colors.black, 
                                   this.borderColor = Colors.black, 
                                   this.weight = FontWeight.normal});

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
                  Text(text, 
                        style: TextStyle(
                                fontFamily: font, 
                                fontSize: size,
                                fontWeight: weight,
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
                                  fontWeight: weight,
                                  color: color
                                ),
                  )
           ]
    );
  }
}

class CustomSwitch extends StatelessWidget {
  const CustomSwitch({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AppController.instance, 
      builder: (context, child) {
        return Switch(
                value: AppController.instance.isDarkTheme, 
                onChanged: (value) {
                  AppController.instance.changeTheme();
                },
        );
      }
    );
  }
}

class OurAppBar extends AppBar {

  final String textTitle;

  OurAppBar({super.key, required this.textTitle});

  @override
  State<OurAppBar> createState() => _OurAppBarState();
}

class _OurAppBarState extends State<OurAppBar> {

  get text => widget.textTitle;

  @override
  Widget build(BuildContext context) {
    return AppBar(
        title: TextWithBorder(text: text, font: 'crash-a-like', size: 60, color: const Color.fromARGB(196, 0, 255, 166)),
        backgroundColor: Colors.green,
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
              decoration: const BoxDecoration(color: Color.fromARGB(255, 0, 245, 114)),
              currentAccountPicture: ClipRRect(
                                        borderRadius: BorderRadius.circular(50),
                                        child: Image.asset('../assets/images/ProfilePic.jpg')
                                     ),
              accountName: const Text('Dante Espec', style: TextStyle(color: Colors.black)), 
              accountEmail: const Text('dante_espec@gmail.com', style: TextStyle(color: Colors.black))
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Home'),
              subtitle: const Text('Menu Inicial'),
              onTap: () {
                Navigator.of(context).pushReplacementNamed('/home');
              },
            ),
            ListTile(
              leading: const Icon(Icons.storage),
              title: const Text('Estoque'),
              subtitle: const Text('Estoque de Produtos'),
              onTap: () {
                Navigator.of(context).pushNamed('/storage');
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Configurações'),
              subtitle: const Text('Menu de configurações'),
              onTap: () {
                Navigator.of(context).pushNamed('/settings');
              },
            ),
            ListTile(
              leading: const Icon(Icons.exit_to_app),
              title: const Text('Logout'),
              subtitle: const Text('Sair'),
              onTap: () {
                AppController.instance.Logout(context);
              },
            )
          ],
        ),
      );
  }
}

class CustomTextField extends StatefulWidget {
  final String labelText;
  final bool isOcult;
  final Function(String) onChanged;
  final TextInputType textInputType;
  final int? maxLength;

  const CustomTextField({
                         super.key, 
                         required this.labelText, 
                         this.isOcult = false,
                         required this.onChanged,
                         this.textInputType = TextInputType.text,
                         this.maxLength
                        });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {

  get labelText => widget.labelText;
  get isOcult => widget.isOcult;
  get inputType => widget.textInputType;
  get maxLen => widget.maxLength;
  late bool ifisOcult = isOcult;
  
  @override
  Widget build(BuildContext context) {

    final int? realMaxLen = inputType == TextInputType.phone ? 11 : maxLen;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        shape: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(50))),
        child: TextField(
          onChanged:(value){
            widget.onChanged(value);
          },
          obscuringCharacter: '✦',
          obscureText: ifisOcult,
          keyboardType: inputType,
          inputFormatters: inputType == TextInputType.phone || inputType == TextInputType.number
                           ? [
                            LengthLimitingTextInputFormatter(realMaxLen),
                            FilteringTextInputFormatter.digitsOnly
                           ]
                           : [],
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(horizontal: 10),
            border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(50))),
            labelText: labelText,
            suffixIcon: isOcult 
            ? IconButton(
                icon: Icon(
                  ifisOcult
                  ? Icons.visibility_off 
                  : Icons.visibility,
                ),
                onPressed: (){
                  setState(() {
                    ifisOcult = !ifisOcult;
                  });
                },
              )
            : null
          )
        ),
      ),
    );
  }
}