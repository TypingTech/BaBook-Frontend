import 'package:flutter/material.dart';
import 'package:babook_front_end/routes/app_routes.dart';

class HalamanAwal extends StatefulWidget {
  const HalamanAwal({super.key});

  @override
  State<HalamanAwal> createState() => _HalamanAwalState();
}

class _HalamanAwalState extends State<HalamanAwal>
    with SingleTickerProviderStateMixin {
  late final AnimationController _kontrol;

  @override
  void initState() {
    super.initState();
    _kontrol = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..forward();

    // kalau bar sudah penuh, pindah ke halaman login
    _kontrol.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        Navigator.pushReplacementNamed(context, AppRoutes.login);
      }
    });
  }

  @override
  void dispose() {
    _kontrol.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F1D8),
      body: Stack(
        children: [
          // lingkaran biru kanan atas
          Positioned(
            top: -40,
            right: -40,
            child: Container(
              width: 130,
              height: 130,
              decoration: const BoxDecoration(
                color: Color(0xFF2F6BFF),
                shape: BoxShape.circle,
              ),
            ),
          ),

          // lingkaran kuning kiri bawah
          Positioned(
            bottom: -50,
            left: -50,
            child: Container(
              width: 130,
              height: 130,
              decoration: const BoxDecoration(
                color: Color(0xFFFFC72C),
                shape: BoxShape.circle,
              ),
            ),
          ),

          // garis lengkung kiri atas
          Positioned(
            top: 110,
            left: 20,
            child: CustomPaint(
              size: const Size(70, 25),
              painter: GarisLengkung(),
            ),
          ),

          // garis lengkung kanan bawah
          Positioned(
            bottom: 190,
            right: 40,
            child: CustomPaint(
              size: const Size(70, 25),
              painter: GarisLengkung(),
            ),
          ),

          // bar loading
          Positioned(
            bottom: 140,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: 140,
                height: 14,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.black87, width: 1.2),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black87,
                      offset: Offset(0, 3),
                      blurRadius: 0,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: AnimatedBuilder(
                    animation: _kontrol,
                    builder: (context, _) {
                      return Align(
                        alignment: Alignment.centerLeft,
                        child: FractionallySizedBox(
                          widthFactor: _kontrol.value,
                          child: Container(color: const Color(0xFF2F6BFF)),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),

          // konten utama (dinaikkan dengan padding bawah)
          Center(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 80),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // logo + bintang
                  SizedBox(
                    width: 260,
                    height: 170,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Positioned(
                          left: 10,
                          top: 0,
                          child: Transform.rotate(
                            angle: -0.3,
                            child: const Icon(
                              Icons.star_rounded,
                              size: 42,
                              color: Color(0xFFC9C3B0),
                            ),
                          ),
                        ),
                        Positioned(
                          right: 10,
                          top: 0,
                          child: Transform.rotate(
                            angle: 0.3,
                            child: const Icon(
                              Icons.star_rounded,
                              size: 42,
                              color: Color(0xFFC9C3B0),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          child: Image.asset(
                            'assets/images/logo.png',
                            height: 150,
                            width: 150,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  // banner teks miring
                  Transform.rotate(
                    angle: -0.05,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF6C224),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.black87, width: 1.2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            offset: const Offset(2, 3),
                            blurRadius: 0,
                          ),
                        ],
                      ),
                      child: const Text(
                        'Baca buku, kapan saja',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// class untuk menggambar garis lengkung
class GarisLengkung extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black87
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..moveTo(0, size.height * 0.6)
      ..quadraticBezierTo(
        size.width * 0.25,
        -size.height * 0.2,
        size.width * 0.5,
        size.height * 0.5,
      )
      ..quadraticBezierTo(
        size.width * 0.75,
        size.height * 1.2,
        size.width,
        size.height * 0.2,
      );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
