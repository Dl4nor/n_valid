import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
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

class PageCategory extends StatefulWidget {
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
  _PageCategoryState createState() => _PageCategoryState();
}

class _PageCategoryState extends State<PageCategory> {
  
  get isPressed => widget.isPressed;
  get pressedColors => widget.pressedColors;
  get name => widget.name;
  get days => widget.days;

  @override
  Widget build(BuildContext context) {

    String today = "${DateTime.now().day.toString().padLeft(2, '0')} / "
                   "${DateTime.now().month.toString().padLeft(2, '0')} / "
                   "${DateTime.now().year}";
    DateTime todayDate = DateTime.now();
    String expiration = "dd / mm / yyyy";
    int dias = 0;

    String nomeFuncionario = '';
    String telFuncionario = '';
    String errorText = '';
    bool? isManager;

    bool isBatch = false;
    String? goodsName;
    Timestamp? expirationDate;
    Timestamp? dateEntry;
    int? goodsAmount;
    String? goodsBarcode;
    String? goodsID;

    File? goodsImage;
    String imageName = '';

    String? storeCNPJ = AppController.instance.controllerCNPJ;
    String? storeName = AppController.instance.controllerStoreName;

    Future<void> pickImage(Function setStateDialog) async {
      final File? image = await AppController.instance.pickImage(context);
      if (image != null) {
       await setStateDialog(() {
          goodsImage = image;
          imageName = image.path.split('/').last;
        });
      }
    }

    updateCheckBox(Function setStateDialog){
      setStateDialog(() {
        isBatch = !isBatch;
      });
    }

    loadStorageData() async {
      AppController.instance.barcodeController.clear();
      setState(() async {
        final storageData = await AppController.instance.loadStoredata();
        goodsID = storageData!.id;
        imageName = storageData['imageURL'];
        isBatch = storageData['isBatch'];
        goodsName = storageData['name'];
        dateEntry = storageData['dateEntry'];
        expirationDate = storageData['dateExpiration'];
        goodsAmount = storageData['amount'];
        goodsBarcode = storageData['barcode'];
      });
    }

    uploadStorageData() async{
      if(goodsImage != null){

        await FirebaseFirestore.instance.collection('Storage').add(
          {
            'imageURL': '',
            'isBatch': isBatch,
            'name': goodsName,
            'dateEntry': Timestamp.fromDate(DateTime.now()),
            'dateExpiration': expirationDate,
            'amount': goodsAmount,
            'barcode': goodsBarcode,
            'CNPJ': storeCNPJ,
          }
        );

        await loadStorageData();

        final storageRef = FirebaseStorage.instance.ref().child('/Stores/$storeCNPJ/goods_images/$goodsID.jpg');
        await storageRef.putFile(goodsImage!);
        String downloadURL = await storageRef.getDownloadURL();

        FirebaseFirestore.instance.collection('Storage').doc(goodsID).update(
          {
            'imageURL': downloadURL
          }
        );

        FirebaseFirestore.instance.collection('Stores').doc('$storeName$storeCNPJ').update(
          {
            'storage': FieldValue.arrayUnion([goodsID])
          }
        );
      } 
      else {
        await FirebaseFirestore.instance.collection('Storage').add(
          {
            'isBatch': isBatch,
            'name': goodsName,
            'dateEntry': Timestamp.fromDate(DateTime.now()),
            'dateExpiration': expirationDate,
            'amount': goodsAmount,
            'barcode': goodsBarcode,
            'CNPJ': storeCNPJ,
          }
        );
      }
    }

    clearStoageData(){
      isBatch = false;
      goodsName = null;
      expirationDate = null;
      goodsAmount = null;
      goodsBarcode = null;
      expiration = 'dd / mm / yyyy';
    }

    loadUserData() async {
      final userData = await AppController.instance.loadUserData();
      isManager = userData!['isManager'];
    }

    loadUserData();

    Widget dialogBoxEmployeeRegistration(BuildContext context){
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

                    bool isEmployee = userNameSnapshot.docs.where((doc) => doc['CNPJ'] == storeCNPJ).toList().isNotEmpty;

                    if(userNameSnapshot.docs.isNotEmpty && !isEmployee){
                      FirebaseFirestore.instance
                      .collection('Users')
                      .doc(userNameSnapshot.docs[0].id)
                      .update(
                        {
                          'CNPJ': FieldValue.arrayUnion([storeCNPJ]),
                          'store': FieldValue.arrayUnion([storeName])
                        }
                      );
                      FirebaseFirestore.instance
                      .collection('Stores')
                      .doc('$storeName$storeCNPJ')
                      .update(
                       {
                          'employee': FieldValue.arrayUnion([userNameSnapshot.docs[0].get('userName').toString()])
                       } 
                      );
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
    }

    Widget dialogBoxGoodsRegistration(BuildContext context){
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
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.all(10.0),
                  height: 150,
                  width: 150,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromARGB(255, 201, 201, 201),
                      padding: EdgeInsets.all(0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100),
                        side: const BorderSide(color: Color.fromARGB(255, 0, 255, 47))
                      )
                    ),
                    onPressed: () {
                      pickImage(setStateDialog);
                    }, 
                    child: goodsImage == null
                    ? const Icon(
                        Icons.add_photo_alternate, 
                        size: 60, 
                        color: Color.fromARGB(255, 102, 102, 102)
                      )
                    : CircleAvatar(
                      radius: 100,
                      backgroundImage: FileImage(goodsImage!),
                      backgroundColor: const Color.fromARGB(255, 54, 119, 56),
                    )
                  ),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: AppController.instance.barcodeController,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(horizontal: 10),
                    border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(50))),
                    labelText: "Código do produto",
                    suffixIcon: IconButton(
                      icon: Icon(Icons.camera_alt_outlined),
                      onPressed: () async{
                        goodsBarcode = await AppController.instance.OpenScanner(context);
                      },
                    )
                  ),
                  onChanged: (text){
                    goodsBarcode = text;
                  },
                ),
                SizedBox(height: 10),
                TextField(
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.symmetric(horizontal: 10),
                    border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(50))),
                    labelText: "Nome do produto"
                  ),
                  onChanged: (text) {
                    goodsName = text;
                  },
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
                    Text("Validade:  ", style: TextStyle(fontSize: 16)),
                    Container(width: 10),
                    ElevatedButton(
                      onPressed: (){
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
                                expirationDate = Timestamp.fromDate(selectedDate);
                                // Essa parte conta os dias até um produto vencer 🏆:
                                dias = expirationDate!.toDate().difference(todayDate).inDays;
                                print("$dias");
                              });
                            }
                        });
                      }, 
                      child: Text(expiration)
                    )
                  ],
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Checkbox(
                      activeColor: Colors.green,
                      value: isBatch,
                      onChanged: (x) {
                        updateCheckBox(setStateDialog);
                      }
                    ),
                    Text('É um Lote?')
                  ],
                ),
                
                if(isBatch) ...[
                  SizedBox(height: 10),
                  TextField(
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.symmetric(horizontal: 10),
                      border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(50))),
                      labelText: "Quantidade no lote",
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly
                    ],
                    onChanged: (text) {
                      goodsAmount = int.tryParse(text);
                    },
                  ),
                ],
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: (){
                    uploadStorageData();
                    loadStorageData();
                    Navigator.of(context, rootNavigator: true).pop();
                  }, 
                  child: Text("Cadastrar"),
                )
              ],
            ),
          ),
        );
      });
    }

    Widget modalBottomRegistration(BuildContext context){
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
            if(isManager!)
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
                      builder: (BuildContext context) {
                        return dialogBoxEmployeeRegistration(context);
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
                      return dialogBoxGoodsRegistration(context);
                    }
                  );
                },
              ),
            ),
          ],
        ),
      );
    }
    
    return Stack(
      children: [
        Container(
          height: MediaQuery.sizeOf(context).height,
          color: pressedColors[isPressed].withOpacity(0.3),
        ),
        Column(
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
                          return modalBottomRegistration(context);
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
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(8.0) + const EdgeInsets.only(bottom: 55),
                  child: Table(
                    children: [
                      for (int i=0;i<30;i++)
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
                ),
              ),
            ),
          ]
        ),
      ]
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