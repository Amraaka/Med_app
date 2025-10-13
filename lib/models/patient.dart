import 'dart:convert';

class Patient {
  final String id;
  final String name;
  final String condition;
  final String medicine;
  final String dosage;
  final String instructions;
  final DateTime prescriptionDate;

  Patient({
    required this.id,
    required this.name,
    required this.condition,
    required this.medicine,
    required this.dosage,
    required this.instructions,
    required this.prescriptionDate,
  });

  Patient copyWith({
    String? id,
    String? name,
    String? condition,
    String? medicine,
    String? dosage,
    String? instructions,
    DateTime? prescriptionDate,
  }) => Patient(
    id: id ?? this.id,
    name: name ?? this.name,
    condition: condition ?? this.condition,
    medicine: medicine ?? this.medicine,
    dosage: dosage ?? this.dosage,
    instructions: instructions ?? this.instructions,
    prescriptionDate: prescriptionDate ?? this.prescriptionDate,
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'condition': condition,
    'medicine': medicine,
    'dosage': dosage,
    'instructions': instructions,
    'prescriptionDate': prescriptionDate.toIso8601String(),
  };

  factory Patient.fromMap(Map<String, dynamic> map) => Patient(
    id: map['id'] as String,
    name: map['name'] as String,
    condition: map['condition'] as String? ?? map['situation'] as String? ?? '',
    medicine: map['medicine'] as String? ?? '',
    dosage: map['dosage'] as String? ?? '',
    instructions: map['instructions'] as String? ?? '',
    prescriptionDate: map['prescriptionDate'] != null
        ? DateTime.parse(map['prescriptionDate'] as String)
        : DateTime.now(),
  );

  String toJson() => json.encode(toMap());
  factory Patient.fromJson(String source) =>
      Patient.fromMap(json.decode(source));
}
