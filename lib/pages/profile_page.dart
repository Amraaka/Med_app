import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/patient_service.dart';
import '../services/prescription_service.dart';
import 'prescription_form_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final patientService = context.watch<PatientService>();
    final prescriptionService = context.watch<PrescriptionService>();
    final current = patientService.currentPatient;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: scheme.primary.withValues(alpha: 0.1),
        automaticallyImplyLeading: true,
        title: const Text('Doctor Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Current Patient',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            if (current == null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'No patient selected',
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Use the + button to add a new patient or select from previous patients',
                        style: TextStyle(color: Colors.grey[500]),
                      ),
                    ],
                  ),
                ),
              )
            else
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        current.fullName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text('Нас: ${current.age} • Хүйс: ${current.sex.name}'),
                      const SizedBox(height: 4),
                      Text('РД: ${current.registrationNumber}'),
                      const SizedBox(height: 4),
                      Text('Утас: ${current.phone}'),
                      const SizedBox(height: 4),
                      Text('Хаяг: ${current.address}'),
                      const SizedBox(height: 8),
                      Text('Онош: ${current.diagnosis}  (ICD: ${current.icd})'),
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              await Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) =>
                                      PrescriptionFormPage(patient: current),
                                ),
                              );
                            },
                            icon: const Icon(Icons.add),
                            label: const Text('Энэ өвчтөнд жор бичих'),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 20),
            const Text(
              'All Registered Patients',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: patientService.patients.isEmpty
                  ? Center(
                      child: Text(
                        'No registered patients yet',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    )
                  : ListView.separated(
                      itemCount: patientService.patients.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final patient = patientService.patients[index];
                        final prescriptions = prescriptionService
                            .getPrescriptionsByPatient(patient.id);
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          child: ExpansionTile(
                            leading: CircleAvatar(
                              child: Text(
                                patient.givenName.isNotEmpty
                                    ? patient.givenName[0].toUpperCase()
                                    : 'P',
                              ),
                            ),
                            title: Text(
                              patient.fullName,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                            subtitle: Text(
                              prescriptions.isEmpty
                                  ? 'No prescriptions yet • Age: ${patient.age}'
                                  : '${prescriptions.length} prescription${prescriptions.length > 1 ? 's' : ''} • Age: ${patient.age}',
                            ),
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Patient Details
                                    const Text(
                                      'Patient Details',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text('РД: ${patient.registrationNumber}'),
                                    Text('Хүйс: ${patient.sex.name}'),
                                    Text('Утас: ${patient.phone}'),
                                    Text('Хаяг: ${patient.address}'),
                                    Text(
                                      'Онош: ${patient.diagnosis} (ICD: ${patient.icd})',
                                    ),
                                    const SizedBox(height: 16),
                                    // Prescription History
                                    const Text(
                                      'Prescription History',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    if (prescriptions.isEmpty)
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 8.0,
                                        ),
                                        child: Text(
                                          'No prescriptions recorded for this patient',
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontStyle: FontStyle.italic,
                                          ),
                                        ),
                                      )
                                    else
                                      ...prescriptions.map((prescription) {
                                        final topDrug =
                                            prescription.drugs.isNotEmpty
                                            ? prescription
                                                  .drugs
                                                  .first
                                                  .mongolianName
                                            : 'No drugs';
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 4.0,
                                          ),
                                          child: Row(
                                            children: [
                                              const Icon(
                                                Icons.description_outlined,
                                                size: 20,
                                              ),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      '$topDrug • ${prescription.type.name}',
                                                      style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                                    Text(
                                                      '${prescription.createdAt.year}-${prescription.createdAt.month.toString().padLeft(2, '0')}-${prescription.createdAt.day.toString().padLeft(2, '0')}',
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        color: Colors.grey[600],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      }).toList(),
                                    const SizedBox(height: 12),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: 8.0,
                                      ),
                                      child: SizedBox(
                                        width: double.infinity,
                                        child: ElevatedButton.icon(
                                          onPressed: () {
                                            if (!mounted) return;
                                            patientService.setCurrentPatient(
                                              patient,
                                            );
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  'Selected ${patient.fullName}',
                                                ),
                                              ),
                                            );
                                          },
                                          icon: const Icon(
                                            Icons.person,
                                            size: 18,
                                          ),
                                          label: const Text(
                                            'Select as Current Patient',
                                          ),
                                          style: ElevatedButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 8,
                                            ),
                                          ),
                                        ),
                                      ),
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
      ),
    );
  }
}
