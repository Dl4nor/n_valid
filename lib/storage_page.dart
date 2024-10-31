import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:n_valid/app_controller.dart';
import 'package:n_valid/app_widget.dart';

class StoragePage extends StatefulWidget {
  const StoragePage({super.key});

  @override
  State<StoragePage> createState() => _StoragePageState();
}

class _StoragePageState extends State<StoragePage> {
  int isPressed = 0;
  List<bool> pressed = [true, false, false];
  List<String> textCategory = [
    "❗Danger", 
    "⚠️Caution", 
    "✅Fine"
  ];
  List<Color> pressedColors = [
    Colors.red,
    Colors.yellow, 
    Colors.green
  ];

  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
  }

  void updatePressed(int index) {
    setState(() {
      for (int i = 0; i < pressed.length; i++) {
        pressed[i] = false;
      }
      pressed[index] = true;
      isPressed = index;
      
      _pageController.animateToPage(
        index,  
        duration: Durations.short2,
        curve: Curves.easeInOut
      );
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      drawer: const OurDrawer(),
      appBar: OurAppBar(textTitle: 'N. Stock'),
      body: Stack(
        
        children: [
          PageView(
            controller: _pageController,
            onPageChanged: (int index) {
              setState(() {
                updatePressed(index);
              });
            },
            children: [
              PageCategory(pressedColors: pressedColors, isPressed: 0, name: "Yogurte", days: 2),
              PageCategory(pressedColors: pressedColors, isPressed: 1, name: "Leite Jussara 2L", days: 30),
              PageCategory(pressedColors: pressedColors, isPressed: 2, name: "Arroz Tio João 5Kg", days: 197)
            ],
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Card(
                margin: const EdgeInsets.all(0),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
                elevation: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      for (int i = 0; i < pressed.length; i++)
                        _SlideButton(
                          text: textCategory[i], 
                          color: pressedColors[i], 
                          isPressed: pressed[i], 
                          onPressed: () => updatePressed(i)
                        )
                    ],
                  ),
              ),
            ],
          ),
        ]
      ),
    );
  }
}

class PageCategory extends StatelessWidget {

  final int isPressed;
  final List<Color> pressedColors;
  final String name;
  final int days;

  const PageCategory({
    super.key, 
    required this.pressedColors, 
    required this.isPressed, 
    required this.name, 
    required this.days
  });

