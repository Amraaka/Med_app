import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/patient_provider.dart';
import 'patient_form_page.dart';
import 'existing_patients_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Future<void> _openPatientChooser() async {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        final provider = context.read<PatientProvider>();
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.person_add_alt_1),
                  title: const Text('New patient'),
                  subtitle: const Text('Create a new patient record'),
                  onTap: () async {
                    Navigator.of(context).pop();
                    final result = await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const PatientFormPage(),
                      ),
                    );
                    if (!mounted) return;
                    if (result != null) {
                      await provider.addOrUpdate(result as dynamic);
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Patient saved')),
                      );
                    }
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.history),
                  title: const Text('Choose from previous'),
                  subtitle: const Text('Select an existing patient'),
                  onTap: () async {
                    Navigator.of(context).pop();
                    final chosen = await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const ExistingPatientsPage(),
                      ),
                    );
                    if (!mounted) return;
                    if (chosen != null) {
                      await provider.setCurrent(chosen);
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Patient selected')),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final current = context.watch<PatientProvider>().current;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: scheme.primary.withOpacity(0.1),
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
                        current.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text('Condition: ${current.condition}'),
                      const SizedBox(height: 4),
                      Text('Medicine: ${current.medicine}'),
                      const SizedBox(height: 4),
                      Text('Dosage: ${current.dosage}'),
                      const SizedBox(height: 4),
                      Text('Instructions: ${current.instructions}'),
                      const SizedBox(height: 4),
                      Text(
                        'Prescribed: ${current.prescriptionDate.day}/${current.prescriptionDate.month}/${current.prescriptionDate.year}',
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openPatientChooser,
        child: const Icon(Icons.add),
      ),
    );
  }
}
