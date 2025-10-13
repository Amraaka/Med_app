class Drug {
  final String mongolianName;
  final String latinName;
  final String dose; // e.g., 500mg
  final String form; // e.g., Tablet, Syrup
  final int quantity; // number of units
  final String instructions; // Mongolian usage instructions
  final int? treatmentDays; // duration in days for this drug

  Drug({
    required this.mongolianName,
    required this.latinName,
    required this.dose,
    required this.form,
    required this.quantity,
    required this.instructions,
    this.treatmentDays,
  });

  Map<String, dynamic> toMap() => {
    'mongolianName': mongolianName,
    'latinName': latinName,
    'dose': dose,
    'form': form,
    'quantity': quantity,
    'instructions': instructions,
    'treatmentDays': treatmentDays,
  };

  factory Drug.fromMap(Map<String, dynamic> map) => Drug(
    mongolianName: (map['mongolianName'] ?? '') as String,
    latinName: (map['latinName'] ?? '') as String,
    dose: (map['dose'] ?? '') as String,
    form: (map['form'] ?? '') as String,
    quantity: (map['quantity'] ?? 0) as int,
    instructions: (map['instructions'] ?? '') as String,
    treatmentDays: (map['treatmentDays'] as num?)?.toInt(),
  );
}
