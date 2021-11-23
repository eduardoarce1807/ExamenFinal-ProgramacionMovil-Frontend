// ignore_for_file: prefer_const_constructors

import 'package:examen_final/resumen.dart';
import 'package:flutter/material.dart';
import 'package:examen_final/home.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Examen Final',
        darkTheme: ThemeData(
          brightness: Brightness.dark,
        ),
        themeMode: ThemeMode.dark,
        debugShowCheckedModeBanner: false,
        routes: {
          HomePage.ruta: (BuildContext context) => HomePage(),
          Resumen.ruta: (BuildContext context) => Resumen(),
        });
  }
}
