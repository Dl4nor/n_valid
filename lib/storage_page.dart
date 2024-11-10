import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
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

  Future<Map<String, List<DocumentSnapshot>>> defineCategory() async{
    try{
      CollectionReference storageCollection = FirebaseFirestore.instance.collection('Storage');
      QuerySnapshot storage = await storageCollection.where('CNPJ', isEqualTo: AppController.instance.controllerCNPJ).get();
      DateTime now = DateTime.now();

      Map<String, List<DocumentSnapshot>> categorizedStorage = {
        'danger': [],
        'caution': [],
        'fine': []
      };

      for(var doc in storage.docs){
        DateTime expirationDate = doc['dateExpiration'].toDate();
        DateTime entryDate = doc['dateEntry'].toDate();

        int daysToExpiration = expirationDate.difference(now).inDays;
        int totalDays = expirationDate.difference(entryDate).inDays;

        if (daysToExpiration < (totalDays/4)) {
          categorizedStorage['danger']!.add(doc);
        } else if (daysToExpiration >= (totalDays/4) && daysToExpiration < (totalDays/2)) {
          categorizedStorage['caution']!.add(doc);
        } else {
          categorizedStorage['fine']!.add(doc);
        }
        print(expirationDate);
        print(entryDate);
        print(daysToExpiration);
      }
      
      return categorizedStorage;
    } catch(e){
      print('Erro ao tentar carregar documentos: $e');
      return {
        'danger': [],
        'caution': [],
        'fine': []
      };
    }
  }

  Map<String, List<DocumentSnapshot>>? categorizedStorage;
  bool isLoading = true;
  Future<void> _loadCategories() async {
    categorizedStorage = await defineCategory();
    setState(() {
      isLoading = false;
      print(categorizedStorage);
    });
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    _loadCategories();
  }

  @override
  Widget build(BuildContext context){
    
    if(isLoading){
      return const Center(child: CircularProgressIndicator());
    }

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
              PageCategory(pressedColors: pressedColors, isPressed: 0, categorizedStorage: categorizedStorage?['danger'] ?? []),
              PageCategory(pressedColors: pressedColors, isPressed: 1, categorizedStorage: categorizedStorage?['caution'] ?? []),
              PageCategory(pressedColors: pressedColors, isPressed: 2, categorizedStorage: categorizedStorage?['fine'] ?? [])
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
  final List<DocumentSnapshot> categorizedStorage;

  const PageCategory({
    super.key, 
    required this.pressedColors, 
    required this.isPressed, 
    required this.categorizedStorage,
  });
  
  @override
  _PageCategoryState createState() => _PageCategoryState();
}

class _PageCategoryState extends State<PageCategory> {
  
  get isPressed => widget.isPressed;
  get pressedColors => widget.pressedColors;
  get categorizedStorage => widget.categorizedStorage;

