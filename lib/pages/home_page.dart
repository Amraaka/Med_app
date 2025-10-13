import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/patient_service.dart';
import '../services/prescription_service.dart';
import '../models/patient.dart';
import 'select_patient_page.dart';
import 'prescription_form_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final patientCount = context.watch<PatientService>().patients.length;
    final recent = context
        .watch<PrescriptionService>()
        .getRecentPrescriptions();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
        title: const Text('Medical Dashboard'),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome, Dr. Smith',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Manage prescriptions and patient records',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 32),

            // Stats Cards
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    title: 'Total Patients',
                    value: patientCount.toString(),
                    icon: Icons.people,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    title: 'Prescriptions',
                    value: patientCount.toString(),
                    icon: Icons.medical_services,
                    color: theme.colorScheme.secondary,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Recent prescriptions
            Text(
              'Сүүлийн жорууд',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            if (recent.isEmpty)
              Text(
                'Одоогоор жор байхгүй',
                style: TextStyle(color: Colors.grey[600]),
              )
            else
              Expanded(
                child: ListView.separated(
                  itemCount: recent.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, i) {
                    final r = recent[i];
                    final patient = context
                        .read<PatientService>()
                        .patients
                        .firstWhere(
                          (p) => p.id == r.patientId,
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
                    final topDrug = r.drugs.isNotEmpty
                        ? r.drugs.first.mongolianName
                        : '-';
                    return ListTile(
                      leading: Icon(
                        Icons.picture_as_pdf,
                        color: theme.colorScheme.primary,
                      ),
                      title: Text('${patient.fullName} • $topDrug'),
                      subtitle: Text(
                        '${r.createdAt.year}-${r.createdAt.month.toString().padLeft(2, '0')}-${r.createdAt.day.toString().padLeft(2, '0')}  •  ${r.type.name}',
                      ),
                      onTap: () {},
                    );
                  },
                ),
              ),

            // Quick Actions
            const SizedBox(height: 16),

            const SizedBox(height: 12),

            _buildActionCard(
              context: context,
              title: 'Patient Records',
              subtitle: 'View and manage patient history',
              icon: Icons.folder_shared,
              color: theme.colorScheme.primary,
              onTap: () {
                // Switch to Profile tab
              },
            ),
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 106.0),
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
          label: const Text('Шинэ жор бичих'),
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(title, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }
}
