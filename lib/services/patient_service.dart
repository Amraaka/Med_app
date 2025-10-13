import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/patient.dart';

/// Simple service to manage patients - combines data storage and state management
class PatientService extends ChangeNotifier {
  List<Patient> _patients = [];
  Patient? _currentPatient;

  List<Patient> get patients => _patients;
  Patient? get currentPatient => _currentPatient;

  /// Load all patients from storage
  Future<void> loadPatients() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList('patients_list') ?? [];
    _patients = data.map((e) => Patient.fromJson(e)).toList();
    notifyListeners();
  }

  /// Save all patients to storage
  Future<void> _savePatients() async {
    final prefs = await SharedPreferences.getInstance();
    final list = _patients.map((e) => e.toJson()).toList();
    await prefs.setStringList('patients_list', list);
  }

  /// Add a new patient or update existing one
  Future<void> savePatient(Patient patient) async {
    final index = _patients.indexWhere((p) => p.id == patient.id);
    if (index >= 0) {
      _patients[index] = patient;
    } else {
      _patients.add(patient);
    }
    await _savePatients();
    _currentPatient = patient;
    notifyListeners();
  }

  /// Set the current patient
  void setCurrentPatient(Patient? patient) {
    _currentPatient = patient;
    notifyListeners();
  }
}
