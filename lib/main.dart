import 'package:flutter/material.dart';
import 'package:ramdon_rise/crear_estudio.dart/crear_estudio.dart';
import 'package:ramdon_rise/ir_estudio.dart/ir_estudio.dart';
import 'package:ramdon_rise/ir_estudio.dart/mostrar_datos_estudio.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:go_router/go_router.dart';
import 'home/home.dart';
import 'login/login_page.dart';

void main() {
  setUrlStrategy(PathUrlStrategy());
  runApp(const MyApp());
}

final GoRouter _router = GoRouter(
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      builder: (context, state) => const Login(),
    ),
    GoRoute(
      path: '/home_page',
      builder: (context, state) => const Home(),
    ),
    GoRoute(
      path: '/crear_estudio_page',
      builder: (context, state) => const CrearEstudio(),
    ),
    GoRoute(
      path: '/ir_estudio_page',
      builder: (context, state) => const IrEstudio(),
    ),
    GoRoute(
      path: '/mostrar_datos_estudio_page',
      builder: (context, state) => const MostrarDatosEstudio(),
    ),
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: _router,
      title: 'Ramdon Rise',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
        useMaterial3: true,
      ),
      // home: const Login(),
      // routes: {
      //   Home.routeHome: (_) => const Home(),
      //   CrearEstudio.routeCrearEstudio: (_) => const CrearEstudio(),
      //   IrEstudio.routeIrEstudio: (_) => const IrEstudio(),
      //   MostrarDatosEstudio.routeMostrarDatosEstudio: (context) =>
      //       const MostrarDatosEstudio()
      // },
    );
  }
}
