import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AuraThemeStyle {
  soloNeon(
    0,
    'সোলো নিওন সিস্টেম',
    'গ্লোয়িং আরপিজি ফ্রেম, ডার্ক ক্যানভাস ও ২০টি নিওন কালার',
  ),
  soft3D(
    1,
    'থ্রিডি সফট ক্লে স্টাইল',
    'রিয়েল থ্রিডি আইকন, ক্লেমরফিক কার্ড ও ২০টি প্যাস্টেল কালার',
  ),
  botanicalGlass(
    2,
    'বোটানিক্যাল গ্লাসমরফিজম',
    'লাইভ ফ্রস্টেড গ্লাস ব্লার, কাস্টম ওয়ালপেপার ও অটো-কালার মার্জ',
  );

  final int id;
  final String titleBn;
  final String subtitleBn;
  const AuraThemeStyle(this.id, this.titleBn, this.subtitleBn);

  static AuraThemeStyle fromId(int id) {
    return AuraThemeStyle.values.firstWhere(
      (e) => e.id == id,
      orElse: () => AuraThemeStyle.soloNeon,
    );
  }
}

class ColorPreset {
  final int id;
  final String nameBn;
  final Color primary;
  final Color secondary;
  final Color glow;

  const ColorPreset({
    required this.id,
    required this.nameBn,
    required this.primary,
    required this.secondary,
    required this.glow,
  });
}

class AuraColorPresets {
  // 20 Neon Color Presets for Theme 1 (Default = Solo Leveling Monarch Purple)
  static const List<ColorPreset> neonPresets = [
    ColorPreset(id: 0, nameBn: 'মনার্ক পার্পল (ডিফল্ট)', primary: Color(0xFFC468FF), secondary: Color(0xFF8C38F5), glow: Color(0xFFE59EFF)),
    ColorPreset(id: 1, nameBn: 'নিওন পিঙ্ক পালস', primary: Color(0xFFFF4DA6), secondary: Color(0xFFD91B78), glow: Color(0xFFFF8ECF)),
    ColorPreset(id: 2, nameBn: 'সাইবার গ্রিন', primary: Color(0xFF00F5A0), secondary: Color(0xFF00B874), glow: Color(0xFF72FFD0)),
    ColorPreset(id: 3, nameBn: 'ইলেকট্রিক ব্লু', primary: Color(0xFF28B5FF), secondary: Color(0xFF0077E6), glow: Color(0xFF8BE2FF)),
    ColorPreset(id: 4, nameBn: 'ক্রিমসন রেড', primary: Color(0xFFFF385C), secondary: Color(0xFFC81038), glow: Color(0xFFFF889E)),
    ColorPreset(id: 5, nameBn: 'ফিনিক্স গোল্ড', primary: Color(0xFFFFB82E), secondary: Color(0xFFE08200), glow: Color(0xFFFFDD85)),
    ColorPreset(id: 6, nameBn: 'অরোরা সায়ান', primary: Color(0xFF00E5FF), secondary: Color(0xFF0099B8), glow: Color(0xFF84F4FF)),
    ColorPreset(id: 7, nameBn: 'টক্সিক লাইম', primary: Color(0xFFA8FF1A), secondary: Color(0xFF6ECC00), glow: Color(0xFFD5FF80)),
    ColorPreset(id: 8, nameBn: 'প্লাজমা মেজেন্টা', primary: Color(0xFFF528D6), secondary: Color(0xFFB30098), glow: Color(0xFFFF8CEE)),
    ColorPreset(id: 9, nameBn: 'সোলার অরেঞ্জ', primary: Color(0xFFFF6D28), secondary: Color(0xFFD14000), glow: Color(0xFFFFAE80)),
    ColorPreset(id: 10, nameBn: 'ফ্রস্ট আইস ব্লু', primary: Color(0xFF60D6FF), secondary: Color(0xFF2694CC), glow: Color(0xFFB5EEFF)),
    ColorPreset(id: 11, nameBn: 'অ্যামেথিস্ট গ্লো', primary: Color(0xFF9B6BFF), secondary: Color(0xFF6236CC), glow: Color(0xFFCBB2FF)),
    ColorPreset(id: 12, nameBn: 'এমারেল্ড ফ্লেয়ার', primary: Color(0xFF10E888), secondary: Color(0xFF06A65E), glow: Color(0xFF7FF7BE)),
    ColorPreset(id: 13, nameBn: 'রুবি লেজার', primary: Color(0xFFFF2A7A), secondary: Color(0xFFB8004C), glow: Color(0xFFFF8AB5)),
    ColorPreset(id: 14, nameBn: 'কোবাল্ট ওভারড্রাইভ', primary: Color(0xFF4C7BFF), secondary: Color(0xFF1C49CC), glow: Color(0xFF9CB6FF)),
    ColorPreset(id: 15, nameBn: 'সানবার্স্ট ইয়েলো', primary: Color(0xFFFFE033), secondary: Color(0xFFCCA800), glow: Color(0xFFFFF099)),
    ColorPreset(id: 16, nameBn: 'ভায়োলেট স্টর্ম', primary: Color(0xFFDF52FF), secondary: Color(0xFF9914BD), glow: Color(0xFFF1A3FF)),
    ColorPreset(id: 17, nameBn: 'মিন্ট ম্যাট্রিক্স', primary: Color(0xFF2EFFC7), secondary: Color(0xFF00B889), glow: Color(0xFF99FFE3)),
    ColorPreset(id: 18, nameBn: 'কোরাল সুপারনোভা', primary: Color(0xFFFF6666), secondary: Color(0xFFCC2929), glow: Color(0xFFFFB2B2)),
    ColorPreset(id: 19, nameBn: 'গ্যালাক্সি ইন্ডিগো', primary: Color(0xFF7C83FF), secondary: Color(0xFF474ECC), glow: Color(0xFFBDC1FF)),
  ];

