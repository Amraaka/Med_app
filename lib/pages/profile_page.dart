import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services.dart';
import 'patient_form_page.dart';
import 'patient_detail_page.dart';

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
                        child: ListTile(
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
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) =>
                                    PatientDetailPage(patient: patient),
                              ),
                            );
                          },
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
}
