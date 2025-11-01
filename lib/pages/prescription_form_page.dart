import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models.dart';
import '../services.dart';
import '../services/pdf_service.dart';
import '../widgets.dart';

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

  final _regNoCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();

  final _doctorNameCtrl = TextEditingController();
  final _doctorPhoneCtrl = TextEditingController();
  final _clinicNameCtrl = TextEditingController();
  bool _clinicStamp = false;
  bool _generalDoctorSignature = false;
  final _ePrescriptionCodeCtrl = TextEditingController();

  final _specialIndexCtrl = TextEditingController();
  final _serialNumberCtrl = TextEditingController();
  final _receiverNameCtrl = TextEditingController();
  final _receiverRegCtrl = TextEditingController();
  final _receiverPhoneCtrl = TextEditingController();

  bool _isPalliative = false;

  @override
  void initState() {
    super.initState();

    _diagnosisCtrl.text = widget.patient.diagnosis;
    _icdCtrl.text = widget.patient.icd;
    _regNoCtrl.text = widget.patient.registrationNumber;
    _phoneCtrl.text = widget.patient.phone;
    _addressCtrl.text = widget.patient.address;
  }

  @override
  void dispose() {
    _notesCtrl.dispose();
    _guardianNameCtrl.dispose();
    _guardianPhoneCtrl.dispose();
    _diagnosisCtrl.dispose();
    _icdCtrl.dispose();
    _regNoCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    _doctorNameCtrl.dispose();
    _doctorPhoneCtrl.dispose();
    _clinicNameCtrl.dispose();
    _ePrescriptionCodeCtrl.dispose();
    _specialIndexCtrl.dispose();
    _serialNumberCtrl.dispose();
    _receiverNameCtrl.dispose();
    _receiverRegCtrl.dispose();
    _receiverPhoneCtrl.dispose();
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
          dose: '',
          form: '',
          quantity: 0,
          instructions: '',
        ),
      ),
    );
  }

  int? _allowedDays() {
    switch (_type) {
      case PrescriptionType.psychotropic:
        return 10;
      case PrescriptionType.narcotic:
        return _isPalliative ? 10 : 3;
      case PrescriptionType.regular:
        return null;
    }
  }

  String? _validateBusinessRules() {
    if (_drugs.isEmpty) return 'Дор хаяж нэг эм нэмнэ үү';
    const regularMaxDrugs = 3;
    const psychotropicMaxDrugs = 2;
    const narcoticMaxDrugs = 1;
    if (_type == PrescriptionType.regular && _drugs.length > regularMaxDrugs) {
      return 'Энгийн жорт эмийн мөр $regularMaxDrugs-аас ихгүй';
    }
    if (_type == PrescriptionType.psychotropic &&
        _drugs.length > psychotropicMaxDrugs) {
      return 'Сэтгэцэд нөлөөлөх жорт эмийн мөр $psychotropicMaxDrugs-аас ихгүй';
    }
    if (_type == PrescriptionType.narcotic &&
        _drugs.length > narcoticMaxDrugs) {
      return 'Мансуурах эмийн мөр $narcoticMaxDrugs-аас ихгүй';
    }
    final limit = _allowedDays();
    if (limit != null) {
      for (final d in _drugs) {
        final days = d.treatmentDays ?? 0;
        if (days <= 0 || days > limit) {
          return 'Энэ төрлийн жорт эмийн хоног ≤ $limit байх ёстой';
        }
      }
    }
    if (widget.patient.age < 16) {
      if (_guardianNameCtrl.text.trim().isEmpty ||
          _guardianPhoneCtrl.text.trim().isEmpty) {
        return 'Асран хамгаалагчийн нэр, утас заавал';
      }
    }
    if (_doctorNameCtrl.text.trim().isEmpty) {
      return 'Жор бичсэн эмчийн нэр заавал';
    }
    if (_clinicNameCtrl.text.trim().isEmpty) {
      return 'Эмнэлгийн нэр заавал';
    }
    if (_type == PrescriptionType.psychotropic ||
        _type == PrescriptionType.narcotic) {
      if (_specialIndexCtrl.text.trim().isEmpty ||
          _serialNumberCtrl.text.trim().isEmpty) {
        return 'Индекс болон серийн дугаар заавал';
      }
      if (_receiverNameCtrl.text.trim().isEmpty ||
          _receiverRegCtrl.text.trim().isEmpty) {
        return 'Хүлээн авагчийн нэр ба РД заавал';
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

    final updatedPatient = widget.patient.copyWith(
      registrationNumber: _regNoCtrl.text.trim().isNotEmpty
          ? _regNoCtrl.text.trim()
          : widget.patient.registrationNumber,
      phone: _phoneCtrl.text.trim().isNotEmpty
          ? _phoneCtrl.text.trim()
          : widget.patient.phone,
      address: _addressCtrl.text.trim().isNotEmpty
          ? _addressCtrl.text.trim()
          : widget.patient.address,
      diagnosis: _diagnosisCtrl.text.trim().isNotEmpty
          ? _diagnosisCtrl.text.trim()
          : widget.patient.diagnosis,
      icd: _icdCtrl.text.trim().isNotEmpty
          ? _icdCtrl.text.trim()
          : widget.patient.icd,
    );

    await context.read<PatientService>().savePatient(updatedPatient);

    final overallDays = _drugs
        .map((d) => d.treatmentDays ?? 0)
        .fold<int>(0, (prev, e) => e > prev ? e : prev);

    final eCode = _ePrescriptionCodeCtrl.text.trim().isEmpty
        ? 'EP-${DateTime.now().millisecondsSinceEpoch.toRadixString(36).toUpperCase()}'
        : _ePrescriptionCodeCtrl.text.trim();

    final presc = Prescription(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      patientId: widget.patient.id,
      diagnosis: _diagnosisCtrl.text.trim(),
      icd: _icdCtrl.text.trim(),
      type: _type,
      drugs: _drugs,
      notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
      guardianName: widget.patient.age < 16
          ? _guardianNameCtrl.text.trim()
          : null,
      guardianPhone: widget.patient.age < 16
          ? _guardianPhoneCtrl.text.trim()
          : null,
      treatmentDays: overallDays > 0 ? overallDays : null,
      doctorName: _doctorNameCtrl.text.trim().isEmpty
          ? null
          : _doctorNameCtrl.text.trim(),
      doctorPhone: _doctorPhoneCtrl.text.trim().isEmpty
          ? null
          : _doctorPhoneCtrl.text.trim(),
      clinicName: _clinicNameCtrl.text.trim().isEmpty
          ? null
          : _clinicNameCtrl.text.trim(),
      clinicStamp: _clinicStamp,
      generalDoctorSignature: _generalDoctorSignature,
      ePrescriptionCode: eCode,
      specialIndex: _specialIndexCtrl.text.trim().isEmpty
          ? null
          : _specialIndexCtrl.text.trim(),
      serialNumber: _serialNumberCtrl.text.trim().isEmpty
          ? null
          : _serialNumberCtrl.text.trim(),
      receiverName: _receiverNameCtrl.text.trim().isEmpty
          ? null
          : _receiverNameCtrl.text.trim(),
      receiverReg: _receiverRegCtrl.text.trim().isEmpty
          ? null
          : _receiverRegCtrl.text.trim(),
      receiverPhone: _receiverPhoneCtrl.text.trim().isEmpty
          ? null
          : _receiverPhoneCtrl.text.trim(),
      createdAt: DateTime.now(),
    );

    await context.read<PrescriptionService>().savePrescription(presc);

    await PdfService.showPrescriptionPdf(context, updatedPatient, presc);

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
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${p.fullName} • ${p.age} настай • ${p.sex.name}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (p.registrationNumber.isNotEmpty ||
                          p.phone.isNotEmpty ||
                          p.address.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          [
                            if (p.registrationNumber.isNotEmpty)
                              'РД: ${p.registrationNumber}',
                            if (p.phone.isNotEmpty) 'Утас: ${p.phone}',
                          ].join(' • '),
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[700],
                          ),
                        ),
                        if (p.address.isNotEmpty)
                          Text(
                            'Хаяг: ${p.address}',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[700],
                            ),
                          ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              if (p.registrationNumber.isEmpty ||
                  p.phone.isEmpty ||
                  p.address.isEmpty) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.warning_amber,
                            color: Colors.orange.shade700,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Өвчтний бүрэн мэдээллийг оруулна уу',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.orange.shade900,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _regNoCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Регистрийн дугаар (РД)',
                          border: OutlineInputBorder(),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return 'РД заавал';
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _phoneCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Утасны дугаар',
                          border: OutlineInputBorder(),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        keyboardType: TextInputType.phone,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty)
                            return 'Утас заавал';
                          final cleaned = v.replaceAll(RegExp(r'[^0-9+]'), '');
                          if (cleaned.length < 6) return 'Утас буруу';
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _addressCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Хаяг',
                          border: OutlineInputBorder(),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty)
                            return 'Хаяг заавал';
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

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

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Эмийн жагсаалт',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      final limit = () {
                        switch (_type) {
                          case PrescriptionType.regular:
                            return 3;
                          case PrescriptionType.psychotropic:
                            return 2;
                          case PrescriptionType.narcotic:
                            return 1;
                        }
                      }();
                      if (_drugs.length >= limit) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Энэ төрлийн жорт дээд тал нь $limit эм бичиж болно',
                            ),
                          ),
                        );
                        return;
                      }
                      _addDrug();
                    },
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

              if (_type == PrescriptionType.narcotic)
                SwitchListTile(
                  title: const Text('Паллиатив тусламж (хоног ≤ 10)'),
                  value: _isPalliative,
                  onChanged: (v) => setState(() => _isPalliative = v),
                ),

              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  side: BorderSide(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Эмч ба байгууллага',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _doctorNameCtrl,
                              decoration: const InputDecoration(
                                labelText: 'Жор бичсэн эмчийн нэр',
                                border: OutlineInputBorder(),
                              ),
                              validator: (v) => (v == null || v.trim().isEmpty)
                                  ? 'Эмчийн нэр заавал'
                                  : null,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _doctorPhoneCtrl,
                              decoration: const InputDecoration(
                                labelText: 'Эмчийн утас (сонголт)',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.phone,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _clinicNameCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Эмнэлгийн нэр',
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Эмнэлгийн нэр заавал'
                            : null,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _ePrescriptionCodeCtrl,
                              decoration: const InputDecoration(
                                labelText: 'E-жор код (сонголт)',
                                hintText: 'EP-XXXX',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: SwitchListTile(
                              title: const Text('Байгууллагын тэмдэг'),
                              contentPadding: EdgeInsets.zero,
                              value: _clinicStamp,
                              onChanged: (v) =>
                                  setState(() => _clinicStamp = v),
                            ),
                          ),
                        ],
                      ),
                      SwitchListTile(
                        title: const Text('Ерөнхий эмчийн гарын үсэг'),
                        contentPadding: EdgeInsets.zero,
                        value: _generalDoctorSignature,
                        onChanged: (v) =>
                            setState(() => _generalDoctorSignature = v),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              if (_type == PrescriptionType.psychotropic ||
                  _type == PrescriptionType.narcotic) ...[
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    side: BorderSide(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Тусгай мэдээлэл',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _specialIndexCtrl,
                                decoration: const InputDecoration(
                                  labelText: 'Индекс (Index)',
                                  border: OutlineInputBorder(),
                                ),
                                validator: (v) =>
                                    (v == null || v.trim().isEmpty)
                                    ? 'Индекс заавал'
                                    : null,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                controller: _serialNumberCtrl,
                                decoration: const InputDecoration(
                                  labelText: 'Серийн дугаар',
                                  border: OutlineInputBorder(),
                                ),
                                validator: (v) =>
                                    (v == null || v.trim().isEmpty)
                                    ? 'Серийн дугаар заавал'
                                    : null,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _receiverNameCtrl,
                                decoration: const InputDecoration(
                                  labelText: 'Хүлээн авагчийн нэр',
                                  border: OutlineInputBorder(),
                                ),
                                validator: (v) =>
                                    (v == null || v.trim().isEmpty)
                                    ? 'Нэр заавал'
                                    : null,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                controller: _receiverRegCtrl,
                                decoration: const InputDecoration(
                                  labelText: 'Хүлээн авагчийн РД',
                                  border: OutlineInputBorder(),
                                ),
                                validator: (v) =>
                                    (v == null || v.trim().isEmpty)
                                    ? 'РД заавал'
                                    : null,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _receiverPhoneCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Хүлээн авагчийн утас (сонголт)',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.phone,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],

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

              const SizedBox(height: 12),
              Builder(
                builder: (context) {
                  final limit = _allowedDays();
                  return Text(
                    'Жор олгосон өдрөөс хойш 7 хоног хүчинтэй.' +
                        (limit != null
                            ? ' Энэ төрлийн жорын эмчилгээний хоног ≤ $limit.'
                            : ''),
                    style: TextStyle(color: Colors.grey[700], fontSize: 12),
                  );
                },
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
