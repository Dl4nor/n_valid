import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

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
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushReplacementNamed('/');
  }

  String? controllerStoreName;
  String? controllerCNPJ;
  setStore(storeName, CNPJ){
    controllerStoreName = storeName;
    controllerCNPJ = CNPJ;
  }

  Future<DocumentSnapshot?> loadUserData() async{
    User? user = FirebaseAuth.instance.currentUser;
    if(user != null){
      final userData = await FirebaseFirestore.instance
        .collection('Users')
        .doc(user.uid)
        .get();
      return userData;
    }
    return null;
  }

  Future<File?> pickImage(BuildContext context) async {
    ImageSource? imageSource;

    // Mostra o diálogo para escolher a fonte da imagem
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            "Selecione uma opção",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.green, 
              fontSize: 18, 
              fontWeight: FontWeight.bold
            ),
          ),
          content: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: 100,
                    width: 100,
                    child: ElevatedButton(
                      onPressed: () {
                        imageSource = ImageSource.camera;
                        Navigator.pop(context);
                      },
                      child: const Icon(Icons.camera_alt, color: Colors.green),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 16, 69, 18),
                      ),
                    ),
                  ),
                  const Text("Câmera", style: TextStyle(color: Colors.green)),
                ],
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: 100,
                    width: 100,
                    child: ElevatedButton(
                      onPressed: () {
                        imageSource = ImageSource.gallery;
                        Navigator.pop(context);
                      },
                      child: const Icon(Icons.photo, color: Colors.green),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 16, 69, 18),
                      ),
                    ),
                  ),
                  const Text("Galeria", style: TextStyle(color: Colors.green)),
                ],
              ),
            ],
          ),
        );
      },
    );

    // Retorna o arquivo de imagem escolhido
    if (imageSource != null) {
      final XFile? image = await ImagePicker().pickImage(source: imageSource!);
      return image != null ? File(image.path) : null;
    }
    return null;
  }
}