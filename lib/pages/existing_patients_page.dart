import 'package:flutter/material.dart';

import '../models/patient.dart';
import '../services/patient_repository.dart';

class ExistingPatientsPage extends StatefulWidget {
  const ExistingPatientsPage({super.key});

  @override
  State<ExistingPatientsPage> createState() => _ExistingPatientsPageState();
}

class _ExistingPatientsPageState extends State<ExistingPatientsPage> {
  final _repo = PatientRepository();
  late Future<List<Patient>> _future;

  @override
  void initState() {
    super.initState();
    _future = _repo.getPatients();
  }

  Future<void> _refresh() async {
    setState(() {
      _future = _repo.getPatients();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Choose Existing Patient')),
      body: FutureBuilder<List<Patient>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final patients = snap.data ?? [];
          if (patients.isEmpty) {
            return const Center(child: Text('No previous patients yet'));
          }
          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.separated(
              itemCount: patients.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final p = patients[index];
                return ListTile(
                  title: Text(p.name),
                  subtitle: Text(
                    '${p.condition} - ${p.medicine}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Text(
                    '${p.prescriptionDate.day}/${p.prescriptionDate.month}/${p.prescriptionDate.year}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  onTap: () => Navigator.of(context).pop(p),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
