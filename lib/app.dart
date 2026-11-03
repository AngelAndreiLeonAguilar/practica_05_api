import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'pages/home_shell.dart';

/// Aplicación de la Práctica 5: consumo de API REST y procesamiento JSON.
class Practica05App extends StatelessWidget {
  const Practica05App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Práctica 05 · API REST',
      debugShowCheckedModeBanner: false,
      // Toda la interfaz se muestra en español, incluidos los textos que
      // proporcionan los widgets de Material (tooltips, menús, selector de
      // fechas, etiquetas de accesibilidad, etc.).
      locale: const Locale('es', 'MX'),
      supportedLocales: const [Locale('es', 'MX'), Locale('es')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0B6E4F)),
        useMaterial3: true,
      ),
      home: const HomeShell(),
    );
  }
}
