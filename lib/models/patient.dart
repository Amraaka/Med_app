import 'dart:convert';

enum Sex { male, female }

class Patient {
  final String id;
  final String familyName; // Овог
  final String givenName; // Нэр
  final DateTime birthDate; // Төрсөн огноо
  final Sex sex; // Хүйс
  // Optional fields - collected when creating prescription
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
    // Backward compatibility with older saves
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
