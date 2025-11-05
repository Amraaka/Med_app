import 'package:flutter/material.dart';
import 'package:med_app/models.dart';
import 'package:med_app/services/pediatric_dose_calculator.dart';

/// Example widget showing how to integrate pediatric dose calculator
/// into the prescription form for pediatric patients
class PediatricDoseHelper extends StatelessWidget {
  const PediatricDoseHelper({
    super.key,
    required this.patient,
    required this.adultDose,
    this.onDoseSelected,
  });

  final Patient patient;
  final String adultDose;
  final ValueChanged<String>? onDoseSelected;

  @override
  Widget build(BuildContext context) {
    // Only show for pediatric patients (< 18 years)
    if (patient.age >= 18) {
      return const SizedBox.shrink();
    }

    return Card(
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.child_care, color: Colors.blue.shade700, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Хүүхдэд зориулсан тун тооцоолох',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.blue.shade900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Насанд хүрэгчдэд зориулсан тун: $adultDose',
              style: TextStyle(fontSize: 13, color: Colors.grey[700]),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () => _showDoseCalculator(context),
              icon: const Icon(Icons.calculate),
              label: const Text('Хүүхдийн тун тооцоолох'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade700,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDoseCalculator(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => _DoseCalculatorDialog(
        patient: patient,
        adultDose: adultDose,
        onDoseSelected: onDoseSelected,
      ),
    );
  }
}

class _DoseCalculatorDialog extends StatefulWidget {
  const _DoseCalculatorDialog({
    required this.patient,
    required this.adultDose,
    this.onDoseSelected,
  });

  final Patient patient;
  final String adultDose;
  final ValueChanged<String>? onDoseSelected;

  @override
  State<_DoseCalculatorDialog> createState() => _DoseCalculatorDialogState();
}

class _DoseCalculatorDialogState extends State<_DoseCalculatorDialog> {
  final _weightCtrl = TextEditingController();
  final _heightCtrl = TextEditingController();
  DoseCalculationResult? _result;

  @override
  void dispose() {
    _weightCtrl.dispose();
    _heightCtrl.dispose();
    super.dispose();
  }

  void _calculate() {
    final weight = double.tryParse(_weightCtrl.text.trim());
    final height = double.tryParse(_heightCtrl.text.trim());

    setState(() {
      _result = PediatricDoseCalculator.calculatePediatricDose(
        adultDoseString: widget.adultDose,
        childAgeYears: widget.patient.age,
        childWeightKg: weight,
        childHeightCm: height,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Хүүхдийн тун тооцоолох'),
      content: SingleChildScrollView(
        child: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Patient Info
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.patient.fullName,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text('Нас: ${widget.patient.age} жил'),
                    Text('Насанд хүрэгчдэд зориулсан тун: ${widget.adultDose}'),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Weight Input
              TextField(
                controller: _weightCtrl,
                decoration: const InputDecoration(
                  labelText: 'Жин (кг)',
                  hintText: 'Жишээ: 25',
                  border: OutlineInputBorder(),
                  helperText: 'Тооцооллын нарийвчлал сайжирна',
                ),
                keyboardType: TextInputType.number,
                onChanged: (_) => _calculate(),
              ),
              const SizedBox(height: 12),

              // Height Input
              TextField(
                controller: _heightCtrl,
                decoration: const InputDecoration(
                  labelText: 'Өндөр (см) - сонголт',
                  hintText: 'Жишээ: 125',
                  border: OutlineInputBorder(),
                  helperText: 'BSA аргыг ашиглахад шаардлагатай',
                ),
                keyboardType: TextInputType.number,
                onChanged: (_) => _calculate(),
              ),
              const SizedBox(height: 16),

              // Calculate Button
              if (_result == null)
                Center(
                  child: ElevatedButton.icon(
                    onPressed: _calculate,
                    icon: const Icon(Icons.calculate),
                    label: const Text('Тооцоолох'),
                  ),
                ),

              // Results
              if (_result != null) ...[
                const Divider(),
                _buildResults(_result!),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Хаах'),
        ),
        if (_result != null && _result!.calculatedDose > 0)
          ElevatedButton(
            onPressed: () {
              widget.onDoseSelected?.call(_result!.formattedDose);
              Navigator.of(context).pop();
            },
            child: const Text('Ашиглах'),
          ),
      ],
    );
  }

  Widget _buildResults(DoseCalculationResult result) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Calculated Dose
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.green.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Тооцоолсон тун:',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 4),
              Text(
                result.formattedDose,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Арга: ${result.method}',
                style: TextStyle(fontSize: 12, color: Colors.grey[700]),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Warning
        if (result.warning.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.warning_amber, color: Colors.orange.shade700),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    result.warning,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.orange.shade900,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],

        // Recommendation
        if (result.recommendation.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue.shade700),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    result.recommendation,
                    style: TextStyle(fontSize: 13, color: Colors.blue.shade900),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
