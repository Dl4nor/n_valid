import 'package:flutter/material.dart';
import 'package:n_valid/app_widget.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {

  @override
  Widget build(BuildContext context) {

    String email;
    String senha;
    String telefone = '';
    String nome = '';
    String Uname = '';
    bool isAdmin = false;

    void generateUname(String nomeCompleto, String tel){
      List<String> nomes = nomeCompleto.split(' ');

      if(nomes.length>1 && tel.length == 11){
        String firstLetter = nomes.first[0];
        String lastName = nomes.last;
        String last4digits = tel.substring(-4);

        setState(() {
          Uname = '$firstLetter$lastName$last4digits';
        }); 
      }
    }

    return Scaffold(
      appBar: OurAppBar(textTitle: 'Registro'),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomTextField(
              labelText: "Nome Completo", 
              onChanged: (nome){
                nome = nome;
                if(nome.isNotEmpty) {
                  generateUname(nome, telefone);
                }
              }
            ),
            CustomTextField(
              labelText: "Telefone profissional",
              textInputType: TextInputType.phone,
              onChanged: (telefone) {
                telefone = telefone;
                if(telefone.isNotEmpty) {
                  generateUname(nome, telefone); //Gerar Uname aparentemente não está funcionando
                }  
              },
            ),
            CustomTextField(
              labelText: "Email Profissional", 
              onChanged: (email) {email = email;}
            ),
            CustomTextField(
              labelText: "Senha do aplicativo",
              isOcult: true,
              onChanged: (senha) {senha = senha;},
            ),
            

          ],
        )
      ),
    );
  }
}