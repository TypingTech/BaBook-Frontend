import 'package:flutter/material.dart';
import 'package:babook_front_end/routes/app_routes.dart';
import 'package:babook_front_end/services/api_service.dart';

class HalamanSignUp extends StatefulWidget {
  const HalamanSignUp({super.key});

  @override
  State<HalamanSignUp> createState() => _HalamanSignUpState();
}

class _HalamanSignUpState extends State<HalamanSignUp> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _sembunyikanPassword = true;
  bool _loading = false;

  @override
  void dispose() {
    _namaController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _tampilPesan(String pesan) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(pesan)));
  }

  Future<void> _prosesSignUp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    final hasil = await ApiService.register(
      name: _namaController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (!mounted) return;
    setState(() => _loading = false);

    if (hasil.success) {
      _tampilPesan('Registrasi berhasil, silakan login');
      // register tidak memberi token, jadi arahkan ke halaman login
      Navigator.pushReplacementNamed(context, AppRoutes.login);
    } else if (hasil.statusCode == 422 && hasil.errors.isNotEmpty) {
      // error per field dari backend, misalnya "Password minimal 8 karakter"
      _tampilPesan(hasil.errors.values.join('\n'));
    } else {
      // termasuk 409 "Email sudah terdaftar" dan error koneksi
      _tampilPesan(hasil.message);
    }
  }

  // kotak input dengan gaya sama seperti halaman login
  Widget _kolomInput({
    required TextEditingController controller,
    required String hint,
    required IconData ikon,
    required String? Function(String?) validator,
    TextInputType tipe = TextInputType.text,
    bool password = false,
  }) {
    OutlineInputBorder garis(Color warna) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: warna, width: 1),
    );

    return TextFormField(
      controller: controller,
      validator: validator,
      obscureText: password ? _sembunyikanPassword : false,
      keyboardType: tipe,
      style: const TextStyle(fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(fontSize: 13, color: Colors.black87),
        prefixIcon: Icon(ikon, size: 20, color: Colors.black87),
        suffixIcon: password
            ? IconButton(
                icon: Icon(
                  _sembunyikanPassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  size: 20,
                  color: Colors.black54,
                ),
                onPressed: () {
                  setState(() {
                    _sembunyikanPassword = !_sembunyikanPassword;
                  });
                },
              )
            : null,
        filled: true,
        fillColor: Colors.white,
        border: garis(Colors.black87),
        enabledBorder: garis(Colors.black87),
        focusedBorder: garis(Colors.black87),
        errorBorder: garis(Colors.red),
        focusedErrorBorder: garis(Colors.red),
        errorStyle: const TextStyle(fontSize: 12, height: 1.3),
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F1D8),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // lingkaran kuning kiri bawah
          Positioned(
            bottom: -60,
            left: -60,
            child: Container(
              width: 140,
              height: 140,
              decoration: const BoxDecoration(
                color: Color(0xFFFFC72C),
                shape: BoxShape.circle,
              ),
            ),
          ),

          // garis lengkung kiri atas
          Positioned(
            top: 60,
            left: 20,
            child: CustomPaint(
              size: const Size(90, 30),
              painter: GarisSignUpPainter(),
            ),
          ),

          // konten utama
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 40),

                    // logo + judul
                    Center(
                      child: Column(
                        children: [
                          Image.asset(
                            'assets/images/logo.png',
                            height: 80,
                            width: 80,
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Sign Up',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),

                    // nama
                    const Text('Name', style: TextStyle(fontSize: 18)),
                    const SizedBox(height: 8),
                    _kolomInput(
                      controller: _namaController,
                      hint: 'Enter your name',
                      ikon: Icons.person_outline,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Nama tidak boleh kosong';
                        }
                        if (v.trim().length > 100) {
                          return 'Nama maksimal 100 karakter';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 22),

                    // email
                    const Text('Email', style: TextStyle(fontSize: 18)),
                    const SizedBox(height: 8),
                    _kolomInput(
                      controller: _emailController,
                      hint: 'Enter your email',
                      ikon: Icons.mail_outline,
                      tipe: TextInputType.emailAddress,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Email tidak boleh kosong';
                        }
                        final ok = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                            .hasMatch(v.trim());
                        return ok ? null : 'Format email tidak valid';
                      },
                    ),

                    const SizedBox(height: 22),

                    // password
                    const Text('Password', style: TextStyle(fontSize: 18)),
                    const SizedBox(height: 8),
                    _kolomInput(
                      controller: _passwordController,
                      hint: 'Enter your password',
                      ikon: Icons.lock_outline,
                      password: true,
                      // backend meminta minimal 8 karakter
                      validator: (v) => (v == null || v.length < 8)
                          ? 'Password minimal 8 karakter'
                          : null,
                    ),

                    const SizedBox(height: 28),

                    // tombol sign up
                    Container(
                      width: double.infinity,
                      height: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.5),
                            offset: const Offset(0, 3),
                            blurRadius: 2,
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: _loading ? null : _prosesSignUp,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1250E8),
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: const Color(0xFF1250E8),
                          disabledForegroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: _loading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'Sign Up',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 40),

                    // sudah punya akun
                    Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Already have an account? ',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.pushReplacementNamed(
                                context,
                                AppRoutes.login,
                              );
                            },
                            child: const Text(
                              'Sign In',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2F6BFF),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// menggambar garis lengkung dekoratif
class GarisSignUpPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black87
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..moveTo(0, size.height * 0.8)
      ..quadraticBezierTo(
        size.width * 0.25,
        -size.height * 0.1,
        size.width * 0.5,
        size.height * 0.5,
      )
      ..quadraticBezierTo(
        size.width * 0.75,
        size.height * 1.0,
        size.width,
        size.height * 0.1,
      );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
