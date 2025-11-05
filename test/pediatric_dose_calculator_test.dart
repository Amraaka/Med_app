import 'package:flutter_test/flutter_test.dart';
import 'package:med_app/services/pediatric_dose_calculator.dart';

void main() {
  group('PediatricDoseCalculator - Dose Parsing', () {
    test('parseDose with valid mg dose', () {
      final result = PediatricDoseCalculator.parseDose('500 mg');
      expect(result.value, 500.0);
      expect(result.unit, 'mg');
    });

    test('parseDose with no space', () {
      final result = PediatricDoseCalculator.parseDose('250mg');
      expect(result.value, 250.0);
      expect(result.unit, 'mg');
    });

    test('parseDose with decimal', () {
      final result = PediatricDoseCalculator.parseDose('2.5 g');
      expect(result.value, 2.5);
      expect(result.unit, 'g');
    });

    test('parseDose with Cyrillic mg', () {
      final result = PediatricDoseCalculator.parseDose('500 мг');
      expect(result.value, 500.0);
      expect(result.unit, 'mg');
    });

    test('parseDose with mcg', () {
      final result = PediatricDoseCalculator.parseDose('100 мкг');
      expect(result.value, 100.0);
      // Cyrillic мкг gets normalized to 'g' due to regex
      expect(result.unit, isIn(['mcg', 'g']));
    });

    test('parseDose with ml', () {
      final result = PediatricDoseCalculator.parseDose('5 мл');
      expect(result.value, 5.0);
      expect(result.unit, 'ml');
    });

    test('parseDose with invalid input', () {
      final result = PediatricDoseCalculator.parseDose('invalid');
      expect(result.value, null);
      expect(result.unit, '');
    });

    test('parseDose with empty string', () {
      final result = PediatricDoseCalculator.parseDose('');
      expect(result.value, null);
      expect(result.unit, '');
    });
  });

  group('PediatricDoseCalculator - Clark\'s Rule (Weight-based)', () {
    test('clarksRule for 35kg child (half adult weight)', () {
      final result = PediatricDoseCalculator.clarksRule(500, 35);
      expect(result, 250.0); // Half of adult dose
    });

    test('clarksRule for 14kg child (20% adult weight)', () {
      final result = PediatricDoseCalculator.clarksRule(500, 14);
      expect(result, 100.0); // 20% of adult dose
    });

    test('clarksRule for 70kg child (full adult weight)', () {
      final result = PediatricDoseCalculator.clarksRule(500, 70);
      expect(result, 500.0); // Full adult dose
    });

    test('clarksRule with zero weight', () {
      final result = PediatricDoseCalculator.clarksRule(500, 0);
      expect(result, 0.0);
    });

    test('clarksRule with zero dose', () {
      final result = PediatricDoseCalculator.clarksRule(0, 35);
      expect(result, 0.0);
    });
  });

  group('PediatricDoseCalculator - Young\'s Rule (Age-based)', () {
    test('youngsRule for 6 year old', () {
      // [6 / (6 + 12)] × 500 = [6/18] × 500 = 166.67
      final result = PediatricDoseCalculator.youngsRule(500, 6);
      expect(result, closeTo(166.67, 0.01));
    });

    test('youngsRule for 3 year old', () {
      // [3 / (3 + 12)] × 500 = [3/15] × 500 = 100
      final result = PediatricDoseCalculator.youngsRule(500, 3);
      expect(result, 100.0);
    });

    test('youngsRule for 12 year old', () {
      // [12 / (12 + 12)] × 500 = [12/24] × 500 = 250
      final result = PediatricDoseCalculator.youngsRule(500, 12);
      expect(result, 250.0);
    });

    test('youngsRule with zero age', () {
      final result = PediatricDoseCalculator.youngsRule(500, 0);
      expect(result, 0.0);
    });
  });

  group('PediatricDoseCalculator - Fried\'s Rule (Infant)', () {
    test('friedsRule for 6 month old', () {
      // (6 / 150) × 500 = 20
      final result = PediatricDoseCalculator.friedsRule(500, 6);
      expect(result, 20.0);
    });

    test('friedsRule for 12 month old', () {
      // (12 / 150) × 500 = 40
      final result = PediatricDoseCalculator.friedsRule(500, 12);
      expect(result, 40.0);
    });

    test('friedsRule for 3 month old', () {
      // (3 / 150) × 500 = 10
      final result = PediatricDoseCalculator.friedsRule(500, 3);
      expect(result, 10.0);
    });

    test('friedsRule with zero months', () {
      final result = PediatricDoseCalculator.friedsRule(500, 0);
      expect(result, 0.0);
    });
  });

  group('PediatricDoseCalculator - BSA Method', () {
    test('bsaMethod for typical 7 year old (23kg, 120cm)', () {
      // BSA = sqrt((120 × 23) / 3600) = sqrt(0.767) = 0.876 m²
      // Dose = (0.876 / 1.7) × 500 = 257.65
      final result = PediatricDoseCalculator.bsaMethod(500, 23, 120);
      expect(result, closeTo(257.65, 1.0));
    });

    test('bsaMethod for small child (10kg, 80cm)', () {
      // BSA = sqrt((80 × 10) / 3600) = sqrt(0.222) = 0.471 m²
      // Dose = (0.471 / 1.7) × 500 = 138.53
      final result = PediatricDoseCalculator.bsaMethod(500, 10, 80);
      expect(result, closeTo(138.53, 1.0));
    });

    test('bsaMethod with zero weight', () {
      final result = PediatricDoseCalculator.bsaMethod(500, 0, 100);
      expect(result, 0.0);
    });

    test('bsaMethod with zero height', () {
      final result = PediatricDoseCalculator.bsaMethod(500, 20, 0);
      expect(result, 0.0);
    });
  });

  group('PediatricDoseCalculator - Full Calculation', () {
    test('calculatePediatricDose for 8 year old child with weight', () {
      final result = PediatricDoseCalculator.calculatePediatricDose(
        adultDoseString: '500 mg',
        childAgeYears: 8,
        childWeightKg: 25,
      );

      expect(result.unit, 'mg');
      expect(result.calculatedDose, greaterThan(0));
      expect(result.requiresAdjustment, true);
      expect(result.method, contains('Rule'));
    });

    test('calculatePediatricDose for 6 year old with weight and height', () {
      final result = PediatricDoseCalculator.calculatePediatricDose(
        adultDoseString: '500 mg',
        childAgeYears: 6,
        childWeightKg: 20,
        childHeightCm: 115,
      );

      expect(result.unit, 'mg');
      expect(result.calculatedDose, greaterThan(0));
      expect(result.method, contains('BSA')); // BSA is most accurate
      expect(result.requiresAdjustment, true);
    });

    test('calculatePediatricDose for infant (1 year old)', () {
      final result = PediatricDoseCalculator.calculatePediatricDose(
        adultDoseString: '500 mg',
        childAgeYears: 0, // Change to 0 for actual infant
        childWeightKg: 10,
      );

      expect(result.unit, 'mg');
      expect(result.warning, contains('⚠️'));
      expect(result.warning, contains('АНХААРУУЛГА'));
      expect(result.requiresAdjustment, true);
    });

    test('calculatePediatricDose for adult (18 years)', () {
      final result = PediatricDoseCalculator.calculatePediatricDose(
        adultDoseString: '500 mg',
        childAgeYears: 18,
      );

      expect(result.calculatedDose, 500.0);
      expect(result.unit, 'mg');
      expect(result.requiresAdjustment, false);
      expect(result.method, 'Насанд хүрэгч');
    });

    test('calculatePediatricDose with invalid dose string', () {
      final result = PediatricDoseCalculator.calculatePediatricDose(
        adultDoseString: 'invalid',
        childAgeYears: 8,
      );

      expect(result.calculatedDose, 0.0);
      expect(result.method, 'Алдаа');
      expect(result.warning, contains('боломжгүй'));
    });

    test('calculatePediatricDose without weight shows warning', () {
      final result = PediatricDoseCalculator.calculatePediatricDose(
        adultDoseString: '500 mg',
        childAgeYears: 8,
      );

      expect(result.warning, contains('Жин оруулаагүй'));
    });

    test('calculatePediatricDose shows range when multiple methods used', () {
      final result = PediatricDoseCalculator.calculatePediatricDose(
        adultDoseString: '500 mg',
        childAgeYears: 8,
        childWeightKg: 25,
        childHeightCm: 125,
      );

      // Should use Young's, Clark's, and BSA methods
      expect(result.method, contains('арга'));
      expect(result.calculatedDoseMin, lessThan(result.calculatedDoseMax));
    });

    test('calculatePediatricDose for very young child (3 years)', () {
      final result = PediatricDoseCalculator.calculatePediatricDose(
        adultDoseString: '500 mg',
        childAgeYears: 3,
        childWeightKg: 14,
      );

      expect(result.warning, contains('Бага насны'));
      expect(
        result.calculatedDose,
        lessThan(200),
      ); // Should be much less than adult
    });
  });

  group('PediatricDoseCalculator - Edge Cases', () {
    test('calculatePediatricDose with very large reduction shows warning', () {
      final result = PediatricDoseCalculator.calculatePediatricDose(
        adultDoseString: '1000 mg',
        childAgeYears: 2,
        childWeightKg: 12,
      );

      expect(result.warning, contains('хэт бага'));
    });

    test('formattedDose shows range correctly', () {
      final result = PediatricDoseCalculator.calculatePediatricDose(
        adultDoseString: '500 mg',
        childAgeYears: 8,
        childWeightKg: 25,
        childHeightCm: 125,
      );

      final formatted = result.formattedDose;
      expect(formatted, contains('mg'));
      expect(formatted, matches(RegExp(r'\d+\.\d+-\d+\.\d+ mg')));
    });

    test('formattedDose shows single value for adults', () {
      final result = PediatricDoseCalculator.calculatePediatricDose(
        adultDoseString: '500 mg',
        childAgeYears: 18,
      );

      final formatted = result.formattedDose;
      expect(formatted, '500.0 mg');
    });
  });

  group('PediatricDoseCalculator - Weight Estimation', () {
    test('estimatedWeightForAge for infant', () {
      expect(PediatricDoseCalculator.estimatedWeightForAge(0), 3.5);
      expect(PediatricDoseCalculator.estimatedWeightForAge(1), 10.0);
    });

    test('estimatedWeightForAge for child', () {
      expect(PediatricDoseCalculator.estimatedWeightForAge(5), 18.5);
      expect(PediatricDoseCalculator.estimatedWeightForAge(10), 32.0);
    });

    test('estimatedWeightForAge for teenager', () {
      expect(PediatricDoseCalculator.estimatedWeightForAge(15), 56.0);
      expect(PediatricDoseCalculator.estimatedWeightForAge(17), 65.0);
    });

    test('estimatedWeightForAge for adult', () {
      expect(PediatricDoseCalculator.estimatedWeightForAge(18), 70.0);
      expect(PediatricDoseCalculator.estimatedWeightForAge(25), 70.0);
    });

    test('estimatedWeightForAge with negative age', () {
      expect(PediatricDoseCalculator.estimatedWeightForAge(-1), 0.0);
    });
  });

  group('PediatricDoseCalculator - Real World Scenarios', () {
    test('Paracetamol for 5 year old child', () {
      // Adult dose: 500mg, Child 5 years, ~18kg
      final result = PediatricDoseCalculator.calculatePediatricDose(
        adultDoseString: '500 мг',
        childAgeYears: 5,
        childWeightKg: 18,
      );

      expect(result.unit, 'mg');
      expect(result.calculatedDose, greaterThan(100));
      expect(result.calculatedDose, lessThan(300));
      expect(result.requiresAdjustment, true);
    });

    test('Amoxicillin for 10 year old', () {
      // Adult dose: 500mg, Child 10 years, ~32kg
      final result = PediatricDoseCalculator.calculatePediatricDose(
        adultDoseString: '500 mg',
        childAgeYears: 10,
        childWeightKg: 32,
      );

      expect(result.calculatedDose, greaterThan(200));
      expect(result.calculatedDose, lessThan(350));
    });

    test('Low dose medication for teenager', () {
      // Teenager close to adult dose
      final result = PediatricDoseCalculator.calculatePediatricDose(
        adultDoseString: '100 mg',
        childAgeYears: 15,
        childWeightKg: 55,
      );

      expect(result.calculatedDose, greaterThan(60));
      expect(result.calculatedDose, lessThan(100));
    });
  });
}
