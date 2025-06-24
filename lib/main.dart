import 'package:flutter/material.dart';
import 'views/main_view.dart';

/// Punto de entrada principal de la aplicación
/// Configura el tema y llama a la vista principal
void main() {
  runApp(const MyApp());
}

/// Widget principal de la aplicación
/// Configura el tema y la vista inicial
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EduTrack',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFF07613)),
      ),
      home: const MainView(),
    );
  }
}