  // 20 Soft 3D Clay Presets for Theme 2 (Default = Mint Teal from 2nd reference photo)
  static const List<ColorPreset> soft3DPresets = [
    ColorPreset(id: 0, nameBn: 'মিন্ট টিল (ডিফল্ট)', primary: Color(0xFF25B4A5), secondary: Color(0xFFFF8F73), glow: Color(0xFFBCEEE8)),
    ColorPreset(id: 1, nameBn: 'কোরাল ব্লসম', primary: Color(0xFFF26B5B), secondary: Color(0xFF2FB8A8), glow: Color(0xFFFFD8D1)),
    ColorPreset(id: 2, nameBn: 'ল্যাভেন্ডার ব্রিজ', primary: Color(0xFF7E60E8), secondary: Color(0xFFFF8CA3), glow: Color(0xFFDDD4FC)),
    ColorPreset(id: 3, nameBn: 'স্কাই অ্যাকোয়া', primary: Color(0xFF2896E8), secondary: Color(0xFFFF9E5E), glow: Color(0xFFC7E6FC)),
    ColorPreset(id: 4, nameBn: 'রোজ কোয়ার্টজ', primary: Color(0xFFE8528C), secondary: Color(0xFF42B5A8), glow: Color(0xFFFCD2E3)),
    ColorPreset(id: 5, nameBn: 'সেজ ফরেস্ট', primary: Color(0xFF2EA86F), secondary: Color(0xFFF29659), glow: Color(0xFFC5F0DC)),
    ColorPreset(id: 6, nameBn: 'পিচ সানসেট', primary: Color(0xFFF07B46), secondary: Color(0xFF2CA89A), glow: Color(0xFFFCE0D2)),
    ColorPreset(id: 7, nameBn: 'বেরি ভেলভেট', primary: Color(0xFFB548C7), secondary: Color(0xFF32B5A4), glow: Color(0xFFF0CEF7)),
    ColorPreset(id: 8, nameBn: 'ওশান লাগুন', primary: Color(0xFF1A9CB8), secondary: Color(0xFFF57E64), glow: Color(0xFFC2EDF7)),
    ColorPreset(id: 9, nameBn: 'হানি অ্যাম্বার', primary: Color(0xFFE0961F), secondary: Color(0xFF28A898), glow: Color(0xFFFAE6BE)),
    ColorPreset(id: 10, nameBn: 'পেরিউইঙ্কল ব্লু', primary: Color(0xFF566CE8), secondary: Color(0xFFF2796B), glow: Color(0xFFD2D9FC)),
    ColorPreset(id: 11, nameBn: 'পিস্তাচিও গ্রিন', primary: Color(0xFF58B34B), secondary: Color(0xFFF07865), glow: Color(0xFFD5F5D0)),
    ColorPreset(id: 12, nameBn: 'ফ্ল্যামিঙ্গো পিঙ্ক', primary: Color(0xFFF05E7B), secondary: Color(0xFF2AB0A2), glow: Color(0xFFFCD4DC)),
    ColorPreset(id: 13, nameBn: 'টার্কোয়েজ জেড', primary: Color(0xFF1EBA9C), secondary: Color(0xFFFA8C69), glow: Color(0xFFC2F7ED)),
    ColorPreset(id: 14, nameBn: 'প্লাম অর্কিড', primary: Color(0xFF9552D9), secondary: Color(0xFFF2855E), glow: Color(0xFFE4D0FA)),
    ColorPreset(id: 15, nameBn: 'সিনামন স্পাইস', primary: Color(0xFFD9643A), secondary: Color(0xFF2AA696), glow: Color(0xFFFAD8CC)),
    ColorPreset(id: 16, nameBn: 'আর্কটিক টিল', primary: Color(0xFF22A6B8), secondary: Color(0xFFF0738A), glow: Color(0xFFC4F0F5)),
    ColorPreset(id: 17, nameBn: 'চেরি পেটাল', primary: Color(0xFFD94366), secondary: Color(0xFF2BB3A3), glow: Color(0xFFFACCD7)),
    ColorPreset(id: 18, nameBn: 'মচা গোল্ড', primary: Color(0xFFB87A3D), secondary: Color(0xFF26A898), glow: Color(0xFFF5E0CC)),
    ColorPreset(id: 19, nameBn: 'আইরিস ভায়োলেট', primary: Color(0xFF6B52E0), secondary: Color(0xFFFA8269), glow: Color(0xFFD8D0FA)),
  ];
}

