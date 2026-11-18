import 'dart:math' as math;

class CalcHistoryItem {
  final String expression;
  final String result;
  final String timestampBn;

  const CalcHistoryItem({
    required this.expression,
    required this.result,
    required this.timestampBn,
  });
}

class BengaliNumeralFormatter {
  static const Map<String, String> _enToBn = {
    '0': '০',
    '1': '১',
    '2': '২',
    '3': '৩',
    '4': '৪',
    '5': '৫',
    '6': '৬',
    '7': '৭',
    '8': '৮',
    '9': '৯',
  };

  static const Map<String, String> _bnToEn = {
    '০': '0',
    '১': '1',
    '২': '2',
    '৩': '3',
    '৪': '4',
    '৫': '5',
    '৬': '6',
    '৭': '7',
    '৮': '8',
    '৯': '9',
  };

  static String toOutputDigits(String input, bool useBn) {
    if (!useBn) return toEnglishDigits(input);
    final sb = StringBuffer();
    for (int i = 0; i < input.length; i++) {
      final ch = input[i];
      sb.write(_enToBn[ch] ?? ch);
    }
    return sb.toString();
  }

  static String toEnglishDigits(String input) {
    final sb = StringBuffer();
    for (int i = 0; i < input.length; i++) {
      final ch = input[i];
      sb.write(_bnToEn[ch] ?? ch);
    }
    return sb.toString();
  }

  static double? parseDoubleSafe(String input) {
    final clean = toEnglishDigits(input).replaceAll(',', '').trim();
    return double.tryParse(clean);
  }

  static String formatNumber(double value, bool useBn, {int maxDecimals = 6}) {
    if (value.isNaN || value.isInfinite) return 'অসংজ্ঞায়িত';
    final double cleanVal = value.abs() < 1e-12 ? 0.0 : value;
    String raw;
    if (cleanVal == cleanVal.roundToDouble() && cleanVal.abs() < 1e15) {
      raw = cleanVal.round().toString();
    } else {
      raw = cleanVal
          .toStringAsFixed(maxDecimals)
          .replaceFirst(RegExp(r'0+$'), '')
          .replaceFirst(RegExp(r'\.$'), '');
    }
    return toOutputDigits(raw, useBn);
  }
}

class MathEvaluator {
  static double? evaluate(String rawExpr) {
    String clean = BengaliNumeralFormatter.toEnglishDigits(rawExpr)
        .replaceAll('×', '*')
        .replaceAll('÷', '/')
        .replaceAll('−', '-')
        .replaceAll(',', '')
        .replaceAll(' ', '')
        .trim();

    while (clean.isNotEmpty && '+-*/.'.contains(clean[clean.length - 1])) {
      clean = clean.substring(0, clean.length - 1);
    }
    if (clean.isEmpty) return null;

    final int openCount = '('.allMatches(clean).length;
    final int closeCount = ')'.allMatches(clean).length;
    if (openCount > closeCount) {
      clean = clean + (')' * (openCount - closeCount));
    }

    try {
      final parser = _ExprParser(clean);
      final res = parser.parseExpression();
      if (parser.pos < clean.length || res.isNaN || res.isInfinite) return null;
      return res;
    } catch (_) {
      return null;
    }
  }
}

class _ExprParser {
  final String input;
  int pos = 0;
  _ExprParser(this.input);

  String _peek() => pos < input.length ? input[pos] : '';
  String _consume() => input[pos++];

  double parseExpression() {
    double value = _parseTerm();
    while (pos < input.length) {
      final ch = _peek();
      if (ch == '+') {
        _consume();
        value += _parseTerm();
      } else if (ch == '-') {
        _consume();
        value -= _parseTerm();
      } else {
        break;
      }
    }
    return value;
  }

  double _parseTerm() {
    double value = _parseFactor();
    while (pos < input.length) {
      final ch = _peek();
      if (ch == '*') {
        _consume();
        value *= _parseFactor();
      } else if (ch == '/') {
        _consume();
        final div = _parseFactor();
        if (div.abs() < 1e-15) return double.nan;
        value /= div;
      } else {
        break;
      }
    }
    return value;
  }

  double _parseFactor() {
    double sign = 1.0;
    while (_peek() == '+' || _peek() == '-') {
      if (_consume() == '-') sign = -sign;
    }

    double value;
    if (_peek() == '(') {
      _consume();
      value = parseExpression();
      if (_peek() == ')') _consume();
    } else {
      final start = pos;
      while (pos < input.length &&
          (RegExp(r'[0-9.]').hasMatch(_peek()))) {
        _consume();
      }
      if (start == pos) throw const FormatException('Invalid token');
      value = double.parse(input.substring(start, pos));
    }

    while (_peek() == '%') {
      _consume();
      value /= 100.0;
    }

    if (_peek() == '(') {
      value *= _parseFactor();
    }
    return sign * value;
  }
}

class AgeCalculationResult {
  final int years;
  final int months;
  final int days;
  final int totalWeeks;
  final int totalDays;
  final int totalHours;
  final String birthDayOfWeekBn;
  final int nextBirthdayMonths;
  final int nextBirthdayDays;
  final double yearProgressPercent;

