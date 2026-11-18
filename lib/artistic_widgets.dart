import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'theme_engine.dart';

/// Animated 3D / Neon / Glass Icon that pops in with elastic bounce,
/// gently levitates in 3D space, and spins 360° with 3D perspective on tap or trigger!
class AnimatedAuraIcon extends StatefulWidget {
  final String assetPath;
  final IconData fallbackIcon;
  final ActiveAuraPalette palette;
  final double size;
  final int spinTrigger;

  const AnimatedAuraIcon({
    super.key,
    required this.assetPath,
    required this.fallbackIcon,
    required this.palette,
    this.size = 54,
    this.spinTrigger = 0,
  });

  @override
  State<AnimatedAuraIcon> createState() => _AnimatedAuraIconState();
}

class _AnimatedAuraIconState extends State<AnimatedAuraIcon>
    with TickerProviderStateMixin {
  late final AnimationController _floatCtrl;
  late final AnimationController _spinCtrl;
  late final Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _floatCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1900),
    )..repeat(reverse: true);

    _spinCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 680),
    );
    _scaleAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.25, end: 1.14), weight: 65),
      TweenSequenceItem(tween: Tween(begin: 1.14, end: 1.0), weight: 35),
    ]).animate(CurvedAnimation(parent: _spinCtrl, curve: Curves.easeOutBack));

    _spinCtrl.forward(from: 0);
  }

  @override
  void didUpdateWidget(covariant AnimatedAuraIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.spinTrigger != widget.spinTrigger ||
        oldWidget.palette.style != widget.palette.style ||
        oldWidget.assetPath != widget.assetPath) {
      _spinCtrl.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _floatCtrl.dispose();
    _spinCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _spinCtrl.forward(from: 0),
      child: AnimatedBuilder(
        animation: Listenable.merge([_floatCtrl, _spinCtrl]),
        builder: (context, child) {
          final double floatY = (_floatCtrl.value - 0.5) * 6.0;
          final double angle = _spinCtrl.value * 2 * math.pi;
          final double scale = _scaleAnim.value;

          return Transform.translate(
            offset: Offset(0, floatY),
            child: Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.0015)
                ..scale(scale, scale)
                ..rotateZ(angle)
                ..rotateY(math.sin(angle) * 0.35),
              child: SizedBox(
                width: widget.size,
                height: widget.size,
                child: _buildThemedIconContent(),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildThemedIconContent() {
    switch (widget.palette.style) {
      case AuraThemeStyle.soloNeon:
        return Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF130E24),
            border: Border.all(color: widget.palette.primary, width: 2.2),
            boxShadow: [
              BoxShadow(
                color: widget.palette.primary.withOpacity(0.65),
                blurRadius: 16,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Center(
            child: Icon(
              widget.fallbackIcon,
              color: widget.palette.glow,
              size: widget.size * 0.50,
            ),
          ),
        );

      case AuraThemeStyle.soft3D:
        return Image.asset(
          widget.assetPath,
          fit: BoxFit.contain,
        );

      case AuraThemeStyle.botanicalGlass:
        return ClipRRect(
          borderRadius: BorderRadius.circular(widget.size * 0.32),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: EdgeInsets.all(widget.size * 0.08),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(widget.size * 0.32),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    widget.palette.primary.withOpacity(0.42),
                    widget.palette.secondary.withOpacity(0.24),
                  ],
                ),
                border: Border.all(
                  color: Colors.white.withOpacity(0.55),
                  width: 1.2,
                ),
              ),
              child: Image.asset(
                widget.assetPath,
                fit: BoxFit.contain,
              ),
            ),
          ),
        );
    }
  }
}

/// Theme-Adaptive Artistic Card:
/// - Theme 1 (Solo Neon): Glowing RPG system frame with corner filigree & neon BoxShadow
/// - Theme 2 (Soft 3D): Claymorphic 3D pillow surface with white inner rim & soft drop shadow
/// - Theme 3 (Botanical Glass): Real-time BackdropFilter frosted glass with luminous wave accent
class AuraThemedCard extends StatelessWidget {
  final ActiveAuraPalette palette;
  final Widget child;
  final int glassTintIndex;
  final EdgeInsetsGeometry padding;
  final double borderRadius;

