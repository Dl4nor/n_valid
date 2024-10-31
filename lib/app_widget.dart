import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:n_valid/app_controller.dart';
import 'package:n_valid/home_page.dart';
import 'package:n_valid/login_page.dart';
import 'package:n_valid/register_page.dart';
import 'package:n_valid/settings_page.dart';
import 'package:n_valid/storage_page.dart';

class AppWidget extends StatelessWidget{
  static var instance;

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
        backgroundColor: AppController.instance.isDarkTheme
         ? const Color.fromARGB(255, 57, 202, 93)
         : const Color.fromARGB(255, 0, 245, 114),
      );
  }
}

class OurDrawer extends StatefulWidget {
  const OurDrawer({super.key});

  @override
  _OurDrawerState createState() => _OurDrawerState();
}

class _OurDrawerState extends State<OurDrawer> {

  bool errorCNPJ = false;
  bool errorStore = false;
  String? Uname;
  String? name;
  String? email;
  String? imageURL;
  List<dynamic>? stores;
  List<dynamic>? userCNPJ;
  bool? isManager;
  bool isLoading = true;
  String newCNPJ = '';
  String newStoreName = '';
  User? user = FirebaseAuth.instance.currentUser;
  DocumentSnapshot? userData;
  File? profileImage;
  String imageName = '';

  Future<void> loadUserData() async{
    final userData = await AppController.instance.loadUserData();
    if(userData!.exists){
      setState(() {
        Uname = userData['userName'];
        name = userData['name'];
        email = userData['mail'];
        stores = userData['store'];
        userCNPJ = userData['CNPJ'];
        isManager = userData['isManager'];
        imageURL = userData['imageURL'];
        isLoading = false;  
      });
    }
  }

  Future<void> logout() async{
    Uname = null;
    name = null; 
    email = null; 
    stores = null; 
    userCNPJ = null;
    isManager = null; 
    imageURL =  null;
    isLoading = false;  
  }
  
