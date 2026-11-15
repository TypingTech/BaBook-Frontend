import 'package:flutter/material.dart';
import 'package:babook_front_end/features/halaman_utama.dart';
import 'package:babook_front_end/features/halaman_login.dart';
import 'package:babook_front_end/features/halaman_signup.dart';
import 'package:babook_front_end/features/halaman_home.dart';
import 'package:babook_front_end/features/halaman_lupa_password.dart';
import 'package:babook_front_end/features/halaman_reset_password.dart';

class AppRoutes {
  // nama-nama rute
  static const String awal = '/';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String home = '/home';
  static const String lupaPassword = '/lupa-password';
  static const String resetPassword = '/reset-password';

  // daftar rute: nama -> halaman
  static Map<String, WidgetBuilder> get routes => {
    awal: (context) => const HalamanAwal(),
    login: (context) => const HalamanLogin(),
    signup: (context) => const HalamanSignUp(),
    home: (context) => const HalamanHome(),
    lupaPassword: (context) => const HalamanLupaPassword(),
    resetPassword: (context) => const HalamanResetPassword(),
  };
}
