import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:n_valid/app_controller.dart';

class ManagementPage extends StatefulWidget {
  const ManagementPage({super.key});

  @override
  State<ManagementPage> createState() => _ManagementPageState();
}

class _ManagementPageState extends State<ManagementPage> {

  List<DocumentSnapshot?> storeEmployeeList = [];
  List<DocumentSnapshot?> filteredEmployeeList = [];
  QuerySnapshot? userNameSnapshot;
  DocumentSnapshot<Object?>? storeData;
  DocumentSnapshot<Object?>? currenteUserData;
  bool isSearching = false;
  bool isPressing = false;
  String? pressed;
  final TextEditingController searchController = TextEditingController();

  @override
  void initState(){
    super.initState();
    loadCurrentUserData();
    loadStoreData();
    loadEmployeeList();
  }

  bool onWillPop() {
    if(isSearching){
      FocusScope.of(context).unfocus();
      setState(() {
        isSearching = false;
      });
      return false;
    }
    return true;
  }

  Future<void> detectUsername(String employeeName, String employeePhone) async{
    String firstLetter = employeeName.split(' ').first[0];
    String lastName = employeeName.split(' ').last;
    String last4Digits = employeePhone.substring(7);
    String unameFuncionario = '$firstLetter$lastName$last4Digits';
    userNameSnapshot = await FirebaseFirestore.instance
      .collection('Users')
      .where('userName', isEqualTo: unameFuncionario)
      .get();
    setState(() {
      userNameSnapshot = userNameSnapshot;
    });
  }

