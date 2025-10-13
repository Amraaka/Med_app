import 'package:flutter/material.dart';

import '../models/drug.dart';

class DrugInput extends StatefulWidget {
  const DrugInput({
    super.key,
    this.initial,
    required this.onChanged,
    required this.onRemove,
  });

  final Drug? initial;
  final ValueChanged<Drug> onChanged;
  final VoidCallback onRemove;

  @override
  State<DrugInput> createState() => _DrugInputState();
}

class _DrugInputState extends State<DrugInput> {
  late final TextEditingController _mnCtrl;
  late final TextEditingController _latCtrl;
  late final TextEditingController _doseCtrl;
  late final TextEditingController _formCtrl;
  late final TextEditingController _qtyCtrl;
  late final TextEditingController _instrCtrl;

  // Ensure Mongolian (Cyrillic) input renders by providing a font fallback.
  // NotoSans may not include all glyphs depending on the asset variant; this
  // fallback guarantees proper display while preserving app styling.
  static const TextStyle _inputTextStyle = TextStyle(
    fontFamily: 'NotoSans',
    fontFamilyFallback: <String>[
      'Roboto',
      'Apple SD Gothic Neo',
      'Helvetica Neue',
      'Arial Unicode MS',
      'sans-serif',
    ],
  );

  @override
  void initState() {
    super.initState();
    _mnCtrl = TextEditingController(text: widget.initial?.mongolianName ?? '');
    _latCtrl = TextEditingController(text: widget.initial?.latinName ?? '');
    _doseCtrl = TextEditingController(text: widget.initial?.dose ?? '');
    _formCtrl = TextEditingController(text: widget.initial?.form ?? '');
    _qtyCtrl = TextEditingController(
      text: widget.initial?.quantity.toString() ?? '',
    );
    _instrCtrl = TextEditingController(
      text: widget.initial?.instructions ?? '',
    );

    WidgetsBinding.instance.addPostFrameCallback((_) => _emit());
  }

  @override
  void dispose() {
    _mnCtrl.dispose();
    _latCtrl.dispose();
    _doseCtrl.dispose();
    _formCtrl.dispose();
    _qtyCtrl.dispose();
    _instrCtrl.dispose();
    super.dispose();
  }

  void _emit() {
    final qty = int.tryParse(_qtyCtrl.text.trim());
    widget.onChanged(
      Drug(
        mongolianName: _mnCtrl.text.trim(),
        latinName: _latCtrl.text.trim(),
        dose: _doseCtrl.text.trim(),
        form: _formCtrl.text.trim(),
        quantity: qty ?? 0,
        instructions: _instrCtrl.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _mnCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Эмийн нэр (монгол)',
                      border: OutlineInputBorder(),
                    ),
                    style: _inputTextStyle,
                    onChanged: (_) => _emit(),
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Эмийн нэр заавал'
                        : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _latCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Latin name',
                      border: OutlineInputBorder(),
                    ),
                    style: _inputTextStyle,
                    onChanged: (_) => _emit(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _doseCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Тун (dose)',
                      hintText: 'e.g., 500mg',
                      border: OutlineInputBorder(),
                    ),
                    style: _inputTextStyle,
                    onChanged: (_) => _emit(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _formCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Хэлбэр (form)',
                      hintText: 'Tablet/Syrup',
                      border: OutlineInputBorder(),
                    ),
                    style: _inputTextStyle,
                    onChanged: (_) => _emit(),
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 100,
                  child: TextFormField(
                    controller: _qtyCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Тоо (qty)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    style: _inputTextStyle,
                    onChanged: (_) => _emit(),
                    validator: (v) => (int.tryParse(v ?? '') ?? 0) <= 0
                        ? 'Тоо зөв оруул'
                        : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _instrCtrl,
              decoration: const InputDecoration(
                labelText: 'Хэрэглэх заавар (instructions)',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
              style: _inputTextStyle,
              onChanged: (_) => _emit(),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: widget.onRemove,
                icon: const Icon(Icons.delete_outline),
                label: const Text('Remove'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