class ActiveAuraPalette {
  final AuraThemeStyle style;
  final Color primary;
  final Color secondary;
  final Color glow;
  final Color bgTop;
  final Color bgBottom;
  final Color cardSurface;
  final Color cardBorder;
  final Color textPrimary;
  final Color textSecondary;

  const ActiveAuraPalette({
    required this.style,
    required this.primary,
    required this.secondary,
    required this.glow,
    required this.bgTop,
    required this.bgBottom,
    required this.cardSurface,
    required this.cardBorder,
    required this.textPrimary,
    required this.textSecondary,
  });

  static const Color defaultGlassPrimary = Color(0xFF42D6C4);
  static const Color defaultGlassSecondary = Color(0xFFD984C6);
  static const Color defaultGlassGlow = Color(0xFFF7C97E);

  static ActiveAuraPalette build({
    required AuraThemeStyle style,
    required int neonPresetId,
    required int soft3dPresetId,
    required Color glassPrimary,
    required Color glassSecondary,
    required Color glassGlow,
  }) {
    switch (style) {
      case AuraThemeStyle.soloNeon:
        final p = AuraColorPresets.neonPresets[
            neonPresetId.clamp(0, AuraColorPresets.neonPresets.length - 1)];
        return ActiveAuraPalette(
          style: style,
          primary: p.primary,
          secondary: p.secondary,
          glow: p.glow,
          bgTop: const Color(0xFF090712),
          bgBottom: const Color(0xFF140F26),
          cardSurface: const Color(0xEE17122B),
          cardBorder: p.primary.withOpacity(0.75),
          textPrimary: const Color(0xFFF9F5FF),
          textSecondary: p.glow.withOpacity(0.85),
        );

      case AuraThemeStyle.soft3D:
        final p = AuraColorPresets.soft3DPresets[
            soft3dPresetId.clamp(0, AuraColorPresets.soft3DPresets.length - 1)];
        return ActiveAuraPalette(
          style: style,
          primary: p.primary,
          secondary: p.secondary,
          glow: p.glow,
          bgTop: Color.lerp(const Color(0xFFDDF2EE), p.glow, 0.45)!,
          bgBottom: const Color(0xFFFCF4EB),
          cardSurface: const Color(0xFFFAF7F2),
          cardBorder: const Color(0xFFFFFFFF),
          textPrimary: const Color(0xFF153836),
          textSecondary: const Color(0xFF4F7370),
        );

      case AuraThemeStyle.botanicalGlass:
        return ActiveAuraPalette(
          style: style,
          primary: glassPrimary,
          secondary: glassSecondary,
          glow: glassGlow,
          bgTop: const Color(0xFF072029),
          bgBottom: const Color(0xFF0E1B2E),
          cardSurface: glassPrimary.withOpacity(0.22),
          cardBorder: const Color(0x66FFFFFF),
          textPrimary: const Color(0xFFFFFFFF),
          textSecondary: const Color(0xFFE4F6F4),
        );
    }
  }
}

class AuraTextStyles {
  static const String fontFamily = 'NotoSansBengali';

  static TextStyle hero(Color color, {double size = 38}) => TextStyle(
        fontFamily: fontFamily,
        fontWeight: FontWeight.w700,
        fontSize: size,
        color: color,
        height: 1.18,
      );

  static TextStyle titleLarge(Color color, {double size = 21}) => TextStyle(
        fontFamily: fontFamily,
        fontWeight: FontWeight.w700,
        fontSize: size,
        color: color,
        height: 1.25,
      );