  @override
  Widget build(BuildContext context) {

    String entryDate = "${DateTime.now().day.toString().padLeft(2, '0')} / "
                       "${DateTime.now().month.toString().padLeft(2, '0')} / "
                       "${DateTime.now().year}";
    String expiration = "dd / mm / yyyy";



    bool isBatch = false;
    String? goodsName;
    Timestamp? expirationDate;
    Timestamp? entryTimestamp;
    int? goodsAmount;
    String? goodsBarcode;
    String? goodsID;

    File? goodsImage;

    String? storeCNPJ = AppController.instance.controllerCNPJ;
    String? storeName = AppController.instance.controllerStoreName;
    String? userUname;
    bool isManager = false;

    Future<void> pickImage(Function setStateDialog) async {
      final File? image = await AppController.instance.pickImage(context);
      if (image != null) {
       await setStateDialog(() {
          goodsImage = image;
        });
      }
    }

    updateCheckBox(Function setStateDialog){
      setStateDialog(() {
        isBatch = !isBatch;
      });
    }

    loadStorageData() async {
      final storageData = await AppController.instance.loadStorageData();
      goodsID = storageData!.id;
      isBatch = storageData['isBatch'];
      goodsName = storageData['name'];
      expirationDate = storageData['dateExpiration'];
      goodsAmount = storageData['amount'];
      goodsBarcode = storageData['barcode'];
    }

    uploadStorageData() async{
      if(goodsImage != null){

        await FirebaseFirestore.instance.collection('Storage').add(
          {
            'imageURL': '',
            'isBatch': isBatch,
            'name': goodsName,
            'dateEntry': entryTimestamp,
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
            'imageURL': '',
            'isBatch': isBatch,
            'name': goodsName,
            'dateEntry': entryTimestamp,
            'dateExpiration': expirationDate,
            'amount': goodsAmount,
            'barcode': goodsBarcode,
            'CNPJ': storeCNPJ,
          }
        );
      }
    }

    loadUserData() async {
      final userData = await AppController.instance.loadUserData();
      final storeData = await AppController.instance.loadStoreData();
      userUname = await userData!['userName'];
      List<dynamic> storeManagers = await storeData!['managers'];
      if(storeManagers.contains(userUname)){
        isManager = true;
      }
    }

    loadUserData();

    @override
    void clearGoodsContent() {
      isBatch = false;
      goodsName = null;
      expirationDate = null;
      goodsAmount = null;
      goodsBarcode = null;
      goodsID = null;
      goodsImage = null;
      expiration = 'dd / mm / yyyy';
      AppController.instance.barcodeController.clear();
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
                          firstDate: DateTime(2000), 
                          lastDate: DateTime.now(),
                        ).then((selectedDate){
                          if(selectedDate != null){
                            setStateDialog((){
                              entryDate = 
                                "${selectedDate.day.toString().padLeft(2, '0')} / "
                                "${selectedDate.month.toString().padLeft(2, '0')} / "
                                "${selectedDate.year}";
                              entryTimestamp = Timestamp.fromDate(selectedDate);
                            });
                          }
                        });
                      }, 
                      child: Text(entryDate)
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
                  clearGoodsContent();
                  
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
                  Expanded(
                    child: Card(
                      shape: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20), 
                        borderSide: BorderSide(
                          color: Colors.transparent,
                        )
                      ), 
                      child: TextField(
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide(color: pressedColors[isPressed].withOpacity(0.6))
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide(color: pressedColors[isPressed])
                          ),
                          labelText: "Pesquisar produto",
                          labelStyle: TextStyle(color: pressedColors[isPressed].withOpacity(0.9)),
                          floatingLabelStyle: TextStyle(color: pressedColors[isPressed]),
                        ),
                        onChanged: (text){
                          
                        },
                        onTapOutside: (event) {
                          FocusScope.of(context).unfocus();
                        },
                      ),
                    ),
                  ),
                  PopupMenuButton(
                    icon: const Icon(Icons.more_vert, size: 40, color: Colors.white),
                    onSelected: (val) {
                      switch (val) {
                        case 'cadastrar':
                          showModalBottomSheet(
                            context: context,
                            builder: (BuildContext context) {
                              return modalBottomRegistration(context);
                            },
                          );
                          break;
                        case 'gerenciar':
                          Navigator.pushNamed(context, '/storage/management');
                          break;
                      }
                    },
                    itemBuilder: (BuildContext context) {
                      return [
                        const PopupMenuItem(
                          value: 'cadastrar',
                          child: Row(
                            children: [
                              Icon(Icons.my_library_add, size: 20, color: Colors.white),
                              SizedBox(width: 10),
                              Text("Menu de cadastros")
                            ],
                          ),
                        ),
                        if(isManager)
                          const PopupMenuItem(
                            value: 'gerenciar',
                            child: Row(
                              children: [
                                Icon(Icons.people, size: 20, color: Colors.white),
                                SizedBox(width: 10),
                                Text("Gerenciar funcionários")
                              ],
                            ),
                          ),
                      ];
                    },
                    color: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  )
                ]
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(8.0) + const EdgeInsets.only(bottom: 55),
                  child: Table(
                    children: [
                      for (var doc in categorizedStorage)
                        TableRow(
                          decoration: const BoxDecoration(
                            border: Border.symmetric(
                              horizontal: BorderSide(width: 0.3)
                            ),
                          ),
                          children: [
                            Container(
                              height: 50,
                              margin: EdgeInsets.all(2) + EdgeInsets.symmetric(vertical: 5),
                              decoration: BoxDecoration(borderRadius: BorderRadius.circular(50)),
                              child: doc['imageURL'].isEmpty
                               ? const ImageIcon(AssetImage('assets/images/box.png'))
                               : Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: pressedColors[isPressed].withOpacity(0.7),
                                  ),
                                  child: CircleAvatar(
                                      backgroundImage: NetworkImage(doc['imageURL']),
                                    ),
                                ),
                            ),
                            ConstrainedBox(
                              constraints: const BoxConstraints(
                                maxHeight: 60,
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(2)+EdgeInsets.symmetric(vertical: 5), 
                                child: Text(
                                  doc['name'], 
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold, 
                                    fontSize: 17
                                  ), 
                                  textAlign: TextAlign.start
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(2)+EdgeInsets.symmetric(vertical: 18), 
                              child: Text(
                                '${doc['dateExpiration'].toDate().difference(DateTime.now()).inDays} Dias', 
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold, 
                                  fontSize: 17
                                ), 
                                textAlign: TextAlign.center
                              ),
                            )
                          ]
                        ),
                      ],
                  )
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