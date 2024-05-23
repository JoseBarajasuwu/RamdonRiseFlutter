import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:universal_html/html.dart' as html;
import '../global.dart';

class MostrarDatosEstudio extends StatefulWidget {
  const MostrarDatosEstudio({super.key});
  static const routeMostrarDatosEstudio = 'mostrar_datos_estudio_page';
  @override
  State<MostrarDatosEstudio> createState() => _MostrarDatosEstudioState();
}

class _MostrarDatosEstudioState extends State<MostrarDatosEstudio> {
  bool loginPage = false;
  bool solicitandoHttp = false;

  String estudioID = "";
  static final header = {"Content-type": "application/json"};

  List lDatos = [];
  String? obtenerDatoDeCookie(String key) {
    final cookies =
        html.document.cookie!.split(';'); // Obtiene todas las cookies
    for (final cookie in cookies) {
      final keyValue = cookie.trim().split('=');
      final cookieKey = keyValue[0];
      final cookieValue = keyValue.length > 1 ? keyValue[1] : '';
      if (cookieKey == key) {
        estudioID = cookieValue;
        return cookieValue;
      }
    }
    return null; // Devuelve null si no se encuentra la cookie
  }

  Future<void> mostrarEstudio() async {
    if (!solicitandoHttp) {
      solicitandoHttp = true;
      setState(() {
        loginPage = true;
      });
      var baseUrl = "${Url.url}/estudio/datos-estudio";
      try {
        var jsonD = '{"EstudioID": "$estudioID"}';
        http.Response response =
            await http.post(Uri.parse(baseUrl), headers: header, body: jsonD);
        // Convertir el mapa a JSON

        // Imprimir el JSON
        // print(jsonString);
        print(jsonD);
        if (response.statusCode == 200) {
          if (response.body.isNotEmpty) {
            var jsonData = json.decode(response.body);
            setState(() {
              lDatos = jsonData;
              print(lDatos);
              loginPage = false;
            });
            solicitandoHttp = false;
          } else {
            // ignore: use_build_context_synchronously
            Navigator.pop(context);
            // ignore: use_build_context_synchronously
            Navigator.pop(context);
          }
        } else {
          solicitandoHttp = false;
          setState(() {
            loginPage = false;
          });
          showErrorDialog(
              "Error en la respuesta servidor. Por favor, inténtalo de nuevo más tarde.");
        }
      } catch (error) {
        solicitandoHttp = false;
        setState(() {
          loginPage = false;
        });
        showErrorDialog(
            "Error en servidor. Por favor, inténtalo de nuevo más tarde.");
        print(error);
      }
    }
  }

  void showErrorDialog(mensaje) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            mensaje,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          actions: <Widget>[
            Center(
              child: TextButton(
                child: const Text('Aceptar'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    obtenerDatoDeCookie("EstudioID");
    mostrarEstudio();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: loginPage == true
          ? const Center(
              child: SizedBox(
                width: 30,
                height: 30,
                child: CircularProgressIndicator(),
              ),
            )
          : Center(
              child: ListView.builder(
                itemCount: lDatos.length,
                itemBuilder: (context, index) {
                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Colors.black87, Colors.tealAccent],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.numbers,
                                  color: Colors.white,
                                  size: 30,
                                ),
                                Text(
                                  lDatos[index]["Numero"].toString(),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Text(
                                  lDatos[index]["Rojo"].toString(),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                    color: Colors.white,
                                  ),
                                ),
                                const Icon(
                                  Icons.circle,
                                  color: Colors.red,
                                  size: 30,
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Text(
                                  lDatos[index]["Negro"].toString(),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                    color: Colors.white,
                                  ),
                                ),
                                const Icon(
                                  Icons.circle,
                                  color: Colors.black,
                                  size: 30,
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Text(
                                  lDatos[index]["Verde"].toString(),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                    color: Colors.white,
                                  ),
                                ),
                                const Icon(
                                  Icons.circle,
                                  color: Colors.green,
                                  size: 30,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
