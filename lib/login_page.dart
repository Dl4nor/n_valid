import 'dart:io';

import 'package:flutter/material.dart';
import 'package:n_valid/app_controller.dart';
import 'package:n_valid/home_page.dart';

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
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Email',
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
        
                TextField(
                  onChanged: (text) {
                    password = text;
                  },
                  obscureText: true,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Password',
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
        
                ElevatedButton(
                  onPressed: () {
                    if(email == 'dante_espec@gmail.com' && password == '123'){

                      // Navigator.of(context).pushReplacement(
                      //   MaterialPageRoute(builder: (context) => HomePage())
                      // );
                      
                      Navigator.of(context).pushReplacementNamed('/home');

                    } else {
                      print('ERROUUUUUU!!!!!');
                    }
                  }, 
                  child: const Text('Entrar')
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}