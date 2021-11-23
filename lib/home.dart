// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

import 'package:connectivity/connectivity.dart';

import 'package:examen_final/globals.dart' as globals;

import 'package:geolocator/geolocator.dart';

class HomePage extends StatefulWidget {
  static String ruta = "/";

  @override
  State<StatefulWidget> createState() {
    return _HomePageState();
  }
}

class _HomePageState extends State<HomePage> {
  String rutaImagen =
      "https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png";
  String imagenCargada = "";

  String descripcion = "";

  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Examen Final - Cámara"),
      ),
      body: SingleChildScrollView(
          child: Column(
        children: <Widget>[
          Form(
              key: formKey,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(
                      height: 30,
                    ),
                    getDescripcion(),
                    SizedBox(
                      height: 15,
                    ),
                    Container(
                      alignment: Alignment.center,
                      child: ElevatedButton(
                          onPressed: () {
                            abrirSeleccionOrigen();
                          },
                          child: Text("Tomar/Seleccionar Foto")),
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    Text(
                      "Examen Final - Programación Móvil",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                        "Esta aplicación permite capturar desde la cámara o seleccionar una foto por la galería del dispositivo, enviarla al backend y recibirla con la descripción ingresada y también con la geolocalización desde donde se subió dicha imagen y con qué tipo de conectividad se envió (WiFi o Datos Móviles)."),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      "Eduardo Antonio Arce Saavedra",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    )
                  ],
                ),
              ))
        ],
      )),
    );
  }

  Future<void> abrirSeleccionOrigen() {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: SingleChildScrollView(
                child: Column(
              children: [
                TextButton(
                  style: TextButton.styleFrom(
                    primary: Colors.white,
                    backgroundColor: Colors.teal,
                    onSurface: Colors.grey,
                  ),
                  child: Text("Cámara"),
                  onPressed: () {
                    obtenerImagen(ImageSource.camera);
                  },
                ),
                Padding(padding: EdgeInsets.all(15)),
                TextButton(
                  style: TextButton.styleFrom(
                    primary: Colors.white,
                    backgroundColor: Colors.teal,
                    onSurface: Colors.grey,
                  ),
                  child: Text("Galería"),
                  onPressed: () {
                    obtenerImagen(ImageSource.gallery);
                  },
                ),
              ],
            )),
          );
        });
  }

  void obtenerImagen(ImageSource source) async {
    File image;

    var picture = await ImagePicker.platform.pickImage(source: source);

    if (picture != null) {
      image = File(picture.path);

      ImageResponse ir = await subirImagen(image, descripcion);

      this.imagenCargada = ir.fileUploaded;

      //VERIFICACION DE TIPO DE CONECTIVIDAD
      var result = await Connectivity().checkConnectivity();
      print("INTERNET COMO: $result");
      if (result == ConnectivityResult.wifi) {
        globals.conectividad = "WiFi";
      } else if (result == ConnectivityResult.mobile) {
        globals.conectividad = "Datos Móviles";
      }

      if (imagenCargada != '') {
        setState(() {
          this.rutaImagen = "http://10.0.2.2:8282/image/" + imagenCargada;
          globals.rutaImagen = "http://10.0.2.2:8282/image/" + imagenCargada;

          this.imagenCargada = '';

          Navigator.pushNamed(context, '/resumen');
        });
      }
    }
  }

  Future<ImageResponse> subirImagen(File image, String desc) async {
    var request =
        http.MultipartRequest("POST", Uri.parse("http://10.0.2.2:8282/image"));

    var picture = await http.MultipartFile.fromPath("imagen", image.path);

    request.files.add(picture);

    Position position = await obtenerPosicionGeografica();

    request.fields["descripcion"] = desc;
    request.fields["longitud"] = position.longitude.toString();
    request.fields["latitud"] = position.latitude.toString();
    request.fields["altitud"] = position.altitude.toString();

    globals.descripcion = desc;
    globals.longitud = position.longitude.toString();
    globals.latitud = position.latitude.toString();
    globals.altitud = position.altitude.toString();

    var response = await request.send();

    var responseData = await response.stream.toBytes();

    String rawResponse = utf8.decode(responseData);

    var jsonResponse = jsonDecode(rawResponse);

    print(rawResponse);

    ImageResponse ir = ImageResponse(jsonResponse);

    return ir;
  }

  Future<Position> obtenerPosicionGeografica() async {
    bool servicioHabilidado = await Geolocator.isLocationServiceEnabled();
    //GPS esta encendido

    if (servicioHabilidado) {
      LocationPermission permisos = await Geolocator.checkPermission();

      if (permisos == LocationPermission.denied ||
          permisos == LocationPermission.deniedForever) {
        permisos = await Geolocator.requestPermission();
      }

      if (permisos == LocationPermission.whileInUse ||
          permisos == LocationPermission.always) {
        Position position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.bestForNavigation);
        return position;
      }
    }

    return Position(
        longitude: 0,
        latitude: 0,
        timestamp: DateTime.now(),
        accuracy: 0,
        altitude: 0,
        heading: 0,
        speed: 0,
        speedAccuracy: 0);
  }

  TextFormField getDescripcion() {
    return TextFormField(
      keyboardType: TextInputType.text,
      decoration: InputDecoration(
        labelStyle: TextStyle(fontWeight: FontWeight.w500),
        border: OutlineInputBorder(
          borderSide:
              BorderSide(color: Color.fromRGBO(49, 39, 79, 1), width: 2.0),
        ),
        labelText: 'Descripción',
        hintText: "Agregue una descripción",
        hintStyle: TextStyle(color: Colors.grey),
      ),
      onChanged: (String? newValue) {
        setState(() {
          descripcion = newValue!;
        });
      },
    );
  }
}

class ImageResponse {
  String fileUploaded = '';

  ImageResponse(Map jsonResponse) {
    this.fileUploaded = jsonResponse["fileUploaded"];
  }
}
