import 'dart:math' as math;

/// medication doses using Young's Rule
class PediatricDoseCalculator {
  static double calculateByAge(int ageInYears, double adultDose) {
    if (ageInYears >= 18) return adultDose;
    if (ageInYears <= 0) return 0;
    return (ageInYears / (ageInYears + 12)) * adultDose;
  }

  static String formatDose(double dose) {
    if (dose == dose.roundToDouble()) {
      return dose.toInt().toString();
    }
    return dose.toStringAsFixed(1);
  }

  static PediatricDoseResult calculateDose({
    required int ageInYears,
    required double adultDose,
    String unit = 'mg',
  }) {
    final calculatedDose = calculateByAge(ageInYears, adultDose);

    String warning = '';
    if (ageInYears < 1) {
      warning = '⚠️ Нярайд онцгой анхаарал хандуулна уу!';
    } else if (ageInYears < 3) {
      warning = '⚠️ Бага насны хүүхэд - эмчтэй зөвлөлдөнө үү';
    }

    return PediatricDoseResult(
      pediatricDose: calculatedDose,
      formattedDose: '${formatDose(calculatedDose)} $unit',
      warning: warning,
    );
  }
}

class PediatricDoseResult {
  final double pediatricDose;
  final String formattedDose;
  final String warning;

  PediatricDoseResult({
    required this.pediatricDose,
    required this.formattedDose,
    required this.warning,
  });
}

class AdvancedPediatricDoseCalculator {
  static const double standardAdultWeight = 70.0;

  static ({double? value, String unit}) parseDose(String doseString) {
    if (doseString.trim().isEmpty) {
      return (value: null, unit: '');
    }

    final cleaned = doseString.trim().toLowerCase();
    final numericMatch = RegExp(r'(\d+\.?\d*)').firstMatch(cleaned);
    if (numericMatch == null) {
      return (value: null, unit: '');
    }

    final value = double.tryParse(numericMatch.group(1)!);
    String unit = cleaned.replaceAll(RegExp(r'[\d\s\.]'), '').trim();

    if (unit.contains('мг') || unit == 'mg') {
      unit = 'mg';
    } else if (unit.contains('г') || unit == 'g') {
      unit = 'g';
    } else if (unit.contains('мл') || unit == 'ml') {
      unit = 'ml';
    } else if (unit.contains('мкг') ||
        unit.contains('mcg') ||
        unit.contains('μg')) {
      unit = 'mcg';
    }

    return (value: value, unit: unit);
  }

  /// Clark's Rule
  static double clarksRule(double adultDose, double childWeightKg) {
    if (childWeightKg <= 0 || adultDose <= 0) return 0;
    return (childWeightKg / standardAdultWeight) * adultDose;
  }

  /// Young's Rule: based on age
  static double youngsRule(double adultDose, int ageYears) {
    if (ageYears <= 0 || adultDose <= 0) return 0;
    return (ageYears / (ageYears + 12)) * adultDose;
  }

  /// Fried's Rule: for infants under 2 years
  static double friedsRule(double adultDose, int ageMonths) {
    if (ageMonths <= 0 || adultDose <= 0) return 0;
    return (ageMonths / 150.0) * adultDose;
  }

  /// BSA Method: Body Surface Area method (most accurate)
  static double bsaMethod(
    double adultDose,
    double childWeightKg,
    double childHeightCm,
  ) {
    if (childWeightKg <= 0 || childHeightCm <= 0 || adultDose <= 0) return 0;
    final childBSA = math.sqrt((childHeightCm * childWeightKg) / 3600);
    const adultBSA = 1.7;
    return (childBSA / adultBSA) * adultDose;
  }

