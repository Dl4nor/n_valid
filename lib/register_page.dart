import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:n_valid/app_widget.dart';
import 'package:provider/provider.dart';

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
  String CNPJ = '';
  String nomeLoja = '';
  File? profileImage;
  String imageName = '';
  bool isAdmin = false;

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

    void updateCheckBox(){
      setState(() {
        isAdmin = !isAdmin;
      });
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
      final XFile? image = await ImagePicker().pickImage(source: ImageSource.gallery);

      if (image != null){
        setState(() {
          profileImage = File(image.path);
          imageName = image.name;
        });
      }
    }

    Widget buildAdminField() {
      return Column(
              children: [
                CustomTextField(
                  labelText: "CNPJ da loja",
                  maxLength: 14,
                  textInputType: TextInputType.number,
                  onChanged: (senha) {senha = senha;},
                ),
            
                CustomTextField(
                  labelText: "Nome da Loja",
                  onChanged: (senha) {senha = senha;},
                ),
              ],
            );
    }

    return Scaffold(
      appBar: OurAppBar(textTitle: 'Registro'),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(10.0),
              height: 200,
              width: 200,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 194, 194, 194),
                  shadowColor: Colors.green,
                  padding: EdgeInsets.all(0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100)
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

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Checkbox(
                  activeColor: Colors.green,
                  value: isAdmin,
                  onChanged: (x) {
                    updateCheckBox();
                  }),
                  Text('É um gerente/líder?')
              ],
            ),
            if(isAdmin) 
              buildAdminField(),

            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: ElevatedButton(
                onPressed: () async{
                    if(ValidateFields()){
                      generateUname(nomeCompleto, telefone);

                      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
                        email: email, 
                        password: senha
                      );

                      String userID = userCredential.user!.uid;

                      if(profileImage != null){
                        final storageRef = FirebaseStorage.instance.ref().child('profile_images/$userID.jpg');
                        await storageRef.putFile(profileImage!);

                        String downloadURL = await storageRef.getDownloadURL();
                      
                        await FirebaseFirestore.instance.collection('Users').add(
                          {
                            'name': nomeCompleto,
                            'userName': Uname,
                            'phone': telefone,
                            'mail': email,
                            'isManager': isAdmin,
                            'CNPJ': CNPJ,
                            'Store': nomeLoja,
                            'ImageURL': downloadURL
                          }
                        );
                      } 
                      else {
                        await FirebaseFirestore.instance.collection('Users').add(
                          {
                            'name': nomeCompleto,
                            'userName': Uname,
                            'phone': telefone,
                            'mail': email,
                            'isManager': isAdmin,
                            'CNPJ': CNPJ,
                            'Store': nomeLoja,
                            'ImageURL': null,
                          }
                        );
                      }
                      Navigator.of(context).pushReplacementNamed('/');
                    }
                }, 
                child: Text('Registrar')
              ),
            )
          ],
        )
      ),
    );
  }
}