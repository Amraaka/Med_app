import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/prescription.dart';

/// Simple service to manage prescriptions - combines data storage and state management
class PrescriptionService extends ChangeNotifier {
  List<Prescription> _prescriptions = [];

  List<Prescription> get prescriptions => _prescriptions;

  /// Load all prescriptions from storage
  Future<void> loadPrescriptions() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList('prescriptions_list') ?? [];
    _prescriptions = data.map((e) => Prescription.fromJson(e)).toList();
    // Sort by most recent first
    _prescriptions.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    notifyListeners();
  }

  /// Save all prescriptions to storage
  Future<void> _savePrescriptions() async {
    final prefs = await SharedPreferences.getInstance();
    final list = _prescriptions.map((e) => e.toJson()).toList();
    await prefs.setStringList('prescriptions_list', list);
  }

  /// Add a new prescription or update existing one
  Future<void> savePrescription(Prescription prescription) async {
    final index = _prescriptions.indexWhere((p) => p.id == prescription.id);
    if (index >= 0) {
      _prescriptions[index] = prescription;
    } else {
      _prescriptions.add(prescription);
    }
    // Keep sorted by most recent
    _prescriptions.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    await _savePrescriptions();
    notifyListeners();
  }

  /// Get recent prescriptions (default 10)
  List<Prescription> getRecentPrescriptions([int limit = 10]) {
    return _prescriptions.take(limit).toList();
  }

  /// Get all prescriptions for a specific patient
  List<Prescription> getPrescriptionsByPatient(String patientId) {
    return _prescriptions.where((p) => p.patientId == patientId).toList();
  }

  /// Delete a prescription
  Future<void> deletePrescription(String prescriptionId) async {
    _prescriptions.removeWhere((p) => p.id == prescriptionId);
    await _savePrescriptions();
    notifyListeners();
  }

  /// Delete all prescriptions for a patient
  Future<void> deletePrescriptionsByPatient(String patientId) async {
    _prescriptions.removeWhere((p) => p.patientId == patientId);
    await _savePrescriptions();
    notifyListeners();
  }
}
