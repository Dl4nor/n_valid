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
  bool isLoading = true;
  Timestamp timestampYesterday = Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 1)));
  PageController? _pageController;
  Map<String, List<DocumentSnapshot>>? categorizedStorage;
  Map<String, List<DocumentSnapshot>>? filteredStorage;
  DocumentSnapshot<Object?>? storeData;
  DocumentSnapshot<Object?>? userData;
  String storeCNPJ = AppController.controllerCNPJ!;
  String storeName = AppController.controllerStoreName!;
  File? productImage;
  Map<String, dynamic> product = {};
  FocusNode searchFocusNode = FocusNode(); 

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    loadCategories();
    loadStoreData();
    loadUserData();
  }

  void loadMap() {
    productImage = null;
    product = {
      'CNPJ': storeCNPJ,
      'amount': 0,
      'barcode': '',
      'dateEntry': Timestamp.now(),
      'dateExpiration': timestampYesterday,
      'imageURL': '',
      'isBatch': false,
      'name': ''
    };
  }

  void updatePressed(int index) {
    setState(() {
      for (int i = 0; i < pressed.length; i++) {
        pressed[i] = false;
      }
      pressed[index] = true;
      isPressed = index;
      
      _pageController!.animateToPage(
        index,  
        duration: Durations.short2,
        curve: Curves.easeInOut
      );
    });
  }

  void loadCategories() async {
    categorizedStorage = await AppController.instance.defineCategory();
    setState(() {
      filteredStorage = categorizedStorage;
      isLoading = false;
    });
  }

  void loadStoreData() async{
    storeData = await AppController.instance.loadStoreData();
    setState(() {
      storeData = storeData;
    });
  }

  void loadUserData() async{
    userData = await AppController.instance.loadUserData();
    setState(() {
      userData = userData;
    });
  }

  void filterCategory(String text){
    setState(() {
      if(text.isEmpty){
        filteredStorage = {
          for(String category in categorizedStorage!.keys)
            category: List.from(categorizedStorage![category]!)
        };
      } else{
        filteredStorage = {
          for(String category in categorizedStorage!.keys)
            category: categorizedStorage![category]!.where((item){
              final productName = item['name'].toString().toLowerCase();
              return productName.contains(text.toLowerCase());
            }).toList()
        };
      }
    });
  }

  void pickImage(Function setStateDialog) async {
    final File? image = await AppController.instance.pickImage(context);
    if (image != null) {
      await setStateDialog(() {
        productImage = image;
      });
    }
  }

  Map<String, String> validateProduct() {
    Map<String, String> errorMap = {};
    if(product['barcode'].isEmpty){
      errorMap['barcode'] = 'Cadastre um código de barras';
    }
    if(product['name'].isEmpty){
      errorMap['name'] = 'Cadastre um nome';
    }
    if(product['dateExpiration'] == timestampYesterday){
      errorMap['dateExpiration'] = 'Insira uma data de validade';
    }
    return errorMap;
  }

  uploadStorageData() async{
    if(product['amount'] < 1 || !product['isBatch']){
      product['amount'] = 1;
    }
    if(productImage != null){
      final newProduct = await FirebaseFirestore.instance.collection('Storage').add(product);
      final storageRef = FirebaseStorage.instance.ref().child('/Stores/$storeCNPJ/goods_images/${newProduct.id}.jpg');
      await storageRef.putFile(productImage!);
      product['imageURL'] = await storageRef.getDownloadURL();

      FirebaseFirestore.instance.collection('Storage').doc(newProduct.id).update(
        {
          'imageURL': product['imageURL']
        }
      );

      FirebaseFirestore.instance.collection('Stores').doc('$storeName$storeCNPJ').update(
        {
          'storage': FieldValue.arrayUnion([newProduct.id])
        }
      );
    } 
    else {
      await FirebaseFirestore.instance.collection('Storage').add(product);
    }
  }

  bool updateCheckBox(isBatch){
    return !isBatch;
  }

  Widget dialogBoxGoodsRegistration(){
    String entryDateText = "${DateTime.now().day.toString().padLeft(2, '0')} / "
                           "${DateTime.now().month.toString().padLeft(2, '0')} / "
                           "${DateTime.now().year}";                   
    String expirationDateText = "dd / mm / yyyy";
    Map<String, String> errorMap = {};
    TextEditingController barcodeController = TextEditingController();
    loadMap();
    barcodeController.text = product['barcode'];

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
                  child: productImage == null
                  ? const Icon(
                      Icons.add_photo_alternate, 
                      size: 60, 
                      color: Color.fromARGB(255, 102, 102, 102)
                    )
                  : CircleAvatar(
                    radius: 100,
                    backgroundImage: FileImage(productImage!),
                    backgroundColor: const Color.fromARGB(255, 54, 119, 56),
                  )
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: barcodeController,
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.symmetric(horizontal: 10),
                  border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(50))),
                  labelText: "Código do produto",
                  suffixIcon: IconButton(
                    icon: Icon(Icons.camera_alt_outlined),
                    onPressed: () async{
                      product['barcode'] = await AppController.instance.OpenScanner(context);
                      barcodeController.text = product['barcode'];
                    },
                  )
                ),
                onChanged: (text){
                  product['barcode'] = text;
                  barcodeController.text = text;
                },
              ),
              Text(errorMap['barcode'] ?? '', style: TextStyle(color: Colors.red)),
              SizedBox(height: 10),
              TextField(
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.symmetric(horizontal: 10),
                  border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(50))),
                  labelText: "Nome do produto"
                ),
                onChanged: (text) {
                  product['name'] = text;
                },
              ),
              Text(errorMap['name'] ?? '', style: TextStyle(color: Colors.red)),
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
                            entryDateText = 
                              "${selectedDate.day.toString().padLeft(2, '0')} / "
                              "${selectedDate.month.toString().padLeft(2, '0')} / "
                              "${selectedDate.year}";
                            product['dateEntry'] = Timestamp.fromDate(selectedDate);
                          });
                        }
                      });
                    }, 
                    child: Text(entryDateText)
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
                            expirationDateText =
                              "${selectedDate.day.toString().padLeft(2, '0')} / "
                              "${selectedDate.month.toString().padLeft(2, '0')} / "
                              "${selectedDate.year}"; 
                            product['dateExpiration'] = Timestamp.fromDate(selectedDate);
                          });
                        }
                      });
                    }, 
                    child: Text(expirationDateText)
                  )
                ],
              ),
              Text(errorMap['dateExpiration'] ?? '', style: TextStyle(color: Colors.red)),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Checkbox(
                    activeColor: Colors.green,
                    value: product['isBatch'],
                    onChanged: (x) {
                      setStateDialog((){
                        product['isBatch'] = updateCheckBox(product['isBatch']);
                      });
                    }
                  ),
                  Text('É um Lote?')
                ],
              ),
              
              if(product['isBatch']) ...[
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
                    product['amount'] = int.tryParse(text);
                  },
                ),
              ],
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: (){
                  errorMap = validateProduct();
                  if(errorMap.isEmpty){
                    uploadStorageData();
                    loadCategories();
                    Navigator.of(context, rootNavigator: true).pop();
                  } else{
                    setStateDialog((){});
                  }
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
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return dialogBoxGoodsRegistration();
                  }
                );
              },
            ),
          ),
        ],
      ),
    );
  }



  @override
  Widget build(BuildContext context){
    if(isLoading){
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      drawer: const OurDrawer(),
      appBar: OurAppBar(
        textTitle: 'Estoque',
        sizeTitle: 24,
        textSubtitle: '$storeName - ${storeCNPJ.substring(8, 12)}',
        sizeSubtitle: 12,
        backgroundColor: pressedColors[isPressed].withOpacity(0.6),
      ),
      body: Stack(
        children: [
          Container(
            height: MediaQuery.sizeOf(context).height,
            color: pressedColors[isPressed].withOpacity(0.3),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: GestureDetector(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Expanded(
                    child: Card(
                      shape: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20), 
                        borderSide: const BorderSide(
                          color: Colors.transparent,
                        )
                      ), 
                      child: TextField(
                        focusNode: searchFocusNode,
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
                          filterCategory(text);
                        },
                        onTapOutside: (event){
                          searchFocusNode.unfocus();
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
                        if(storeData?['managers'].contains(userData?['userName']))
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
          ),
          Container(
            padding: EdgeInsets.only(top: 70, bottom: 60),
            child: PageView(
              controller: _pageController,
              onPageChanged: (int index) {
                setState(() {
                  updatePressed(index);
                });
              },
              children: [
                PageCategory(pressedColors: pressedColors, isPressed: 0, categorizedStorage: filteredStorage?['danger'] ?? []),
                PageCategory(pressedColors: pressedColors, isPressed: 1, categorizedStorage: filteredStorage?['caution'] ?? []),
                PageCategory(pressedColors: pressedColors, isPressed: 2, categorizedStorage: filteredStorage?['fine'] ?? [])
              ],
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Card(
                margin: const EdgeInsets.all(0),
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
    return Stack(
      children: [
        Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      // for(int i=0;i<20;i++)
                      // Container(
                      //   padding: EdgeInsets.symmetric(horizontal: 15),
                      //     decoration: const BoxDecoration(
                      //       border: Border.symmetric(
                      //         horizontal: BorderSide(width: 0.3)
                      //       ),
                      //     ),
                      //     child: Row(
                      //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      //       children: [
                      //         Container(
                      //           height: 50,
                      //           width: 50,
                      //           decoration: BoxDecoration(borderRadius: BorderRadius.circular(50)),
                      //           child: const ImageIcon(AssetImage('assets/images/box.png'))
                      //         ),
                      //         ConstrainedBox(
                      //           constraints: const BoxConstraints(
                      //             maxHeight: 60,
                      //             maxWidth: 180,
                      //           ),
                      //           child: Padding(
                      //             padding: EdgeInsets.all(2)+EdgeInsets.symmetric(vertical: 5), 
                      //             child: Text(
                      //               'SADASDdaals', 
                      //               style: const TextStyle(
                      //                 fontWeight: FontWeight.bold, 
                      //                 fontSize: 17
                      //               ), 
                      //               textAlign: TextAlign.start
                      //             ),
                      //           ),
                      //         ),
                      //         Padding(
                      //           padding: EdgeInsets.all(2)+EdgeInsets.symmetric(vertical: 18), 
                      //           child: Text(
                      //             '500 Dias', 
                      //             style: const TextStyle(
                      //               fontWeight: FontWeight.bold, 
                      //               fontSize: 17
                      //             ), 
                      //             textAlign: TextAlign.center
                      //           ),
                      //         )
                      //       ]
                      //     ),
                      //   ),
                      for (var doc in categorizedStorage)
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 15),
                          decoration: const BoxDecoration(
                            border: Border.symmetric(
                              horizontal: BorderSide(width: 0.3)
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                height: 50,
                                width: 50,
                                margin: EdgeInsets.symmetric(vertical: 5),
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
                                      backgroundColor: const Color.fromARGB(178, 76, 175, 79),
                                      backgroundImage: NetworkImage(doc['imageURL']),
                                    ),
                                  ),
                              ),
                              ConstrainedBox(
                                constraints: const BoxConstraints(
                                  maxHeight: 60,
                                  maxWidth: 180,
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