  const AuraThemedCard({
    super.key,
    required this.palette,
    required this.child,
    this.glassTintIndex = 0,
    this.padding = const EdgeInsets.all(16),
    this.borderRadius = 24,
  });

  @override
  Widget build(BuildContext context) {
    switch (palette.style) {
      case AuraThemeStyle.soloNeon:
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xF21A1430), Color(0xF20E0A1C)],
            ),
            border: Border.all(
              color: palette.primary.withOpacity(0.80),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: palette.primary.withOpacity(0.32),
                blurRadius: 18,
                spreadRadius: 1,
              ),
            ],
          ),
          child: CustomPaint(
            painter: _SoloCornerTicksPainter(color: palette.glow),
            child: Padding(padding: padding, child: child),
          ),
        );

      case AuraThemeStyle.soft3D:
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFFFFFFF), Color(0xFFF3EFE8)],
            ),
            border: Border.all(color: Colors.white, width: 2.2),
            boxShadow: [
              BoxShadow(
                color: palette.primary.withOpacity(0.18),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
              const BoxShadow(
                color: Color(0xCCFFFFFF),
                blurRadius: 6,
                offset: Offset(-3, -3),
              ),
            ],
          ),
          child: Padding(padding: padding, child: child),
        );

      case AuraThemeStyle.botanicalGlass:
        final List<Color> tintColors = switch (glassTintIndex % 4) {
          0 => [palette.primary.withOpacity(0.30), const Color(0x990A252E)],
          1 => [const Color(0x4D4CA8F5), const Color(0x990E1E38)],
          2 => [palette.secondary.withOpacity(0.30), const Color(0x99261236)],
          _ => [palette.glow.withOpacity(0.28), const Color(0x992E2012)],
        };

        return ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(borderRadius),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: tintColors,
                ),
                border: Border.all(
                  color: Colors.white.withOpacity(0.38),
                  width: 1.2,
                ),
              ),
              child: CustomPaint(
                painter: _GlassWaveAccentPainter(color: palette.primary),
                child: Padding(padding: padding, child: child),
              ),
            ),
          ),
        );
    }
  }
}

class _SoloCornerTicksPainter extends CustomPainter {
  final Color color;
  _SoloCornerTicksPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.75)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    const double pad = 7.0;
    const double len = 14.0;
    // Top-left
    canvas.drawLine(const Offset(pad, pad), const Offset(pad + len, pad), paint);
    canvas.drawLine(const Offset(pad, pad), const Offset(pad, pad + len), paint);
    // Top-right
    canvas.drawLine(Offset(size.width - pad, pad), Offset(size.width - pad - len, pad), paint);
    canvas.drawLine(Offset(size.width - pad, pad), Offset(size.width - pad, pad + len), paint);
    // Bottom-left
    canvas.drawLine(Offset(pad, size.height - pad), Offset(pad + len, size.height - pad), paint);
    canvas.drawLine(Offset(pad, size.height - pad), Offset(pad, size.height - pad - len), paint);
    // Bottom-right
    canvas.drawLine(Offset(size.width - pad, size.height - pad), Offset(size.width - pad - len, size.height - pad), paint);
    canvas.drawLine(Offset(size.width - pad, size.height - pad), Offset(size.width - pad, size.height - pad - len), paint);
  }

  @override
  bool shouldRepaint(covariant _SoloCornerTicksPainter oldDelegate) =>
      oldDelegate.color != color;
}

class _GlassWaveAccentPainter extends CustomPainter {
  final Color color;
  _GlassWaveAccentPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(0, size.height * 0.88)
      ..cubicTo(
        size.width * 0.28,
        size.height * 0.78,
        size.width * 0.68,
        size.height * 0.96,
        size.width,
        size.height * 0.82,
      );

    final paint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.transparent,
          color.withOpacity(0.45),
          Colors.white.withOpacity(0.45),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8;

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _GlassWaveAccentPainter oldDelegate) =>
      oldDelegate.color != color;
}

/// Ornate Solo Leveling RPG Center Diamond Divider (« ─── ❖ ─── »)
class SoloNeonOrnateDivider extends StatelessWidget {
  final ActiveAuraPalette palette;
  const SoloNeonOrnateDivider({super.key, required this.palette});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 22,
      width: double.infinity,
      child: CustomPaint(
        painter: _OrnateDividerPainter(
          primary: palette.primary,
          glow: palette.glow,
        ),
      ),
    );
  }
}

