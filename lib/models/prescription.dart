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
