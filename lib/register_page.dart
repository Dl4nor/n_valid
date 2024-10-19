import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:n_valid/app_widget.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {

  String email = '';
  String senha = '';
  late String telefone;
  late String nomeCompleto;
  late String Uname;
  late String CNPJ;
  late String nomeLoja;
  bool isAdmin = false;

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
                style: const ButtonStyle(
                  backgroundColor: WidgetStatePropertyAll(Color.fromARGB(255, 201, 201, 201)),
                ),
                onPressed: (){
                  
                }, 
                child: const Icon(
                  Icons.add_photo_alternate, 
                  size: 60, 
                  color: Color.fromARGB(255, 102, 102, 102),)
              ),
            ),
            CustomTextField(
              labelText: "Nome Completo", 
              onChanged: (nome){
                nomeCompleto = nome;
              }
            ),
            CustomTextField(
              labelText: "Telefone profissional",
              textInputType: TextInputType.phone,
              onChanged: (tel) {
                telefone = tel;
              },
            ),
            CustomTextField(
              labelText: "Email Profissional", 
              onChanged: (mail) {email = mail;}
            ),
            CustomTextField(
              labelText: "Senha do aplicativo",
              isOcult: true,
              onChanged: (pass) {senha = pass;},
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

            ElevatedButton(
              onPressed: (){
                setState(() {
                  if(email.isNotEmpty && senha.isNotEmpty) //Falta terminar aq doidão :(
                  FirebaseAuth.instance.createUserWithEmailAndPassword(
                    email: email, 
                    password: senha
                  );
                  if(telefone.length == 11 && nomeCompleto.split(' ').length > 1) {
                    generateUname(nomeCompleto, telefone);
                  }  
                });
              }, 
              child: Text('Registrar')
            )
          ],
        )
      ),
    );
  }
}