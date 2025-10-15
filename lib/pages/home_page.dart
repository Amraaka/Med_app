import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services.dart';
import '../services/pdf_service.dart';
import '../models.dart';
import 'select_patient_page.dart';
import 'prescription_form_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _searchQuery = '';
  PrescriptionType? _filterType;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final prescriptionService = context.watch<PrescriptionService>();
    final patientService = context.watch<PatientService>();

    final allPrescriptions = prescriptionService.prescriptions;
    final filteredPrescriptions = allPrescriptions.where((presc) {
      if (_filterType != null && presc.type != _filterType) return false;

      if (_searchQuery.isNotEmpty) {
        final patient = patientService.patients.firstWhere(
          (p) => p.id == presc.patientId,
          orElse: () => Patient(
            id: '',
            familyName: '',
            givenName: '',
            birthDate: DateTime(1990),
            registrationNumber: '',
            sex: Sex.male,
            phone: '',
            address: '',
            diagnosis: '',
            icd: '',
          ),
        );
        final searchLower = _searchQuery.toLowerCase();
        return patient.fullName.toLowerCase().contains(searchLower) ||
            presc.diagnosis.toLowerCase().contains(searchLower) ||
            presc.drugs.any(
              (d) => d.mongolianName.toLowerCase().contains(searchLower),
            );
      }
      return true;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
        title: const Text('Жорын бүртгэл'),
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              onChanged: (value) => setState(() => _searchQuery = value),
              decoration: InputDecoration(
                hintText: 'Өвчтөн, онош, эм хайх...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Container(
            height: 56,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                FilterChip(
                  label: const Text('Бүгд'),
                  selected: _filterType == null,
                  onSelected: (_) => setState(() => _filterType = null),
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('Энгийн'),
                  selected: _filterType == PrescriptionType.regular,
                  onSelected: (_) =>
                      setState(() => _filterType = PrescriptionType.regular),
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('Сэтгэц'),
                  selected: _filterType == PrescriptionType.psychotropic,
                  onSelected: (_) => setState(
                    () => _filterType = PrescriptionType.psychotropic,
                  ),
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('Мансуурах'),
                  selected: _filterType == PrescriptionType.narcotic,
                  onSelected: (_) =>
                      setState(() => _filterType = PrescriptionType.narcotic),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Text(
                  '${filteredPrescriptions.length} жор',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: filteredPrescriptions.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.description_outlined,
                          size: 64,
                          color: Colors.grey[300],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isNotEmpty || _filterType != null
                              ? 'Жор олдсонгүй'
                              : 'Жор байхгүй байна',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filteredPrescriptions.length,
                    itemBuilder: (context, index) {
                      final presc = filteredPrescriptions[index];
                      final patient = patientService.patients.firstWhere(
                        (p) => p.id == presc.patientId,
                        orElse: () => Patient(
                          id: '',
                          familyName: 'Устгагдсан',
                          givenName: 'өвчтөн',
                          birthDate: DateTime(1990),
                          registrationNumber: '',
                          sex: Sex.male,
                          phone: '',
                          address: '',
                          diagnosis: '',
                          icd: '',
                        ),
                      );

                      return _buildPrescriptionCard(
                        context,
                        theme,
                        presc,
                        patient,
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 100.0),
        child: FloatingActionButton.extended(
          onPressed: () async {
            final selected = await Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SelectPatientPage()),
            );
            if (!context.mounted) return;
            if (selected is Patient) {
              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => PrescriptionFormPage(patient: selected),
                ),
              );
            }
          },
          icon: const Icon(Icons.add),
          label: const Text('Шинэ жор'),
        ),
      ),
    );
  }

  Widget _buildPrescriptionCard(
    BuildContext context,
    ThemeData theme,
    Prescription presc,
    Patient patient,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () async {
          await PdfService.showPrescriptionPdf(context, patient, presc);
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: theme.colorScheme.primary.withValues(
                      alpha: 0.1,
                    ),
                    child: Text(
                      patient.givenName.isNotEmpty
                          ? patient.givenName[0].toUpperCase()
                          : 'P',
                      style: TextStyle(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          patient.fullName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '${patient.age} нас • ${patient.sex.name}',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getTypeColor(
                            presc.type,
                          ).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _getTypeLabel(presc.type),
                          style: TextStyle(
                            fontSize: 12,
                            color: _getTypeColor(presc.type),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatDate(presc.createdAt),
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Онош: ${presc.diagnosis}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                'ICD: ${presc.icd}',
                style: TextStyle(fontSize: 13, color: Colors.grey[600]),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: presc.drugs.take(3).map((drug) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.medication,
                          size: 14,
                          color: Colors.grey[700],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          drug.mongolianName,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[800],
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
              if (presc.drugs.length > 3)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    '+${presc.drugs.length - 3} бусад эм',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              const SizedBox(height: 12),
              const Divider(height: 1),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () async {
                      await PdfService.showPrescriptionPdf(
                        context,
                        patient,
                        presc,
                      );
                    },
                    icon: const Icon(Icons.picture_as_pdf, size: 16),
                    label: const Text('PDF', style: TextStyle(fontSize: 12)),
                  ),
                  TextButton.icon(
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Жор устгах уу?'),
                          content: Text(
                            '${patient.fullName}-н жорыг устгах уу?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, false),
                              child: const Text('Үгүй'),
                            ),
                            FilledButton(
                              onPressed: () => Navigator.pop(ctx, true),
                              style: FilledButton.styleFrom(
                                backgroundColor: Colors.red,
                              ),
                              child: const Text('Устгах'),
                            ),
                          ],
                        ),
                      );
                      if (confirm == true) {
                        if (!context.mounted) return;
                        await context
                            .read<PrescriptionService>()
                            .deletePrescription(presc.id);
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Жор устгагдлаа')),
                        );
                      }
                    },
                    icon: const Icon(Icons.delete, size: 16, color: Colors.red),
                    label: const Text(
                      'Устгах',
                      style: TextStyle(fontSize: 12, color: Colors.red),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getTypeLabel(PrescriptionType type) {
    switch (type) {
      case PrescriptionType.regular:
        return 'Энгийн';
      case PrescriptionType.psychotropic:
        return 'Сэтгэц';
      case PrescriptionType.narcotic:
        return 'Мансуурах';
    }
  }

  Color _getTypeColor(PrescriptionType type) {
    switch (type) {
      case PrescriptionType.regular:
        return Colors.blue;
      case PrescriptionType.psychotropic:
        return Colors.orange;
      case PrescriptionType.narcotic:
        return Colors.red;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
  }
}
