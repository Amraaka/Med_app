# Beginner's Guide to Med App

Welcome! This guide will help you understand the structure and flow of this Flutter medical prescription app.

## 📱 What Does This App Do?

This app helps doctors:
1. Manage patient records (add new patients, view existing ones)
2. Create prescriptions for patients
3. Generate PDF documents for prescriptions

## 🗂️ Project Structure Explained

### `lib/main.dart` - The Starting Point
This is where your app begins. It sets up:
- **Services**: Two services that manage data throughout the app
- **Navigation**: Bottom navigation bar with Home and Profile tabs
- **Theme**: Colors and fonts for the entire app

### `lib/models/` - Data Structures
Think of these as blueprints for your data:
- **`patient.dart`**: What information we store about each patient (name, age, diagnosis, etc.)
- **`prescription.dart`**: Details of a prescription (patient ID, drugs, notes, etc.)
- **`drug.dart`**: Information about medications (name, dosage, instructions)

### `lib/services/` - The Brain of the App
These files handle all the important logic:

#### `patient_service.dart`
- **What it does**: Manages all patient data
- **Key methods**:
  - `loadPatients()`: Loads saved patients from device storage
  - `savePatient(patient)`: Saves a new or updated patient
  - `setCurrentPatient(patient)`: Sets which patient is currently selected

#### `prescription_service.dart`
- **What it does**: Manages all prescription data
- **Key methods**:
  - `loadPrescriptions()`: Loads saved prescriptions from device storage
  - `savePrescription(prescription)`: Saves a new prescription
  - `getRecentPrescriptions()`: Gets the most recent prescriptions
  - `getPrescriptionsByPatient(id)`: Gets all prescriptions for a specific patient

#### `pdf_service.dart`
- **What it does**: Creates PDF documents for prescriptions
- Uses the `pdf` and `printing` packages to generate professional-looking documents

### `lib/pages/` - The Screens

#### `home_page.dart` - Dashboard
Shows:
- Welcome message
- Total number of patients
- Recent prescriptions
- Quick action button to create a new prescription

#### `profile_page.dart` - Doctor Profile
Shows:
- Current selected patient
- Button to select/add a patient
- List of prescriptions for the current patient
- Button to create a new prescription

#### `patient_form_page.dart` - Add/Edit Patient
A form to enter patient information:
- Family name and given name
- Birth date
- Registration number
- Sex
- Phone and address
- Diagnosis and ICD code

#### `prescription_form_page.dart` - Create Prescription
A form to create a prescription:
- Add multiple drugs
- Enter clinic name and doctor info
- Add notes
- Guardian info (if patient is under 16)

#### `existing_patients_page.dart` - Patient List
Shows a list of all saved patients that you can select from.

#### `select_patient_page.dart` - Patient Selector
Allows you to either:
- Select an existing patient from the list
- Add a new patient

### `lib/widgets/` - Reusable Components

#### `drug_input.dart`
A custom widget for entering drug information:
- Drug name
- Dosage (strength)
- Quantity
- Usage instructions

### `lib/utils/` - Helper Functions

#### `validators.dart`
Contains validation functions for forms:
- Check if required fields are filled
- Validate phone numbers
- Validate dates

## 🔄 How Data Flows

### Adding a New Patient:
1. User fills out form in `patient_form_page.dart`
2. Form validates the input
3. Page returns the patient object
4. Service saves it using `PatientService.savePatient()`
5. Data is stored in device memory using SharedPreferences
6. UI updates automatically (thanks to Provider/ChangeNotifier)

### Creating a Prescription:
1. User selects a patient
2. User fills out prescription form in `prescription_form_page.dart`
3. Service saves it using `PrescriptionService.savePrescription()`
4. PDF is generated and shown to the user
5. Data is stored in device memory
6. UI updates to show the new prescription

## 🎨 State Management with Provider

**Provider** is a simple state management solution:

```dart
// 1. Service extends ChangeNotifier
class PatientService extends ChangeNotifier {
  List<Patient> _patients = [];
  
  // 2. When data changes, call notifyListeners()
  Future<void> savePatient(Patient patient) async {
    _patients.add(patient);
    notifyListeners(); // This updates all listening widgets
  }
}

// 3. In pages, watch for changes
final patients = context.watch<PatientService>().patients;
```

When `notifyListeners()` is called, all widgets using `context.watch()` automatically rebuild with the new data!

## 💾 Data Storage

Data is saved locally on the device using **SharedPreferences**:
- Converts data to JSON strings
- Stores in device memory
- Persists between app sessions
- Perfect for small amounts of data like patients and prescriptions

```dart
// Save
final prefs = await SharedPreferences.getInstance();
await prefs.setStringList('patients_list', jsonList);

// Load
final data = prefs.getStringList('patients_list') ?? [];
```

## 🚀 Common Tasks

### Adding a New Feature
1. **Add to Model**: If you need new data, update the model class
2. **Update Service**: Add methods to save/load the new data
3. **Create UI**: Build the page/widget to display or edit the data
4. **Connect with Provider**: Use `context.watch()` or `context.read()`

### Debugging Tips
- Use `print()` statements to see what's happening
- Check the Flutter DevTools for widget tree inspection
- Use breakpoints in VS Code to step through code
- Look at console for error messages

## 📚 Next Steps to Learn

1. **Dart Basics**: Learn about classes, async/await, lists, maps
2. **Flutter Widgets**: Study StatelessWidget vs StatefulWidget
3. **Forms**: Understand TextEditingController and Form validation
4. **Navigation**: Learn about Navigator.push() and routes
5. **State Management**: Explore Provider, Riverpod, or Bloc

## 🛠️ Modifying the App

### Change Colors
Edit `main.dart` line 32-33:
```dart
seedColor: const Color(0xFF008B8B), // Change this hex color
secondary: const Color(0xFFE55A52),  // And this one
```

### Add a New Field to Patient
1. Add to `patient.dart` model
2. Update JSON methods (`toJson`, `fromJson`)
3. Add form field in `patient_form_page.dart`
4. Update display in pages showing patient info

### Add a New Page
1. Create new file in `lib/pages/`
2. Build your StatelessWidget or StatefulWidget
3. Navigate to it using:
```dart
Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => YourNewPage()),
);
```

## ❓ Common Questions

**Q: Where is data stored?**
A: On the device using SharedPreferences (like cookies in web apps).

**Q: Why use Provider?**
A: It automatically updates the UI when data changes, without manual setState calls.

**Q: What if I want to use a real database?**
A: Replace SharedPreferences with sqflite or Hive for local database, or use Firebase for cloud storage.

**Q: How do I add more tabs?**
A: Add a new page to the `_pages` list in `main.dart` and add a new navigation item.

## 📖 Resources

- [Flutter Documentation](https://docs.flutter.dev/)
- [Dart Language Tour](https://dart.dev/guides/language/language-tour)
- [Provider Package](https://pub.dev/packages/provider)
- [Flutter Widget Catalog](https://docs.flutter.dev/ui/widgets)

Happy coding! 🎉