  static TextStyle titleMedium(Color color, {double size = 17}) => TextStyle(
        fontFamily: fontFamily,
        fontWeight: FontWeight.w700,
        fontSize: size,
        color: color,
        height: 1.25,
      );

  static TextStyle bodyBold(Color color, {double size = 14.5}) => TextStyle(
        fontFamily: fontFamily,
        fontWeight: FontWeight.w700,
        fontSize: size,
        color: color,
        height: 1.3,
      );

  static TextStyle bodyRegular(Color color, {double size = 13}) => TextStyle(
        fontFamily: fontFamily,
        fontWeight: FontWeight.w400,
        fontSize: size,
        color: color,
        height: 1.35,
      );
}

class WallpaperColorExtractor {
  /// Extracts vibrant primary, secondary, and glow accent colors directly from
  /// an uploaded wallpaper image so the Glassmorphism UI automatically merges with its colors!
  static Future<List<Color>> extractHarmoniousColors(File imageFile) async {
    try {
      final Uint8List bytes = await imageFile.readAsBytes();
      final ui.Codec codec = await ui.instantiateImageCodec(
        bytes,
        targetWidth: 48,
        targetHeight: 48,
      );
      final ui.FrameInfo frame = await codec.getNextFrame();
      final ByteData? pixelData = await frame.image.toByteData(
        format: ui.ImageByteFormat.rawRgba,
      );
      if (pixelData == null) {
        return [
          ActiveAuraPalette.defaultGlassPrimary,
          ActiveAuraPalette.defaultGlassSecondary,
          ActiveAuraPalette.defaultGlassGlow,
        ];
      }

      double rWeighted = 0, gWeighted = 0, bWeighted = 0, wTotal = 0;
      double rSec = 0, gSec = 0, bSec = 0, wSecTotal = 0;

      for (int i = 0; i < pixelData.lengthInBytes; i += 4) {
        final int r = pixelData.getUint8(i);
        final int g = pixelData.getUint8(i + 1);
        final int b = pixelData.getUint8(i + 2);

        final int maxC = [r, g, b].reduce((a, c) => a > c ? a : c);
        final int minC = [r, g, b].reduce((a, c) => a < c ? a : c);
        final double sat = maxC == 0 ? 0 : (maxC - minC) / maxC.toDouble();
        final double lum = (r + g + b) / (255.0 * 3.0);

        // Favor vibrant mid-to-bright pixels
        final double weight = (sat + 0.15) * (1.0 - (lum - 0.55).abs());
        if (i < pixelData.lengthInBytes ~/ 2) {
          rWeighted += r * weight;
          gWeighted += g * weight;
          bWeighted += b * weight;
          wTotal += weight;
        } else {
          rSec += r * weight;
          gSec += g * weight;
          bSec += b * weight;
          wSecTotal += weight;
        }
      }

      Color c1 = wTotal > 0
          ? Color.fromARGB(
              255,
              (rWeighted / wTotal).round().clamp(55, 245),
              (gWeighted / wTotal).round().clamp(55, 245),
              (bWeighted / wTotal).round().clamp(55, 245),
            )
          : ActiveAuraPalette.defaultGlassPrimary;

      Color c2 = wSecTotal > 0
          ? Color.fromARGB(
              255,
              (rSec / wSecTotal).round().clamp(65, 245),
              (gSec / wSecTotal).round().clamp(65, 245),
              (bSec / wSecTotal).round().clamp(65, 245),
            )
          : ActiveAuraPalette.defaultGlassSecondary;

      // Boost saturation and lightness slightly so glass cards glow vividly
      final HSLColor hsl1 = HSLColor.fromColor(c1);
      final Color finalPrimary = hsl1
          .withSaturation((hsl1.saturation * 1.25).clamp(0.45, 0.92))
          .withLightness(hsl1.lightness.clamp(0.52, 0.74))
          .toColor();

      final HSLColor hsl2 = HSLColor.fromColor(c2);
      final Color finalSecondary = hsl2
          .withHue((hsl2.hue + 28) % 360)
          .withSaturation((hsl2.saturation * 1.25).clamp(0.45, 0.90))
          .withLightness(hsl2.lightness.clamp(0.55, 0.76))
          .toColor();

      final Color finalGlow = Color.lerp(finalPrimary, Colors.white, 0.38)!;
      return [finalPrimary, finalSecondary, finalGlow];
    } catch (_) {
      return [
        ActiveAuraPalette.defaultGlassPrimary,
        ActiveAuraPalette.defaultGlassSecondary,
        ActiveAuraPalette.defaultGlassGlow,
      ];
    }
  }
}
