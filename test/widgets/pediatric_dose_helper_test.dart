import 'package:flutter_test/flutter_test.dart';
import 'package:med_app/services/pediatric_dose_calculator.dart';

void main() {
  group('Pediatric Dose Calculation Tests', () {
    test('5-year-old child ', () {
      final result = PediatricDoseCalculator.calculateDose(
        ageInYears: 5,
        adultDose: 500.0,
      );

      final doseValue = double.tryParse(
        result.formattedDose.replaceAll(RegExp(r'[^0-9.]'), ''),
      );

      expect(doseValue, isNotNull);
      expect(doseValue!, lessThan(500.0));
      expect(doseValue, greaterThan(0));
    });

    test('10-year-old child ', () {
      final result = PediatricDoseCalculator.calculateDose(
        ageInYears: 10,
        adultDose: 500.0,
      );

      final doseValue = double.tryParse(
        result.formattedDose.replaceAll(RegExp(r'[^0-9.]'), ''),
      );

      expect(doseValue, isNotNull);
      expect(doseValue!, lessThan(500.0));
      expect(doseValue, greaterThan(0));
    });
  });
}
