import 'package:flutter/foundation.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'models.dart';
import 'package:path_provider/path_provider.dart';

// Patient Service

class PatientService extends ChangeNotifier {
  List<Patient> _patients = [];

  List<Patient> get patients => _patients;

  Future<void> loadPatients() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList('patients_list') ?? [];
    _patients = data.map((e) => Patient.fromJson(e)).toList();
    // Seed demo patients on first run (when no stored patients)
    if (_patients.isEmpty) {
      final demos = _buildDemoPatients();
      _patients = demos;
      await _savePatients();
    }
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
    notifyListeners();
  }

  /// Delete a patient
  Future<void> deletePatient(String patientId) async {
    _patients.removeWhere((p) => p.id == patientId);
    await _savePatients();
    notifyListeners();
  }
}

// ============================================================================
// Prescription Service
// ============================================================================

/// Simple service to manage prescriptions - combines data storage and state management
class PrescriptionService extends ChangeNotifier {
  List<Prescription> _prescriptions = [];

  List<Prescription> get prescriptions => _prescriptions;

  /// Load all prescriptions from storage
  Future<void> loadPrescriptions() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList('prescriptions_list') ?? [];
    _prescriptions = data.map((e) => Prescription.fromJson(e)).toList();
    // Seed demo prescriptions on first run (when none exist)
    if (_prescriptions.isEmpty) {
      // Ensure there's at least one patient to attach to
      final patientData = prefs.getStringList('patients_list') ?? [];
      List<Patient> storedPatients = patientData
          .map((e) => Patient.fromJson(e))
          .toList();

      if (storedPatients.isEmpty) {
        // Create and persist demo patients if none exist yet
        storedPatients = _buildDemoPatients();
        await prefs.setStringList(
          'patients_list',
          storedPatients.map((p) => p.toJson()).toList(),
        );
      }

      // Create three demo prescriptions mapped to three types
      final rxList = <Prescription>[];
      if (storedPatients.isNotEmpty) {
        // Regular
        rxList.add(
          _buildDemoPrescriptionFor(
            patientId: storedPatients[0].id,
            type: PrescriptionType.regular,
          ),
        );
      }
      if (storedPatients.length > 1) {
        // Psychotropic
        rxList.add(
          _buildDemoPrescriptionFor(
            patientId: storedPatients[1].id,
            type: PrescriptionType.psychotropic,
          ),
        );
      }
      if (storedPatients.length > 2) {
        // Narcotic
        rxList.add(
          _buildDemoPrescriptionFor(
            patientId: storedPatients[2].id,
            type: PrescriptionType.narcotic,
          ),
        );
      }

      _prescriptions = rxList;
      await _savePrescriptions();
    }
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

// Doctor Profile Service

class DoctorProfileService extends ChangeNotifier {
  static const _prefsKey = 'doctor_profile';
  DoctorProfile _profile = const DoctorProfile(
    name: 'Др. Ариун',
    title: 'Дотрын эмч',
    location: 'Улаанбаатар, Монгол',
  );

  DoctorProfile get profile => _profile;

  Future<void> loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    if (raw != null) {
      _profile = DoctorProfile.fromJson(raw);
    }
    notifyListeners();
  }

  Future<void> updateProfile(DoctorProfile updated) async {
    _profile = updated;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, _profile.toJson());
    notifyListeners();
  }

  Future<String?> savePickedImage(File sourceFile) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final filename =
          'doctor_${DateTime.now().millisecondsSinceEpoch}${sourceFile.path.split('.').last.isNotEmpty ? '.${sourceFile.path.split('.').last}' : ''}';
      final dest = File('${dir.path}/$filename');
      final bytes = await sourceFile.readAsBytes();
      await dest.writeAsBytes(bytes, flush: true);
      return dest.path;
    } catch (_) {
      return null;
    }
  }
}

// Demo Seed Builders

