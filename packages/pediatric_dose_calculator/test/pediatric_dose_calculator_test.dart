import 'package:flutter_test/flutter_test.dart';
import 'package:pediatric_dose_calculator/pediatric_dose_calculator.dart';

void main() {
  group('PediatricDoseCalculator', () {
    test('calculates dose correctly using Young\'s Rule', () {
      final result = PediatricDoseCalculator.calculateDose(
        ageInYears: 8,
        adultDose: 500.0,
        unit: 'mg',
      );

      // 8 / (8 + 12) * 500 = 200
      expect(result.pediatricDose, closeTo(200.0, 0.01));
      expect(result.formattedDose, '200 mg');
    });

    test('returns adult dose for ages 18+', () {
      final result = PediatricDoseCalculator.calculateDose(
        ageInYears: 20,
        adultDose: 500.0,
      );

      expect(result.pediatricDose, 500.0);
      expect(result.warning, isEmpty);
    });

    test('shows warning for infants', () {
      final result = PediatricDoseCalculator.calculateDose(
        ageInYears: 0,
        adultDose: 100.0,
      );

      expect(result.warning, contains('Нярайд онцгой анхаарал'));
    });

    test('shows warning for young children', () {
      final result = PediatricDoseCalculator.calculateDose(
        ageInYears: 2,
        adultDose: 100.0,
      );

      expect(result.warning, contains('Бага насны хүүхэд'));
    });
  });

  group('AdvancedPediatricDoseCalculator', () {
    test('parses dose string correctly', () {
      final parsed1 = AdvancedPediatricDoseCalculator.parseDose('500 mg');
      expect(parsed1.value, 500.0);
      expect(parsed1.unit, 'mg');

      final parsed2 = AdvancedPediatricDoseCalculator.parseDose('2.5g');
      expect(parsed2.value, 2.5);
      expect(parsed2.unit, 'g');
    });

    test('calculates using multiple methods', () {
      final result = AdvancedPediatricDoseCalculator.calculatePediatricDose(
        adultDoseString: '500 mg',
        childAgeYears: 8,
        childWeightKg: 25.5,
        childHeightCm: 130.0,
      );

      expect(result.calculatedDose, greaterThan(0));
      expect(result.unit, 'mg');
      expect(result.method, isNotEmpty);
    });

    test('uses Fried\'s Rule for infants', () {
      final result = AdvancedPediatricDoseCalculator.calculatePediatricDose(
        adultDoseString: '150 mg',
        childAgeYears: 1,
      );

      expect(result.method, contains('Fried'));
    });

    test('estimates weight for age', () {
      final weight8Years =
          AdvancedPediatricDoseCalculator.estimatedWeightForAge(8);
      expect(weight8Years, 25.5);

      final weightAdult =
          AdvancedPediatricDoseCalculator.estimatedWeightForAge(20);
      expect(weightAdult, 70.0);
    });
  });
}
