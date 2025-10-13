# Project Structure Visualization

## App Architecture Overview

```
┌─────────────────────────────────────────┐
│           main.dart                      │
│  (App Entry Point + Navigation)          │
│                                          │
│  ┌────────────────────────────────┐     │
│  │   MultiProvider                │     │
│  │  - PatientService              │     │
│  │  - PrescriptionService         │     │
│  └────────────────────────────────┘     │
│                                          │
│  ┌──────────────┬──────────────┐        │
│  │  Home Page   │ Profile Page │        │
│  └──────────────┴──────────────┘        │
└─────────────────────────────────────────┘
```

## Data Flow Diagram

```
User Interaction
      ↓
   UI Page (pages/)
      ↓
   Service (services/)
      ↓
SharedPreferences (Storage)
      ↓
Service notifyListeners()
      ↓
   UI Updates
```

## File Organization

```
med_app/
│
├── lib/                          ← All Dart code
│   │
│   ├── main.dart                 ← START HERE!
│   │   └─ Sets up app, navigation, services
│   │
│   ├── models/                   ← Data blueprints
│   │   ├── patient.dart          (Name, age, diagnosis...)
│   │   ├── prescription.dart     (Drugs, date, notes...)
│   │   └── drug.dart             (Name, dosage, usage...)
│   │
│   ├── services/                 ← Business logic
│   │   ├── patient_service.dart       (Manage patients)
│   │   ├── prescription_service.dart  (Manage prescriptions)
│   │   └── pdf_service.dart           (Generate PDFs)
│   │
│   ├── pages/                    ← All screens
│   │   ├── home_page.dart             📊 Dashboard
│   │   ├── profile_page.dart          👤 Doctor profile
│   │   ├── patient_form_page.dart     ➕ Add patient
│   │   ├── prescription_form_page.dart 💊 New prescription
│   │   ├── existing_patients_page.dart 📋 Patient list
│   │   └── select_patient_page.dart   🔍 Select patient
│   │
│   ├── widgets/                  ← Reusable UI
│   │   └── drug_input.dart       (Drug entry form)
│   │
│   └── utils/                    ← Helpers
│       └── validators.dart       (Form validation)
│
├── android/                      ← Android specific
├── ios/                          ← iOS specific
├── assets/                       ← Images, fonts
│   ├── images/
│   └── fonts/
│
├── pubspec.yaml                  ← Dependencies
└── README.md                     ← Project info
```

## Service Architecture (Simplified!)

### Before (Complex):
```
UI ← Provider ← Repository ← SharedPreferences
      ↓
   Business Logic
```

### After (Beginner-Friendly):
```
UI ← Service (Provider + Repository + Logic)
       ↓
   SharedPreferences
```

**One service does it all!**
✅ Manages state (Provider)
✅ Stores data (Repository)
✅ Handles business logic

## Page Flow

### Creating a Prescription:

```
┌─────────────────┐
│   Home Page     │ Click "New Prescription"
└────────┬────────┘
         ↓
┌─────────────────────┐
│ Select Patient Page │ Choose or add patient
└─────────┬───────────┘
          ↓
┌───────────────────────┐
│ Prescription Form Page│ Fill prescription details
└─────────┬─────────────┘
          ↓
┌──────────────────┐
│ PrescriptionService │ Save prescription
└─────────┬────────────┘
          ↓
┌──────────────────┐
│   PDF Service    │ Generate PDF
└─────────┬────────┘
          ↓
┌──────────────────┐
│  Show PDF to user │
└──────────────────┘
```

### Adding a Patient:

```
┌─────────────────┐
│  Profile Page   │ Click "Add Patient"
└────────┬────────┘
         ↓
┌──────────────────┐
│ Patient Form Page│ Fill patient info
└─────────┬────────┘
          ↓
┌──────────────────┐
│  PatientService  │ Save patient
└─────────┬────────┘
          ↓
┌──────────────────┐
│  UI Auto-updates │ (thanks to Provider!)
└──────────────────┘
```

## Key Concepts

### 1. Models = Data Structure
```dart
class Patient {
  String name;
  int age;
  String diagnosis;
}
```

### 2. Services = Data + Logic
```dart
class PatientService extends ChangeNotifier {
  List<Patient> patients = [];
  
  void addPatient(Patient p) {
    patients.add(p);
    notifyListeners(); // Updates UI!
  }
}
```

### 3. Pages = UI Screens
```dart
class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Use service data
    final service = context.watch<PatientService>();
    return Text('Patients: ${service.patients.length}');
  }
}
```

### 4. Provider Pattern
```
┌──────────────┐
│   Service    │ ← Single source of truth
└───────┬──────┘
        │
    ┌───┴───┬───────┬──────┐
    ↓       ↓       ↓      ↓
  Page1  Page2  Page3  Widget1
```
All widgets listen to the same service!

## Navigation Structure

```
MainScreen (Bottom Navigation)
    │
    ├─── [Tab 0] HomePage
    │       └─── Button → PrescriptionFormPage
    │
    └─── [Tab 1] ProfilePage
            ├─── Button → PatientFormPage
            ├─── Button → ExistingPatientsPage
            └─── Button → PrescriptionFormPage
```

## What Was Removed (Beginner-Friendly Changes)

❌ Removed:
- `lib/providers/` folder (merged into services)
- `lib/services/patient_repository.dart` (merged into patient_service.dart)
- `lib/services/prescription_repository.dart` (merged into prescription_service.dart)
- `lib/app_theme.dart` (moved theme inline to main.dart)
- `web/`, `linux/`, `macos/`, `windows/` (focus on mobile)
- `analysis_options.yaml` (not needed for beginners)
- `devtools_options.yaml` (auto-generated)

✅ Result:
- Fewer files to understand
- Simpler architecture
- Easier to follow data flow
- Same functionality!

## Learning Path

```
1. main.dart
   ↓ Understand app structure
   
2. models/
   ↓ Learn data structures
   
3. services/
   ↓ See how data is managed
   
4. pages/home_page.dart
   ↓ Simple page to start
   
5. pages/patient_form_page.dart
   ↓ Form handling
   
6. pages/prescription_form_page.dart
   ↓ Complex form with widgets
   
7. widgets/
   ↓ Reusable components
   
8. utils/
   ↓ Helper functions
```

Start at step 1 and work your way down! 🎯
