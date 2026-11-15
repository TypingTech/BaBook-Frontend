import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:babook_front_end/routes/app_routes.dart';
import 'package:babook_front_end/services/api_service.dart';
// pakai ulang garis lengkung dari halaman login
import 'package:babook_front_end/features/halaman_login.dart'
    show GarisLoginPainter;

class HalamanResetPassword extends StatefulWidget {
  const HalamanResetPassword({super.key});

  @override
  State<HalamanResetPassword> createState() => _HalamanResetPasswordState();
}

class _HalamanResetPasswordState extends State<HalamanResetPassword> {
  final _formKey = GlobalKey<FormState>();
  final _otpController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _sembunyikanPassword = true;
  bool _loading = false;
  bool _kirimUlang = false;

  @override
  void dispose() {
    _otpController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // email dikirim dari halaman lupa password lewat arguments
  String get _email =>
      (ModalRoute.of(context)?.settings.arguments as String?) ?? '';

  void _tampilPesan(String pesan) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(pesan)));
  }

  Future<void> _prosesReset() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    final hasil = await ApiService.resetPassword(
      email: _email,
      otp: _otpController.text.trim(), // tetap String, jangan jadi angka
      newPassword: _passwordController.text,
    );

    if (!mounted) return;
    setState(() => _loading = false);

    if (hasil.success) {
      _tampilPesan(hasil.message);
      // hapus semua halaman sebelumnya, kembali ke login
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.login,
        (route) => false,
      );
    } else {
      _tampilPesan(hasil.message);
    }
  }

  Future<void> _kirimKodeUlang() async {
    setState(() => _kirimUlang = true);
    final hasil = await ApiService.forgotPassword(email: _email);
    if (!mounted) return;
    setState(() => _kirimUlang = false);
    _tampilPesan(
      hasil.success
          ? 'Kode baru telah dikirim jika email terdaftar'
          : hasil.message,
    );
  }

  @override
  Widget build(BuildContext context) {
    OutlineInputBorder garis(Color warna) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: warna, width: 1),
    );

    InputDecoration dekorasi({
      required String hint,
      required IconData ikon,
      Widget? suffix,
    }) {
      return InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(fontSize: 13, color: Colors.black87),
        prefixIcon: Icon(ikon, size: 20, color: Colors.black87),
        suffixIcon: suffix,
        counterText: '',
        filled: true,
        fillColor: Colors.white,
        border: garis(Colors.black87),
        enabledBorder: garis(Colors.black87),
        focusedBorder: garis(Colors.black87),
        errorBorder: garis(Colors.red),
        focusedErrorBorder: garis(Colors.red),
        errorStyle: const TextStyle(fontSize: 12, height: 1.3),
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
      );
    }

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
                            'Reset Password',
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

                    Center(
                      child: Text(
                        'Masukkan kode 6 digit yang dikirim ke\n$_email',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),

                    const SizedBox(height: 30),

                    // kode OTP
                    const Text(
                      'Verification Code',
                      style: TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _otpController,
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      style: const TextStyle(fontSize: 14, letterSpacing: 4),
                      validator: (v) {
                        if (v == null || v.trim().length != 6) {
                          return 'Kode harus 6 digit angka';
                        }
                        return null;
                      },
                      decoration: dekorasi(
                        hint: 'Enter 6-digit code',
                        ikon: Icons.pin_outlined,
                      ),
                    ),

                    const SizedBox(height: 22),

                    // password baru
                    const Text('New Password', style: TextStyle(fontSize: 18)),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _sembunyikanPassword,
                      style: const TextStyle(fontSize: 14),
                      validator: (v) => (v == null || v.length < 8)
                          ? 'Password minimal 8 karakter'
                          : null,
                      decoration: dekorasi(
                        hint: 'Enter new password',
                        ikon: Icons.lock_outline,
                        suffix: IconButton(
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
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    // kirim ulang kode
                    Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: _kirimUlang ? null : _kirimKodeUlang,
                        child: Text(
                          _kirimUlang ? 'Sending...' : 'Resend code',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2F6BFF),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 28),

                    // tombol reset
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
                        onPressed: _loading ? null : _prosesReset,
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
                                'Reset Password',
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
                          'Back',
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