class _OrnateDividerPainter extends CustomPainter {
  final Color primary;
  final Color glow;
  _OrnateDividerPainter({required this.primary, required this.glow});

  @override
  void paint(Canvas canvas, Size size) {
    final midY = size.height / 2;
    final midX = size.width / 2;

    final leftPaint = Paint()
      ..shader = LinearGradient(
        colors: [Colors.transparent, primary.withOpacity(0.75)],
      ).createShader(Rect.fromLTWH(0, 0, midX - 24, size.height))
      ..strokeWidth = 1.6;

    final rightPaint = Paint()
      ..shader = LinearGradient(
        colors: [primary.withOpacity(0.75), Colors.transparent],
      ).createShader(Rect.fromLTWH(midX + 24, 0, midX - 24, size.height))
      ..strokeWidth = 1.6;

    canvas.drawLine(Offset(10, midY), Offset(midX - 24, midY), leftPaint);
    canvas.drawLine(Offset(midX + 24, midY), Offset(size.width - 10, midY), rightPaint);

    final diamond = Path()
      ..moveTo(midX, midY - 6)
      ..lineTo(midX + 6, midY)
      ..lineTo(midX, midY + 6)
      ..lineTo(midX - 6, midY)
      ..close();

    canvas.drawPath(diamond, Paint()..color = glow);
    canvas.drawCircle(Offset(midX - 14, midY), 2.5, Paint()..color = primary);
    canvas.drawCircle(Offset(midX + 14, midY), 2.5, Paint()..color = primary);
  }

  @override
  bool shouldRepaint(covariant _OrnateDividerPainter oldDelegate) =>
      oldDelegate.primary != primary;
}

/// Circular Glowing Ring Gauge featured across all 3 reference photos
class CircularGlowGauge extends StatelessWidget {
  final double percent;
  final String labelCenterBn;
  final String labelSubBn;
  final ActiveAuraPalette palette;
  final double size;

