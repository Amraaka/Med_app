import 'dart:convert';

import 'drug.dart';

enum PrescriptionType { regular, psychotropic, narcotic }

class Prescription {
  final String id;
  final String patientId;
  final String diagnosis; // Mongolian diagnosis text
  final String icd; // ICD code
  final PrescriptionType type;
  final List<Drug> drugs;
  final String? notes;
  final String? guardianName; // if patient < 16
  final String? guardianPhone;
  final String? attachmentPath; // optional custom image path
  // New structured fields
  final int? treatmentDays; // total treatment duration in days
  final String? doctorName;
  final String? doctorPhone;
  final String? clinicName;
  final bool? clinicStamp; // Whether clinic stamp applied
  final bool?
  generalDoctorSignature; // Whether additional general doctor signature applied
  final String? ePrescriptionCode; // unique code
  final String? specialIndex; // for psychotropic/narcotic
  final String? serialNumber; // prescription serial number
  // Receiver (dispense) info for psychotropic/narcotic
  final String? receiverName;
  final String? receiverReg;
  final String? receiverPhone;
  final DateTime createdAt;

  Prescription({
    required this.id,
    required this.patientId,
    required this.diagnosis,
    required this.icd,
    required this.type,
    required this.drugs,
    required this.createdAt,
    this.notes,
    this.guardianName,
    this.guardianPhone,
    this.attachmentPath,
    this.treatmentDays,
    this.doctorName,
    this.doctorPhone,
    this.clinicName,
    this.clinicStamp,
    this.generalDoctorSignature,
    this.ePrescriptionCode,
    this.specialIndex,
    this.serialNumber,
    this.receiverName,
    this.receiverReg,
    this.receiverPhone,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'patientId': patientId,
    'diagnosis': diagnosis,
    'icd': icd,
    'type': type.name,
    'drugs': drugs.map((d) => d.toMap()).toList(),
    'notes': notes,
    'guardianName': guardianName,
    'guardianPhone': guardianPhone,
    'attachmentPath': attachmentPath,
    'treatmentDays': treatmentDays,
    'doctorName': doctorName,
    'doctorPhone': doctorPhone,
    'clinicName': clinicName,
    'clinicStamp': clinicStamp,
    'generalDoctorSignature': generalDoctorSignature,
    'ePrescriptionCode': ePrescriptionCode,
    'specialIndex': specialIndex,
    'serialNumber': serialNumber,
    'receiverName': receiverName,
    'receiverReg': receiverReg,
    'receiverPhone': receiverPhone,
    'createdAt': createdAt.toIso8601String(),
  };

  factory Prescription.fromMap(Map<String, dynamic> map) => Prescription(
    id: map['id'] as String,
    patientId: map['patientId'] as String,
    diagnosis: (map['diagnosis'] ?? '') as String,
    icd: (map['icd'] ?? '') as String,
    type: _parseType(map['type'] as String?),
    drugs: (map['drugs'] as List<dynamic>? ?? [])
        .map((e) => Drug.fromMap(e as Map<String, dynamic>))
        .toList(),
    notes: map['notes'] as String?,
    guardianName: map['guardianName'] as String?,
    guardianPhone: map['guardianPhone'] as String?,
    attachmentPath: map['attachmentPath'] as String?,
    treatmentDays: (map['treatmentDays'] as num?)?.toInt(),
    doctorName: map['doctorName'] as String?,
    doctorPhone: map['doctorPhone'] as String?,
    clinicName: map['clinicName'] as String?,
    clinicStamp: map['clinicStamp'] as bool?,
    generalDoctorSignature: map['generalDoctorSignature'] as bool?,
    ePrescriptionCode: map['ePrescriptionCode'] as String?,
    specialIndex: map['specialIndex'] as String?,
    serialNumber: map['serialNumber'] as String?,
    receiverName: map['receiverName'] as String?,
    receiverReg: map['receiverReg'] as String?,
    receiverPhone: map['receiverPhone'] as String?,
    createdAt:
        DateTime.tryParse(map['createdAt'] as String? ?? '') ?? DateTime.now(),
  );

  static PrescriptionType _parseType(String? raw) {
    switch (raw) {
      case 'psychotropic':
        return PrescriptionType.psychotropic;
      case 'narcotic':
        return PrescriptionType.narcotic;
      case 'regular':
      default:
        return PrescriptionType.regular;
    }
  }

  String toJson() => json.encode(toMap());
  factory Prescription.fromJson(String source) =>
      Prescription.fromMap(json.decode(source));
}
