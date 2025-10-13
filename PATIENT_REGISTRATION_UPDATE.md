# Patient Registration Flow Update

## Overview
The patient registration flow has been simplified to collect minimal information upfront and gather complete details when creating a prescription.

## Changes Made

### 1. Patient Model (`lib/models/patient.dart`)
- Made the following fields **optional** with empty string defaults:
  - `registrationNumber` (РД)
  - `phone` (Утас)
  - `address` (Хаяг)
  - `diagnosis` (Онош)
  - `icd` (ICD код)

- **Required fields** (collected during patient registration):
  - `familyName` (Овог)
  - `givenName` (Нэр)
  - `birthDate` (Төрсөн огноо)
  - `sex` (Хүйс)

### 2. Patient Form Page (`lib/pages/patient_form_page.dart`)
**Simplified to collect only essential information:**
- First Name (Нэр)
- Last Name (Овог)
- Date of Birth (Төрсөн огноо)
- Sex (Хүйс)

**Removed fields** (now collected during prescription creation):
- Registration Number (РД)
- Phone (Утас)
- Address (Хаяг)
- Diagnosis (Онош)
- ICD Code

Added an info box explaining that additional information will be collected when creating a prescription.

### 3. Prescription Form Page (`lib/pages/prescription_form_page.dart`)
**Enhanced to collect missing patient information:**

- Added fields for patient information if not yet filled:
  - Registration Number (РД)
  - Phone (Утас)
  - Address (Хаяг)

- These fields appear in an **orange warning box** when the patient's info is incomplete
- The form automatically updates the patient's record when saving the prescription
- Patient info is prefilled if already available

**Workflow:**
1. Shows patient summary card at the top
2. If patient info is incomplete, displays warning box with required fields
3. Collects diagnosis and ICD for the specific prescription
4. Updates both patient record and creates prescription on save

### 4. Profile Page (`lib/pages/profile_page.dart`)
**Updated to handle empty fields gracefully:**
- Shows `—` (em dash) for empty patient information fields
- Empty fields are displayed in gray italic text
- All patient details remain visible but clearly indicate missing information

## User Flow

### Creating a New Patient
1. Click "Шинэ өвчтөн" (New Patient) button
2. Enter only:
   - Family Name
   - Given Name
   - Birth Date
   - Sex
3. Save patient
4. Patient is now registered with basic information

### Creating First Prescription
1. Select patient from profile page or home page
2. Click "Шинэ жор бичих" (Create New Prescription)
3. **If patient info is incomplete**, fill in:
   - Registration Number
   - Phone
   - Address
4. Fill in prescription details:
   - Diagnosis
   - ICD Code
   - Prescription Type
   - Drugs
5. Save prescription
6. Patient record is automatically updated with complete information

### Subsequent Prescriptions
- Patient information is already complete
- Warning box does not appear
- Only prescription-specific details need to be entered

## Benefits

1. **Faster Patient Registration**: Only 4 fields needed to register a patient
2. **Natural Workflow**: Detailed information collected when actually needed (during prescription)
3. **Reduced Friction**: Doctors can quickly register a patient and immediately create a prescription
4. **Data Quality**: Information is collected at the point of care when it's most relevant
5. **Flexibility**: Supports both quick registration and complete data collection in one flow

## Technical Details

- Patient model uses optional parameters with default empty strings
- `copyWith` method properly handles updating partial patient information
- Profile page gracefully displays incomplete patient records
- Prescription form validates required patient fields before saving
- Both patient and prescription services are updated atomically during prescription creation
