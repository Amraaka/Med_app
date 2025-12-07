import 'package:flutter/material.dart';
import 'package:pediatric_dose_calculator/pediatric_dose_calculator.dart';

class PediatricDoseHelper extends StatefulWidget {
  final int patientAge;
  final Function(String dose) onDoseCalculated;

  const PediatricDoseHelper({
    super.key,
    required this.patientAge,
    required this.onDoseCalculated,
  });

  @override
  State<PediatricDoseHelper> createState() => _PediatricDoseHelperState();
}

class _PediatricDoseHelperState extends State<PediatricDoseHelper> {
  final _adultDoseController = TextEditingController();
  String? _calculatedDose;
  String? _warning;

  void _calculate() {
    final adultDose = double.tryParse(_adultDoseController.text);
    if (adultDose == null || adultDose <= 0) {
      setState(() {
        _calculatedDose = null;
        _warning = null;
      });
      return;
    }

    final result = PediatricDoseCalculator.calculateDose(
      ageInYears: widget.patientAge,
      adultDose: adultDose,
    );

    setState(() {
      _calculatedDose = result.formattedDose;
      _warning = result.warning;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.patientAge >= 18) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(top: 8, bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.black),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row(
          //   children: [
          //     Icon(Icons.calculate, size: 18),
          //     const SizedBox(width: 6),
          //     Text(
          //       'Хүүхдийн тун',
          //       style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          //     ),
          //   ],
          // ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: TextField(
                  controller: _adultDoseController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Том хүний тун',
                    hintText: '500',
                    suffixText: 'mg',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    isDense: true,
                  ),
                  onChanged: (_) => _calculate(),
                ),
              ),
              const SizedBox(width: 12),
              Icon(Icons.arrow_forward, color: Colors.blue.shade400, size: 20),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _calculatedDose != null
                          ? Colors.green.shade300
                          : Colors.grey.shade300,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Хүүхдийн тун',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _calculatedDose ?? '—',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: _calculatedDose != null
                              ? Colors.green.shade900
                              : Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (_calculatedDose != null) ...[
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () {
                    widget.onDoseCalculated(_calculatedDose!);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Тун хуулагдлаа'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                  icon: Icon(Icons.check_circle, color: Colors.green.shade600),
                  tooltip: 'Тун ашиглах',
                  constraints: const BoxConstraints(),
                  padding: EdgeInsets.zero,
                ),
              ],
            ],
          ),
          if (_warning != null && _warning!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    size: 16,
                    color: Colors.orange.shade700,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      _warning!,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.orange.shade900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  void dispose() {
    _adultDoseController.dispose();
    super.dispose();
  }
}
