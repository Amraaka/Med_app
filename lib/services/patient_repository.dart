import 'package:shared_preferences/shared_preferences.dart';

import '../models/patient.dart';

class PatientRepository {
  static const _keyPatients = 'patients_list_v1';

  Future<List<Patient>> getPatients() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList(_keyPatients);
    if (data == null) return [];
    return data.map((e) => Patient.fromJson(e)).toList();
  }

  Future<void> savePatients(List<Patient> patients) async {
    final prefs = await SharedPreferences.getInstance();
    final list = patients.map((e) => e.toJson()).toList();
    await prefs.setStringList(_keyPatients, list);
  }

  Future<void> addOrUpdatePatient(Patient patient) async {
    final patients = await getPatients();
    final idx = patients.indexWhere((p) => p.id == patient.id);
    if (idx >= 0) {
      patients[idx] = patient;
    } else {
      patients.add(patient);
    }
    await savePatients(patients);
  }
}