  Future<void> pickImage() async {
    final File? image = await AppController.instance.pickImage(context);
    if (image != null) {
      setState(() {
        profileImage = image;
        imageName = image.path.split('/').last;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
        child: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
          children: [
            UserAccountsDrawerHeader(
              decoration: BoxDecoration(
                color: AppController.instance.isDarkTheme 
                ? const Color.fromARGB(255, 57, 202, 93)
                : const Color.fromARGB(255, 0, 245, 114)
              ),
              currentAccountPicture: imageURL != null 
                ? ElevatedButton(
                  onPressed: () async{
                    await pickImage();

                    if(profileImage != null){
                      final storageRef = FirebaseStorage.instance.ref().child('$Uname/profile_images/${user!.uid}.jpg');
                      await storageRef.putFile(profileImage!);
                      String downloadURL = await storageRef.getDownloadURL();
                    
                      await FirebaseFirestore.instance.collection('Users').doc(user!.uid).update(
                        {
                          'imageURL': downloadURL
                        }
                      );
                      loadUserData();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(0),
                    backgroundBuilder: (context, states, child) {
                      return Container(
                        padding: EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color.fromARGB(255, 60, 255, 0)
                        ),
                        child: CircleAvatar(
                          backgroundColor: const Color.fromARGB(255, 0, 245, 114),
                          backgroundImage: NetworkImage(imageURL!)
                        ),
                      );
                    },
                  ),
                  child: const Text('')
                )
                : ElevatedButton(
                    onPressed: (){
                      AppController.instance.pickImage(context);
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(0),
                      backgroundBuilder: (context, states, child) {
                        return Container(
                          padding: EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color.fromARGB(255, 60, 255, 0)
                          ),
                          child: const Icon(Icons.people)
                        );
                      },
                    ),
                    child: const Text('')
                  ),
              accountName: name!.split(' ').length > 2 
                ? Text(
                    '${name!.split(' ').first} ${name!.split(' ')[1][0].toUpperCase()}. ${name!.split(' ').last}', 
                    style: const TextStyle(color: Colors.black)
                  ) 
                : Text(
                    '${name!.split(' ').first} ${name!.split(' ').last}', 
                    style: const TextStyle(color: Colors.black)
                  ), 
              accountEmail: Text(email!, style: const TextStyle(color: Colors.black))
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
              leading: const Icon(Icons.store),
              title: const Text('Loja'),
              subtitle: const Text('Lista de Lojas'),
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  builder: (BuildContext context){
                    return SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const ListTile(
                            title: Text(
                              'Selecione uma Loja', 
                              style: TextStyle(
                                color: Color.fromARGB(255, 57, 202, 93), 
                                fontWeight: FontWeight.bold,
                                fontSize: 18
                              ), 
                              textAlign: TextAlign.center
                            ),
                          ),
                          for(int i=0;i < stores!.length;i++)
                            Container(
                              margin: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                              decoration: BoxDecoration(
                                border: Border.symmetric(horizontal: BorderSide(width: 2)),
                                borderRadius: BorderRadius.circular(10)
                              ),
                              child: ListTile(
                                title: Text('${stores![i]} - ${userCNPJ![i].toString().substring(10)}', textAlign: TextAlign.center),
                                onTap: () {
                                  AppController.instance.setStore(stores![i], userCNPJ![i]);
                                  Navigator.of(context).pushReplacementNamed('/storage');
                                },
                              ),
                            ),
                          if(isManager!)
                            ListTile(
                              title: Container(
                                padding: EdgeInsets.symmetric(vertical: 5),
                                decoration: BoxDecoration(
                                  color: const Color.fromARGB(255, 22, 83, 39),
                                  borderRadius: BorderRadius.circular(100)
                                ),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.add_circle, size: 30),
                                    SizedBox(width: 10),
                                    Text("Adicionar Loja")
                                  ]
                                ),
                              ),
                              onTap: () {
                                showDialog(
                                  context: context, 
                                  builder: (BuildContext context){
                                    return StatefulBuilder(
                                      builder:(context, setState) {
                                        return AlertDialog(
                                          title: const Text(
                                            "Cadastrar Loja", 
                                            style: TextStyle(color: Color.fromARGB(255, 57, 202, 93), fontWeight: FontWeight.bold), 
                                            textAlign: TextAlign.center
                                          ),
                                          content: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              CustomTextField(
                                                labelText: 'Nome da Loja', 
                                                onChanged: (text) {
                                                  newStoreName = text;
                                                },
                                                error: errorStore,
                                                errorText: "Nome Inválido",
                                              ),
                                              CustomTextField(
                                                labelText: 'CNPJ', 
                                                onChanged: (text) {
                                                  newCNPJ = text;
                                                },
                                                maxLength: 14,
                                                textInputType: TextInputType.number,
                                                error: errorCNPJ,
                                                errorText: "CNPJ Inválido",
                                              ),
                                              ElevatedButton(
                                                onPressed: () async {
                                                  setState(() {
                                                    errorCNPJ = newCNPJ.length < 14 || (userCNPJ != null && userCNPJ!.contains(newCNPJ));
                                                    errorStore = newStoreName.isEmpty || (stores != null && stores!.contains(newStoreName));
                                                  });
                                                  if(!errorCNPJ && !errorStore){
                                                    FirebaseFirestore.instance.collection('Users')
                                                    .doc(user!.uid)
                                                    .update(
                                                      {
                                                        'CNPJ': FieldValue.arrayUnion([newCNPJ]),
                                                        'store': FieldValue.arrayUnion([newStoreName])
                                                      }
                                                    );
                                                    FirebaseFirestore.instance.collection('Stores')
                                                    .doc('$newStoreName${newCNPJ.substring(10)}')
                                                    .set(
                                                      {
                                                        'CNPJ': newCNPJ,
                                                        'store': newStoreName,
                                                        'employers': [],
                                                        'storageCode': ''
                                                      }
                                                    );

                                                    await loadUserData();

                                                    if(mounted) {
                                                      Navigator.of(context, rootNavigator: true).pop();
                                                    }
                                                  }
                                                }, 
                                                child: Text("Cadastrar")
                                              )
                                            ],
                                          ),
                                        );
                                      },
                                    );
                                  }
                                );
                              },
                            ),
                        ],
                      ),
                    );
                  }
                );
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
                logout();
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
  final String? errorText;
  final bool error;

  const CustomTextField({
                         super.key, 
                         required this.labelText, 
                         this.isOcult = false,
                         required this.onChanged,
                         this.textInputType = TextInputType.text,
                         this.maxLength,
                         this.error = false,
                         this.errorText
                        });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {

  get labelText => widget.labelText;
  get isOcult => widget.isOcult;
  get inputType => widget.textInputType;
  get maxLen => widget.maxLength;
  get inputError => widget.errorText;
  get erro => widget.error;
  late bool ifisOcult = isOcult;
  
  @override
  Widget build(BuildContext context) {

    final int? realMaxLen = inputType == TextInputType.phone ? 11 : maxLen;

    return 
        Padding(
          padding: const EdgeInsets.all(6.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                shape: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(50)), borderSide: BorderSide(color: Colors.transparent)),
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
                    border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(50))),
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
              if(erro)
                Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: ErrorText(text: inputError),
                )
            ],
          ),
        );
  }
}

class ErrorText extends StatelessWidget {
  final String text;

  const ErrorText({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(text, style: const TextStyle(color: Colors.red));
  }
}

