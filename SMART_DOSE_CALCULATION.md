# Smart Pediatric Dose Calculation

## Overview
The medication app now features **automatic pediatric dose calculation** that intelligently adjusts medication doses based on the patient's age.

## How It Works

### 1. **Automatic Calculation on Drug Selection**
When you select a drug from the catalog for a pediatric patient (age < 18):
- The system automatically detects the patient's age
- Parses the adult dose from the drug catalog
- Calculates the appropriate pediatric dose using **Young's Rule**
- Displays the calculated dose with visual indicators

### 2. **Young's Rule Formula**
```
Pediatric Dose = (Age / (Age + 12)) × Adult Dose
```

For patients 18 years or older, the adult dose is used without modification.

### 3. **Supported Dose Formats**
The calculator intelligently parses various dose formats:
- `500mg`, `500 mg`
- `1g`, `1 g`
- `5ml`, `5 ml`
- `250mcg`, `250 μg`
- Mongolian units: `мг`, `г`, `мл`, `мкг`

### 4. **Visual Indicators**
- A **child care icon** (👶) appears in the dose field for pediatric patients
- The icon indicates that automatic dose calculation is active
- Tooltip shows "Хүүхдийн тун автоматаар тооцоологдоно" (Pediatric dose calculated automatically)

## Features

### Smart Integration
- **No extra steps required**: Just select a drug from the catalog
- **Seamless experience**: The dose field is automatically populated with the pediatric-adjusted dose
- **Manual override**: Doctors can still manually adjust the dose if needed

### Safety Warnings
The calculator provides age-specific warnings:
- **Age < 1 year**: "⚠️ Нярайд онцгой анхаарал хандуулна уу!" (Special care for infants!)
- **Age < 3 years**: "⚠️ Бага насны хүүхэд - эмчтэй зөвлөлдөнө үү" (Young child - consult with doctor)

### Manual Calculation Option
The `PediatricDoseHelper` widget is still available below each drug entry for:
- Manual dose verification
- Calculating doses for custom medications not in the catalog
- Educational purposes to show the calculation process

## Technical Implementation

### Modified Components

1. **DrugInput Widget** (`lib/widgets.dart`)
   - Added `patientAge` parameter
   - Integrated `_calculatePediatricDose()` method
   - Automatic calculation on drug selection
   - Visual indicator for pediatric mode

2. **PrescriptionFormPage** (`lib/pages/prescription_form_page.dart`)
   - Passes patient age to each `DrugInput` widget
   - Maintains existing `PediatricDoseHelper` for manual calculations

3. **Dose Calculator** (`lib/services/pediatric_dose_calculator.dart`)
   - `PediatricDoseCalculator.calculateDose()` - Main calculation method
   - `OldPediatricDoseCalculator.parseDose()` - Dose string parser
   - Support for multiple dosing formulas (Young's, Clark's, Fried's, BSA)

## Usage Example

### Before (Manual)
1. Select drug "Амоксициллин" with dose "500mg"
2. Doctor manually calculates pediatric dose for 8-year-old
3. Manually enters adjusted dose "200mg"

### After (Automatic)
1. Select drug "Амоксициллин" with dose "500mg"
2. System automatically calculates: (8 / (8 + 12)) × 500 = 200mg
3. Dose field shows "200 mg" with 👶 indicator
4. Doctor can verify or adjust as needed

## Benefits

✅ **Faster**: No manual calculation needed  
✅ **Safer**: Reduces calculation errors  
✅ **Smarter**: Context-aware based on patient age  
✅ **Transparent**: Visual indicators show when auto-calculation is active  
✅ **Flexible**: Doctors can still override if needed  

## Edge Cases Handled

- **Adults (≥18)**: Uses full adult dose
- **Unparseable doses**: Returns original dose string
- **Missing patient age**: Falls back to standard behavior
- **Zero or negative doses**: Returns original value
- **Custom medications**: Manual helper still available

## Future Enhancements

Potential improvements for consideration:
- Weight-based calculations (Clark's Rule)
- BSA-based calculations for chemotherapy
- Drug-specific dosing guidelines
- Maximum dose limits per drug
- Interaction with contraindications database
