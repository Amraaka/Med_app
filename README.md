# Medical Prescription App

A beginner-friendly Flutter application for managing patients and prescriptions.

## Project Structure (Simplified for Beginners)

```
lib/
├── main.dart                    # App entry point
├── models/                      # Data models
│   ├── patient.dart            # Patient information
│   ├── prescription.dart       # Prescription details
│   └── drug.dart              # Drug/medication info
├── pages/                       # All screens in the app
│   ├── home_page.dart          # Dashboard/home screen
│   ├── profile_page.dart       # Doctor profile & current patient
│   ├── patient_form_page.dart  # Add/edit patient
│   ├── prescription_form_page.dart  # Create prescription
│   ├── existing_patients_page.dart  # List of patients
│   └── select_patient_page.dart     # Patient selector
├── services/                    # Business logic & data storage
│   ├── patient_service.dart    # Patient management (CRUD + state)
│   ├── prescription_service.dart  # Prescription management
│   └── pdf_service.dart        # PDF generation
├── widgets/                     # Reusable UI components
│   └── drug_input.dart         # Drug input widget
└── utils/                       # Helper functions
    └── validators.dart         # Form validation

android/                         # Android-specific files
ios/                            # iOS-specific files
assets/                         # Images and fonts
```

## Key Features

- 📋 Patient management (add, view, select)
- 💊 Prescription creation with multiple drugs
- 📄 PDF generation for prescriptions
- 💾 Local data storage using SharedPreferences
- 🎨 Clean Material Design UI

## How It Works

### State Management
The app uses **Provider** for simple state management:
- `PatientService` - Manages patient data and notifies UI of changes
- `PrescriptionService` - Manages prescriptions and notifies UI of changes

### Data Persistence
Data is stored locally using **SharedPreferences**:
- Patients are saved as JSON strings
- Prescriptions are saved as JSON strings
- Data persists between app sessions

## Getting Started

### Prerequisites
- Flutter SDK installed
- Android Studio or Xcode for running on emulator/simulator
- VS Code (recommended) with Flutter extension

### Run the App

```bash
# Get dependencies
flutter pub get

# Run on connected device or emulator
flutter run
```

## Simplified Changes for Beginners

This project has been simplified by:
1. ✅ Removing complex repository pattern - services handle both data and state
2. ✅ Removing unused platform folders (web, linux, macos, windows)
3. ✅ Removing unnecessary config files
4. ✅ Combining provider + repository into simple services
5. ✅ Clear comments explaining what each file does
6. ✅ Straightforward folder structure

## Learning Path

1. **Start with `main.dart`** - Understand app initialization and navigation
2. **Explore `models/`** - See how data is structured
3. **Check `services/`** - Learn how data is saved and loaded
4. **Study `pages/`** - See how screens are built
5. **Review `widgets/`** - Understand reusable components

## Resources for Beginners

- [Flutter Documentation](https://docs.flutter.dev/)
- [Provider Package](https://pub.dev/packages/provider)
- [Dart Language Tour](https://dart.dev/guides/language/language-tour)
