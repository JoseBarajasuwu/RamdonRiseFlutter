import 'dart:convert';
// import 'dart:js_interop';
// import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import '../global.dart';
import 'package:universal_html/html.dart' as html;
// import 'dart:html' as html2;
import 'package:flutter_excel/excel.dart';
import 'package:file_picker/file_picker.dart';

class CrearEstudio extends StatefulWidget {
  const CrearEstudio({super.key});
  static const routeCrearEstudio = 'crear_estudio_page';
  @override
  State<CrearEstudio> createState() => _CrearEstudioState();
}

class _CrearEstudioState extends State<CrearEstudio> {
  static final header = {"Content-type": "application/json"};
  final fromEstudio = GlobalKey<FormState>();
  bool loginPage = false;
  bool faltaArchivo = false;
  bool solicitandoHttp = false;
  String nombre = "";
  String sobreNombre = "";
  String _currentTime = '';
  String usuarioID = "";
  Map<int, String> rouletteColors = {
    0: 'Green',
    1: 'Red',
    2: 'Black',
    3: 'Red',
    4: 'Black',
    5: 'Red',
    6: 'Black',
    7: 'Red',
    8: 'Black',
    9: 'Red',
    10: 'Black',
    11: 'Black',
    12: 'Red',
    13: 'Black',
    14: 'Red',
    15: 'Black',
    16: 'Red',
    17: 'Black',
    18: 'Red',
    19: 'Red',
    20: 'Black',
    21: 'Red',
    22: 'Black',
    23: 'Red',
    24: 'Black',
    25: 'Red',
    26: 'Black',
    27: 'Red',
    28: 'Black',
    29: 'Black',
    30: 'Red',
    31: 'Black',
    32: 'Red',
    33: 'Black',
    34: 'Red',
    35: 'Black',
    36: 'Red',
  };
  List<int> numbers = [];
  Map<int, Map<String, int>> colorFrequency = {};

  TextEditingController nombreController = TextEditingController();
  TextEditingController sobreNombreController = TextEditingController();

