import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/drug.dart';
import '../models/patient.dart';
import '../models/prescription.dart';
import '../services/prescription_service.dart';
import '../services/pdf_service.dart';
import '../widgets/drug_input.dart';

class PrescriptionFormPage extends StatefulWidget {
  const PrescriptionFormPage({super.key, required this.patient});

  final Patient patient;

  @override
  State<PrescriptionFormPage> createState() => _PrescriptionFormPageState();
}

class _PrescriptionFormPageState extends State<PrescriptionFormPage> {
  final _formKey = GlobalKey<FormState>();
  PrescriptionType _type = PrescriptionType.regular;
  final List<Drug> _drugs = [];
  final _notesCtrl = TextEditingController();
  final _guardianNameCtrl = TextEditingController();
  final _guardianPhoneCtrl = TextEditingController();
  final _diagnosisCtrl = TextEditingController();
  final _icdCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Prefill with patient's existing diagnosis and ICD to streamline workflow
    _diagnosisCtrl.text = widget.patient.diagnosis;
    _icdCtrl.text = widget.patient.icd;
  }

  @override
  void dispose() {
    _notesCtrl.dispose();
    _guardianNameCtrl.dispose();
    _guardianPhoneCtrl.dispose();
    _diagnosisCtrl.dispose();
    _icdCtrl.dispose();
    super.dispose();
  }

  void _onDrugChanged(int index, Drug drug) {
    if (index < _drugs.length) {
      _drugs[index] = drug;
    } else if (index == _drugs.length) {
      _drugs.add(drug);
    }
    setState(() {});
  }

  void _addDrug() {
    setState(
      () => _drugs.add(
        Drug(
          mongolianName: '',
          latinName: '',
          dose: '',
          form: '',
          quantity: 0,
          instructions: '',
        ),
      ),
    );
  }

  String? _validateBusinessRules() {
    if (_drugs.isEmpty) return 'Дор хаяж нэг эм нэмнэ үү';
    // Psychotropic/Narcotic simple constraint example
    const psychotropicMaxDrugs = 3;
    const narcoticMaxDrugs = 3;
    if (_type == PrescriptionType.psychotropic &&
        _drugs.length > psychotropicMaxDrugs) {
      return 'Сэтгэцэд нөлөөлөх жорт эмийн мөр $psychotropicMaxDrugs-аас ихгүй';
    }
    if (_type == PrescriptionType.narcotic &&
        _drugs.length > narcoticMaxDrugs) {
      return 'Мансуурах эмийн мөр $narcoticMaxDrugs-аас ихгүй';
    }
    // Guardian required if patient age < 16
    if (widget.patient.age < 16) {
      if (_guardianNameCtrl.text.trim().isEmpty ||
          _guardianPhoneCtrl.text.trim().isEmpty) {
        return 'Асран хамгаалагчийн нэр, утас заавал';
      }
    }
    return null;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final rulesError = _validateBusinessRules();
    if (rulesError != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(rulesError)));
      return;
    }

    final presc = Prescription(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      patientId: widget.patient.id,
      diagnosis: _diagnosisCtrl.text.trim().isEmpty
          ? widget.patient.diagnosis
          : _diagnosisCtrl.text.trim(),
      icd: _icdCtrl.text.trim().isEmpty
          ? widget.patient.icd
          : _icdCtrl.text.trim(),
      type: _type,
      drugs: _drugs,
      notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
      guardianName: widget.patient.age < 16
          ? _guardianNameCtrl.text.trim()
          : null,
      guardianPhone: widget.patient.age < 16
          ? _guardianPhoneCtrl.text.trim()
          : null,
      createdAt: DateTime.now(),
    );

    await context.read<PrescriptionService>().savePrescription(presc);

    // Generate and preview PDF
    await PdfService.showPrescriptionPdf(context, widget.patient, presc);

    if (!mounted) return;
    Navigator.of(context).pop(presc);
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.patient;
    return Scaffold(
      appBar: AppBar(title: const Text('Шинэ жор бичих')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Patient summary
              Card(
                child: ListTile(
                  title: Text('${p.fullName} • ${p.age} настай'),
                  subtitle: Text(
                    '${p.registrationNumber} • ${p.phone}\n${p.address}',
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Prescription type
              InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Жорын төрөл',
                  border: OutlineInputBorder(),
                ),
                child: Wrap(
                  spacing: 8,
                  children: [
                    ChoiceChip(
                      label: const Text('Энгийн'),
                      selected: _type == PrescriptionType.regular,
                      onSelected: (_) =>
                          setState(() => _type = PrescriptionType.regular),
                    ),
                    ChoiceChip(
                      label: const Text('Сэтгэц'),
                      selected: _type == PrescriptionType.psychotropic,
                      onSelected: (_) =>
                          setState(() => _type = PrescriptionType.psychotropic),
                    ),
                    ChoiceChip(
                      label: const Text('Мансуурах'),
                      selected: _type == PrescriptionType.narcotic,
                      onSelected: (_) =>
                          setState(() => _type = PrescriptionType.narcotic),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Diagnosis and ICD for this prescription
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _diagnosisCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Онош (энэ жор) - заавал',
                        border: OutlineInputBorder(),
                        hintText: 'Ж: Цочмог дээд амьсгалын замын халдвар',
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Онош заавал';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _icdCtrl,
                      decoration: const InputDecoration(
                        labelText: 'ICD-10 код - заавал',
                        border: OutlineInputBorder(),
                        hintText: 'Ж: J06.9',
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty)
                          return 'ICD-10 код заавал';
                        final cleaned = v.trim().toUpperCase();
                        if (!RegExp(
                          r'^[A-Z][0-9]{2}(\.[0-9A-Z]{1,4})?$',
                        ).hasMatch(cleaned)) {
                          return 'ICD-10 код буруу (ж: J06.9)';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Drugs dynamic list
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Эмийн жагсаалт',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextButton.icon(
                    onPressed: _addDrug,
                    icon: const Icon(Icons.add),
                    label: const Text('Эм нэмэх'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ...List.generate(
                _drugs.length,
                (i) => DrugInput(
                  initial: _drugs[i],
                  onChanged: (d) => _onDrugChanged(i, d),
                  onRemove: () => setState(() => _drugs.removeAt(i)),
                ),
              ),
              if (_drugs.isEmpty)
                OutlinedButton.icon(
                  onPressed: _addDrug,
                  icon: const Icon(Icons.add_box_outlined),
                  label: const Text('Эм нэмэх'),
                ),

              const SizedBox(height: 16),

              if (p.age < 16) ...[
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _guardianNameCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Асран хамгаалагч (нэр)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _guardianPhoneCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Асран хамгаалагч (утас)',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.phone,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],

              TextFormField(
                controller: _notesCtrl,
                decoration: const InputDecoration(
                  labelText: 'Тэмдэглэл / Notes',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),

              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _save,
                  icon: const Icon(Icons.picture_as_pdf),
                  label: const Text('Хадгалах ба PDF үүсгэх'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
