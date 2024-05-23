import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:universal_html/html.dart' as html;
import '../global.dart';

class IrEstudio extends StatefulWidget {
  const IrEstudio({super.key});
  static const routeIrEstudio = 'ir_estudio_page';
  @override
  State<IrEstudio> createState() => _IrEstudioState();
}

class _IrEstudioState extends State<IrEstudio> {
  bool loginPage = false;
  bool solicitandoHttp = false;

  String usuarioID = "";
  static final header = {"Content-type": "application/json"};

  List lEstudios = [];
  String? obtenerDatoDeCookie(String key) {
    final cookies =
        html.document.cookie!.split(';'); // Obtiene todas las cookies
    for (final cookie in cookies) {
      final keyValue = cookie.trim().split('=');
      final cookieKey = keyValue[0];
      final cookieValue = keyValue.length > 1 ? keyValue[1] : '';
      if (cookieKey == key) {
        usuarioID = cookieValue;
        return cookieValue;
      }
    }
    return null; // Devuelve null si no se encuentra la cookie
  }

  void borrarCookie() {
    const cookie = 'EstudioID=; expires=Thu, 01 Jan 1970 00:00:00 GMT; path=/';
    html.document.cookie = cookie;
  }

  void guardarDatoEnCookie(String key, String value) {
    final cookie = '$key=$value; path=/'; // Define el formato de la cookie
    html.document.cookie = cookie; // Establece la cookie en el navegador
  }

  Future<void> mostrarEstudio() async {
    if (!solicitandoHttp) {
      solicitandoHttp = true;
      setState(() {
        loginPage = true;
      });
      var baseUrl = "${Url.url}/estudio/mostrar-estudio";
      try {
        var jsonD = '{"UsuarioID": "$usuarioID"}';
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
              lEstudios = jsonData;
              loginPage = false;
            });
            print(lEstudios);
            solicitandoHttp = false;
          } else {
            // // ignore: use_build_context_synchronously
            // Navigator.pop(context);
            // // ignore: use_build_context_synchronously
            // Navigator.pop(context);
            // ignore: use_build_context_synchronously
            context.pop();
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

  void showEliminar(estudioID) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            "¿Desea eliminarlo?",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                child: const Text('Cancelar'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: const Text('Eliminar'),
                onPressed: () {
                  eliminarEstudio(estudioID);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> eliminarEstudio(estudioID) async {
    var baseUrl = "${Url.url}/estudio/eliminar-estudio";
    try {
      var jsonD = '{"EstudioID" : "$estudioID"}';
      setState(() {
        loginPage = true;
      });
      Navigator.pop(context);
      http.Response response =
          await http.post(Uri.parse(baseUrl), headers: header, body: jsonD);
      if (response.statusCode == 200) {
        var jsonData = json.decode(response.body);
        int eliminado = jsonData;
        if (eliminado == 1) {
          lEstudios.clear();
          mostrarEstudio();
        }
      }
    } catch (e) {}
  }

  void showInicioSesion() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            "Inicia sesión de nuevo, por fis.",
            style: TextStyle(fontWeight: FontWeight.bold),
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
    obtenerDatoDeCookie("UsuarioID");
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
                itemCount: lEstudios.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      borrarCookie();
                      guardarDatoEnCookie(
                          "EstudioID", "${lEstudios[index]["EstudioID"]}");
                      print(lEstudios[index]["EstudioID"]);
                      // Navigator.pushNamed(
                      //     context, 'mostrar_datos_estudio_page');
                      context.go('/mostrar_datos_estudio_page');
                    },
                    child: Card(
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
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.casino,
                                        color: Colors.white,
                                        size: 30,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        lEstudios[index]["NombreCasino"],
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                  IconButton(
                                      onPressed: () {
                                        showEliminar(
                                            lEstudios[index]["EstudioID"]);
                                      },
                                      icon: const Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                        size: 30,
                                      ))
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                lEstudios[index]["SobreNombre"],
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 18,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                lEstudios[index]["FechaRegistro"],
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
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
