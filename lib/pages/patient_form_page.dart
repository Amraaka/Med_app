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
  final _regNoCtrl = TextEditingController();
  Sex _sex = Sex.male;
  final _phoneCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _diagnosisCtrl = TextEditingController();
  final _icdCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    if (widget.existing != null) {
      _familyCtrl.text = widget.existing!.familyName;
      _givenCtrl.text = widget.existing!.givenName;
      _birthDate = widget.existing!.birthDate;
      _regNoCtrl.text = widget.existing!.registrationNumber;
      _sex = widget.existing!.sex;
      _phoneCtrl.text = widget.existing!.phone;
      _addressCtrl.text = widget.existing!.address;
      _diagnosisCtrl.text = widget.existing!.diagnosis;
      _icdCtrl.text = widget.existing!.icd;
    }
  }

  @override
  void dispose() {
    _familyCtrl.dispose();
    _givenCtrl.dispose();
    _regNoCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    _diagnosisCtrl.dispose();
    _icdCtrl.dispose();
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
      registrationNumber: _regNoCtrl.text.trim(),
      sex: _sex,
      phone: _phoneCtrl.text.trim(),
      address: _addressCtrl.text.trim(),
      diagnosis: _diagnosisCtrl.text.trim(),
      icd: _icdCtrl.text.trim(),
    );
    // Just return the patient - the service will save it
    if (!mounted) return;
    Navigator.of(context).pop(patient);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Patient Details')),
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
              const SizedBox(height: 16),
              TextFormField(
                controller: _regNoCtrl,
                decoration: const InputDecoration(
                  labelText: 'Регистрийн дугаар (Registration Number)',
                  border: OutlineInputBorder(),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'РД заавал';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _phoneCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Утас (Phone)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.phone,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Утасны дугаар заавал';
                        final cleaned = v.replaceAll(RegExp(r'[^0-9+]'), '');
                        if (cleaned.length < 6) return 'Утасны дугаар буруу';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _icdCtrl,
                      decoration: const InputDecoration(
                        labelText: 'ICD код',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'ICD-10 код заавал';
                        final cleaned = v.trim().toUpperCase();
                        if (!RegExp(r'^[A-Z][0-9]{2}(\.[0-9A-Z]{1,4})?$').hasMatch(cleaned)) {
                          return 'ICD-10 код буруу (ж: J06.9)';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _addressCtrl,
                decoration: const InputDecoration(
                  labelText: 'Хаяг (Address)',
                  border: OutlineInputBorder(),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Хаяг заавал';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _diagnosisCtrl,
                decoration: const InputDecoration(
                  labelText: 'Онош (Diagnosis - Mongolian)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Онош заавал';
                  return null;
                },
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
