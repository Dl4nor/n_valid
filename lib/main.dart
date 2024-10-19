import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'language_provider.dart'; // Importa o LanguageProvider
import 'app_widget.dart'; // Importa sua AppWidget
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

Future<void> main() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    DevicePreview(
      enabled: true, // Ativa o Device Preview
      builder: (context) => ChangeNotifierProvider(
        create: (context) => LanguageProvider(),
        child: const MyApp(), // Chama a classe MyApp
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Validad',
      home: AppWidget(), // Aqui você pode apontar para a sua página inicial
      // Adicione outras configurações, como rotas, se necessário
    );
  }
}
