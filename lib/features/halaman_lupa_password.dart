import 'package:flutter/material.dart';
import 'package:babook_front_end/routes/app_routes.dart';
import 'package:babook_front_end/services/api_service.dart';
import 'package:babook_front_end/features/halaman_login.dart'
    show GarisLoginPainter;

class HalamanLupaPassword extends StatefulWidget {
  const HalamanLupaPassword({super.key});

  @override
  State<HalamanLupaPassword> createState() => _HalamanLupaPasswordState();
}

class _HalamanLupaPasswordState extends State<HalamanLupaPassword> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _tampilPesan(String pesan) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(pesan)));
  }

  Future<void> _kirimKode() async {
    if (!_formKey.currentState!.validate()) return;

    final email = _emailController.text.trim();
    setState(() => _loading = true);

    final hasil = await ApiService.forgotPassword(email: email);

    if (!mounted) return;
    setState(() => _loading = false);

    if (hasil.success) {
      // pesan netral: backend tidak memberi tahu apakah email terdaftar
      _tampilPesan('Jika email terdaftar, cek kotak masuk kamu');
      Navigator.pushNamed(
        context,
        AppRoutes.resetPassword,
        arguments: email, // dibawa ke halaman berikutnya
      );
    } else {
      _tampilPesan(hasil.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    OutlineInputBorder garis(Color warna) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: warna, width: 1),
    );

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
              painter: GarisLoginPainter(),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 40),

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
                            'Forgot Password',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    const Center(
                      child: Text(
                        'Masukkan email akunmu. Kami akan mengirim\nkode verifikasi 6 digit.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 13),
                      ),
                    ),

                    const SizedBox(height: 30),

                    const Text('Email', style: TextStyle(fontSize: 18)),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      style: const TextStyle(fontSize: 14),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Email tidak boleh kosong';
                        }
                        final ok = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                            .hasMatch(v.trim());
                        return ok ? null : 'Format email tidak valid';
                      },
                      decoration: InputDecoration(
                        hintText: 'Enter your email',
                        hintStyle: const TextStyle(
                          fontSize: 13,
                          color: Colors.black87,
                        ),
                        prefixIcon: const Icon(
                          Icons.mail_outline,
                          size: 20,
                          color: Colors.black87,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        border: garis(Colors.black87),
                        enabledBorder: garis(Colors.black87),
                        focusedBorder: garis(Colors.black87),
                        errorBorder: garis(Colors.red),
                        focusedErrorBorder: garis(Colors.red),
                        errorStyle: const TextStyle(fontSize: 12, height: 1.3),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 16,
                        ),
                      ),
                    ),

                    const SizedBox(height: 28),

                    // tombol kirim kode
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
                        onPressed: _loading ? null : _kirimKode,
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
                                'Send Code',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 40),

                    Center(
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Text(
                          'Back to Sign In',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2F6BFF),
                          ),
                        ),
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
