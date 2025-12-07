import 'package:flutter/foundation.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'models.dart';
import 'package:path_provider/path_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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

  Future<void> _savePatients() async {
    final prefs = await SharedPreferences.getInstance();
    final list = _patients.map((e) => e.toJson()).toList();
    await prefs.setStringList('patients_list', list);
  }

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

  Future<void> deletePatient(String patientId) async {
    _patients.removeWhere((p) => p.id == patientId);
    await _savePatients();
    notifyListeners();
  }
}

// ============================================================================
// Prescription Service
// ============================================================================

class PrescriptionService extends ChangeNotifier {
  List<Prescription> _prescriptions = [];

  List<Prescription> get prescriptions => _prescriptions;

  Future<void> loadPrescriptions() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList('prescriptions_list') ?? [];
    _prescriptions = data.map((e) => Prescription.fromJson(e)).toList();
    if (_prescriptions.isEmpty) {
      final patientData = prefs.getStringList('patients_list') ?? [];
      List<Patient> storedPatients = patientData
          .map((e) => Patient.fromJson(e))
          .toList();

      if (storedPatients.isEmpty) {
        storedPatients = _buildDemoPatients();
        await prefs.setStringList(
          'patients_list',
          storedPatients.map((p) => p.toJson()).toList(),
        );
      }

      final rxList = <Prescription>[];
      if (storedPatients.isNotEmpty) {
        rxList.add(
          _buildDemoPrescriptionFor(
            patientId: storedPatients[0].id,
            type: PrescriptionType.regular,
          ),
        );
      }
      if (storedPatients.length > 1) {
        rxList.add(
          _buildDemoPrescriptionFor(
            patientId: storedPatients[1].id,
            type: PrescriptionType.psychotropic,
          ),
        );
      }
      if (storedPatients.length > 2) {
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
    _prescriptions.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    notifyListeners();
  }

  Future<void> _savePrescriptions() async {
    final prefs = await SharedPreferences.getInstance();
    final list = _prescriptions.map((e) => e.toJson()).toList();
    await prefs.setStringList('prescriptions_list', list);
  }

  Future<void> savePrescription(Prescription prescription) async {
    final index = _prescriptions.indexWhere((p) => p.id == prescription.id);
    if (index >= 0) {
      _prescriptions[index] = prescription;
    } else {
      _prescriptions.add(prescription);
    }
    _prescriptions.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    await _savePrescriptions();
    notifyListeners();
  }

  List<Prescription> getRecentPrescriptions([int limit = 10]) {
    return _prescriptions.take(limit).toList();
  }

  List<Prescription> getPrescriptionsByPatient(String patientId) {
    return _prescriptions.where((p) => p.patientId == patientId).toList();
  }

  Future<void> deletePrescription(String prescriptionId) async {
    _prescriptions.removeWhere((p) => p.id == prescriptionId);
    await _savePrescriptions();
    notifyListeners();
  }

  Future<void> deletePrescriptionsByPatient(String patientId) async {
    _prescriptions.removeWhere((p) => p.patientId == patientId);
    await _savePrescriptions();
    notifyListeners();
  }
}

class DoctorProfileService extends ChangeNotifier {
  static const _prefsKey = 'doctor_profile';
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  DoctorProfile _profile = const DoctorProfile(
    name: 'Др. Ариун',
    title: 'Дотрын эмч',
    location: 'Улаанбаатар, Монгол',
    phone: '77112233',
    clinicName: 'Мед Клиник',
  );

  DoctorProfile get profile => _profile;

  /// Load profile from Firestore. Falls back to SharedPreferences if not found.
  Future<void> loadProfile() async {
    final userId = _auth.currentUser?.uid;
    if (userId != null) {
      try {
        final doc = await _firestore.collection('doctors').doc(userId).get();
        if (doc.exists) {
          _profile = DoctorProfile.fromMap(doc.data()!);
          notifyListeners();
          return;
        }
      } catch (e) {
        debugPrint('Error loading profile from Firestore: $e');
      }
    }

    // Fallback to SharedPreferences for backward compatibility
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    try {
      if (raw != null) {
        _profile = DoctorProfile.fromJson(raw);
      }
    } catch (_) {
      // If stored data is corrupted or incompatible, keep defaults
    }
    notifyListeners();
  }

  /// Create a new doctor profile in Firestore
  Future<void> createProfile({
    required String userId,
    required String name,
    required String title,
    required String location,
    String phone = '',
    String clinicName = '',
  }) async {
    try {
      final newProfile = DoctorProfile(
        userId: userId,
        name: name,
        title: title,
        location: location,
        phone: phone,
        clinicName: clinicName,
      );

      await _firestore
          .collection('doctors')
          .doc(userId)
          .set(newProfile.toMap());
      _profile = newProfile;
      notifyListeners();
    } catch (e) {
      debugPrint('Error creating profile in Firestore: $e');
      rethrow;
    }
  }

  /// Update existing profile in Firestore
  Future<void> updateProfile(DoctorProfile updated) async {
    _profile = updated;
    final userId = _auth.currentUser?.uid ?? updated.userId;

    if (userId != null) {
      try {
        await _firestore
            .collection('doctors')
            .doc(userId)
            .set(
              updated.copyWith(userId: userId).toMap(),
              SetOptions(merge: true),
            );
      } catch (e) {
        debugPrint('Error updating profile in Firestore: $e');
        // Still save locally as fallback
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_prefsKey, updated.toJson());
      }
    } else {
      // Fallback to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefsKey, _profile.toJson());
    }
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
