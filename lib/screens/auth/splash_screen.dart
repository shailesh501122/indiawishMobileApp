import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/constants.dart';
import '../../providers/user_provider.dart';
import '../main_screens_wrapper.dart';

// ─── Data model for orbiting category icons ────────────────────────────────
class _CategoryItem {
  final IconData icon;
  final String label;
  final Color color;

  const _CategoryItem(this.icon, this.label, this.color);
}

// ─── Splash Screen ──────────────────────────────────────────────────────────
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // Animation controllers
  late AnimationController _orbitController;
  late AnimationController _logoController;
  late AnimationController _pulseController;

  // Animations
  late Animation<double> _logoScale;
  late Animation<double> _logoFade;
  late Animation<double> _taglineFade;
  late Animation<Offset> _taglineSlide;
  late Animation<double> _pulse;
  late Animation<double> _orbitFade;

  // Classified categories that orbit the logo
  static const List<_CategoryItem> _categories = [
    _CategoryItem(Icons.directions_car, 'Cars', Color(0xFF4FC3F7)),
    _CategoryItem(Icons.smartphone, 'Mobiles', Color(0xFF81C784)),
    _CategoryItem(Icons.home_work_outlined, 'Property', Color(0xFFFFB74D)),
    _CategoryItem(Icons.work_outline, 'Jobs', Color(0xFFBA68C8)),
    _CategoryItem(Icons.two_wheeler, 'Bikes', Color(0xFFFF8A65)),
    _CategoryItem(Icons.chair_outlined, 'Furniture', Color(0xFF4DB6AC)),
    _CategoryItem(Icons.checkroom_outlined, 'Fashion', Color(0xFFF06292)),
    _CategoryItem(Icons.pets, 'Pets', Color(0xFFA5D6A7)),
  ];

  @override
  void initState() {
    super.initState();

    // Orbit: continuous slow rotation
    _orbitController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 9),
    )..repeat();

    // Logo entrance: elastic pop-in
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    // Pulse: gentle heartbeat on the logo
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);

    // Logo scale: elastic bounce
    _logoScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.65, curve: Curves.elasticOut),
      ),
    );

    // Logo fade
    _logoFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.35, curve: Curves.easeIn),
      ),
    );

    // Orbit items fade in after logo
    _orbitFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.4, 0.8, curve: Curves.easeIn),
      ),
    );

    // Tagline fade
    _taglineFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.65, 1.0, curve: Curves.easeIn),
      ),
    );

    // Tagline slide up
    _taglineSlide = Tween<Offset>(begin: const Offset(0, 0.4), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _logoController,
            curve: const Interval(0.65, 1.0, curve: Curves.easeOut),
          ),
        );

    // Pulse: subtle scale breathe
    _pulse = Tween<double>(begin: 1.0, end: 1.06).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _logoController.forward();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    // Show splash for at least 3 seconds so the animation has time to impress
    await Future.delayed(const Duration(milliseconds: 3200));
    if (!mounted) return;

    final userProvider = context.read<UserProvider>();
    await userProvider.checkToken();
    if (!mounted) return;

    // All users go to Main (Home) screen after splash
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const MainScreensWrapper()),
    );
  }

  @override
  void dispose() {
    _orbitController.dispose();
    _logoController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF000F1E),
              Color(0xFF002040),
              Color(0xFF002F5A),
              Color(0xFF00407A),
            ],
            stops: [0.0, 0.3, 0.7, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // ── Decorative background blobs ──────────────────────────────
            _BackgroundBlobs(screenSize: size),

            // ── Star particles ────────────────────────────────────────────
            const _StarField(),

            // ── Main orbit + logo area ────────────────────────────────────
            Positioned.fill(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 290,
                    height: 290,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Orbit path ring
                        FadeTransition(
                          opacity: _orbitFade,
                          child: CustomPaint(
                            size: const Size(290, 290),
                            painter: _OrbitRingPainter(),
                          ),
                        ),

                        // Orbiting category icons
                        FadeTransition(
                          opacity: _orbitFade,
                          child: AnimatedBuilder(
                            animation: _orbitController,
                            builder: (_, __) => Stack(
                              alignment: Alignment.center,
                              children: _categories.asMap().entries.map((e) {
                                final index = e.key;
                                final item = e.value;
                                final baseAngle =
                                    (2 * pi * index / _categories.length);
                                final angle =
                                    baseAngle +
                                    (_orbitController.value * 2 * pi);
                                const radius = 118.0;
                                return Transform.translate(
                                  offset: Offset(
                                    radius * cos(angle),
                                    radius * sin(angle),
                                  ),
                                  child: _OrbitIcon(item: item, angle: angle),
                                );
                              }).toList(),
                            ),
                          ),
                        ),

                        // Glowing ring behind logo
                        FadeTransition(
                          opacity: _logoFade,
                          child: AnimatedBuilder(
                            animation: _pulse,
                            builder: (_, __) => Transform.scale(
                              scale: _pulse.value,
                              child: Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.featured.withOpacity(
                                        0.25,
                                      ),
                                      blurRadius: 36,
                                      spreadRadius: 12,
                                    ),
                                    BoxShadow(
                                      color: const Color(
                                        0xFF4FC3F7,
                                      ).withOpacity(0.15),
                                      blurRadius: 60,
                                      spreadRadius: 4,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),

                        // Center logo
                        FadeTransition(
                          opacity: _logoFade,
                          child: ScaleTransition(
                            scale: _logoScale,
                            child: AnimatedBuilder(
                              animation: _pulse,
                              builder: (_, child) => Transform.scale(
                                scale: _pulse.value,
                                child: child,
                              ),
                              child: _CenterLogo(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ── Bottom brand name + tagline + loader ──────────────────────
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: FadeTransition(
                opacity: _taglineFade,
                child: SlideTransition(
                  position: _taglineSlide,
                  child: const _BottomBrand(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Orbit ring painter (dashed circle) ────────────────────────────────────
class _OrbitRingPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    const radius = 118.0;

    // Outer glow ring
    final glowPaint = Paint()
      ..color = Colors.white.withOpacity(0.04)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
    canvas.drawCircle(center, radius, glowPaint);

    // Dashed orbit ring
    final dashPaint = Paint()
      ..color = Colors.white.withOpacity(0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    const dashCount = 40;
    const dashAngle = (2 * pi) / dashCount;
    const gapFraction = 0.45;

    for (int i = 0; i < dashCount; i++) {
      final startAngle = i * dashAngle;
      final sweepAngle = dashAngle * (1 - gapFraction);
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        dashPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─── Orbit icon chip ────────────────────────────────────────────────────────
class _OrbitIcon extends StatelessWidget {
  final _CategoryItem item;
  final double angle;

  const _OrbitIcon({required this.item, required this.angle});

  @override
  Widget build(BuildContext context) {
    // Counter-rotate so icon stays upright regardless of orbit position
    return Transform.rotate(
      angle: -angle,
      child: Container(
        width: 54,
        height: 54,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: item.color.withOpacity(0.12),
          border: Border.all(color: item.color.withOpacity(0.45), width: 1.4),
          boxShadow: [
            BoxShadow(
              color: item.color.withOpacity(0.35),
              blurRadius: 10,
              spreadRadius: 0,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(item.icon, color: item.color, size: 20),
            const SizedBox(height: 1),
            Text(
              item.label,
              style: TextStyle(
                color: item.color,
                fontSize: 6.5,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Center logo widget ─────────────────────────────────────────────────────
class _CenterLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 104,
      height: 104,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, Color(0xFFDCEAF8)],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 24,
            spreadRadius: 2,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'IW',
            style: GoogleFonts.outfit(
              color: AppColors.primary,
              fontSize: 30,
              fontWeight: FontWeight.w900,
              letterSpacing: -1.5,
              height: 1,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.featured,
              borderRadius: BorderRadius.circular(3),
            ),
            child: Text(
              'INDIA',
              style: GoogleFonts.outfit(
                color: AppColors.primary,
                fontSize: 7,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.8,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Bottom brand section ────────────────────────────────────────────────────
class _BottomBrand extends StatelessWidget {
  const _BottomBrand();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 52),
      child: Column(
        children: [
          Text(
            'IndiaWish',
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.8,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Buying & Selling Made Simple',
            style: GoogleFonts.outfit(
              color: Colors.white.withOpacity(0.6),
              fontSize: 13.5,
              fontWeight: FontWeight.w400,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 36),
          const _BouncingDotsLoader(),
        ],
      ),
    );
  }
}

// ─── Bouncing dots loader ────────────────────────────────────────────────────
class _BouncingDotsLoader extends StatefulWidget {
  const _BouncingDotsLoader();

  @override
  State<_BouncingDotsLoader> createState() => _BouncingDotsLoaderState();
}

class _BouncingDotsLoaderState extends State<_BouncingDotsLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (i) {
            // Each dot has a staggered phase
            final phase = (i / 3.0);
            final t = ((_ctrl.value - phase) % 1.0 + 1.0) % 1.0;
            final bounce = sin(t * pi).clamp(0.0, 1.0);
            return AnimatedContainer(
              duration: Duration.zero,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: 7 + bounce * 2,
              height: 7 + bounce * 2,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.35 + bounce * 0.65),
              ),
            );
          }),
        );
      },
    );
  }
}

// ─── Decorative background blobs ─────────────────────────────────────────────
class _BackgroundBlobs extends StatelessWidget {
  final Size screenSize;
  const _BackgroundBlobs({required this.screenSize});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Top-right large blob
        Positioned(
          top: -100,
          right: -80,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.featured.withOpacity(0.04),
            ),
          ),
        ),
        // Bottom-left blob
        Positioned(
          bottom: screenSize.height * 0.18,
          left: -90,
          child: Container(
            width: 280,
            height: 280,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF4FC3F7).withOpacity(0.05),
            ),
          ),
        ),
        // Center-right accent
        Positioned(
          top: screenSize.height * 0.55,
          right: -30,
          child: Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF81C784).withOpacity(0.04),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Static star field ───────────────────────────────────────────────────────
class _StarField extends StatelessWidget {
  const _StarField();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: MediaQuery.of(context).size,
      painter: _StarPainter(),
    );
  }
}

class _StarPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white;
    final rng = Random(42); // fixed seed = same stars every time
    for (int i = 0; i < 55; i++) {
      final x = rng.nextDouble() * size.width;
      final y = rng.nextDouble() * size.height;
      final r = rng.nextDouble() * 1.4 + 0.3;
      paint.color = Colors.white.withOpacity(rng.nextDouble() * 0.25 + 0.05);
      canvas.drawCircle(Offset(x, y), r, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
