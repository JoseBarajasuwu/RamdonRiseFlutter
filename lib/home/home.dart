import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// void borrarCookie(String key) {
//   final cookie = '$key=; expires=Thu, 01 Jan 1970 00:00:00 GMT; path=/';
//   html.document.cookie = cookie;
// }

class Home extends StatefulWidget {
  const Home({super.key});
  static const routeHome = 'home_page';
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int counter = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 70, 10, 0),
          child: Center(
            child: Column(
              children: [
                SizedBox(
                    width: 210,
                    child: ElevatedButton(
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
                        onPressed: () {
                          // Navigator.pushNamed(context, 'crear_estudio_page');
                          context.go('/crear_estudio_page');
                        },
                        child: const Text("Crear nuevo estudio"))),
                const SizedBox(height: 16),
                SizedBox(
                    width: 210,
                    child: ElevatedButton(
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
                        onPressed: () {
                          context.go('/ir_estudio_page');
                          // Navigator.pushNamed(context, 'ir_estudio_page');
                        },
                        child: const Text("Ir a un estudio"))),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