List<Patient> _buildDemoPatients() {
  return [
    Patient(
      id: 'p_demo_regular',
      familyName: 'Бат',
      givenName: 'Энх-Оргил',
      birthDate: DateTime(1992, 5, 14),
      sex: Sex.male,
      registrationNumber: 'УБ92051412',
      phone: '99001122',
      address: 'УБ, БЗД, 15-р хороо',
      diagnosis: 'Дээд амьсгалын замын цочмог халдвар',
      icd: 'J06.9',
    ),
    Patient(
      id: 'p_demo_narcotic',
      familyName: 'Долгор',
      givenName: 'Саруул',
      birthDate: DateTime(1975, 3, 28),
      sex: Sex.female,
      registrationNumber: 'УБ75032845',
      phone: '98887766',
      address: 'УБ, ЧД, 4-р хороо',
      diagnosis: 'Мэдрэлийн гаралтай архаг өвдөлт',
      icd: 'G89.2',
    ),
  ];
}

Prescription _buildDemoPrescriptionFor({
  required String patientId,
  required PrescriptionType type,
}) {
  switch (type) {
    case PrescriptionType.regular:
      return Prescription(
        id: 'rx_demo_regular',
        patientId: patientId,
        diagnosis: 'Дээд амьсгалын замын цочмог халдвар',
        icd: 'J06.9',
        type: PrescriptionType.regular,
        drugs: [
          Drug(
            mongolianName: 'Парацетамол',
            dose: '500 мг',
            form: 'шахмал',
            quantity: 10,
            instructions: 'Өдөрт 3 удаа, хоолны дараа',
            treatmentDays: 3,
          ),
          Drug(
            mongolianName: 'Амоксициллин',
            dose: '500 мг',
            form: 'капсул',
            quantity: 21,
            instructions: 'Өдөрт 3 удаа, 7 хоног',
            treatmentDays: 7,
          ),
        ],
        notes: 'Шингэн сайн ууж амар тайван байх',
        treatmentDays: 7,
        doctorName: 'Др. Ариун',
        doctorPhone: '77112233',
        clinicName: 'Мед Клиник',
        clinicStamp: true,
        generalDoctorSignature: false,
        ePrescriptionCode: 'EP-REG-001',
        createdAt: DateTime.now(),
      );
    case PrescriptionType.psychotropic:
      return Prescription(
        id: 'rx_demo_psycho',
        patientId: patientId,
        diagnosis: 'Нойрны эмгэг',
        icd: 'G47.9',
        type: PrescriptionType.psychotropic,
        drugs: [
          Drug(
            mongolianName: 'Диазепам',
            dose: '5 мг',
            form: 'шахмал',
            quantity: 10,
            instructions: 'Орой унтахын өмнө 1 шахмал',
            treatmentDays: 10,
          ),
        ],
        notes: 'Жолоо барихгүй, архи хэрэглэхгүй байх',
        treatmentDays: 10,
        doctorName: 'Др. Солонго',
        doctorPhone: '77003344',
        clinicName: 'Сэтгэцийн эмнэлэг',
        clinicStamp: true,
        generalDoctorSignature: true,
        ePrescriptionCode: 'EP-PSY-001',
        specialIndex: 'PT-001',
        serialNumber: 'S-PSY-001',
        receiverName: 'Отгонцэцэг',
        receiverReg: 'УБ90010123',
        receiverPhone: '99112233',
        createdAt: DateTime.now(),
      );
    case PrescriptionType.narcotic:
      return Prescription(
        id: 'rx_demo_narc',
        patientId: patientId,
        diagnosis: 'Мэдрэлийн гаралтай архаг өвдөлт',
        icd: 'G89.2',
        type: PrescriptionType.narcotic,
        drugs: [
          Drug(
            mongolianName: 'Морфин сульфат',
            dose: '10 мг',
            form: 'тарилга',
            quantity: 5,
            instructions: 'Эмчийн зааврын дагуу',
            treatmentDays: 5,
          ),
        ],
        notes: 'Хэтрүүлж хэрэглэхгүй, хадгалалт аюулгүй байлгах',
        treatmentDays: 5,
        doctorName: 'Др. Тэмүүжин',
        doctorPhone: '77005566',
        clinicName: 'Өвдөлт намдаах төв',
        clinicStamp: true,
        generalDoctorSignature: true,
        ePrescriptionCode: 'EP-NAR-001',
        specialIndex: 'NC-001',
        serialNumber: 'S-NAR-001',
        receiverName: 'Баярмагнай',
        receiverReg: 'УБ82070777',
        receiverPhone: '99334455',
        createdAt: DateTime.now(),
      );
  }
}
