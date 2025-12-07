# Pediatric Dose Calculator

A Flutter package for calculating pediatric medication doses using standard medical formulas.

## Features

- **Young's Rule**: Age-based dose calculation for children 1-18 years
- **Clark's Rule**: Weight-based dose calculation
- **Fried's Rule**: Age-based calculation for infants under 2 years
- **BSA Method**: Body Surface Area calculation (most accurate when height/weight available)

## Usage

### Simple Dose Calculation

```dart
import 'package:pediatric_dose_calculator/pediatric_dose_calculator.dart';

final result = PediatricDoseCalculator.calculateDose(
  ageInYears: 8,
  adultDose: 500.0,
  unit: 'mg',
);

print(result.formattedDose); // "266.7 mg"
print(result.warning); // Age-specific warnings if applicable
```

### Advanced Multi-Method Calculation

```dart
final result = AdvancedPediatricDoseCalculator.calculatePediatricDose(
  adultDoseString: '500 mg',
  childAgeYears: 8,
  childWeightKg: 25.5,
  childHeightCm: 130.0,
);

print(result.formattedDose); // Range if multiple methods used
print(result.method); // Which calculation method(s) were used
print(result.warning); // Important warnings
print(result.recommendation); // Clinical recommendations
```

## Important Medical Disclaimer

This calculator is for educational and reference purposes. Always consult with a qualified healthcare professional before administering any medication to children. Pediatric dosing requires careful medical supervision.
