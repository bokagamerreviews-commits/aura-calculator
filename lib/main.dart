import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'artistic_widgets.dart';
import 'calculator_engines.dart';
import 'theme_engine.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
    ),
  );
  runApp(const AuraCalculatorApp());
}

enum AuraScreen {
  calculator('আউরা ক্যালকুলেটর', 'assets/images/ic_3d_calculator.png', Icons.calculate_rounded),
  ageDate('বয়স ও তারিখের হিসাব', 'assets/images/ic_3d_age.png', Icons.calendar_month_rounded),
  percentage('শতকরা ক্যালকুলেটর', 'assets/images/ic_3d_percentage.png', Icons.percent_rounded),
  converterWeightDist('ওজন ও দূরত্ব কনভার্টার', 'assets/images/ic_3d_converter.png', Icons.swap_calls_rounded),
  converterLand('জমি ও এলাকার মাপ', 'assets/images/ic_3d_area.png', Icons.landscape_rounded),
  converterTempData('তাপমাত্রা ও ডেটা কনভার্টার', 'assets/images/ic_3d_temperature.png', Icons.thermostat_rounded),
  themeStudio('থিম ও কালার স্টুডিও', 'assets/images/ic_3d_theme.png', Icons.palette_rounded);

  final String titleBn;
  final String iconAsset;
  final IconData fallbackIcon;
  const AuraScreen(this.titleBn, this.iconAsset, this.fallbackIcon);
}

class AuraCalculatorApp extends StatefulWidget {
  const AuraCalculatorApp({super.key});

  @override
  State<AuraCalculatorApp> createState() => _AuraCalculatorAppState();
}

class _AuraCalculatorAppState extends State<AuraCalculatorApp> {
  AuraThemeStyle _themeStyle = AuraThemeStyle.soloNeon;
  int _neonPresetId = 0;
  int _soft3dPresetId = 0;
  bool _useBnDigits = true;

  // Custom Glass Wallpaper State
  String? _customWallpaperPath;
  double _glassBlurSigma = 18.0;
  Color _glassPrimary = ActiveAuraPalette.defaultGlassPrimary;
  Color _glassSecondary = ActiveAuraPalette.defaultGlassSecondary;
  Color _glassGlow = ActiveAuraPalette.defaultGlassGlow;

  AuraScreen _currentScreen = AuraScreen.calculator;
  ConverterCategory _initialConverterCategory = ConverterCategory.weight;
  int _headerSpinTrigger = 0;
  final List<CalcHistoryItem> _history = [];

  @override
  void initState() {
    super.initState();
    _loadSavedPrefs();
  }

