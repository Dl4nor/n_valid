import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:n_valid/app_controller.dart';
import 'package:n_valid/home_page.dart';
import 'language_provider.dart'; // Importa o LanguageProvider

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String email = '';
  String password = '';

  @override
  Widget build(BuildContext context) {
    // Obtém o idioma atual do LanguageProvider
    String currentLanguage = Provider.of<LanguageProvider>(context).selectedLanguage;

    // Define textos com base no idioma atual
    String emailLabel;
    String passwordLabel;
    String loginButtonText;

    switch (currentLanguage) {
      case 'pt':
        emailLabel = 'Email';
        passwordLabel = 'Senha';
        loginButtonText = 'Entrar';
        break;
      case 'es':
        emailLabel = 'Correo electrónico';
        passwordLabel = 'Contraseña';
        loginButtonText = 'Iniciar sesión';
        break;
      case 'en':
      default:
        emailLabel = 'Email';
        passwordLabel = 'Password';
        loginButtonText = 'Login';
        break;
    }

    return Scaffold(
      body: SingleChildScrollView(
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 300,
                  height: 300,
                  child: Image(
                    image: const NetworkImage('../src/Logo GTR Transparente.png'),
                    color: AppController.instance.isDarkTheme 
                           ? Colors.white 
                           : Colors.black,
                  ),
                ),
                TextField(
                  onChanged: (text) {
                    email = text;
                  },
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    labelText: emailLabel, // Usando texto traduzido
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  onChanged: (text) {
                    password = text;
                  },
                  obscureText: true,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    labelText: passwordLabel, // Usando texto traduzido
                  ),
                ),
                const SizedBox(height: 15),
                ElevatedButton(
                  onPressed: () {
                    if (email == 'dante_espec@gmail.com' && password == '123') {
                      Navigator.of(context).pushReplacementNamed('/home');
                    } else {
                      print('ERROUUUUUU!!!!!');
                    }
                  }, 
                  child: Text(loginButtonText) // Usando texto traduzido
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}