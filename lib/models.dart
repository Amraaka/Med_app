import 'dart:convert';

class Drug {
  final String mongolianName;
  final String dose;
  final String form;
  final int quantity;
  final String instructions;
  final int? treatmentDays;

  const Drug({
    required this.mongolianName,
    required this.dose,
    required this.form,
    required this.quantity,
    required this.instructions,
    this.treatmentDays,
  });

  Drug copyWith({
    String? mongolianName,
    String? dose,
    String? form,
    int? quantity,
    String? instructions,
    int? treatmentDays,
  }) {
    return Drug(
      mongolianName: mongolianName ?? this.mongolianName,
      dose: dose ?? this.dose,
      form: form ?? this.form,
      quantity: quantity ?? this.quantity,
      instructions: instructions ?? this.instructions,
      treatmentDays: treatmentDays ?? this.treatmentDays,
    );
  }

  factory Drug.fromJson(Map<String, dynamic> json) => Drug(
    mongolianName: json['mongolianName'] as String? ?? '',
    dose: json['dose'] as String? ?? '',
    form: json['form'] as String? ?? '',
    quantity: (json['quantity'] as num?)?.toInt() ?? 0,
    instructions: json['instructions'] as String? ?? '',
    treatmentDays: (json['treatmentDays'] as num?)?.toInt(),
  );

  Map<String, dynamic> toJson() => {
    'mongolianName': mongolianName,
    'dose': dose,
    'form': form,
    'quantity': quantity,
    'instructions': instructions,
    'treatmentDays': treatmentDays,
  };

  factory Drug.fromMap(Map<String, dynamic> map) => Drug.fromJson(map);

  Map<String, dynamic> toMap() => toJson();
}

enum Sex { male, female }

class Patient {
  final String id;
  final String familyName; // Овог
  final String givenName; // Нэр
  final DateTime birthDate; // Төрсөн огноо
  final Sex sex; // Хүйс

  final String registrationNumber; // Регистрийн дугаар
  final String phone; // Утас
  final String address; // Хаяг
  final String diagnosis; // Онош (Mongolian)
  final String icd; // ICD code

  Patient({
    required this.id,
    required this.familyName,
    required this.givenName,
    required this.birthDate,
    required this.sex,
    this.registrationNumber = '',
    this.phone = '',
    this.address = '',
    this.diagnosis = '',
    this.icd = '',
  });

  String get fullName => '$familyName $givenName';
  int get age {
    final now = DateTime.now();
    int years = now.year - birthDate.year;
    final hasHadBirthday =
        (now.month > birthDate.month) ||
        (now.month == birthDate.month && now.day >= birthDate.day);
    return hasHadBirthday ? years : years - 1;
  }

  Patient copyWith({
    String? id,
    String? familyName,
    String? givenName,
    DateTime? birthDate,
    String? registrationNumber,
    Sex? sex,
    String? phone,
    String? address,
    String? diagnosis,
    String? icd,
  }) => Patient(
    id: id ?? this.id,
    familyName: familyName ?? this.familyName,
    givenName: givenName ?? this.givenName,
    birthDate: birthDate ?? this.birthDate,
    registrationNumber: registrationNumber ?? this.registrationNumber,
    sex: sex ?? this.sex,
    phone: phone ?? this.phone,
    address: address ?? this.address,
    diagnosis: diagnosis ?? this.diagnosis,
    icd: icd ?? this.icd,
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'familyName': familyName,
    'givenName': givenName,
    'birthDate': birthDate.toIso8601String(),
    'registrationNumber': registrationNumber,
    'sex': sex.name,
    'phone': phone,
    'address': address,
    'diagnosis': diagnosis,
    'icd': icd,
  };

  factory Patient.fromMap(Map<String, dynamic> map) {
    final legacyName = map['name'] as String?;
    final legacyCondition =
        map['condition'] as String? ?? map['situation'] as String?;
    final birth = map['birthDate'] as String?;
    final sexRaw = map['sex'] as String?;
    return Patient(
      id: (map['id'] ?? '') as String,
      familyName:
          (map['familyName'] as String?) ??
          (legacyName?.split(' ').first ?? ''),
      givenName:
          (map['givenName'] as String?) ??
          (legacyName?.split(' ').skip(1).join(' ') ?? ''),
      birthDate: birth != null && birth.isNotEmpty
          ? DateTime.tryParse(birth) ?? DateTime(1990, 1, 1)
          : DateTime(1990, 1, 1),
      registrationNumber: (map['registrationNumber'] as String?) ?? '',
      sex: sexRaw == 'female' ? Sex.female : Sex.male,
      phone: (map['phone'] as String?) ?? '',
      address: (map['address'] as String?) ?? '',
      diagnosis: (map['diagnosis'] as String?) ?? (legacyCondition ?? ''),
      icd: (map['icd'] as String?) ?? '',
    );
  }

  String toJson() => json.encode(toMap());
  factory Patient.fromJson(String source) =>
      Patient.fromMap(json.decode(source));
}

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
  final int? treatmentDays;
  final String? doctorName;
  final String? doctorPhone;
  final String? clinicName;
  final bool? clinicStamp; // Whether clinic stamp applied
  final bool? generalDoctorSignature;
  final String? ePrescriptionCode;
  final String? specialIndex;
  final String? serialNumber;

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

class DoctorProfile {
  final String name;
  final String title;
  final String location;
  final String? photoPath;

  const DoctorProfile({
    required this.name,
    required this.title,
    required this.location,
    this.photoPath,
  });

  DoctorProfile copyWith({
    String? name,
    String? title,
    String? location,
    String? photoPath,
  }) => DoctorProfile(
    name: name ?? this.name,
    title: title ?? this.title,
    location: location ?? this.location,
    photoPath: photoPath ?? this.photoPath,
  );

  Map<String, dynamic> toMap() => {
    'name': name,
    'title': title,
    'location': location,
    'photoPath': photoPath,
  };

  factory DoctorProfile.fromMap(Map<String, dynamic> map) => DoctorProfile(
    name: (map['name'] as String?) ?? '',
    title: (map['title'] as String?) ?? '',
    location: (map['location'] as String?) ?? '',
    photoPath: map['photoPath'] as String?,
  );

  String toJson() => json.encode(toMap());
  factory DoctorProfile.fromJson(String source) =>
      DoctorProfile.fromMap(json.decode(source));
}
