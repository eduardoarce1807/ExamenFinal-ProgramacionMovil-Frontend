// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:convert';
import 'dart:io';

import 'package:examen_final/globals.dart' as globals;

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

import 'package:geolocator/geolocator.dart';

class Resumen extends StatefulWidget {
  static String ruta = "/resumen";

  @override
  State<StatefulWidget> createState() {
    return _Resumen();
  }
}

class _Resumen extends State<Resumen> {
  String rutaImagen = globals.rutaImagen;
  String imagenCargada = "";

  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    print("ruta imagen ${globals.rutaImagen}");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Resumen de la Foto"),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              children: <Widget>[
                Container(
                  alignment: Alignment.center,
                  margin:
                      EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 20),
                  width: MediaQuery.of(context).size.width * 0.8,
                  height: MediaQuery.of(context).size.height * 0.7,
                  decoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                      image: DecorationImage(
                          fit: BoxFit.cover, image: NetworkImage(rutaImagen))),
                ),
                Text(
                  "Descripción:",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(globals.descripcion),
                SizedBox(
                  height: 10,
                ),
                Text(
                  "Coordenadas de geolocalización:",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text("${globals.longitud}, ${globals.latitud}"),
                SizedBox(
                  height: 10,
                ),
                Text(
                  "Tipo de Conectividad:",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(globals.conectividad),
                SizedBox(
                  height: 30,
                ),
              ],
            ),
          ),
        ));
  }
}
