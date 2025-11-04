import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models.dart';
import '../services.dart';
import '../services/pdf_service.dart';
import 'patient_form_page.dart';
import 'prescription_form_page.dart';

class PatientDetailPage extends StatelessWidget {
  const PatientDetailPage({super.key, required this.patient});

  final Patient patient;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final prescriptionService = context.watch<PrescriptionService>();
    final prescriptions = prescriptionService.getPrescriptionsByPatient(
      patient.id,
    );

    return Scaffold(
      appBar: AppBar(title: Text(patient.fullName)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 28,
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
                            fontSize: 20,
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
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
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
                    ],
                  ),
                  const SizedBox(height: 12),
                  _infoRow('РД', patient.registrationNumber),
                  _infoRow('Утас', patient.phone),
                  _infoRow('Хаяг', patient.address),
                  _infoRow('Онош', patient.diagnosis),
                  _infoRow('ICD', patient.icd),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => PrescriptionFormPage(patient: patient),
                      ),
                    );
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Шинэ жор бичих'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final result = await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => PatientFormPage(existing: patient),
                      ),
                    );
                    if (!context.mounted) return;
                    if (result != null) {
                      await context.read<PatientService>().savePatient(result);
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Өвчтөн шинэчлэгдлээ')),
                      );
                    }
                  },
                  icon: const Icon(Icons.edit),
                  label: const Text('Засах'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Устгах уу?'),
                        content: Text(
                          'Өвчтөн "${patient.fullName}"-г устгах уу?\n\nЖорууд мөн устах болно.',
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
                          .deletePrescriptionsByPatient(patient.id);
                      await context.read<PatientService>().deletePatient(
                        patient.id,
                      );
                      if (!context.mounted) return;
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Өвчтөн устгагдлаа')),
                      );
                    }
                  },
                  icon: const Icon(Icons.delete, color: Colors.red),
                  label: const Text(
                    'Устгах',
                    style: TextStyle(color: Colors.red),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.red),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Text(
            'Жорын түүх (${prescriptions.length})',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          if (prescriptions.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Жор бичигдээгүй байна',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            )
          else
            ...prescriptions.map((presc) {
              final dateStr =
                  '${presc.createdAt.year}.${presc.createdAt.month.toString().padLeft(2, '0')}.${presc.createdAt.day.toString().padLeft(2, '0')}';
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                color: Colors.grey[50],
                child: Column(
                  children: [
                    InkWell(
                      onTap: () async {
                        await PdfService.showPrescriptionPdf(
                          context,
                          patient,
                          presc,
                        );
                      },
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(8),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _getTypeColor(
                                      presc.type,
                                    ).withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    _getTypeLabel(presc.type),
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: _getTypeColor(presc.type),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  dateStr,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              presc.diagnosis,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              presc.drugs
                                  .map((d) => d.mongolianName)
                                  .join(', '),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[700],
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                      child: Row(
                        children: [
                          // Expanded(
                          //   child: TextButton.icon(
                          //     onPressed: () async {
                          //       await PdfService.showPrescriptionPdf(
                          //         context,
                          //         patient,
                          //         presc,
                          //       );
                          //     },
                          //     icon: const Icon(Icons.picture_as_pdf, size: 16),
                          //     label: const Text(
                          //       'PDF харах',
                          //       style: TextStyle(fontSize: 12),
                          //     ),
                          //   ),
                          // ),
                          Expanded(
                            child: TextButton.icon(
                              onPressed: () async {
                                final pngBytes =
                                    await PdfService.generatePrescriptionPng(
                                      patient,
                                      presc,
                                      dpi: 300,
                                    );
                                if (!context.mounted) return;
                                showDialog(
                                  context: context,
                                  builder: (ctx) => Dialog(
                                    insetPadding: const EdgeInsets.all(12),
                                    child: InteractiveViewer(
                                      minScale: 0.5,
                                      maxScale: 4,
                                      child: Image.memory(
                                        pngBytes,
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.image, size: 16),
                              label: const Text(
                                'Хэвлэх',
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                          ),
                          TextButton.icon(
                            onPressed: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: const Text('Жор устгах уу?'),
                                  content: const Text('Энэ жорыг устгах уу?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(ctx, false),
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
                                  const SnackBar(
                                    content: Text('Жор устгагдлаа'),
                                  ),
                                );
                              }
                            },
                            icon: const Icon(Icons.delete, size: 16),
                            label: const Text(
                              'Устгах',
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    final isEmpty = value.trim().isEmpty;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 60,
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              isEmpty ? '—' : value,
              style: TextStyle(
                fontSize: 13,
                color: isEmpty ? Colors.grey[400] : Colors.black,
                fontStyle: isEmpty ? FontStyle.italic : FontStyle.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getTypeLabel(type) {
    switch (type.toString().split('.').last) {
      case 'regular':
        return 'Энгийн';
      case 'psychotropic':
        return 'Сэтгэц';
      case 'narcotic':
        return 'Мансуурах';
      default:
        return 'Энгийн';
    }
  }

  Color _getTypeColor(type) {
    switch (type.toString().split('.').last) {
      case 'regular':
        return Colors.blue;
      case 'psychotropic':
        return Colors.orange;
      case 'narcotic':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }
}
