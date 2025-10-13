import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/patient_service.dart';

class ExistingPatientsPage extends StatelessWidget {
  const ExistingPatientsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final patients = context.watch<PatientService>().patients;

    return Scaffold(
      appBar: AppBar(title: const Text('Choose Existing Patient')),
      body: patients.isEmpty
          ? const Center(child: Text('No previous patients yet'))
          : ListView.separated(
              itemCount: patients.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final p = patients[index];
                return ListTile(
                  title: Text(p.fullName),
                  subtitle: Text(
                    '${p.diagnosis}  (ICD: ${p.icd})',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Text(
                    p.age >= 0 ? '${p.age} настай' : '',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  onTap: () => Navigator.of(context).pop(p),
                );
              },
            ),
    );
  }
}
