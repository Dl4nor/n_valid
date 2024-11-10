import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:n_valid/app_controller.dart';
import 'package:n_valid/app_widget.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {

  String email = '';
  String senha = '';
  String telefone = '';
  String nomeCompleto = '';
  String Uname = '';
  File? profileImage;
  String imageName = '';

  bool emailError = false;
  bool nomeError = false;
  bool senhaError = false;
  bool telError = false;


  @override
  Widget build(BuildContext context) {

    void generateUname(String nomeCompleto, String tel){
      List<String> nomes = nomeCompleto.split(' ');

      if(nomes.length>1 && tel.length == 11){
        String firstLetter = nomes.first[0];
        String lastName = nomes.last;
        String last4digits = tel.substring(7);

        setState(() {
          Uname = '$firstLetter$lastName$last4digits';
        }); 
      }
    }

    bool ValidateFields(){
      setState(() {
        emailError = email.isEmpty;
        senhaError = senha.isEmpty;
        telError = telefone.length != 11;
        nomeError = nomeCompleto.split(' ').length < 2;
      });
      return !emailError && !senhaError && !telError && !nomeError; 
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

    return Scaffold(
      appBar: OurAppBar(textTitle: 'Registro'),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              margin: EdgeInsets.symmetric(vertical: MediaQuery.sizeOf(context).height*0.02),
              padding: const EdgeInsets.all(10.0),
              height: 200,
              width: 200,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 194, 194, 194),
                  shadowColor: Colors.green,
                  padding: const EdgeInsets.all(1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100),
                    side: const BorderSide(color: Color.fromARGB(255, 0, 255, 47))
                  )
                ),
                onPressed: (){
                  pickImage();
                }, 
                child: profileImage == null
                ? const Icon(
                    Icons.add_photo_alternate, 
                    size: 60, 
                    color: Color.fromARGB(255, 102, 102, 102)
                  )
                : CircleAvatar(
                    radius: 100,
                    backgroundImage: FileImage(profileImage!),
                    backgroundColor: const Color.fromARGB(255, 54, 119, 56),
                  )
              ),
            ),
            CustomTextField(
              labelText: "Nome Completo", 
              onChanged: (nome){
                nomeCompleto = nome;
              },
              error: nomeError,
              errorText: "Nome não está completo",
            ),

            CustomTextField(
              labelText: "Telefone profissional",
              textInputType: TextInputType.phone,
              onChanged: (tel) {
                telefone = tel;
              },
              error: telError,
              errorText: "Telefone Inválido",
            ),

            CustomTextField(
              labelText: "Email Profissional", 
              onChanged: (mail) {
                email = mail; 
              },
              textInputType: TextInputType.emailAddress,
              error: emailError,
              errorText: "Email precisa ser preenchido",
            ),

            CustomTextField(
              labelText: "Senha do aplicativo",
              isOcult: true,
              onChanged: (pass) {
                senha = pass;
              },
              error: senhaError,
              errorText: "Senha precisa ser preenchida",
            ),
            SizedBox(height: MediaQuery.sizeOf(context).height*0.02),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 119, 245, 178),
                  borderRadius: BorderRadius.circular(25)
                ),
                padding: EdgeInsets.all(1),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 107, 218, 111),
                    fixedSize: Size(MediaQuery.sizeOf(context).width*0.5, 50),
                    foregroundColor: const Color.fromARGB(192, 0, 0, 0),
                  ),
                  child: const Text('Registrar', style: TextStyle(fontSize: 18),),
                  onPressed: () async{
                
                    final BuildContext dailogContext = context;
                
                    showDialog(
                      context: dailogContext,
                      barrierDismissible: false,
                      builder: (context) => AlertDialog(
                        backgroundColor: Colors.transparent,
                        content: Container(
                          height: 60,
                          child: Center(child: CircularProgressIndicator()),
                        ),
                      ),
                    );
                
                    if(ValidateFields()){
                      generateUname(nomeCompleto, telefone);
                
                      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
                        email: email, 
                        password: senha
                      );
                
                      String userID = userCredential.user!.uid;
                
                      if(profileImage != null){
                        final storageRef = FirebaseStorage.instance.ref().child('/Users/$Uname/profile_images/$userID.jpg');
                        await storageRef.putFile(profileImage!);
                
                        String downloadURL = await storageRef.getDownloadURL();
                      
                        await FirebaseFirestore.instance.collection('Users').doc(userID).set(
                          {
                            'name': nomeCompleto,
                            'userName': Uname,
                            'phone': telefone,
                            'mail': email,
                            'CNPJ': [],
                            'store': [],
                            'imageURL': downloadURL
                          }
                        );
                      } 
                      else {
                        await FirebaseFirestore.instance.collection('Users').doc(userID).set(
                          {
                            'name': nomeCompleto,
                            'userName': Uname,
                            'phone': telefone,
                            'mail': email,
                            'CNPJ': [],
                            'store': [],
                            'imageURL': null,
                          }
                        );
                      }
                      await Future.delayed(Duration(milliseconds: 200));
                      Navigator.of(context, rootNavigator: true).pop();
                      await Future.delayed(Duration(milliseconds: 200));
                      Navigator.of(context).pop();
                    }
                  }, 
                ),
              ),
            )
          ],
        )
      ),
    );
  }
}