  Future<void> _loadSavedPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _themeStyle = AuraThemeStyle.fromId(prefs.getInt('theme_style') ?? 0);
      _neonPresetId = prefs.getInt('neon_preset') ?? 0;
      _soft3dPresetId = prefs.getInt('soft3d_preset') ?? 0;
      _useBnDigits = prefs.getBool('use_bn_digits') ?? true;
      _customWallpaperPath = prefs.getString('custom_wallpaper_path');
      _glassBlurSigma = prefs.getDouble('glass_blur_sigma') ?? 18.0;
      _glassPrimary = Color(
        prefs.getInt('glass_primary') ?? ActiveAuraPalette.defaultGlassPrimary.value,
      );
      _glassSecondary = Color(
        prefs.getInt('glass_secondary') ?? ActiveAuraPalette.defaultGlassSecondary.value,
      );
      _glassGlow = Color(
        prefs.getInt('glass_glow') ?? ActiveAuraPalette.defaultGlassGlow.value,
      );
    });
  }

  Future<void> _savePrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('theme_style', _themeStyle.id);
    await prefs.setInt('neon_preset', _neonPresetId);
    await prefs.setInt('soft3d_preset', _soft3dPresetId);
    await prefs.setBool('use_bn_digits', _useBnDigits);
    await prefs.setDouble('glass_blur_sigma', _glassBlurSigma);
    await prefs.setInt('glass_primary', _glassPrimary.value);
    await prefs.setInt('glass_secondary', _glassSecondary.value);
    await prefs.setInt('glass_glow', _glassGlow.value);
    if (_customWallpaperPath != null) {
      await prefs.setString('custom_wallpaper_path', _customWallpaperPath!);
    } else {
      await prefs.remove('custom_wallpaper_path');
    }
  }

  Future<void> _pickCustomWallpaper() async {
    final picker = ImagePicker();
    final XFile? picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    final file = File(picked.path);
    final extracted = await WallpaperColorExtractor.extractHarmoniousColors(file);
    setState(() {
      _customWallpaperPath = file.path;
      _glassPrimary = extracted[0];
      _glassSecondary = extracted[1];
      _glassGlow = extracted[2];
      _headerSpinTrigger++;
    });
    await _savePrefs();
  }

  Future<void> _resetCurrentTheme() async {
    setState(() {
      switch (_themeStyle) {
        case AuraThemeStyle.soloNeon:
          _neonPresetId = 0;
          break;
        case AuraThemeStyle.soft3D:
          _soft3dPresetId = 0;
          break;
        case AuraThemeStyle.botanicalGlass:
          _customWallpaperPath = null;
          _glassBlurSigma = 18.0;
          _glassPrimary = ActiveAuraPalette.defaultGlassPrimary;
          _glassSecondary = ActiveAuraPalette.defaultGlassSecondary;
          _glassGlow = ActiveAuraPalette.defaultGlassGlow;
          break;
      }
      _headerSpinTrigger += 2;
    });
    await _savePrefs();
  }

  @override
  Widget build(BuildContext context) {
    final palette = ActiveAuraPalette.build(
      style: _themeStyle,
      neonPresetId: _neonPresetId,
      soft3dPresetId: _soft3dPresetId,
      glassPrimary: _glassPrimary,
      glassSecondary: _glassSecondary,
      glassGlow: _glassGlow,
    );

    return MaterialApp(
      title: 'আউরা ক্যালকুলেটর',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: AuraTextStyles.fontFamily,
      ),
      home: PopScope(
        canPop: _currentScreen == AuraScreen.calculator,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop && _currentScreen != AuraScreen.calculator) {
            setState(() {
              _currentScreen = AuraScreen.calculator;
              _headerSpinTrigger++;
            });
          }
        },
        child: Scaffold(
          backgroundColor: palette.bgTop,
          body: Stack(
            fit: StackFit.expand,
            children: [
              // 1. Dynamic Theme Background
              _buildMasterBackground(palette),

              // 2. Main Foreground UI
              SafeArea(
                child: Column(
                  children: [
                    _buildTopBar(palette),
                    Expanded(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 320),
                        switchInCurve: Curves.easeOutBack,
                        transitionBuilder: (child, anim) {
                          return FadeTransition(
                            opacity: anim,
                            child: ScaleTransition(
                              scale: Tween<double>(begin: 0.94, end: 1.0).animate(anim),
                              child: child,
                            ),
                          );
                        },
                        child: _buildActiveScreen(palette),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMasterBackground(ActiveAuraPalette palette) {
    switch (palette.style) {
      case AuraThemeStyle.soloNeon:
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [palette.bgTop, palette.bgBottom, const Color(0xFF06040D)],
            ),
          ),
          child: CustomPaint(
            painter: _SoloOuterFramePainter(color: palette.primary),
          ),
        );

      case AuraThemeStyle.soft3D:
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [palette.bgTop, const Color(0xFFF3EFEA), palette.bgBottom],
            ),
          ),
        );

      case AuraThemeStyle.botanicalGlass:
        final bool hasCustom = _customWallpaperPath != null &&
            File(_customWallpaperPath!).existsSync();
        return Stack(
          fit: StackFit.expand,
          children: [
            hasCustom
                ? Image.file(
                    File(_customWallpaperPath!),
                    fit: BoxFit.cover,
                  )
                : Image.asset(
                    'assets/images/bg_botanical_glass.jpg',
                    fit: BoxFit.cover,
                  ),
            if (hasCustom)
              BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: _glassBlurSigma,
                  sigmaY: _glassBlurSigma,
                ),
                child: Container(color: Colors.black.withOpacity(0.28)),
              )
            else
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0x4404131A),
                      Color(0x66061822),
                      Color(0x88041017),
                    ],
                  ),
                ),
              ),
          ],
        );
    }
  }

  Widget _buildTopBar(ActiveAuraPalette palette) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      child: Row(
        children: [
          if (_currentScreen != AuraScreen.calculator)
            GestureDetector(
              onTap: () => setState(() {
                _currentScreen = AuraScreen.calculator;
                _headerSpinTrigger++;
              }),
              child: Container(
                width: 42,
                height: 42,
                margin: const EdgeInsets.only(right: 10),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: palette.primary.withOpacity(0.20),
                  border: Border.all(color: palette.primary.withOpacity(0.5)),
                ),
                child: Icon(Icons.arrow_back_rounded, color: palette.textPrimary),
              ),
            )
          else ...[
            AnimatedAuraIcon(
              assetPath: _currentScreen.iconAsset,
              fallbackIcon: _currentScreen.fallbackIcon,
              palette: palette,
              size: 44,
              spinTrigger: _headerSpinTrigger,
            ),
            const SizedBox(width: 10),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _currentScreen.titleBn,
                  style: AuraTextStyles.titleMedium(palette.textPrimary, size: 18.5),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  palette.style.titleBn,
                  style: AuraTextStyles.bodyRegular(palette.textSecondary, size: 11.5),
                ),
              ],
            ),
          ),
          // Bangla / English Digit Switch
          GestureDetector(
            onTap: () {
              setState(() {
                _useBnDigits = !_useBnDigits;
                _headerSpinTrigger++;
              });
              _savePrefs();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: palette.primary.withOpacity(0.18),
                border: Border.all(color: palette.primary.withOpacity(0.5)),
              ),
              child: Text(
                _useBnDigits ? 'বাং ১২৩' : 'EN 123',
                style: AuraTextStyles.bodyBold(palette.textPrimary, size: 12),
              ),
            ),
          ),
          const SizedBox(width: 6),
          // Theme Studio Quick Button
          GestureDetector(
            onTap: () => setState(() {
              _currentScreen = AuraScreen.themeStudio;
              _headerSpinTrigger++;
            }),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: palette.primary.withOpacity(0.18),
                border: Border.all(color: palette.primary.withOpacity(0.45)),
              ),
              child: Icon(Icons.palette_rounded, color: palette.primary, size: 20),
            ),
          ),
          const SizedBox(width: 6),
          // Three-Dot Menu Button (⋮)
          Builder(
            builder: (ctx) => GestureDetector(
              onTap: () => _showAnimatedThreeDotMenu(ctx, palette),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [palette.primary, palette.secondary],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: palette.primary.withOpacity(0.40),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: const Icon(Icons.more_vert_rounded, color: Colors.white, size: 21),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveScreen(ActiveAuraPalette palette) {
    switch (_currentScreen) {
      case AuraScreen.calculator:
        return _NormalCalculatorView(
          key: const ValueKey('calc'),
          palette: palette,
          useBnDigits: _useBnDigits,
          history: _history,
          onAddHistory: (item) => setState(() => _history.add(item)),
          onOpenHistory: () => _showHistoryModal(context, palette),
        );
      case AuraScreen.ageDate:
        return _AgeAndDateView(
          key: const ValueKey('age'),
          palette: palette,
          useBnDigits: _useBnDigits,
        );
      case AuraScreen.percentage:
        return _PercentageView(
          key: const ValueKey('pct'),
          palette: palette,
          useBnDigits: _useBnDigits,
        );
      case AuraScreen.converterWeightDist:
      case AuraScreen.converterLand:
      case AuraScreen.converterTempData:
        return _UnitConverterView(
          key: ValueKey('conv_${_initialConverterCategory.name}'),
          palette: palette,
          useBnDigits: _useBnDigits,
          initialCategory: _initialConverterCategory,
        );
      case AuraScreen.themeStudio:
        return _ThemeStudioView(
          key: const ValueKey('theme'),
          palette: palette,
          neonPresetId: _neonPresetId,
          soft3dPresetId: _soft3dPresetId,
          hasCustomWallpaper: _customWallpaperPath != null,
          blurSigma: _glassBlurSigma,
          onSelectStyle: (s) {
            setState(() {
              _themeStyle = s;
              _headerSpinTrigger++;
            });
            _savePrefs();
          },
          onSelectNeonPreset: (id) {
            setState(() {
              _neonPresetId = id;
              _headerSpinTrigger++;
            });
            _savePrefs();
          },
          onSelectSoftPreset: (id) {
            setState(() {
              _soft3dPresetId = id;
              _headerSpinTrigger++;
            });
            _savePrefs();
          },
          onPickWallpaper: _pickCustomWallpaper,
          onChangeBlur: (val) {
            setState(() => _glassBlurSigma = val);
            _savePrefs();
          },
          onResetTheme: _resetCurrentTheme,
        );
    }
  }

  void _showAnimatedThreeDotMenu(BuildContext context, ActiveAuraPalette palette) {
    final items = [
      (
        'সাধারণ ক্যালকুলেটর',
        'লাইভ প্রিভিউ ও ব্র্যাকেটসহ মূল ক্যালকুলেটর',
        AuraScreen.calculator,
        null,
      ),
      (
        'বয়স ও তারিখের পার্থক্য',
        'জন্মতারিখ থেকে বয়স ও দুটি তারিখের ব্যবধান',
        AuraScreen.ageDate,
        null,
      ),
      (
        'শতকরা (Percentage) হিসাব',
        'পরিমাণ ও শতকরা হার থেকে তাৎক্ষণিক উত্তর',
        AuraScreen.percentage,
        null,
      ),
      (
        'ওজন ও দূরত্ব কনভার্টার',
        'কেজি, গ্রাম, পাউন্ড, মিটার, ফুট, মাইল',
        AuraScreen.converterWeightDist,
        ConverterCategory.weight,
      ),
      (
        'জমি ও এলাকার মাপ',
        'শতাংশ, কাঠা, বিঘা, বর্গফুট ও একর হিসাব',
        AuraScreen.converterLand,
        ConverterCategory.landArea,
      ),
      (
        'তাপমাত্রা ও ডেটা কনভার্টার',
        'সেলসিয়াস, ফারেনহাইট এবং KB, MB, GB, TB',
        AuraScreen.converterTempData,
        ConverterCategory.temperature,
      ),
      (
        'থিম ও কালার স্টুডিও (৩টি থিম)',
        'নিওন, থ্রিডি আইকন, গ্লাস ব্লার ও রিসেট',
        AuraScreen.themeStudio,
        null,
      ),
    ];

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'মেনু',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (ctx, anim1, anim2) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Material(
              color: Colors.transparent,
              child: AuraThemedCard(
                palette: palette,
                borderRadius: 28,
                padding: const EdgeInsets.all(18),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'আউরা টুলস ও থিম মেনু',
                            style: AuraTextStyles.titleLarge(palette.textPrimary),
                          ),
                          IconButton(
                            onPressed: () => Navigator.pop(ctx),
                            icon: Icon(Icons.close_rounded, color: palette.textPrimary),
                          ),
                        ],
                      ),
                      if (palette.style == AuraThemeStyle.soloNeon)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: SoloNeonOrnateDivider(palette: palette),
                        ),
                      ...items.asMap().entries.map((entry) {
                        final item = entry.value;
                        final bool isSelected = _currentScreen == item.$3;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(18),
                            onTap: () {
                              Navigator.pop(ctx);
                              setState(() {
                                if (item.$4 != null) {
                                  _initialConverterCategory = item.$4!;
                                }
                                _currentScreen = item.$3;
                                _headerSpinTrigger++;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(18),
                                color: palette.primary.withOpacity(isSelected ? 0.24 : 0.09),
                                border: Border.all(
                                  color: palette.primary.withOpacity(isSelected ? 0.85 : 0.30),
                                  width: isSelected ? 1.6 : 1.0,
                                ),
                              ),
                              child: Row(
                                children: [
                                  AnimatedAuraIcon(
                                    assetPath: item.$3.iconAsset,
                                    fallbackIcon: item.$3.fallbackIcon,
                                    palette: palette,
                                    size: 46,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.$1,
                                          style: AuraTextStyles.bodyBold(palette.textPrimary, size: 15),
                                        ),
                                        Text(
                                          item.$2,
                                          style: AuraTextStyles.bodyRegular(palette.textSecondary, size: 11.5),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
      transitionBuilder: (ctx, anim, _, child) {
        return ScaleTransition(
          scale: CurvedAnimation(parent: anim, curve: Curves.easeOutBack),
          child: FadeTransition(opacity: anim, child: child),
        );
      },
    );
  }

  void _showHistoryModal(BuildContext context, ActiveAuraPalette palette) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: AuraThemedCard(
          palette: palette,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      AnimatedAuraIcon(
                        assetPath: 'assets/images/ic_3d_history.png',
                        fallbackIcon: Icons.history_rounded,
                        palette: palette,
                        size: 42,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'হিসাবের ইতিহাস',
                        style: AuraTextStyles.titleMedium(palette.textPrimary),
                      ),
                    ],
                  ),
                  if (_history.isNotEmpty)
                    IconButton(
                      onPressed: () {
                        setState(() => _history.clear());
                        Navigator.pop(ctx);
                      },
                      icon: Icon(Icons.delete_sweep_rounded, color: palette.secondary),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              if (_history.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Text(
                    'এখনও কোনো হিসাব সংরক্ষিত হয়নি।',
                    style: AuraTextStyles.bodyRegular(palette.textSecondary),
                  ),
                )
              else
                SizedBox(
                  height: 260,
                  child: ListView.separated(
                    itemCount: _history.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (_, idx) {
                      final h = _history[_history.length - 1 - idx];
                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          color: palette.primary.withOpacity(0.14),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              h.timestampBn,
                              style: AuraTextStyles.bodyRegular(palette.textSecondary, size: 11),
                            ),
                            Text(
                              h.expression,
                              style: AuraTextStyles.bodyBold(palette.textSecondary),
                            ),
                            Text(
                              '= ${h.result}',
                              style: AuraTextStyles.titleMedium(palette.primary),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text(
                    'বন্ধ করুন',
                    style: AuraTextStyles.bodyBold(palette.primary),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SoloOuterFramePainter extends CustomPainter {
  final Color color;
  _SoloOuterFramePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.32)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(8, 8, size.width - 16, size.height - 16),
        const Radius.circular(28),
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _SoloOuterFramePainter oldDelegate) =>
      oldDelegate.color != color;
}

// ============================================================================
// VIEW 1: NORMAL CALCULATOR
// ============================================================================
class _NormalCalculatorView extends StatefulWidget {
  final ActiveAuraPalette palette;
  final bool useBnDigits;
  final List<CalcHistoryItem> history;
  final ValueChanged<CalcHistoryItem> onAddHistory;
  final VoidCallback onOpenHistory;

  const _NormalCalculatorView({
    super.key,
    required this.palette,
    required this.useBnDigits,
    required this.history,
    required this.onAddHistory,
    required this.onOpenHistory,
  });

  @override
  State<_NormalCalculatorView> createState() => _NormalCalculatorViewState();
}

class _NormalCalculatorViewState extends State<_NormalCalculatorView> {
  String _expr = '';
  String _lastResult = '';
  int _spinTrigger = 0;

  void _append(String token) {
    setState(() {
      _spinTrigger++;
      const ops = {'+', '-', '×', '÷', '%'};
      if (ops.contains(token) && _expr.isEmpty && _lastResult.isNotEmpty) {
        _expr = _lastResult + token;
        return;
      }
      if ({'+', '×', '÷'}.contains(token) && _expr.isNotEmpty) {
        final last = _expr[_expr.length - 1];
        if ({'+', '-', '×', '÷'}.contains(last)) {
          _expr = _expr.substring(0, _expr.length - 1) + token;
          return;
        }
      }
      _expr += token;
    });
  }

  void _handleParens() {
    setState(() {
      _spinTrigger++;
      final open = '('.allMatches(_expr).length;
      final close = ')'.allMatches(_expr).length;
      final last = _expr.isNotEmpty ? _expr[_expr.length - 1] : '';
      final shouldClose =
          open > close && (RegExp(r'[0-9)%]$').hasMatch(last));
      _expr += shouldClose ? ')' : '(';
    });
  }

  void _handleEquals() {
    final val = MathEvaluator.evaluate(_expr);
    if (val == null) return;
    final formattedEn = BengaliNumeralFormatter.formatNumber(val, false);
    final formattedDisp = BengaliNumeralFormatter.formatNumber(val, widget.useBnDigits);
    final dispExpr = BengaliNumeralFormatter.toOutputDigits(_expr, widget.useBnDigits);
    final now = TimeOfDay.now();
    final timeStr = BengaliNumeralFormatter.toOutputDigits(
      '${now.hourOfPeriod == 0 ? 12 : now.hourOfPeriod}:${now.minute.toString().padLeft(2, '0')}',
      widget.useBnDigits,
    );

    widget.onAddHistory(
      CalcHistoryItem(
        expression: dispExpr,
        result: formattedDisp,
        timestampBn: timeStr,
      ),
    );

    setState(() {
      _spinTrigger += 2;
      _lastResult = formattedEn;
      _expr = formattedEn;
    });
  }

  @override
  Widget build(BuildContext context) {
    final palette = widget.palette;
    final liveVal = MathEvaluator.evaluate(_expr);
    final liveStr = liveVal != null
        ? BengaliNumeralFormatter.formatNumber(liveVal, widget.useBnDigits)
        : '';

    final shownExpr = _expr.isEmpty
        ? BengaliNumeralFormatter.toOutputDigits('0', widget.useBnDigits)
        : BengaliNumeralFormatter.toOutputDigits(_expr, widget.useBnDigits);

    final rows = [
      ['AC', '()', '%', '÷'],
      ['7', '8', '9', '×'],
      ['4', '5', '6', '-'],
      ['1', '2', '3', '+'],
      ['0', '.', '⌫', '='],
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      child: Column(
        children: [
          Expanded(
            flex: 38,
            child: AuraThemedCard(
              palette: palette,
              borderRadius: 28,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          AnimatedAuraIcon(
                            assetPath: 'assets/images/ic_3d_calculator.png',
                            fallbackIcon: Icons.calculate_rounded,
                            palette: palette,
                            size: 42,
                            spinTrigger: _spinTrigger,
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'স্মার্ট ক্যালকুলেটর',
                                style: AuraTextStyles.bodyBold(palette.textPrimary),
                              ),
                              Text(
                                'লাইভ ফলাফল প্রিভিউ সক্রিয়',
                                style: AuraTextStyles.bodyRegular(palette.textSecondary, size: 11),
                              ),
                            ],
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: widget.onOpenHistory,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: palette.primary.withOpacity(0.18),
                            border: Border.all(color: palette.primary.withOpacity(0.45)),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.history_rounded, size: 16, color: palette.primary),
                              const SizedBox(width: 5),
                              Text(
                                'ইতিহাস (${BengaliNumeralFormatter.toOutputDigits(widget.history.length.toString(), widget.useBnDigits)})',
                                style: AuraTextStyles.bodyBold(palette.textPrimary, size: 12),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (palette.style == AuraThemeStyle.soloNeon)
                    SoloNeonOrnateDivider(palette: palette),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        shownExpr,
                        style: AuraTextStyles.hero(
                          palette.textPrimary,
                          size: shownExpr.length > 12 ? 28 : 38,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.right,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        liveStr.isNotEmpty && _expr.isNotEmpty ? '= $liveStr' : ' ',
                        style: AuraTextStyles.titleLarge(
                          palette.style == AuraThemeStyle.soft3D
                              ? palette.primary
                              : palette.glow,
                          size: 21,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            flex: 62,
            child: Column(
              children: rows.map((row) {
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      children: row.map((key) {
                        final label = key == 'AC'
                            ? 'AC'
                            : key == '()'
                                ? '( )'
                                : BengaliNumeralFormatter.toOutputDigits(
                                    key,
                                    widget.useBnDigits,
                                  );
                        final isOp = {'÷', '×', '-', '+'}.contains(key);
                        final isUtil = {'AC', '()', '%', '⌫'}.contains(key);
                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 5),
                            child: AnimatedCalculatorKey(
                              label: label,
                              isOperator: isOp,
                              isUtility: isUtil,
                              isAccentEquals: key == '=',
                              palette: palette,
                              onTap: () {
                                if (key == 'AC') {
                                  setState(() {
                                    _expr = '';
                                    _lastResult = '';
                                    _spinTrigger++;
                                  });
                                } else if (key == '()') {
                                  _handleParens();
                                } else if (key == '⌫') {
                                  setState(() {
                                    if (_expr.isNotEmpty) {
                                      _expr = _expr.substring(0, _expr.length - 1);
                                    }
                                    _spinTrigger++;
                                  });
                                } else if (key == '=') {
                                  _handleEquals();
                                } else if (key == '.') {
                                  final lastSeg = _expr.split(RegExp(r'[+\-×÷()]')).last;
                                  if (!lastSeg.contains('.')) {
                                    _append(lastSeg.isEmpty ? '0.' : '.');
                                  }
                                } else {
                                  _append(key);
                                }
                              },
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// VIEW 2: AGE & DATE DIFFERENCE CALCULATOR
// ============================================================================
class _AgeAndDateView extends StatefulWidget {
  final ActiveAuraPalette palette;
  final bool useBnDigits;

  const _AgeAndDateView({
    super.key,
    required this.palette,
    required this.useBnDigits,
  });

  @override
  State<_AgeAndDateView> createState() => _AgeAndDateViewState();
}

class _AgeAndDateViewState extends State<_AgeAndDateView> {
  int _tab = 0;
  DateTime _birthDate = DateTime(2000, 8, 15);
  DateTime _startDate = DateTime(2024, 1, 1);
  DateTime _endDate = DateTime.now();
  int _spinTrigger = 0;

  String _formatDateBn(DateTime d) {
    final day = BengaliNumeralFormatter.toOutputDigits(d.day.toString(), widget.useBnDigits);
    final month = AgeDateEngine.bengaliMonths[d.month - 1];
    final year = BengaliNumeralFormatter.toOutputDigits(d.year.toString(), widget.useBnDigits);
    return '$day $month, $year';
  }

  @override
  Widget build(BuildContext context) {
    final palette = widget.palette;
    final ageRes = AgeDateEngine.calculateAge(_birthDate);
    final diffRes = AgeDateEngine.calculateDifference(_startDate, _endDate);

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      children: [
        AuraThemedCard(
          palette: palette,
          child: Row(
            children: [
              AnimatedAuraIcon(
                assetPath: 'assets/images/ic_3d_age.png',
                fallbackIcon: Icons.calendar_month_rounded,
                palette: palette,
                size: 62,
                spinTrigger: _spinTrigger,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('বয়স ও তারিখের হিসাব', style: AuraTextStyles.titleLarge(palette.textPrimary)),
                    Text(
                      'জন্মতারিখ বা যেকোনো দুটি তারিখের নিখুঁত ব্যবধান',
                      style: AuraTextStyles.bodyRegular(palette.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildTabPill('বয়স ক্যালকুলেটর', 0, palette),
            const SizedBox(width: 10),
            _buildTabPill('তারিখের পার্থক্য', 1, palette),
          ],
        ),
        const SizedBox(height: 12),
        if (_tab == 0) ...[
          AuraThemedCard(
            palette: palette,
            glassTintIndex: 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('আপনার জন্মতারিখ নির্বাচন করুন', style: AuraTextStyles.titleMedium(palette.textPrimary)),
                const SizedBox(height: 12),
                _buildDateSelectorBox(
                  label: 'নির্বাচিত জন্মতারিখ',
                  value: _formatDateBn(_birthDate),
                  palette: palette,
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _birthDate,
                      firstDate: DateTime(1900),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) {
                      setState(() {
                        _birthDate = picked;
                        _spinTrigger++;
                      });
                    }
                  },
                ),
                const SizedBox(height: 14),
                AuraActionPillButton(
                  textBn: 'বয়স হিসাব করুন',
                  palette: palette,
                  onTap: () => setState(() => _spinTrigger++),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          AuraThemedCard(
            palette: palette,
            glassTintIndex: 2,
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('আপনার বর্তমান বয়স', style: AuraTextStyles.bodyRegular(palette.textSecondary)),
                          const SizedBox(height: 4),
                          Text(
                            '${BengaliNumeralFormatter.toOutputDigits(ageRes.years.toString(), widget.useBnDigits)} বছর '
                            '${BengaliNumeralFormatter.toOutputDigits(ageRes.months.toString(), widget.useBnDigits)} মাস '
                            '${BengaliNumeralFormatter.toOutputDigits(ageRes.days.toString(), widget.useBnDigits)} দিন',
                            style: AuraTextStyles.titleLarge(palette.textPrimary, size: 23),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'জন্মবার: ${ageRes.birthDayOfWeekBn}',
                            style: AuraTextStyles.bodyBold(palette.primary),
                          ),
                        ],
                      ),
                    ),
                    CircularGlowGauge(
                      percent: ageRes.yearProgressPercent,
                      labelCenterBn: '${BengaliNumeralFormatter.toOutputDigits(ageRes.yearProgressPercent.round().toString(), widget.useBnDigits)}%',
                      labelSubBn: 'বর্ষচক্র',
                      palette: palette,
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatMiniPod(
                        'পরবর্তী জন্মদিন',
                        '${BengaliNumeralFormatter.toOutputDigits(ageRes.nextBirthdayMonths.toString(), widget.useBnDigits)} মাস '
                        '${BengaliNumeralFormatter.toOutputDigits(ageRes.nextBirthdayDays.toString(), widget.useBnDigits)} দিন',
                        palette,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildStatMiniPod(
                        'মোট দিন',
                        BengaliNumeralFormatter.toOutputDigits(ageRes.totalDays.toString(), widget.useBnDigits),
                        palette,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatMiniPod(
                        'মোট সপ্তাহ',
                        BengaliNumeralFormatter.toOutputDigits(ageRes.totalWeeks.toString(), widget.useBnDigits),
                        palette,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildStatMiniPod(
                        'মোট ঘণ্টা',
                        BengaliNumeralFormatter.toOutputDigits(ageRes.totalHours.toString(), widget.useBnDigits),
                        palette,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ] else ...[
          AuraThemedCard(
            palette: palette,
            glassTintIndex: 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('দুটি তারিখ নির্বাচন করুন', style: AuraTextStyles.titleMedium(palette.textPrimary)),
                const SizedBox(height: 12),
                _buildDateSelectorBox(
                  label: 'শুরুর তারিখ',
                  value: _formatDateBn(_startDate),
                  palette: palette,
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _startDate,
                      firstDate: DateTime(1900),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) setState(() => _startDate = picked);
                  },
                ),
                const SizedBox(height: 10),
                _buildDateSelectorBox(
                  label: 'শেষের তারিখ',
                  value: _formatDateBn(_endDate),
                  palette: palette,
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _endDate,
                      firstDate: DateTime(1900),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) setState(() => _endDate = picked);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          AuraThemedCard(
            palette: palette,
            glassTintIndex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('দুটি তারিখের ব্যবধান', style: AuraTextStyles.bodyRegular(palette.textSecondary)),
                const SizedBox(height: 6),
                Text(
                  '${BengaliNumeralFormatter.toOutputDigits(diffRes.years.toString(), widget.useBnDigits)} বছর '
                  '${BengaliNumeralFormatter.toOutputDigits(diffRes.months.toString(), widget.useBnDigits)} মাস '
                  '${BengaliNumeralFormatter.toOutputDigits(diffRes.days.toString(), widget.useBnDigits)} দিন',
                  style: AuraTextStyles.titleLarge(palette.textPrimary, size: 24),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatMiniPod(
                        'সর্বমোট দিন',
                        '${BengaliNumeralFormatter.toOutputDigits(diffRes.totalDays.toString(), widget.useBnDigits)} দিন',
                        palette,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildStatMiniPod(
                        'সর্বমোট সপ্তাহ',
                        '${BengaliNumeralFormatter.toOutputDigits(diffRes.totalWeeks.toString(), widget.useBnDigits)} সপ্তাহ',
                        palette,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildTabPill(String title, int index, ActiveAuraPalette palette) {
    final bool selected = _tab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() {
          _tab = index;
          _spinTrigger++;
        }),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            color: selected ? palette.primary : palette.cardSurface,
            border: Border.all(
              color: selected ? Colors.white.withOpacity(0.55) : palette.cardBorder,
            ),
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: AuraTextStyles.bodyBold(
              selected ? Colors.white : palette.textPrimary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDateSelectorBox({
    required String label,
    required String value,
    required ActiveAuraPalette palette,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: palette.primary.withOpacity(0.14),
          border: Border.all(color: palette.primary.withOpacity(0.55)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AuraTextStyles.bodyRegular(palette.textSecondary, size: 11.5)),
                Text(value, style: AuraTextStyles.titleMedium(palette.textPrimary)),
              ],
            ),
            Icon(Icons.calendar_month_rounded, color: palette.primary),
          ],
        ),
      ),
    );
  }

  Widget _buildStatMiniPod(String title, String value, ActiveAuraPalette palette) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: palette.primary.withOpacity(0.14),
        border: Border.all(color: palette.primary.withOpacity(0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AuraTextStyles.bodyRegular(palette.textSecondary, size: 11.5)),
          const SizedBox(height: 4),
          Text(value, style: AuraTextStyles.titleMedium(palette.textPrimary, size: 16.5)),
        ],
      ),
    );
  }
}

// ============================================================================
// VIEW 3: PERCENTAGE CALCULATOR (Amount + % = Answer Box)
// ============================================================================
class _PercentageView extends StatefulWidget {
  final ActiveAuraPalette palette;
  final bool useBnDigits;

  const _PercentageView({
    super.key,
    required this.palette,
    required this.useBnDigits,
  });

  @override
  State<_PercentageView> createState() => _PercentageViewState();
}

class _PercentageViewState extends State<_PercentageView> {
  final TextEditingController _amountCtrl = TextEditingController(text: '1000');
  final TextEditingController _pctCtrl = TextEditingController(text: '10');
  int _spinTrigger = 0;

  @override
  void dispose() {
    _amountCtrl.dispose();
    _pctCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = widget.palette;
    final amount = BengaliNumeralFormatter.parseDoubleSafe(_amountCtrl.text) ?? 0.0;
    final pct = BengaliNumeralFormatter.parseDoubleSafe(_pctCtrl.text) ?? 0.0;
    final answer = (amount * pct) / 100.0;

    final fmtAmount = BengaliNumeralFormatter.formatNumber(amount, widget.useBnDigits);
    final fmtPct = BengaliNumeralFormatter.formatNumber(pct, widget.useBnDigits);
    final fmtAns = BengaliNumeralFormatter.formatNumber(answer, widget.useBnDigits);

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      children: [
        AuraThemedCard(
          palette: palette,
          glassTintIndex: 2,
          child: Row(
            children: [
              AnimatedAuraIcon(
                assetPath: 'assets/images/ic_3d_percentage.png',
                fallbackIcon: Icons.percent_rounded,
                palette: palette,
                size: 62,
                spinTrigger: _spinTrigger,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('শতকরা (Percentage) হিসাব', style: AuraTextStyles.titleLarge(palette.textPrimary)),
                    Text(
                      'পরিমাণ ও শতকরা হার দিলে সরাসরি উত্তর বক্সে ফলাফল',
                      style: AuraTextStyles.bodyRegular(palette.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        AuraThemedCard(
          palette: palette,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildThemedField(
                controller: _amountCtrl,
                label: 'মোট পরিমাণ (Amount)',
                palette: palette,
                onChanged: (_) => setState(() => _spinTrigger++),
              ),
              const SizedBox(height: 12),
              _buildThemedField(
                controller: _pctCtrl,
                label: 'শতকরা হার (%)',
                suffix: '%',
                palette: palette,
                onChanged: (_) => setState(() => _spinTrigger++),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: ['5', '10', '15', '20', '25', '50', '75'].map((p) {
                  return GestureDetector(
                    onTap: () => setState(() {
                      _pctCtrl.text = p;
                      _spinTrigger++;
                    }),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: palette.primary.withOpacity(0.16),
                        border: Border.all(color: palette.primary.withOpacity(0.5)),
                      ),
                      child: Text(
                        '${BengaliNumeralFormatter.toOutputDigits(p, widget.useBnDigits)}%',
                        style: AuraTextStyles.bodyBold(palette.textPrimary),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        AuraThemedCard(
          palette: palette,
          glassTintIndex: 1,
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('উত্তর বক্স (Answer)', style: AuraTextStyles.bodyBold(palette.primary)),
                    const SizedBox(height: 4),
                    Text(
                      '$fmtAmount এর $fmtPct% =',
                      style: AuraTextStyles.bodyRegular(palette.textSecondary),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      fmtAns,
                      style: AuraTextStyles.hero(palette.textPrimary, size: 36),
                    ),
                  ],
                ),
              ),
              CircularGlowGauge(
                percent: pct.clamp(0.0, 100.0),
                labelCenterBn: '$fmtPct%',
                labelSubBn: 'হার',
                palette: palette,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildThemedField({
    required TextEditingController controller,
    required String label,
    String? suffix,
    required ActiveAuraPalette palette,
    required ValueChanged<String> onChanged,
  }) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      onChanged: onChanged,
      style: AuraTextStyles.titleLarge(palette.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: AuraTextStyles.bodyBold(palette.textSecondary),
        suffixText: suffix,
        suffixStyle: AuraTextStyles.titleLarge(palette.primary),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: palette.primary.withOpacity(0.45)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: palette.primary, width: 2),
        ),
      ),
    );
  }
}

// ============================================================================
// VIEW 4: UNIT CONVERTER (Weight, Distance, Land/Area, Temperature, Data)
// ============================================================================
class _UnitConverterView extends StatefulWidget {
  final ActiveAuraPalette palette;
  final bool useBnDigits;
  final ConverterCategory initialCategory;

  const _UnitConverterView({
    super.key,
    required this.palette,
    required this.useBnDigits,
    required this.initialCategory,
  });

  @override
  State<_UnitConverterView> createState() => _UnitConverterViewState();
}

class _UnitConverterViewState extends State<_UnitConverterView> {
  late ConverterCategory _cat;
  late List<UnitDefinition> _units;
  late UnitDefinition _from;
  late UnitDefinition _to;
  final TextEditingController _inputCtrl = TextEditingController(text: '1');
  int _spinTrigger = 0;

  @override
  void initState() {
    super.initState();
    _initCategory(widget.initialCategory);
  }

  void _initCategory(ConverterCategory c) {
    _cat = c;
    _units = UnitConverterEngine.unitsFor(c);
    _from = _units.first;
    _to = _units.length > 1 ? _units[1] : _units.first;
  }

  @override
  void dispose() {
    _inputCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = widget.palette;
    final inputVal = BengaliNumeralFormatter.parseDoubleSafe(_inputCtrl.text) ?? 0.0;
    final outVal = UnitConverterEngine.convert(inputVal, _from, _to, _cat);
    final fmtOut = BengaliNumeralFormatter.formatNumber(outVal, widget.useBnDigits);

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: ConverterCategory.values.map((c) {
              final selected = c == _cat;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () => setState(() {
                    _initCategory(c);
                    _spinTrigger++;
                  }),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      color: selected ? palette.primary : palette.cardSurface,
                      border: Border.all(
                        color: selected ? Colors.white.withOpacity(0.6) : palette.cardBorder,
                      ),
                    ),
                    child: Text(
                      c.titleBn,
                      style: AuraTextStyles.bodyBold(
                        selected ? Colors.white : palette.textPrimary,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 12),
        AuraThemedCard(
          palette: palette,
          glassTintIndex: _cat.id,
          child: Row(
            children: [
              AnimatedAuraIcon(
                assetPath: _cat.iconAsset,
                fallbackIcon: Icons.swap_calls_rounded,
                palette: palette,
                size: 60,
                spinTrigger: _spinTrigger,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${_cat.titleBn} রূপান্তরকারী', style: AuraTextStyles.titleLarge(palette.textPrimary)),
                    Text(_cat.subtitleBn, style: AuraTextStyles.bodyRegular(palette.textSecondary)),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        AuraThemedCard(
          palette: palette,
          glassTintIndex: 1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _inputCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                onChanged: (_) => setState(() => _spinTrigger++),
                style: AuraTextStyles.titleLarge(palette.textPrimary),
                decoration: InputDecoration(
                  labelText: 'মান লিখুন (${_from.nameBn})',
                  labelStyle: AuraTextStyles.bodyBold(palette.textSecondary),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: palette.primary.withOpacity(0.45)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: palette.primary, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildUnitDropdown(
                      label: 'থেকে (From)',
                      current: _from,
                      palette: palette,
                      onChanged: (u) => setState(() {
                        _from = u;
                        _spinTrigger++;
                      }),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: GestureDetector(
                      onTap: () => setState(() {
                        final tmp = _from;
                        _from = _to;
                        _to = tmp;
                        _spinTrigger += 2;
                      }),
                      child: Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [palette.primary, palette.secondary],
                          ),
                        ),
                        child: const Icon(Icons.swap_vert_rounded, color: Colors.white),
                      ),
                    ),
                  ),
                  Expanded(
                    child: _buildUnitDropdown(
                      label: 'তে (To)',
                      current: _to,
                      palette: palette,
                      onChanged: (u) => setState(() {
                        _to = u;
                        _spinTrigger++;
                      }),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  color: palette.primary.withOpacity(0.16),
                  border: Border.all(color: palette.primary.withOpacity(0.55)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${BengaliNumeralFormatter.formatNumber(inputVal, widget.useBnDigits)} ${_from.shortBn} সমান:',
                      style: AuraTextStyles.bodyRegular(palette.textSecondary),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$fmtOut ${_to.shortBn}',
                      style: AuraTextStyles.hero(palette.textPrimary, size: 30),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        AuraThemedCard(
          palette: palette,
          glassTintIndex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('সব এককে এক নজরে ফলাফল', style: AuraTextStyles.titleMedium(palette.textPrimary)),
              const SizedBox(height: 8),
              ..._units.map((u) {
                final v = UnitConverterEngine.convert(inputVal, _from, u, _cat);
                final isTarget = u.code == _to.code;
                return Container(
                  margin: const EdgeInsets.only(bottom: 6),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: palette.primary.withOpacity(isTarget ? 0.22 : 0.07),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(u.nameBn, style: AuraTextStyles.bodyBold(palette.textPrimary, size: 13.5)),
                      Text(
                        '${BengaliNumeralFormatter.formatNumber(v, widget.useBnDigits, maxDecimals: 4)} ${u.shortBn}',
                        style: AuraTextStyles.bodyBold(
                          isTarget ? palette.primary : palette.textSecondary,
                          size: 13.5,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUnitDropdown({
    required String label,
    required UnitDefinition current,
    required ActiveAuraPalette palette,
    required ValueChanged<UnitDefinition> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: palette.primary.withOpacity(0.14),
        border: Border.all(color: palette.primary.withOpacity(0.5)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: current.code,
          isExpanded: true,
          dropdownColor: palette.style == AuraThemeStyle.soft3D
              ? const Color(0xFFFAF7F2)
              : const Color(0xFF18142C),
          items: _units.map((u) {
            return DropdownMenuItem<String>(
              value: u.code,
              child: Text(
                u.nameBn,
                style: AuraTextStyles.bodyBold(palette.textPrimary, size: 13),
                overflow: TextOverflow.ellipsis,
              ),
            );
          }).toList(),
          onChanged: (code) {
            if (code == null) return;
            final found = _units.firstWhere((e) => e.code == code);
            onChanged(found);
          },
        ),
      ),
    );
  }
}

// ============================================================================
// VIEW 5: THEME & CUSTOMIZATION STUDIO
// ============================================================================
class _ThemeStudioView extends StatelessWidget {
  final ActiveAuraPalette palette;
  final int neonPresetId;
  final int soft3dPresetId;
  final bool hasCustomWallpaper;
  final double blurSigma;
  final ValueChanged<AuraThemeStyle> onSelectStyle;
  final ValueChanged<int> onSelectNeonPreset;
  final ValueChanged<int> onSelectSoftPreset;
  final VoidCallback onPickWallpaper;
  final ValueChanged<double> onChangeBlur;
  final VoidCallback onResetTheme;

  const _ThemeStudioView({
    super.key,
    required this.palette,
    required this.neonPresetId,
    required this.soft3dPresetId,
    required this.hasCustomWallpaper,
    required this.blurSigma,
    required this.onSelectStyle,
    required this.onSelectNeonPreset,
    required this.onSelectSoftPreset,
    required this.onPickWallpaper,
    required this.onChangeBlur,
    required this.onResetTheme,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      children: [
        AuraThemedCard(
          palette: palette,
          glassTintIndex: 2,
          child: Row(
            children: [
              AnimatedAuraIcon(
                assetPath: 'assets/images/ic_3d_theme.png',
                fallbackIcon: Icons.palette_rounded,
                palette: palette,
                size: 62,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('থিম ও ডিজাইন স্টুডিও', style: AuraTextStyles.titleLarge(palette.textPrimary)),
                    Text(
                      '৩টি সম্পূর্ণ ভিন্ন ইউআই লুক, ২০টি কালার মোড ও রিসেট সুবিধা',
                      style: AuraTextStyles.bodyRegular(palette.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        ...AuraThemeStyle.values.map((s) {
          final isSelected = palette.style == s;
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: GestureDetector(
              onTap: () => onSelectStyle(s),
              child: AuraThemedCard(
                palette: palette,
                glassTintIndex: s.id,
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(s.titleBn, style: AuraTextStyles.titleMedium(palette.textPrimary, size: 18)),
                          const SizedBox(height: 4),
                          Text(s.subtitleBn, style: AuraTextStyles.bodyRegular(palette.textSecondary)),
                        ],
                      ),
                    ),
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isSelected ? palette.primary : palette.primary.withOpacity(0.18),
                      ),
                      child: isSelected
                          ? const Icon(Icons.check_rounded, color: Colors.white)
                          : null,
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
        AuraThemedCard(
          palette: palette,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      switch (palette.style) {
                        AuraThemeStyle.soloNeon => '২০টি নিওন কালার মোড',
                        AuraThemeStyle.soft3D => '২০টি সফট থ্রিডি কালার মোড',
                        AuraThemeStyle.botanicalGlass => 'গ্লাস ব্যাকগ্রাউন্ড ও অটো-কালার',
                      },
                      style: AuraTextStyles.titleMedium(palette.textPrimary),
                    ),
                  ),
                  GestureDetector(
                    onTap: onResetTheme,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: palette.secondary.withOpacity(0.22),
                        border: Border.all(color: palette.secondary),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.refresh_rounded, size: 16, color: palette.textPrimary),
                          const SizedBox(width: 5),
                          Text(
                            'ডিফল্ট রিসেট',
                            style: AuraTextStyles.bodyBold(palette.textPrimary, size: 12.5),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              if (palette.style == AuraThemeStyle.soloNeon)
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: AuraColorPresets.neonPresets.map((p) {
                    return _buildColorChip(
                      preset: p,
                      selected: p.id == neonPresetId,
                      textColor: palette.textPrimary,
                      onTap: () => onSelectNeonPreset(p.id),
                    );
                  }).toList(),
                )
              else if (palette.style == AuraThemeStyle.soft3D)
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: AuraColorPresets.soft3DPresets.map((p) {
                    return _buildColorChip(
                      preset: p,
                      selected: p.id == soft3dPresetId,
                      textColor: palette.textPrimary,
                      onTap: () => onSelectSoftPreset(p.id),
                    );
                  }).toList(),
                )
              else ...[
                Text(
                  'গ্যালারি থেকে যেকোনো ছবি দিলে সেটি লাইভ ব্লার হয়ে যাবে এবং ছবির রঙের সাথে পুরো ইউআই-এর রঙ অটোমেটিক মিশে যাবে।',
                  style: AuraTextStyles.bodyRegular(palette.textSecondary),
                ),
                const SizedBox(height: 12),
                AuraActionPillButton(
                  textBn: 'গ্যালারি থেকে ব্যাকগ্রাউন্ড দিন',
                  palette: palette,
                  onTap: onPickWallpaper,
                ),
                if (hasCustomWallpaper) ...[
                  const SizedBox(height: 14),
                  Text(
                    'ব্লার (Blur) মাত্রা: ${BengaliNumeralFormatter.toOutputDigits(blurSigma.round().toString(), true)}',
                    style: AuraTextStyles.bodyBold(palette.textPrimary),
                  ),
                  Slider(
                    value: blurSigma,
                    min: 4,
                    max: 36,
                    activeColor: palette.primary,
                    onChanged: onChangeBlur,
                  ),
                ],
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildColorChip({
    required ColorPreset preset,
    required bool selected,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: preset.primary.withOpacity(selected ? 0.28 : 0.12),
          border: Border.all(
            color: selected ? preset.primary : preset.primary.withOpacity(0.45),
            width: selected ? 2.0 : 1.0,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(colors: [preset.primary, preset.secondary]),
                border: Border.all(color: Colors.white),
              ),
              child: selected
                  ? const Icon(Icons.check_rounded, size: 13, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 7),
            Text(preset.nameBn, style: AuraTextStyles.bodyBold(textColor, size: 12)),
          ],
        ),
      ),
    );
  }
}