  const CircularGlowGauge({
    super.key,
    required this.percent,
    required this.labelCenterBn,
    required this.labelSubBn,
    required this.palette,
    this.size = 92,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: percent.clamp(0.0, 100.0)),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOutCubic,
      builder: (context, val, _) {
        return SizedBox(
          width: size,
          height: size,
          child: CustomPaint(
            painter: _GaugeRingPainter(
              percent: val,
              primary: palette.primary,
              secondary: palette.secondary,
              glow: palette.glow,
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    labelCenterBn,
                    style: AuraTextStyles.titleMedium(palette.textPrimary, size: 15),
                  ),
                  if (labelSubBn.isNotEmpty)
                    Text(
                      labelSubBn,
                      style: AuraTextStyles.bodyRegular(palette.textSecondary, size: 10.5),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _GaugeRingPainter extends CustomPainter {
  final double percent;
  final Color primary;
  final Color secondary;
  final Color glow;

  _GaugeRingPainter({
    required this.percent,
    required this.primary,
    required this.secondary,
    required this.glow,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.shortestSide / 2) - 8;

    final trackPaint = Paint()
      ..color = primary.withOpacity(0.18)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 9
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);

    final sweepAngle = (percent / 100.0) * 2 * math.pi;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final arcPaint = Paint()
      ..shader = SweepGradient(
        colors: [primary, secondary, glow, primary],
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 9
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(rect, -math.pi / 2, sweepAngle, false, arcPaint);
  }

  @override
  bool shouldRepaint(covariant _GaugeRingPainter oldDelegate) =>
      oldDelegate.percent != percent || oldDelegate.primary != primary;
}

/// Bouncy Pill Action Button with circular right arrow badge (featured in 2nd reference photo)
class AuraActionPillButton extends StatefulWidget {
  final String textBn;
  final ActiveAuraPalette palette;
  final VoidCallback onTap;

  const AuraActionPillButton({
    super.key,
    required this.textBn,
    required this.palette,
    required this.onTap,
  });

  @override
  State<AuraActionPillButton> createState() => _AuraActionPillButtonState();
}

class _AuraActionPillButtonState extends State<AuraActionPillButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.93 : 1.0,
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOutBack,
        child: Container(
          height: 54,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            gradient: LinearGradient(
              colors: [widget.palette.primary, widget.palette.secondary],
            ),
            border: Border.all(color: Colors.white.withOpacity(0.45), width: 1.2),
            boxShadow: [
              BoxShadow(
                color: widget.palette.primary.withOpacity(0.38),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(width: 34),
              Text(
                widget.textBn,
                style: AuraTextStyles.titleMedium(Colors.white, size: 16.5),
              ),
              Container(
                width: 34,
                height: 34,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
                child: Icon(
                  Icons.arrow_forward_rounded,
                  color: widget.palette.primary,
                  size: 19,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Spring-Bouncy Animated Calculator Keypad Button
class AnimatedCalculatorKey extends StatefulWidget {
  final String label;
  final bool isOperator;
  final bool isAccentEquals;
  final bool isUtility;
  final ActiveAuraPalette palette;
  final VoidCallback onTap;

  const AnimatedCalculatorKey({
    super.key,
    required this.label,
    this.isOperator = false,
    this.isAccentEquals = false,
    this.isUtility = false,
    required this.palette,
    required this.onTap,
  });

  @override
  State<AnimatedCalculatorKey> createState() => _AnimatedCalculatorKeyState();
}

class _AnimatedCalculatorKeyState extends State<AnimatedCalculatorKey> {
  bool _pressed = false;
  int _tapParity = 0;

  @override
  Widget build(BuildContext context) {
    final palette = widget.palette;
    final double radius = switch (palette.style) {
      AuraThemeStyle.soloNeon => 14,
      AuraThemeStyle.soft3D => 22,
      AuraThemeStyle.botanicalGlass => 18,
    };

    final Gradient bgGradient = widget.isAccentEquals
        ? LinearGradient(colors: [palette.primary, palette.secondary])
        : widget.isOperator
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  palette.primary.withOpacity(0.32),
                  palette.secondary.withOpacity(0.18),
                ],
              )
            : widget.isUtility
                ? LinearGradient(
                    colors: [
                      palette.secondary.withOpacity(0.22),
                      palette.secondary.withOpacity(0.10),
                    ],
                  )
                : switch (palette.style) {
                    AuraThemeStyle.soloNeon => const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0xFF1D1632), Color(0xFF100C1E)],
                      ),
                    AuraThemeStyle.soft3D => const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFFFFFFFF), Color(0xFFEDE8DF)],
                      ),
                    AuraThemeStyle.botanicalGlass => LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white.withOpacity(0.20),
                          const Color(0x80091C26),
                        ],
                      ),
                  };

    final Color textColor = widget.isAccentEquals
        ? Colors.white
        : widget.isOperator
            ? (palette.style == AuraThemeStyle.soft3D
                ? palette.primary
                : palette.glow)
            : palette.textPrimary;

    return GestureDetector(
      onTapDown: (_) => setState(() {
        _pressed = true;
        _tapParity++;
      }),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.86 : 1.0,
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOutBack,
        child: AnimatedRotation(
          turns: _pressed ? (_tapParity.isEven ? -0.015 : 0.015) : 0.0,
          duration: const Duration(milliseconds: 140),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(radius),
              gradient: bgGradient,
              border: Border.all(
                color: widget.isAccentEquals
                    ? Colors.white.withOpacity(0.75)
                    : palette.style == AuraThemeStyle.soft3D
                        ? Colors.white
                        : palette.primary.withOpacity(widget.isOperator ? 0.75 : 0.35),
                width: palette.style == AuraThemeStyle.soft3D ? 2.0 : 1.2,
              ),
              boxShadow: palette.style == AuraThemeStyle.soft3D
                  ? [
                      BoxShadow(
                        color: palette.primary.withOpacity(0.14),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : widget.isAccentEquals
                      ? [
                          BoxShadow(
                            color: palette.primary.withOpacity(0.45),
                            blurRadius: 12,
                          ),
                        ]
                      : null,
            ),
            child: Center(
              child: Text(
                widget.label,
                style: AuraTextStyles.titleLarge(
                  textColor,
                  size: widget.label.length > 2 ? 19 : 24,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