  Widget dialogBoxEmployeeRegistration(){
    String nomeFuncionario = '';
    String telFuncionario = '';
    String errorText = '';
    
    return StatefulBuilder(builder: (context, setStateDialog){
      return AlertDialog(
        title: const Text(
          "Cadastrar Funcionário",
          style: TextStyle(
            color: Colors.green,
            fontWeight: FontWeight.bold
          ), 
          textAlign: TextAlign.center
        ),
        content: Column(
        mainAxisSize: MainAxisSize.min,
          children: [
            if(errorText.isNotEmpty)
              Container(
                margin: EdgeInsets.only(bottom: 16),
                child: Text(
                  errorText, 
                  style: const TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold
                  )
                )
              ),
            TextField(
              onChanged: (text){
                nomeFuncionario = text;
              },
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.symmetric(horizontal: 10),
                border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(50))),
                labelText: "Nome completo"
              )
            ),
            Container(height: 10),
            TextField(
              onChanged: (text){
                telFuncionario = text;
              },
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.symmetric(horizontal: 10),
                border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(50))),
                labelText: "Telefone do Funcionário"
              ),
              keyboardType: TextInputType.phone,
              inputFormatters: [
                LengthLimitingTextInputFormatter(11),
                FilteringTextInputFormatter.digitsOnly
              ],
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                if(nomeFuncionario.isNotEmpty && telFuncionario.isNotEmpty){
                  detectUsername(nomeFuncionario, telFuncionario);

                  bool isEmployee = userNameSnapshot!.docs.where((doc) => doc['CNPJ'] == storeData!['CNPJ']).toList().isNotEmpty;

                  if(userNameSnapshot!.docs.isNotEmpty && !isEmployee){
                    FirebaseFirestore.instance
                    .collection('Users')
                    .doc(userNameSnapshot!.docs[0].id)
                    .update(
                      {
                        'CNPJ': FieldValue.arrayUnion([storeData!['CNPJ']]),
                        'store': FieldValue.arrayUnion([storeData!['store']])
                      }
                    );
                    FirebaseFirestore.instance
                    .collection('Stores')
                    .doc(storeData!.id)
                    .update(
                      {
                        'employees': FieldValue.arrayUnion([userNameSnapshot!.docs[0].get('userName').toString()])
                      } 
                    );
                    loadEmployeeList();
                    loadStoreData();
                    Navigator.of(context, rootNavigator: true).pop();
                  }
                  else if(nomeFuncionario.split(' ').length < 2){
                    setStateDialog((){
                      errorText = "Nome não está completo";
                    });
                  }
                  else if(telFuncionario.length < 11) {
                    setStateDialog((){
                      errorText = "Número de Telefone inválido";
                    });
                  }
                  else{
                    setStateDialog((){
                      errorText = "Usuário não encontrado";
                    });
                  }
                }
                else {
                  setStateDialog((){
                    errorText = "Nada a consultar";
                  });
                }
              }, 
              child: const Text('Cadastrar')
            )
          ],
        ),
      );
    });
  }

  void loadStoreData() async{
    storeData = await AppController.instance.loadStoreData();
    setState(() {
      storeData = storeData;
    });
  }

  void loadCurrentUserData() async{
    currenteUserData = await AppController.instance.loadUserData();
    setState(() {
      currenteUserData = currenteUserData;
    });
  }

  void loadEmployeeList() async{
    final employeeData = await FirebaseFirestore.instance.collection('Users');
    QuerySnapshot employeeList = await employeeData.where('CNPJ', arrayContains: AppController.instance.controllerCNPJ!).get();

    if(employeeList.docs.isNotEmpty){
      storeEmployeeList = employeeList.docs;
      setState(() {
        storeEmployeeList.sort((a, b) {
          bool aIsManager = storeData!['managers'].contains(a!['userName']);
          bool bIsManager = storeData!['managers'].contains(b!['userName']);

          if(aIsManager && !bIsManager){
            return -1;
          }
          if(!aIsManager && bIsManager){
            return 1;
          }
          return 0;
        });
        filteredEmployeeList = storeEmployeeList;
      });
    }
  }

  void filterEmployeeList(String text) {
    final filtered = storeEmployeeList.where((name){
      return name!['name'].toString().toLowerCase().contains(text.toLowerCase());
    }).toList();

    setState(() {
      filteredEmployeeList = filtered;
    });
  }

  void demoteEmployee(String userName){
    if(storeData!['managers'].length > 1) {
      FirebaseFirestore.instance.collection('Stores').doc(storeData!.id).update(
        {
          'managers': FieldValue.arrayRemove([userName])
        }
      );
    } else{
      showDialog(
        context: context, 
        builder: (BuildContext context){
          return AlertDialog(
            title: const Text(
              "Falha ao rebaixar", 
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold
              ), 
              textAlign: TextAlign.center
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: MediaQuery.sizeOf(context).width/2.2,
                  child: const Text("Existe na loja somente um gerente, promova alguém para sair", textAlign: TextAlign.center)
                ),
                SizedBox(height: 10),
                Container(
                  width: 100,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(126, 175, 76, 76),
                    ),
                    onPressed: (){
                      Navigator.of(context, rootNavigator: true).pop();
                    }, 
                    child: const Text("OK", style: TextStyle(color: Colors.white))
                  ),
                )
              ],
            ),
          );
        }
      );
    }
  }

  void promoteEmployee(String userName){
    FirebaseFirestore.instance.collection('Stores').doc(storeData!.id).update(
      {
        'managers': FieldValue.arrayUnion([userName])
      }
    );
  }

  void dismissEmployee(final doc){
    if(storeData!['managers'].contains(doc!['userName'])){
      demoteEmployee(doc['userName']);
    }
    if(storeData!['managers'].length > 1 || !storeData!['managers'].contains(doc['userName'])) {
      FirebaseFirestore.instance.collection('Stores').doc(storeData!.id).update(
        {
          'employees': FieldValue.arrayRemove([doc['userName']])
        }
      );
      FirebaseFirestore.instance.collection('Users').doc(doc.id).update(
        {
          'CNPJ': FieldValue.arrayRemove([storeData!['CNPJ']]),
          'store': FieldValue.arrayRemove([storeData!['store']])
        }
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: isSearching
          ? TextField(
            controller: searchController,
            autofocus: true,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              hintText: 'Pesquisar funcionário',
              hintStyle: TextStyle(color: Color.fromARGB(172, 255, 255, 255)),
              border: InputBorder.none,
            ),
            onChanged: (text){
              filterEmployeeList(text);
            },
            onTapOutside: (event){
              FocusScope.of(context).unfocus();
            },
          )
          : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppController.instance.controllerStoreName!, 
                style: const TextStyle(
                  color: Color.fromARGB(255, 255, 255, 255),
                  fontSize: 18,
                  fontWeight: FontWeight.bold
                )
              ),
              Text(
                AppController.instance.controllerCNPJ!.substring(8, 12),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
                textAlign: TextAlign.left,
              )
            ],
          ),
        backgroundColor: const Color.fromARGB(171, 62, 150, 62),
      ),
      body: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.sizeOf(context).height-70
          ),
          child: Card(
            margin: EdgeInsets.only(top: 8)+EdgeInsets.symmetric(horizontal: 2),
            child: Container(
              width: MediaQuery.sizeOf(context).width,
              padding: EdgeInsets.all(4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: EdgeInsets.only(left: 8),
                        child: Text(
                          filteredEmployeeList.length < 2
                           ? "Funcionário: ${filteredEmployeeList.length}"
                           : "Funcionários: ${filteredEmployeeList.length}", 
                          textAlign: TextAlign.left, 
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color.fromARGB(255, 0, 255, 149)
                          )
                        ),
                      ),
                      IconButton(
                        onPressed: (){
                          setState(() {
                            isSearching = !isSearching;
                            if(!isSearching){
                              searchController.clear();
                              filterEmployeeList(searchController.text);
                            }
                          });
                        }, 
                        icon: const Icon(Icons.search, color: Color.fromARGB(255, 0, 255, 149))
                      )
                    ],
                  ),
                  if(!isSearching)
                    ElevatedButton(
                      onPressed: (){
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return dialogBoxEmployeeRegistration();
                          },
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        alignment: Alignment.centerLeft,
                        padding: EdgeInsets.all(0),
                        foregroundColor: const Color.fromARGB(255, 97, 207, 106),
                        shadowColor: Colors.transparent,
                        overlayColor: const Color.fromARGB(207, 255, 255, 255)
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            padding: const EdgeInsets.all(1),
                            margin: const EdgeInsets.only(left: 7),
                            decoration: const BoxDecoration(
                              color: Color.fromARGB(255, 79, 219, 84),
                              shape: BoxShape.circle
                            ),
                            child: Container(
                                decoration: const BoxDecoration(
                                  color: Color.fromARGB(255, 121, 240, 105), 
                                  shape: BoxShape.circle
                                ),
                                child: const Icon(Icons.person_add, color: Color.fromARGB(192, 0, 0, 0))
                              )
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            'Cadastrar funcionário',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16
                            ),
                          ),
                        ],
                      ),
                    ),
                  SizedBox(height: 10),
                  for(var doc in filteredEmployeeList) ...[
                    GestureDetector(
                      onLongPressStart: (details) async{
                        final selectedOption = await showMenu<String>(
                          context: context,
                          position: RelativeRect.fromLTRB(
                            details.globalPosition.dx-200,
                            details.globalPosition.dy,
                            details.globalPosition.dx,
                            details.globalPosition.dy
                          ),
                          items: [
                            if(!storeData!['managers'].contains(doc['userName']))
                              PopupMenuItem(
                                value: 'promover',
                                child:  Container(
                                  child: const Row(
                                    children: [
                                      Icon(Icons.group_add),
                                      SizedBox(width: 10),
                                      Text("Fornecer gerência"),
                                    ],
                                  ),
                                )
                              ) else
                              PopupMenuItem(
                                value: 'rebaixar',
                                child:  Container(
                                  child: const Row(
                                    children: [
                                      Icon(Icons.group_remove, color: Colors.red),
                                      SizedBox(width: 10),
                                      Text("Retirar gerência", style: TextStyle(color: Colors.red)),
                                    ],
                                  ),
                                )
                              ),
                            if(doc['userName'] == currenteUserData!['userName'])
                              PopupMenuItem(
                                value: 'sair',
                                child:  Container(
                                  child: const Row(
                                    children: [
                                      Icon(Icons.group_remove, color: Colors.red),
                                      SizedBox(width: 10),
                                      Text("Sair da loja", style: TextStyle(color: Colors.red)),
                                    ],
                                  ),
                                )
                              ) else
                              PopupMenuItem(
                                value: 'excluir',
                                child:  Container(
                                  child: const Row(
                                    children: [
                                      Icon(Icons.group_remove, color: Colors.red),
                                      SizedBox(width: 10),
                                      Text("Retirar da loja", style: TextStyle(color: Colors.red)),
                                    ],
                                  ),
                                )
                              ),
                          ]
                        );
                        switch (selectedOption){
                          case 'promover':
                            promoteEmployee(doc['userName']);
                            loadStoreData();
                            break;
                          case 'rebaixar':
                            demoteEmployee(doc['userName']);
                            loadStoreData();
                            break;
                          case 'excluir':
                            dismissEmployee(doc);
                            loadStoreData();
                            loadEmployeeList();
                            break;
                          case 'sair':
                            dismissEmployee(doc);
                            Navigator.of(context).pushReplacementNamed('/home');
                            break;
                        }
                      },
                      onTapDown: (_){
                        setState(() {
                          pressed = doc['userName'];
                          isPressing = true;
                        });
                      },
                      onTapCancel: (){
                        setState(() {
                          isPressing = false;
                        });
                      },
                      onTapUp: (_){
                        setState(() {
                          isPressing = false;
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 4),
                        decoration: BoxDecoration(
                          color: isPressing && pressed == doc!['userName']
                            ? const Color.fromARGB(26, 255, 255, 255)
                            : Colors.transparent,
                          borderRadius: BorderRadius.circular(10)
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              padding: const EdgeInsets.all(1),
                              margin: const EdgeInsets.only(left: 7),
                              decoration: const BoxDecoration(
                                color: Color.fromARGB(255, 40, 211, 46),
                                shape: BoxShape.circle
                              ),
                              child: doc!['imageURL'].isEmpty
                                ? Container(
                                  decoration: const BoxDecoration(
                                    color: Colors.greenAccent, 
                                    shape: BoxShape.circle
                                  ),
                                  child: const Icon(Icons.person, color: Color.fromARGB(192, 84, 187, 87),)
                                )
                                : CircleAvatar(
                                  backgroundImage: NetworkImage(doc['imageURL']),
                                  backgroundColor: Colors.greenAccent,
                                ),
                            ),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  doc['name'].split(' ').length < 3
                                  ? doc['name']
                                  : '${doc['name'].split(' ').first} ${doc['name'].split(' ')[1][0].toUpperCase()}. ${doc['name'].split(' ').last}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16
                                  ),
                                ),
                                Text(
                                  '(${doc['phone'].substring(0, 2)}) ${doc['phone'].substring(2, 7)}-${doc['phone'].substring(7)}',
                                  style: const TextStyle(
                                    fontSize: 12
                                  ),
                                )
                              ],
                            ),
                            const Spacer(),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: storeData!['managers'].contains(doc['userName']) 
                                ? [
                                  Card(
                                    child: Container(
                                      padding: const EdgeInsets.all(2),
                                      margin: EdgeInsets.only(right: 8),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(style: BorderStyle.solid, color: Colors.green)
                                      ),
                                      child: const Text(
                                        'Gerente da loja',
                                        style: TextStyle(
                                          color: Colors.green,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 10
                                        ),
                                      )
                                    ),
                                  )
                                ]
                                : [],
                              
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                  ]
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}