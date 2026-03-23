import 'package:flutter/material.dart';
import '../constants.dart';
import 'kit_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;
  late Animation<double> _logoScale;
  late Animation<Offset> _titleSlide;

  // Tube light startup animations
  late Animation<double> _logoGlow;
  late Animation<double> _logoIntensity;
  late Animation<double> _borderGlow;

  // Flickering animation - simple ON OFF ON pattern
  // 2000ms total duration with minimal dark time
  double _getFlickerValue(double progress) {
    // ON: 0-60ms (progress 0-0.03), starts visible immediately
    if (progress < 0.03) {
      return 0.35 + (progress / 0.03) * 0.65;
    }

    // OFF dip: 60-180ms (progress 0.03-0.09), near-off but very short
    if (progress < 0.09) {
      return 1.0 - (progress - 0.03) / 0.06 * 0.92;
    }

    // FINAL ON: 180-2000ms (progress 0.09-1.0)
    return ((progress - 0.09) / 0.91).clamp(0.0, 1.0);
  }

  @override
  void initState() {
    super.initState();
    // 2 second animation - simple ON OFF ON pattern
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2000));

    // Main fade animation
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOutCubic);

    // Logo scale with bounce
    _logoScale = Tween<double>(begin: 0.94, end: 1).animate(CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.15, 1, curve: Curves.easeOutBack),
    ));

    // Title slide animation
    _titleSlide = Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero)
        .animate(CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.2, 1, curve: Curves.easeOutCubic),
    ));

    // Tube light glow animation
    _logoGlow = Tween<double>(begin: 4, end: 56).animate(CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.12, 1, curve: Curves.easeOutCubic),
    ));

    // Green intensity
    _logoIntensity = Tween<double>(begin: 0.08, end: 1.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.1, 1, curve: Curves.easeInOutCubic),
      ),
    );

    // Border glow intensity
    _borderGlow = Tween<double>(begin: 0.1, end: 1.0).animate(CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.12, 1, curve: Curves.easeInOutCubic),
    ));

    _ctrl.forward();

    // Navigate after animation completes
    Future.delayed(const Duration(milliseconds: 2400), () {
      if (!mounted) return;
      Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => const KitScreen(),
            transitionsBuilder: (_, anim, __, child) =>
                FadeTransition(opacity: anim, child: child),
            transitionDuration: const Duration(milliseconds: 400),
          ));
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _ctrl,
        child: const _SplashStaticText(),
        builder: (context, child) {
          // Calculate the flickering effect during startup
          final flicker = _getFlickerValue(_ctrl.value);

          // Interpolate glow shadow blur
          final currentGlowBlur = _logoGlow.value;

          // Green intensity varies from dim startup to full brightness
          final greenIntensity = _logoIntensity.value;

          // Border opacity follows the glow - VERY bright
          final borderColor =
              kGreen.withValues(alpha: 0.15 + _borderGlow.value * 1.0);

          // Primary glow color - EXTREMELY bright
          final primaryGlowColor =
              kGreen.withValues(alpha: 0.6 * greenIntensity * flicker);

          // Secondary glow - EXTREMELY bright
          final secondaryGlowColor =
              kGreen.withValues(alpha: 0.42 * greenIntensity * flicker);

          return Scaffold(
            backgroundColor: kBg,
            body: SafeArea(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      kBg,
                      kSurface,
                      kBg,
                    ],
                    stops: const [0, 0.56, 1],
                  ),
                ),
                child: FadeTransition(
                    opacity: _fade,
                    child: Center(
                        child: SlideTransition(
                      position: _titleSlide,
                      child: Column(mainAxisSize: MainAxisSize.min, children: [
                        ScaleTransition(
                          scale: _logoScale,
                          child: RepaintBoundary(
                            child: Container(
                              width: 102,
                              height: 102,
                              decoration: BoxDecoration(
                                color: kSurface2,
                                borderRadius: BorderRadius.circular(22),
                                border:
                                    Border.all(color: borderColor, width: 1.6),
                                boxShadow: [
                                  // Primary warm glow (tube light effect)
                                  BoxShadow(
                                      color: primaryGlowColor,
                                      blurRadius: currentGlowBlur * 0.85,
                                      spreadRadius: currentGlowBlur * 0.5),
                                  // Secondary, larger glow - much more prominent
                                  BoxShadow(
                                      color: secondaryGlowColor,
                                      blurRadius: currentGlowBlur * 1.8,
                                      spreadRadius: currentGlowBlur * 1.0),
                                  // Subtle blue undertone that stays consistent
                                  BoxShadow(
                                      color: kBlueBright.withValues(
                                          alpha: 0.12 + 0.12 * greenIntensity),
                                      blurRadius: 52,
                                      spreadRadius: 8),
                                ],
                              ),
                              child: Center(
                                  child: Text('85',
                                      style: TextStyle(
                                        color: kGreen.withValues(
                                            alpha: 0.2 +
                                                flicker * greenIntensity * 0.8),
                                        fontSize: 40,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 1,
                                        fontFamily: kMono,
                                        shadows: [
                                          Shadow(
                                              color: kGreen.withValues(
                                                  alpha: 0.65 *
                                                      greenIntensity *
                                                      flicker),
                                              blurRadius:
                                                  14 + currentGlowBlur * 0.6)
                                        ],
                                      ))),
                            ),
                          ),
                        ),
                        child ?? const SizedBox.shrink(),
                      ]),
                    ))),
              ),
            ),
          );
        },
      );
}

class _SplashStaticText extends StatelessWidget {
  const _SplashStaticText();

  @override
  Widget build(BuildContext context) => Column(
        children: [
          const SizedBox(height: 24),
          Text('KIT85',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    letterSpacing: 7,
                    fontFamily: kMono,
                  )),
          const SizedBox(height: 8),
          Text('8085 Microprocessor Simulator',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    letterSpacing: 2,
                    fontFamily: kMono,
                  )),
          const SizedBox(height: 6),
          Text('by forgeVIIl  •  v$kAppVersion',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: kTextDim.withValues(alpha: 0.7),
                    fontFamily: kMono,
                  )),
        ],
      );
}
