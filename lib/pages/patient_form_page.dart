import 'package:flutter/material.dart';
import '../models/patient.dart';

class PatientFormPage extends StatefulWidget {
  const PatientFormPage({super.key, this.existing});

  final Patient? existing;

  @override
  State<PatientFormPage> createState() => _PatientFormPageState();
}

class _PatientFormPageState extends State<PatientFormPage> {
  final _familyCtrl = TextEditingController();
  final _givenCtrl = TextEditingController();
  DateTime? _birthDate;
  Sex _sex = Sex.male;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    if (widget.existing != null) {
      _familyCtrl.text = widget.existing!.familyName;
      _givenCtrl.text = widget.existing!.givenName;
      _birthDate = widget.existing!.birthDate;
      _sex = widget.existing!.sex;
    }
  }

  @override
  void dispose() {
    _familyCtrl.dispose();
    _givenCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_birthDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Төрсөн огноо сонгоно уу')),
      );
      return;
    }
    // Generate a simple unique id when creating a new patient
    final id =
        widget.existing?.id ?? DateTime.now().microsecondsSinceEpoch.toString();
    final patient = Patient(
      id: id,
      familyName: _familyCtrl.text.trim(),
      givenName: _givenCtrl.text.trim(),
      birthDate: _birthDate!,
      sex: _sex,
    );
    // Just return the patient - the service will save it
    if (!mounted) return;
    Navigator.of(context).pop(patient);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Шинэ өвчтөн бүртгэх')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _familyCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Овог (Family Name)',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Овог заавал';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _givenCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Нэр (Given Name)',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Нэр заавал';
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () async {
                        final now = DateTime.now();
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _birthDate ?? DateTime(now.year - 30),
                          firstDate: DateTime(1900),
                          lastDate: now,
                        );
                        if (picked != null) setState(() => _birthDate = picked);
                      },
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Төрсөн огноо (Birth Date)',
                          border: OutlineInputBorder(),
                        ),
                        child: Text(
                          _birthDate == null
                              ? 'Сонгох'
                              : '${_birthDate!.year}-${_birthDate!.month.toString().padLeft(2, '0')}-${_birthDate!.day.toString().padLeft(2, '0')}',
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<Sex>(
                      initialValue: _sex,
                      decoration: const InputDecoration(
                        labelText: 'Хүйс (Sex)',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: Sex.male, child: Text('Эр')),
                        DropdownMenuItem(value: Sex.female, child: Text('Эм')),
                      ],
                      onChanged: (v) => setState(() => _sex = v ?? Sex.male),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue.shade700, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Бусад мэдээлэл (РД, утас, хаяг, онош) жор бичихэд асуугдана',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _save,
                  child: const Text('Хадгалах (Save)'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