  static DoseCalculationResult calculatePediatricDose({
    required String adultDoseString,
    required int childAgeYears,
    double? childWeightKg,
    double? childHeightCm,
  }) {
    final parsedDose = parseDose(adultDoseString);

    if (parsedDose.value == null) {
      return const DoseCalculationResult(
        calculatedDose: 0,
        calculatedDoseMin: 0,
        calculatedDoseMax: 0,
        method: 'Алдаа',
        unit: '',
        warning: 'Тун задруулах боломжгүй',
        recommendation: 'Зөв форматаар оруулна уу (жишээ: 500 mg)',
        requiresAdjustment: false,
      );
    }

    final adultDose = parsedDose.value!;
    final unit = parsedDose.unit;

    if (childAgeYears >= 18) {
      return DoseCalculationResult(
        calculatedDose: adultDose,
        calculatedDoseMin: adultDose,
        calculatedDoseMax: adultDose,
        method: 'Насанд хүрэгч',
        unit: unit,
        warning: '',
        recommendation: 'Насанд хүрэгчдэд зориулсан тун хэрэглэнэ.',
        requiresAdjustment: false,
      );
    }

    List<double> calculatedDoses = [];
    List<String> methods = [];
    String primaryMethod = '';

    if (childAgeYears < 2) {
      final ageMonths = childAgeYears * 12;
      if (ageMonths > 0) {
        final friedDose = friedsRule(adultDose, ageMonths);
        calculatedDoses.add(friedDose);
        methods.add('Fried\'s Rule');
        primaryMethod = 'Fried\'s Rule';
      }
    } else {
      final youngDose = youngsRule(adultDose, childAgeYears);
      calculatedDoses.add(youngDose);
      methods.add('Young\'s Rule');
      primaryMethod = 'Young\'s Rule';
    }

    if (childWeightKg != null && childWeightKg > 0) {
      final clarkDose = clarksRule(adultDose, childWeightKg);
      calculatedDoses.add(clarkDose);
      methods.add('Clark\'s Rule');
      if (primaryMethod.isEmpty) primaryMethod = 'Clark\'s Rule';
    }

    if (childWeightKg != null &&
        childHeightCm != null &&
        childWeightKg > 0 &&
        childHeightCm > 0) {
      final bsaDose = bsaMethod(adultDose, childWeightKg, childHeightCm);
      calculatedDoses.add(bsaDose);
      methods.add('BSA');
      primaryMethod = 'BSA';
    }

    if (calculatedDoses.isEmpty) {
      return DoseCalculationResult(
        calculatedDose: 0,
        calculatedDoseMin: 0,
        calculatedDoseMax: 0,
        method: 'Хангалтгүй мэдээлэл',
        unit: unit,
        warning: 'Тун тооцоолох мэдээлэл дутуу',
        recommendation: 'Хүүхдийн жин, өндрийг оруулна уу.',
        requiresAdjustment: true,
      );
    }

    final minDose = calculatedDoses.reduce(math.min);
    final maxDose = calculatedDoses.reduce(math.max);
    final avgDose =
        calculatedDoses.reduce((a, b) => a + b) / calculatedDoses.length;

    String warning = '';
    String recommendation = '';

    if (childAgeYears < 1) {
      warning =
          '⚠️ АНХААРУУЛГА: Нярайд зориулсан тун - эмчийн зөвлөгөөгүйгээр хэрэглэхгүй!';
      recommendation =
          'Нярайд зориулсан эмийн тун нь эмчийн дэлгэрэнгүй үзлэг шаардлагатай.';
    } else if (childAgeYears < 6) {
      warning = '⚠️ Бага насны хүүхэд - тун нягт хянах шаардлагатай';
      recommendation = 'Тун нь хүүхдийн жин, нас, ерөнхий байдлаас хамаарна.';
    } else if (childAgeYears < 12) {
      recommendation =
          'Хүүхдийн хариу урвалыг ажиглаж, шаардлагатай бол тун тохируулна.';
    }

    if (childWeightKg == null) {
      if (warning.isNotEmpty) warning += '\n';
      warning += 'Жин оруулаагүй - тун нарийвчлал бага байна.';
    }

    final reductionPercent = ((1 - (avgDose / adultDose)) * 100).round();
    if (reductionPercent > 80) {
      if (warning.isNotEmpty) warning += '\n';
      warning += '⚠️ Тун хэт бага байна (${reductionPercent}% бууруулсан)!';
    }

    return DoseCalculationResult(
      calculatedDose: avgDose,
      calculatedDoseMin: minDose,
      calculatedDoseMax: maxDose,
      method: primaryMethod +
          (methods.length > 1 ? ' (${methods.length} арга)' : ''),
      unit: unit,
      warning: warning,
      recommendation: recommendation.isEmpty
          ? 'Тооцоолсон тун: ${methods.join(", ")}'
          : recommendation,
      requiresAdjustment: true,
    );
  }

  /// Estimate weight based on age (for rough calculations only)
  static double estimatedWeightForAge(int ageYears) {
    if (ageYears < 0) return 0;
    if (ageYears >= 18) return standardAdultWeight;
    final weights = {
      0: 3.5,
      1: 10.0,
      2: 12.5,
      3: 14.5,
      4: 16.5,
      5: 18.5,
      6: 20.5,
      7: 23.0,
      8: 25.5,
      9: 28.5,
      10: 32.0,
      11: 36.0,
      12: 40.0,
      13: 45.0,
      14: 50.0,
      15: 56.0,
      16: 60.0,
      17: 65.0,
    };
    return weights[ageYears] ?? standardAdultWeight;
  }
}

class DoseCalculationResult {
  final double calculatedDose;
  final double calculatedDoseMin;
  final double calculatedDoseMax;
  final String method;
  final String unit;
  final String warning;
  final String recommendation;
  final bool requiresAdjustment;

  const DoseCalculationResult({
    required this.calculatedDose,
    required this.calculatedDoseMin,
    required this.calculatedDoseMax,
    required this.method,
    required this.unit,
    required this.warning,
    required this.recommendation,
    required this.requiresAdjustment,
  });

  String get formattedDose {
    if (calculatedDoseMin == calculatedDoseMax) {
      return '${calculatedDose.toStringAsFixed(1)} $unit';
    }
    return '${calculatedDoseMin.toStringAsFixed(1)}-${calculatedDoseMax.toStringAsFixed(1)} $unit';
  }
}
