import 'package:flutter/material.dart';
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

  String today = "${DateTime.now().day} / ${DateTime.now().month} / ${DateTime.now().year}";
  DateTime todayDate = DateTime.now();
  String expiration = "DD / MM / AAAA";
  int dias = 0;
  late DateTime? expirationDate;
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
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return StatefulBuilder(builder: (context, setStateDialog){
              return AlertDialog(
                title: const Text("Cadastro de Produtos"),
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
              }
              );
              }
          );
        }, 
        child: const Icon(Icons.add_shopping_cart)
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
    return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    color: pressedColors[isPressed].withOpacity(0.3),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Table(
                        children: [
                          for (int i=0;i<10;i++)
                          TableRow(
                            decoration: const BoxDecoration(border: Border.symmetric(horizontal: BorderSide(width: 0.3))),
                            children: [
                            Container(
                              height: 40,
                              decoration: BoxDecoration(borderRadius: BorderRadius.circular(50)),
                              child: const ImageIcon(AssetImage("../assets/images/box.png")),
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