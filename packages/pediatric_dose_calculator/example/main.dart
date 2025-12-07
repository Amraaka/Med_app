import 'package:pediatric_dose_calculator/pediatric_dose_calculator.dart';

void main() {
  // Example 1: Simple dose calculation using Young's Rule
  print('=== Example 1: Simple Calculation ===');
  final simpleResult = PediatricDoseCalculator.calculateDose(
    ageInYears: 8,
    adultDose: 500.0,
    unit: 'mg',
  );

  print('Patient age: 8 years');
  print('Adult dose: 500 mg');
  print('Calculated pediatric dose: ${simpleResult.formattedDose}');
  if (simpleResult.warning.isNotEmpty) {
    print('Warning: ${simpleResult.warning}');
  }

  // Example 2: Advanced calculation with multiple methods
  print('\n=== Example 2: Advanced Multi-Method Calculation ===');
  final advancedResult = AdvancedPediatricDoseCalculator.calculatePediatricDose(
    adultDoseString: '500 mg',
    childAgeYears: 8,
    childWeightKg: 25.5,
    childHeightCm: 130.0,
  );

  print('Patient age: 8 years');
  print('Patient weight: 25.5 kg');
  print('Patient height: 130 cm');
  print('Adult dose: 500 mg');
  print('Calculated dose: ${advancedResult.formattedDose}');
  print('Method used: ${advancedResult.method}');
  if (advancedResult.warning.isNotEmpty) {
    print('Warning: ${advancedResult.warning}');
  }
  print('Recommendation: ${advancedResult.recommendation}');

  // Example 3: Infant calculation (Fried's Rule)
  print('\n=== Example 3: Infant Calculation ===');
  final infantResult = AdvancedPediatricDoseCalculator.calculatePediatricDose(
    adultDoseString: '150 mg',
    childAgeYears: 1,
  );

  print('Patient age: 1 year (12 months)');
  print('Adult dose: 150 mg');
  print('Calculated dose: ${infantResult.formattedDose}');
  print('Method used: ${infantResult.method}');
  if (infantResult.warning.isNotEmpty) {
    print('⚠️  ${infantResult.warning}');
  }

  // Example 4: Parsing dose strings
  print('\n=== Example 4: Dose String Parsing ===');
  final doses = ['500 mg', '2.5 g', '750 мг', '100 mcg'];
  for (final doseStr in doses) {
    final parsed = AdvancedPediatricDoseCalculator.parseDose(doseStr);
    print('Input: "$doseStr" → Value: ${parsed.value}, Unit: ${parsed.unit}');
  }
}
