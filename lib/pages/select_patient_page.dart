import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/patient.dart';
import '../services/patient_service.dart';
import 'patient_form_page.dart';

class SelectPatientPage extends StatelessWidget {
  const SelectPatientPage({super.key});

  @override
  Widget build(BuildContext context) {
    final patients = context.watch<PatientService>().patients;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select or Add Patient'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_alt_1),
            onPressed: () async {
              final created = await Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const PatientFormPage()),
              );
              if (created is Patient && context.mounted) {
                Navigator.of(context).pop(created);
              }
            },
          ),
        ],
      ),
      body: patients.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('No patients yet'),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: () async {
                      final created = await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const PatientFormPage(),
                        ),
                      );
                      if (created is Patient && context.mounted) {
                        Navigator.of(context).pop(created);
                      }
                    },
                    icon: const Icon(Icons.person_add_alt_1),
                    label: const Text('Add Patient'),
                  ),
                ],
              ),
            )
          : ListView.separated(
              itemCount: patients.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final p = patients[index];
                return ListTile(
                  title: Text(p.fullName),
                  subtitle: Text('${p.age} настай • ${p.registrationNumber}'),
                  onTap: () => Navigator.of(context).pop(p),
                );
              },
            ),
    );
  }
}