  const AgeCalculationResult({
    required this.years,
    required this.months,
    required this.days,
    required this.totalWeeks,
    required this.totalDays,
    required this.totalHours,
    required this.birthDayOfWeekBn,
    required this.nextBirthdayMonths,
    required this.nextBirthdayDays,
    required this.yearProgressPercent,
  });
}

class DateDiffResult {
  final int years;
  final int months;
  final int days;
  final int totalWeeks;
  final int totalDays;

  const DateDiffResult({
    required this.years,
    required this.months,
    required this.days,
    required this.totalWeeks,
    required this.totalDays,
  });
}

class AgeDateEngine {
  static const List<String> bengaliMonths = [
    'জানুয়ারি',
    'ফেব্রুয়ারি',
    'মার্চ',
    'এপ্রিল',
    'মে',
    'জুন',
    'জুলাই',
    'আগস্ট',
    'সেপ্টেম্বর',
    'অক্টোবর',
    'নভেম্বর',
    'ডিসেম্বর',
  ];

  static String weekdayBn(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return 'সোমবার';
      case DateTime.tuesday:
        return 'মঙ্গলবার';
      case DateTime.wednesday:
        return 'বুধবার';
      case DateTime.thursday:
        return 'বৃহস্পতিবার';
      case DateTime.friday:
        return 'শুক্রবার';
      case DateTime.saturday:
        return 'শনিবার';
      case DateTime.sunday:
      default:
        return 'রবিবার';
    }
  }

  static AgeCalculationResult calculateAge(DateTime birthDate) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final birth = DateTime(birthDate.year, birthDate.month, birthDate.day);

    if (birth.isAfter(today)) {
      return AgeCalculationResult(
        years: 0,
        months: 0,
        days: 0,
        totalWeeks: 0,
        totalDays: 0,
        totalHours: 0,
        birthDayOfWeekBn: weekdayBn(birth.weekday),
        nextBirthdayMonths: 0,
        nextBirthdayDays: 0,
        yearProgressPercent: 0,
      );
    }

    final diff = calculateDifference(birth, today);
    final totalDays = today.difference(birth).inDays;
    final totalWeeks = totalDays ~/ 7;
    final totalHours = totalDays * 24 + now.hour;

    DateTime nextBday = DateTime(today.year, birth.month, birth.day);
    if (!nextBday.isAfter(today)) {
      nextBday = DateTime(today.year + 1, birth.month, birth.day);
    }
    final nextDiff = calculateDifference(today, nextBday);
    final progress =
        (((diff.months * 30.4) + diff.days) / 365.25 * 100.0).clamp(0.0, 100.0);

    return AgeCalculationResult(
      years: diff.years,
      months: diff.months,
      days: diff.days,
      totalWeeks: totalWeeks,
      totalDays: totalDays,
      totalHours: totalHours,
      birthDayOfWeekBn: weekdayBn(birth.weekday),
      nextBirthdayMonths: nextDiff.months,
      nextBirthdayDays: nextDiff.days,
      yearProgressPercent: progress,
    );
  }

  static DateDiffResult calculateDifference(DateTime d1, DateTime d2) {
    final start = d1.isBefore(d2)
        ? DateTime(d1.year, d1.month, d1.day)
        : DateTime(d2.year, d2.month, d2.day);
    final end = d1.isBefore(d2)
        ? DateTime(d2.year, d2.month, d2.day)
        : DateTime(d1.year, d1.month, d1.day);

    int years = end.year - start.year;
    int months = end.month - start.month;
    int days = end.day - start.day;

    if (days < 0) {
      final prevMonthLastDay = DateTime(end.year, end.month, 0).day;
      days += prevMonthLastDay;
      months -= 1;
    }
    if (months < 0) {
      years -= 1;
      months += 12;
    }

    final totalDays = end.difference(start).inDays;
    return DateDiffResult(
      years: years,
      months: months,
      days: days,
      totalWeeks: totalDays ~/ 7,
      totalDays: totalDays,
    );
  }
}

enum ConverterCategory {
  weight(0, 'ওজন', 'কেজি, গ্রাম, পাউন্ড, মণ', 'assets/images/ic_3d_converter.png'),
  distance(1, 'দূরত্ব', 'মিটার, কিমি, ফুট, মাইল', 'assets/images/ic_3d_converter.png'),
  landArea(2, 'জমি ও এলাকা', 'শতাংশ, কাঠা, বিঘা, বর্গফুট', 'assets/images/ic_3d_area.png'),
  temperature(3, 'তাপমাত্রা', 'সেলসিয়াস, ফারেনহাইট, কেলভিন', 'assets/images/ic_3d_temperature.png'),
  digitalData(4, 'ডেটা', 'KB, MB, GB, TB', 'assets/images/ic_3d_data.png');

  final int id;
  final String titleBn;
  final String subtitleBn;
  final String iconAsset;
  const ConverterCategory(this.id, this.titleBn, this.subtitleBn, this.iconAsset);
}

class UnitDefinition {
  final String code;
  final String nameBn;
  final String shortBn;
  final double factorToBase;

