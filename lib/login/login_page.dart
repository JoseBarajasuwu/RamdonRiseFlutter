import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';
import 'package:universal_html/html.dart' as html;

import '../global.dart';

class Login extends StatefulWidget {
  const Login({super.key});
  // static const routeLogin = 'login_page';
  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  static final header = {"Content-type": "application/json"};
  bool _obscureText = true;
  bool loginPage = false;
  Color colorOriginalIcon = Colors.black12;
  TextEditingController usuarioController = TextEditingController();
  String usuario = "";
  TextEditingController contraController = TextEditingController();
  String contra = "";
  void guardarDatoEnCookie(String key, String value) {
    final cookie = '$key=$value; path=/'; // Define el formato de la cookie
    html.document.cookie = cookie; // Establece la cookie en el navegador
  }

  void borrarCookie() {
    const cookie = 'UsuarioID=; expires=Thu, 01 Jan 1970 00:00:00 GMT; path=/';
    html.document.cookie = cookie;
  }

  Future<void> login(String usuario, String contrasenia) async {
    setState(() {
      loginPage = true;
    });
    var baseUrl = "${Url.url}/login";
    try {
      var jsonD = '{"NombreUs":"$usuario","Pass": "$contrasenia"}';
      http.Response response =
          await http.post(Uri.parse(baseUrl), headers: header, body: jsonD);

      if (response.statusCode == 200) {
        var jsonData = json.decode(response.body);
        String usuarioID = "${jsonData[0]["UsuarioID"]}";
        if (usuarioID != "0") {
          guardarDatoEnCookie("UsuarioID", usuarioID);
          // ignore: use_build_context_synchronously
          context.go('/home_page');
        } else {
          setState(() {
            loginPage = false;
          });
          showErrorDialog("Usuario o contraseña mal");
        }
      } else {
        setState(() {
          loginPage = false;
        });
        showErrorDialog(
            "Error en la respuesta servidor. Por favor, inténtalo de nuevo más tarde.");
      }
    } catch (error) {
      setState(() {
        loginPage = false;
      });
      showErrorDialog(
          "Error en servidor. Por favor, inténtalo de nuevo más tarde.");
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
    // borrarCookie();
    super.initState();
  }

  @override
  void dispose() {
    usuarioController.dispose();
    contraController.dispose();
    super.dispose();
  }

  String _calculateSHA1Hash(String input) {
    if (input.isEmpty) {
      return '';
    } else {
      return sha1.convert(utf8.encode(input)).toString();
    }
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
                  child: Column(
                    // crossAxisAlignment: CrossAxisAlignment.stretch,
                    // mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 170,
                        child: TextFormField(
                          controller: usuarioController,
                          inputFormatters: [
                            FilteringTextInputFormatter.deny(
                                RegExp(r'[|!"${}()%&\\//=?¿¡+*-]')),
                            UpperCaseTextFormatter()
                          ],
                          onChanged: (value) {
                            usuario = value;
                          },
                          decoration: const InputDecoration(
                            labelText: 'Usuario',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      SizedBox(
                        width: 170,
                        child: TextFormField(
                          controller: contraController,
                          onChanged: (value) {
                            setState(() {
                              contra = _calculateSHA1Hash(value);
                            });
                          },
                          inputFormatters: [
                            FilteringTextInputFormatter.deny(
                                RegExp(r'[|!"{}%\\=?¿¡]')),
                          ],
                          onFieldSubmitted: (value) => {login(usuario, contra)},
                          decoration: InputDecoration(
                            labelText: 'Contraseña',
                            border: const OutlineInputBorder(),
                            suffixIcon: GestureDetector(
                              onTap: () {
                                Color colorIcono = Colors.black26;
                                setState(() {
                                  _obscureText = !_obscureText;
                                  if (_obscureText == true) {
                                    colorOriginalIcon = colorIcono;
                                  } else {
                                    colorOriginalIcon = Colors.black87;
                                  }
                                });
                              },
                              child: Icon(
                                _obscureText
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: colorOriginalIcon,
                              ),
                            ),
                          ),
                          obscureText: _obscureText,
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      // ElevatedButton(
                      //   onPressed: () => {login(usuario, contra)},
                      //   child: const Text("Entrar"),
                      // ),
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
                        onPressed: () => {login(usuario, contra)},
                        child: const Text('Entrar'),
                      )
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
