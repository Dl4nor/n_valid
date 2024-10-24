import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AppController extends ChangeNotifier{
  static AppController instance = AppController();

   bool isDarkTheme = true;
   changeTheme() {
    isDarkTheme = !isDarkTheme;
    notifyListeners();
   }
 
  Future<String> LoginWithEmailPassword(
    String email,
    String password, 
    BuildContext context
  ) async{
    try{
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email, 
        password: password,
      );
      Navigator.of(context).pushReplacementNamed('/home');
    }
    on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found' || e.code == 'user-disabled') {
        return "Usuário não encontrado!";
      }
      else if (e.code == 'invalid-credential' || e.code == 'wrong-password'){
        return "Senha incorreta, tente novamente!";
      }
      else if (e.code == 'invalid-email'){
        return "Por favor, insira um email Valido!";
      }
      else{
        return e.message as String;
      }
    }
    return '';
  }

  Future<void> Logout(BuildContext context) async {
    FirebaseAuth.instance.signOut();
    Navigator.of(context).pushReplacementNamed('/');
  }
}