  const UnitDefinition(this.code, this.nameBn, this.shortBn, this.factorToBase);
}

class UnitConverterEngine {
  static const List<UnitDefinition> weightUnits = [
    UnitDefinition('kg', 'কিলোগ্রাম (kg)', 'কেজি', 1.0),
    UnitDefinition('g', 'গ্রাম (g)', 'গ্রাম', 0.001),
    UnitDefinition('mg', 'মিলিগ্রাম (mg)', 'মিগ্রা', 0.000001),
    UnitDefinition('lb', 'পাউন্ড (lb)', 'পাউন্ড', 0.45359237),
    UnitDefinition('oz', 'আউন্স (oz)', 'আউন্স', 0.0283495231),
    UnitDefinition('ton', 'মেট্রিক টন (t)', 'টন', 1000.0),
    UnitDefinition('maund', 'মণ (৪০ কেজি)', 'মণ', 40.0),
    UnitDefinition('seer', 'সের (বাংলাদেশি)', 'সের', 0.933105),
  ];

  static const List<UnitDefinition> distanceUnits = [
    UnitDefinition('m', 'মিটার (m)', 'মিটার', 1.0),
    UnitDefinition('km', 'কিলোমিটার (km)', 'কিমি', 1000.0),
    UnitDefinition('cm', 'সেন্টিমিটার (cm)', 'সেমি', 0.01),
    UnitDefinition('mm', 'মিলিমিটার (mm)', 'মিমি', 0.001),
    UnitDefinition('ft', 'ফুট (ft)', 'ফুট', 0.3048),
    UnitDefinition('in', 'ইঞ্চি (inch)', 'ইঞ্চি', 0.0254),
    UnitDefinition('yd', 'গজ (yard)', 'গজ', 0.9144),
    UnitDefinition('mile', 'মাইল (mile)', 'মাইল', 1609.344),
  ];

  static const List<UnitDefinition> landAreaUnits = [
    UnitDefinition('decimal', 'শতাংশ / শতক (Decimal)', 'শতাংশ', 435.6),
    UnitDefinition('katha', 'কাঠা (৭২০ বর্গফুট)', 'কাঠা', 720.0),
    UnitDefinition('bigha', 'বিঘা (২০ কাঠা)', 'বিঘা', 14400.0),
    UnitDefinition('sqft', 'বর্গফুট (Sq. Feet)', 'বর্গফুট', 1.0),
    UnitDefinition('sqm', 'বর্গমিটার (Sq. Meter)', 'বর্গমিটার', 10.7639104),
    UnitDefinition('acre', 'একর (১০০ শতক)', 'একর', 43560.0),
    UnitDefinition('hectare', 'হেক্টর (Hectare)', 'হেক্টর', 107639.104),
    UnitDefinition('chatak', 'ছটাক (৪৫ বর্গফুট)', 'ছটাক', 45.0),
    UnitDefinition('kani', 'কানি (১২০ শতক)', 'কানি', 52272.0),
  ];

  static const List<UnitDefinition> temperatureUnits = [
    UnitDefinition('C', 'সেলসিয়াস (°C)', '°C', 1.0),
    UnitDefinition('F', 'ফারেনহাইট (°F)', '°F', 1.0),
    UnitDefinition('K', 'কেলভিন (K)', 'K', 1.0),
  ];

  static const List<UnitDefinition> dataUnits = [
    UnitDefinition('B', 'বাইট (Byte)', 'Byte', 1.0 / (1024.0 * 1024.0)),
    UnitDefinition('KB', 'কিলোবাইট (KB)', 'KB', 1.0 / 1024.0),
    UnitDefinition('MB', 'মেগাবাইট (MB)', 'MB', 1.0),
    UnitDefinition('GB', 'গিগাবাইট (GB)', 'GB', 1024.0),
    UnitDefinition('TB', 'টেরাবাইট (TB)', 'TB', 1024.0 * 1024.0),
    UnitDefinition('PB', 'পেটাবাইট (PB)', 'PB', 1024.0 * 1024.0 * 1024.0),
  ];

  static List<UnitDefinition> unitsFor(ConverterCategory category) {
    switch (category) {
      case ConverterCategory.weight:
        return weightUnits;
      case ConverterCategory.distance:
        return distanceUnits;
      case ConverterCategory.landArea:
        return landAreaUnits;
      case ConverterCategory.temperature:
        return temperatureUnits;
      case ConverterCategory.digitalData:
        return dataUnits;
    }
  }

  static double convert(
    double value,
    UnitDefinition from,
    UnitDefinition to,
    ConverterCategory category,
  ) {
    if (category == ConverterCategory.temperature) {
      double celsius;
      switch (from.code) {
        case 'F':
          celsius = (value - 32.0) * 5.0 / 9.0;
          break;
        case 'K':
          celsius = value - 273.15;
          break;
        default:
          celsius = value;
      }
      switch (to.code) {
        case 'F':
          return (celsius * 9.0 / 5.0) + 32.0;
        case 'K':
          return celsius + 273.15;
        default:
          return celsius;
      }
    }
    return (value * from.factorToBase) / to.factorToBase;
  }
}
