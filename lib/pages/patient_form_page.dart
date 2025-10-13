import 'package:flutter/material.dart';
import '../models/patient.dart';
import '../services/patient_repository.dart';

class PatientFormPage extends StatefulWidget {
  const PatientFormPage({super.key, this.existing});

  final Patient? existing;

  @override
  State<PatientFormPage> createState() => _PatientFormPageState();
}

class _PatientFormPageState extends State<PatientFormPage> {
  final _nameCtrl = TextEditingController();
  final _conditionCtrl = TextEditingController();
  final _medicineCtrl = TextEditingController();
  final _dosageCtrl = TextEditingController();
  final _instructionsCtrl = TextEditingController();
  final _repo = PatientRepository();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    if (widget.existing != null) {
      _nameCtrl.text = widget.existing!.name;
      _conditionCtrl.text = widget.existing!.condition;
      _medicineCtrl.text = widget.existing!.medicine;
      _dosageCtrl.text = widget.existing!.dosage;
      _instructionsCtrl.text = widget.existing!.instructions;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _conditionCtrl.dispose();
    _medicineCtrl.dispose();
    _dosageCtrl.dispose();
    _instructionsCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    // Generate a simple unique id when creating a new patient
    final id =
        widget.existing?.id ?? DateTime.now().microsecondsSinceEpoch.toString();
    final patient = Patient(
      id: id,
      name: _nameCtrl.text.trim(),
      condition: _conditionCtrl.text.trim(),
      medicine: _medicineCtrl.text.trim(),
      dosage: _dosageCtrl.text.trim(),
      instructions: _instructionsCtrl.text.trim(),
      prescriptionDate: DateTime.now(),
    );
    await _repo.addOrUpdatePatient(patient);
    if (!mounted) return;
    Navigator.of(context).pop(patient);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Prescription')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Patient Name',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Enter patient name'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _conditionCtrl,
                decoration: const InputDecoration(
                  labelText: 'Medical Condition',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Enter medical condition'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _medicineCtrl,
                decoration: const InputDecoration(
                  labelText: 'Medicine Prescribed',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Enter medicine name'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _dosageCtrl,
                decoration: const InputDecoration(
                  labelText: 'Dosage',
                  border: OutlineInputBorder(),
                  hintText: 'e.g., 500mg twice daily',
                ),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Enter dosage information'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _instructionsCtrl,
                decoration: const InputDecoration(
                  labelText: 'Instructions',
                  border: OutlineInputBorder(),
                  hintText: 'e.g., Take with food, before meals, etc.',
                ),
                maxLines: 3,
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _save,
                  child: const Text('Save Prescription'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
