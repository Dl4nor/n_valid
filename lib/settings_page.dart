import 'package:flutter/material.dart';
import 'package:deepl_dart/deepl_dart.dart';
import 'package:provider/provider.dart';
import 'language_provider.dart'; // Importa o LanguageProvider

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final Map<String, String> languageCodes = {
    'Português': 'pt',
    'Espanhol': 'es',
    'Inglês': 'en',
  };

  // Substitua pela sua chave de autenticação da DeepL
  final String authKey = '<75f11077-1f04-40c2-812d-e9fa3651b4ea:fx>';
  late Translator translator;

  @override
  void initState() {
    super.initState();
    translator = Translator(authKey: authKey);
  }

  void onLanguageChanged(String? value) {
    if (value != null) {
      // Atualiza o idioma no LanguageProvider
      Provider.of<LanguageProvider>(context, listen: false).changeLanguage(languageCodes[value]!);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Obtém o idioma atual do LanguageProvider
    String currentLanguage = Provider.of<LanguageProvider>(context).selectedLanguage;

    return Scaffold(
      appBar: AppBar(
        title: Text(getAppBarTitle(currentLanguage)), // Usando título traduzido
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0), // Corrigido o padding
        child: Column(
          children: [
            Text(getChooseLanguageText(currentLanguage), style: TextStyle(fontSize: 18)), // Usando texto traduzido
            DropdownButton<String>(
              value: getLanguageName(currentLanguage), // Corrigido para usar o nome do idioma
              items: languageCodes.keys.map((String lang) {
                return DropdownMenuItem<String>(
                  value: lang,
                  child: Text(getTranslatedLanguageName(lang)), // Usando texto traduzido para as opções
                );
              }).toList(),
              onChanged: onLanguageChanged,
            ),
          ],
        ),
      ),
    );
  }

  String getAppBarTitle(String code) {
    switch (code) {
      case 'pt':
        return 'Configurações de Idioma';
      case 'es':
        return 'Configuración del Idioma';
      case 'en':
      default:
        return 'Language Settings';
    }
  }

  String getChooseLanguageText(String code) {
    switch (code) {
      case 'pt':
        return 'Escolha o idioma:';
      case 'es':
        return 'Elige el idioma:';
      case 'en':
      default:
        return 'Choose the language:';
    }
  }

  String getTranslatedLanguageName(String lang) {
    switch (lang) {
      case 'Português':
        return Provider.of<LanguageProvider>(context).selectedLanguage == 'pt' ? 'Português' : 
               Provider.of<LanguageProvider>(context).selectedLanguage == 'es' ? 'Portugués' : 
               'Portuguese'; // Exemplo de tradução
      case 'Espanhol':
        return Provider.of<LanguageProvider>(context).selectedLanguage == 'pt' ? 'Espanhol' : 
               Provider.of<LanguageProvider>(context).selectedLanguage == 'es' ? 'Español' : 
               'Spanish'; // Exemplo de tradução
      case 'Inglês':
        return Provider.of<LanguageProvider>(context).selectedLanguage == 'pt' ? 'Inglês' : 
               Provider.of<LanguageProvider>(context).selectedLanguage == 'es' ? 'Inglés' : 
               'English'; // Exemplo de tradução
      default:
        return lang; // Retorna o nome original se não houver tradução
    }
  }

  String getLanguageName(String code) {
    return languageCodes.entries.firstWhere((entry) => entry.value == code).key;
  }
}
