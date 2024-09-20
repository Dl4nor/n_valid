import 'package:flutter/material.dart';
import 'package:n_valid/app_controller.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  String email = '';
  String password = '';

  Widget _body(){
      return SingleChildScrollView(
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
                    image: const AssetImage('assets/images/Logo GFR Transparente.png'),
                    color: AppController.instance.isDarkTheme 
                           ? Colors.white 
                           : Colors.black,
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Card(
                    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(50))),
                    child: TextField(
                      onChanged: (text) {
                        email = text;
                      },
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.symmetric(horizontal: 10),
                        border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(50))),
                        labelText: 'Email',
                      )
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
        
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Card(
                    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(50))),
                    child: TextField(
                      onChanged: (text) {
                        password = text;
                      },
                      obscureText: true,
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.symmetric(horizontal: 10),
                        border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(50))),
                        labelText: 'Password',
                      ),
                    ),
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
      );
  }
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: AppController.instance.isDarkTheme 
                        ? const LinearGradient(
                            colors: [Color.fromARGB(255, 52, 165, 44), Color.fromARGB(255, 34, 53, 40)],
                            stops: [0.25, 0.75],
                            begin: Alignment.bottomRight,
                            end: Alignment.topLeft
                          )
                        : const LinearGradient(
                            colors: [Color(0xff54ff47), Color(0xff93ecad)],
                            stops: [0.25, 0.75],
                            begin: Alignment.bottomRight,
                            end: Alignment.topLeft
                          )
      
            )
          ),
          _body(),
        ],
      ),
    );
  }
}