  void _getCurrentTime() {
    final DateTime now = DateTime.now();
    final String formattedTime = _formatDateTime(now);
    setState(() {
      _currentTime = formattedTime;
    });
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}-${dateTime.month}-${dateTime.year} ${dateTime.hour}:${dateTime.minute}:${dateTime.second}';
  }

  String? fileName;

  void _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
    );

    if (result != null) {
      try {
        PlatformFile file = result.files.first;
        Uint8List? bytes = file.bytes;
        // var xd = file.path;
        // var bytes = File(xd!).readAsBytesSync();
        var excel = Excel.decodeBytes(bytes!);

        for (var table in excel.tables.keys) {
          print(table); //sheet Name
          print(excel.tables[table]!.maxCols);
          print(excel.tables[table]!.maxRows);
          for (var row in excel.tables[table]!.rows) {
            if (row[0]?.value != null) {
              int numeros = row[0]!.value;
              numbers.add(numeros);
            }
          }
        }
        setState(() {
          fileName = file.name;
          faltaArchivo = false;
        });
        generarMap();
      } catch (e) {
        print(e);
      }
    }
  }

  void generarMap() {
    // Mapa para contar la frecuencia de colores que siguen a cada número

    // Inicializar el mapa de frecuencias
    for (int i = 0; i <= 36; i++) {
      colorFrequency[i] = {"Numero": i, "Red": 0, "Black": 0, "Green": 0};
    }

    // Contar la frecuencia de colores que siguen a cada número en la lista
    for (int i = 0; i < numbers.length - 1; i++) {
      int currentNumber = numbers[i];
      int nextNumber = numbers[i + 1];
      String nextColor = rouletteColors[nextNumber] ?? 'Unknown';

      if (nextColor != 'Unknown') {
        colorFrequency[currentNumber]![nextColor] =
            (colorFrequency[currentNumber]![nextColor] ?? 0) + 1;
      }
    }

    // Lista para guardar los porcentajes
    // Map<int, Map<String, double>> colorPercentages = {};

    // Calcular los porcentajes
    // colorFrequency.forEach((number, colorCounts) {
    //   int total =
    //       colorCounts['Red']! + colorCounts['Black']! + colorCounts['Green']!;
    //   double redPercentage =
    //       total > 0 ? (colorCounts['Red']! / total) * 100 : 0.0;
    //   double blackPercentage =
    //       total > 0 ? (colorCounts['Black']! / total) * 100 : 0.0;
    //   double greenPercentage =
    //       total > 0 ? (colorCounts['Green']! / total) * 100 : 0.0;

    //   colorPercentages[number] = {
    //     'Red': redPercentage,
    //     'Black': blackPercentage,
    //     'Green': greenPercentage
    //   };
    // });

    // Imprimir las frecuencias
    print('Frecuencias:');
    // colorFrequency.forEach((number, colorCounts) {
    //   print(
    //       'Número $number: ${colorCounts['Red']} Red, ${colorCounts['Black']} Black, ${colorCounts['Green']} Green');
    // });

    // // Imprimir los porcentajes
    // print('\nPorcentajes:');
    // colorPercentages.forEach((number, percentages) {
    //   print(
    //       'Número $number: ${percentages['Red']!.toStringAsFixed(2)}% Red, ${percentages['Black']!.toStringAsFixed(2)}% Black, ${percentages['Green']!.toStringAsFixed(2)}% Green');
    // });
  }

  void borrarCookie() {
    const cookie = 'EstudioID=; expires=Thu, 01 Jan 1970 00:00:00 GMT; path=/';
    html.document.cookie = cookie;
  }

  void guardarDatoEnCookie(String key, String value) {
    final cookie = '$key=$value; path=/'; // Define el formato de la cookie
    html.document.cookie = cookie; // Establece la cookie en el navegador
  }

  Future<void> crearEstudio(String nombre, String sobreNombre) async {
    if (fromEstudio.currentState!.validate() && colorFrequency.isNotEmpty) {
      if (!solicitandoHttp) {
        solicitandoHttp = true;
        setState(() {
          loginPage = true;
        });

        var baseUrl = "${Url.url}/estudio/crear-estudio";
        try {
          _getCurrentTime();
          String jsonString = json.encode("$colorFrequency");
          var jsonD =
              '{"UsuarioID": "$usuarioID","NombreCasino": "$nombre","SobreNombre":"$sobreNombre","FechaRegistro":"$_currentTime", "Numeros" : $jsonString}';
          http.Response response =
              await http.post(Uri.parse(baseUrl), headers: header, body: jsonD);
          // Convertir el mapa a JSON

          // Imprimir el JSON
          // print(jsonString);
          print(jsonD);
          if (response.statusCode == 200) {
            var jsonData = json.decode(response.body);
            String estudioID = "${jsonData["EstudioID"]}";
            if (estudioID != "0") {
              borrarCookie();
              guardarDatoEnCookie("EstudioID", estudioID);
              setState(() {
                solicitandoHttp = false;
              });
              // guardarDatoEnCookie("UsuarioID", usuarioID);
              // ignore: use_build_context_synchronously
              // Navigator.pushNamed(context, 'ir_estudio_page');
              // ignore: use_build_context_synchronously
              context.go('/ir_estudio_page');
            } else {
              solicitandoHttp = false;
              setState(() {
                loginPage = false;
              });
              showErrorDialog("Faltaron datos por enviar.");
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
      } else if (colorFrequency.isEmpty) {
        solicitandoHttp = false;
        setState(() {
          faltaArchivo = true;
        });
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

  @override
  void initState() {
    obtenerDatoDeCookie("UsuarioID");
    super.initState();
  }

  @override
  void dispose() {
    nombreController.dispose();
    sobreNombreController.dispose();
    super.dispose();
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
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 80, 10, 0),
                child: Center(
                  child: Form(
                    key: fromEstudio,
                    child: Column(
                      // crossAxisAlignment: CrossAxisAlignment.stretch,
                      // mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 200,
                          child: TextFormField(
                            controller: nombreController,
                            inputFormatters: [
                              FilteringTextInputFormatter.deny(
                                  RegExp(r'[|!"${}()%&\\//=?¿¡+*-]')),
                              UpperCaseTextFormatter()
                            ],
                            onFieldSubmitted: (value) {
                              crearEstudio(nombre, sobreNombre);
                            },
                            onChanged: (value) {
                              nombre = value;
                            },
                            decoration: const InputDecoration(
                              labelText: 'Nombre del casino',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              String valor = value!.trim();
                              if (valor.isEmpty) {
                                return 'Por favor, ingrese nombre del casino';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(height: 16.0),
                        SizedBox(
                          width: 200,
                          child: TextFormField(
                            controller: sobreNombreController,
                            onFieldSubmitted: (value) {
                              crearEstudio(nombre, sobreNombre);
                            },
                            inputFormatters: [
                              FilteringTextInputFormatter.deny(
                                  RegExp(r'[|!"${}()%&\\//=?¿¡+*-]')),
                              UpperCaseTextFormatter()
                            ],
                            onChanged: (value) {
                              sobreNombre = value;
                            },
                            decoration: const InputDecoration(
                              labelText: 'Apodo del estudio',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              String valor = value!.trim();
                              if (valor.isEmpty) {
                                return 'Por favor, ingrese sobre nombre';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(height: 16.0),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                vertical: 16.0, horizontal: 24.0),
                            shadowColor: Colors.black,
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            textStyle: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          onPressed: _pickFile,
                          child: const Text('Seleccionar Archivo'),
                        ),
                        const SizedBox(height: 8.0),
                        if (fileName != null)
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              'Archivo seleccionado: $fileName',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color.fromARGB(255, 0, 90, 194),
                              ),
                            ),
                          ),
                        if (faltaArchivo == true)
                          const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              'Falta de subir el archivo',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                            ),
                          ),
                        const SizedBox(height: 8.0),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                vertical: 16.0, horizontal: 24.0),
                            shadowColor: Colors.black,
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            textStyle: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          onPressed: () => {crearEstudio(nombre, sobreNombre)},
                          child: const Text("Crear"),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
