import 'package:flutter/foundation.dart';

import '../models/patient.dart';
import '../services/patient_repository.dart';

class PatientProvider extends ChangeNotifier {
  final PatientRepository _repo;
  PatientProvider(this._repo);

  List<Patient> _patients = [];
  Patient? _current;

  List<Patient> get patients => _patients;
  Patient? get current => _current;

  Future<void> load() async {
    _patients = await _repo.getPatients();
    notifyListeners();
  }

  Future<void> setCurrent(Patient? p) async {
    _current = p;
    notifyListeners();
  }

  Future<void> addOrUpdate(Patient p) async {
    await _repo.addOrUpdatePatient(p);
    await load();
    _current = p;
    notifyListeners();
  }
}
