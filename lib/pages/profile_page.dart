import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/patient_service.dart';
import '../services/prescription_service.dart';
import '../services/pdf_service.dart';
import '../models/patient.dart';
import 'patient_form_page.dart';
import 'prescription_form_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final patientService = context.watch<PatientService>();
    final prescriptionService = context.watch<PrescriptionService>();

    final allPatients = patientService.patients;
    final filteredPatients = allPatients.where((patient) {
      if (_searchQuery.isEmpty) return true;
      final searchLower = _searchQuery.toLowerCase();
      return patient.fullName.toLowerCase().contains(searchLower) ||
          patient.registrationNumber.toLowerCase().contains(searchLower) ||
          patient.phone.contains(_searchQuery);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
        title: const Text('Өвчтний бүртгэл'),
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              onChanged: (value) => setState(() => _searchQuery = value),
              decoration: InputDecoration(
                hintText: 'Нэр, РД, утас хайх...',
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
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Text(
                  '${filteredPatients.length} өвчтөн',
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
            child: filteredPatients.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.people_outline,
                          size: 64,
                          color: Colors.grey[300],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isNotEmpty
                              ? 'Өвчтөн олдсонгүй'
                              : 'Өвчтөн бүртгэлгүй байна',
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
                    itemCount: filteredPatients.length,
                    itemBuilder: (context, index) {
                      final patient = filteredPatients[index];
                      final prescriptions = prescriptionService
                          .getPrescriptionsByPatient(patient.id);

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ExpansionTile(
                          leading: CircleAvatar(
                            radius: 24,
                            backgroundColor: theme.colorScheme.primary
                                .withValues(alpha: 0.1),
                            child: Text(
                              patient.givenName.isNotEmpty
                                  ? patient.givenName[0].toUpperCase()
                                  : 'P',
                              style: TextStyle(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ),
                          title: Text(
                            patient.fullName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: Text(
                            '${patient.age} нас • ${patient.sex.name} • ${prescriptions.length} жор',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                            ),
                          ),
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildInfoSection('Өвчтний мэдээлэл', [
                                    _buildInfoRow(
                                      'РД',
                                      patient.registrationNumber,
                                    ),
                                    _buildInfoRow('Утас', patient.phone),
                                    _buildInfoRow('Хаяг', patient.address),
                                    _buildInfoRow('Онош', patient.diagnosis),
                                    _buildInfoRow('ICD', patient.icd),
                                  ]),

                                  if (prescriptions.isNotEmpty) ...[
                                    const SizedBox(height: 16),
                                    const Divider(),
                                    const SizedBox(height: 16),
                                    _buildPrescriptionSection(
                                      context,
                                      theme,
                                      patient,
                                      prescriptions,
                                    ),
                                  ] else ...[
                                    const SizedBox(height: 16),
                                    Center(
                                      child: Text(
                                        'Жор бичигдээгүй байна',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                    ),
                                  ],

                                  const SizedBox(height: 16),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: ElevatedButton.icon(
                                          onPressed: () async {
                                            await Navigator.of(context).push(
                                              MaterialPageRoute(
                                                builder: (_) =>
                                                    PrescriptionFormPage(
                                                      patient: patient,
                                                    ),
                                              ),
                                            );
                                          },
                                          icon: const Icon(Icons.add, size: 18),
                                          label: const Text('Шинэ жор бичих'),
                                          style: ElevatedButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 12,
                                            ),
                                          ),
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
                                            final result =
                                                await Navigator.of(
                                                  context,
                                                ).push(
                                                  MaterialPageRoute(
                                                    builder: (_) =>
                                                        PatientFormPage(
                                                          existing: patient,
                                                        ),
                                                  ),
                                                );
                                            if (!context.mounted) return;
                                            if (result != null) {
                                              await context
                                                  .read<PatientService>()
                                                  .savePatient(result);
                                              if (!context.mounted) return;
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                    'Өвчтөн шинэчлэгдлээ',
                                                  ),
                                                ),
                                              );
                                            }
                                          },
                                          icon: const Icon(
                                            Icons.edit,
                                            size: 18,
                                          ),
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
                                                  'Өвчтөн "${patient.fullName}"-г устгах уу?\n\n'
                                                  '${prescriptions.length} жор мөн устах болно.',
                                                ),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () =>
                                                        Navigator.pop(
                                                          ctx,
                                                          false,
                                                        ),
                                                    child: const Text('Үгүй'),
                                                  ),
                                                  FilledButton(
                                                    onPressed: () =>
                                                        Navigator.pop(
                                                          ctx,
                                                          true,
                                                        ),
                                                    style:
                                                        FilledButton.styleFrom(
                                                          backgroundColor:
                                                              Colors.red,
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
                                                  .deletePrescriptionsByPatient(
                                                    patient.id,
                                                  );
                                              await context
                                                  .read<PatientService>()
                                                  .deletePatient(patient.id);
                                              if (!context.mounted) return;
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                    'Өвчтөн устгагдлаа',
                                                  ),
                                                ),
                                              );
                                            }
                                          },
                                          icon: const Icon(
                                            Icons.delete,
                                            size: 18,
                                            color: Colors.red,
                                          ),
                                          label: const Text(
                                            'Устгах',
                                            style: TextStyle(color: Colors.red),
                                          ),
                                          style: OutlinedButton.styleFrom(
                                            side: const BorderSide(
                                              color: Colors.red,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
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
            final result = await Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const PatientFormPage()));
            if (!context.mounted) return;
            if (result != null) {
              await context.read<PatientService>().savePatient(result);
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Өвчтөн бүртгэгдлээ')),
              );
            }
          },
          icon: const Icon(Icons.person_add),
          label: const Text('Шинэ өвчтөн'),
        ),
      ),
    );
  }

  Widget _buildInfoSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
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

  Widget _buildPrescriptionSection(
    BuildContext context,
    ThemeData theme,
    Patient patient,
    List prescriptions,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Жорын түүх (${prescriptions.length})',
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
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
                          presc.drugs.map((d) => d.mongolianName).join(', '),
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
                      Expanded(
                        child: TextButton.icon(
                          onPressed: () async {
                            await PdfService.showPrescriptionPdf(
                              context,
                              patient,
                              presc,
                            );
                          },
                          icon: const Icon(Icons.picture_as_pdf, size: 16),
                          label: const Text(
                            'PDF харах',
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
                        icon: const Icon(
                          Icons.delete,
                          size: 16,
                          color: Colors.red,
                        ),
                        label: const Text(
                          'Устгах',
                          style: TextStyle(fontSize: 12, color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ],
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
