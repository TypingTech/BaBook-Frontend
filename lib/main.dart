import 'package:flutter/material.dart';
import 'package:babook_front_end/routes/app_routes.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'BaBook',
      initialRoute: AppRoutes.awal,
      routes: AppRoutes.routes,
    );
  }
}
