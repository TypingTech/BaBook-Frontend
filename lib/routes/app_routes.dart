import 'package:flutter/material.dart';
import 'package:babook_front_end/features/halaman_utama.dart';
import 'package:babook_front_end/features/halaman_login.dart';

class AppRoutes {
  // nama-nama rute
  static const String awal = '/';
  static const String login = '/login';

  // daftar rute: nama -> halaman
  static Map<String, WidgetBuilder> get routes => {
    awal: (context) => const HalamanAwal(),
    login: (context) => const HalamanLogin(),
  };
}