  @override
  Widget build(BuildContext context) {

    String today = "${DateTime.now().day} / ${DateTime.now().month} / ${DateTime.now().year}";
    DateTime todayDate = DateTime.now();
    String expiration = "DD / MM / AAAA";
    int dias = 0;
    late DateTime? expirationDate;

    String nomeFuncionario = '';
    String telFuncionario = '';
    String errorText = '';

    Future<DocumentSnapshot?> userData = AppController.instance.loadUserData();
    User? user = FirebaseAuth.instance.currentUser;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.sizeOf(context).height
            ),
            child: Container(
              width: MediaQuery.sizeOf(context).width,
              color: pressedColors[isPressed].withOpacity(0.3),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ElevatedButton(
                            style: const ButtonStyle(
                              backgroundColor: WidgetStatePropertyAll(Colors.transparent),
                              shadowColor: WidgetStatePropertyAll(Colors.transparent),
                              padding: WidgetStatePropertyAll(EdgeInsets.zero)
                            ),
                            child: Icon(Icons.my_library_add, size: 40, color: Colors.white),
                            onPressed: (){
                              showModalBottomSheet(
                                context: context, 
                                builder: (BuildContext context){
                                  return SingleChildScrollView(
                                    child: Column(
                                      children: [
                                        const ListTile(
                                          title: Text(
                                            'Selecione uma opção', 
                                            style: TextStyle(
                                              color: Color.fromARGB(255, 57, 202, 93), 
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18
                                            ), 
                                            textAlign: TextAlign.center
                                          ),
                                        ),
                                        Container(
                                          margin: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                                          decoration: BoxDecoration(
                                            border: Border.symmetric(horizontal: BorderSide(width: 2)),
                                            borderRadius: BorderRadius.circular(10)
                                          ),
                                          child: ListTile(
                                              title: const Row(
                                                children: [
                                                  Icon(Icons.person_add_alt_rounded),
                                                  SizedBox(width: 20),
                                                  Text(
                                                    'Cadastrar funcionário', 
                                                    textAlign: TextAlign.center
                                                  )
                                                ],
                                              ),
                                            onTap: () {
                                              showDialog(
                                                context: context, 
                                                builder:  (BuildContext context) {
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
                                                              labelText: "Nome completo do Funcionário"
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
                                                            onPressed: () async{
                                                              if(nomeFuncionario.isNotEmpty && telFuncionario.isNotEmpty){
                                                                String firstLetter = nomeFuncionario.split(' ').first[0];
                                                                String lastName = nomeFuncionario.split(' ').last;
                                                                String last4Digits = telFuncionario.substring(7);
                                                                String unameFuncionario = '$firstLetter$lastName$last4Digits';
                                                                QuerySnapshot userNameSnapshot = await FirebaseFirestore.instance
                                                                  .collection('Users')
                                                                  .where('userName', isEqualTo: unameFuncionario)
                                                                  .get();

                                                                if(userNameSnapshot.docs.isNotEmpty){
                                                                  FirebaseFirestore.instance
                                                                    .collection('Users')
                                                                    .doc(userNameSnapshot.docs[0].id)
                                                                    .update(
                                                                      {
                                                                        'CNPJ': [AppController.instance.controllerCNPJ],
                                                                        'store': [AppController.instance.controllerStoreName]
                                                                      }
                                                                  );
                                                                  await AppController.instance.loadUserData();
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
                                                            child: const Text('Cadastrar Funcionário')
                                                          )
                                                        ],
                                                      ),
                                                    );
                                                  });
                                                },
                                              );
                                            },
                                          ),
                                        ),
                                        Container(
                                          margin: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                                          decoration: BoxDecoration(
                                            border: Border.symmetric(horizontal: BorderSide(width: 2)),
                                            borderRadius: BorderRadius.circular(10)
                                          ),
                                          child: ListTile(
                                              title: const Row(
                                                children: [
                                                  Icon(Icons.add_shopping_cart),
                                                  SizedBox(width: 20),
                                                  Text(
                                                    'Cadastrar produto', 
                                                    textAlign: TextAlign.center
                                                  )
                                                ],
                                              ),
                                            onTap: () {
                                              showDialog(
                                                context: context,
                                                builder: (BuildContext context) {
                                                  return StatefulBuilder(builder: (context, setStateDialog){
                                                  return AlertDialog(
                                                    title: const Text(
                                                      "Cadastro de Produtos", 
                                                      style: TextStyle(
                                                        color: Colors.green,
                                                        fontWeight: FontWeight.bold
                                                      ), 
                                                      textAlign: TextAlign.center
                                                    ),
                                                    content: Column(
                                                      mainAxisSize: MainAxisSize.min,
                                                        children: [
                                                          Container(
                                                            padding: EdgeInsets.all(10.0),
                                                            height: 150,
                                                            width: 150,
                                                            child: ElevatedButton(
                                                              style: const ButtonStyle(
                                                                backgroundColor: WidgetStatePropertyAll(Color.fromARGB(255, 201, 201, 201)),
                                                              ),
                                                              onPressed: (){
                                                                AppController.instance.pickImage(context);
                                                              }, 
                                                              child: const Icon(
                                                                Icons.add_photo_alternate, 
                                                                size: 60, 
                                                                color: Color.fromARGB(255, 102, 102, 102),)
                                                            ),
                                                          ),
                                                          const TextField(
                                                            decoration: InputDecoration(
                                                              contentPadding: EdgeInsets.symmetric(horizontal: 10),
                                                              border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(50))),
                                                              labelText: "Nome do produto"
                                                            )
                                                          ),
                                                          Container(height: 10),
                                                          Row(
                                                            children: [
                                                              Text("Entrada:   ", style: TextStyle(fontSize: 16)),
                                                              Container(width: 10),
                                                              ElevatedButton(
                                                                onPressed: (){
                                                                  showDatePicker(
                                                                    context: context, 
                                                                    initialDate: DateTime.now(),
                                                                    firstDate: DateTime.now(), 
                                                                    lastDate: DateTime.now(),
                                                                  );
                                                                }, 
                                                                child: Text(today)
                                                              )
                                                            ],
                                                          ),
                                                          Container(height: 10),
                                                          Row(
                                                            children: [
                                                              Text("Validade: ", style: TextStyle(fontSize: 16)),
                                                              Container(width: 10),
                                                              ElevatedButton(onPressed: (){
                                                                showDatePicker(
                                                                  context: context, 
                                                                  initialDate: DateTime.now(),
                                                                  firstDate: DateTime.now(), 
                                                                  lastDate: DateTime(2200)
                                                                ).then((selectedDate) {
                                                                    if(selectedDate != null){
                                                                      setStateDialog(() {
                                                                        expiration =
                                                                          "${selectedDate.day.toString().padLeft(2, '0')} / "
                                                                          "${selectedDate.month.toString().padLeft(2, '0')} / "
                                                                          "${selectedDate.year}"; 
                                                                        expirationDate = selectedDate;
                                                                        // Essa parte conta os dias até um produto vencer 🏆:
                                                                        dias = expirationDate!.difference(todayDate).inDays+1;
                                                                        print("$dias");
                                                                      });
                                                                    }
                                                                });
                                                              }, child: Text(expiration))
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    );
                                                  });
                                                }
                                              );
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }
                              );
                            },
                          ),
                          Expanded(
                            child: Card(
                              shape: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(100), 
                                borderSide: BorderSide(
                                  color: pressedColors[isPressed].withOpacity(0.8)
                                )
                              ), 
                              child: TextField(
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(100)),
                                  labelText: "Pesquisar produto",
                                  contentPadding: EdgeInsets.symmetric(horizontal: 8)
                                ),
                                onChanged: (text){
                                  
                                },
                              ),
                            ),
                          ),
                        ]
                      ),
                    ),
                    Table(
                      children: [
                        for (int i=0;i<10;i++)
                        TableRow(
                          decoration: const BoxDecoration(border: Border.symmetric(horizontal: BorderSide(width: 0.3))),
                          children: [
                          Container(
                            height: 40,
                            decoration: BoxDecoration(borderRadius: BorderRadius.circular(50)),
                            child: const ImageIcon(AssetImage("assets/images/box.png")),
                          ),
                          Padding(
                            padding: EdgeInsets.all(2), 
                            child: Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17), textAlign: TextAlign.start),
                          ),
                          Padding(
                            padding: EdgeInsets.all(2), 
                            child: Text('$days Dias', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17), textAlign: TextAlign.center),
                          )
                          ]
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

class _SlideButton extends StatelessWidget {

  final String text;
  final Color color;
  final bool isPressed;
  final VoidCallback onPressed;

  const _SlideButton({
    required this.text,
    required this.color, 
    required this.isPressed,
    required this.onPressed
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20), 
        color: isPressed
                ? color
                : null
      ),
      width: 100,
      height: 50,
      child: TextButton(
        onPressed: (){
          onPressed();
        }, 
        child: Text(
          text, 
          style: TextStyle(
            color: AppController.instance.isDarkTheme 
                    ? Colors.white 
                    : Colors.black, 
            fontWeight: FontWeight.bold,
            fontSize: 15
          )
        )
      ),
    );
  }
}