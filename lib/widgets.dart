import 'package:flutter/material.dart';
import 'models.dart';

// App Bottom Navigation Widget
class AppBottomNav extends StatelessWidget {
  const AppBottomNav({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  final int selectedIndex;
  final ValueChanged<int> onItemTapped;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final primary = scheme.primary;
    final accent = scheme.primary;

    return Container(
      margin: const EdgeInsets.fromLTRB(60, 0, 60, 40),
      height: 80,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(34),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNavItem(
            icon: Icons.home_outlined,
            selectedIcon: Icons.home,
            label: 'Нүүр',
            isSelected: selectedIndex == 0,
            onTap: () => onItemTapped(0),
            primaryColor: primary,
            accentColor: accent,
            secondaryColor: Colors.black,
          ),
          _buildNavItem(
            icon: Icons.person_outline,
            selectedIcon: Icons.person,
            label: 'Эмч',
            isSelected: selectedIndex == 1,
            onTap: () => onItemTapped(1),
            primaryColor: primary,
            accentColor: accent,
            secondaryColor: Colors.black,
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required IconData selectedIcon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required Color primaryColor,
    required Color accentColor,
    required Color secondaryColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? accentColor : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? selectedIcon : icon,
              color: isSelected ? Colors.white : primaryColor,
              size: 24,
            ),
            const SizedBox(height: 4),
            AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: 1.0,
              child: Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : secondaryColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Drug Input Widget
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
  late final TextEditingController _doseCtrl;
  late final TextEditingController _formCtrl;
  late final TextEditingController _qtyCtrl;
  late final TextEditingController _instrCtrl;
  late final TextEditingController _daysCtrl;

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
    _doseCtrl = TextEditingController(text: widget.initial?.dose ?? '');
    _formCtrl = TextEditingController(text: widget.initial?.form ?? '');
    _qtyCtrl = TextEditingController(
      text: widget.initial?.quantity.toString() ?? '',
    );
    _instrCtrl = TextEditingController(
      text: widget.initial?.instructions ?? '',
    );
    _daysCtrl = TextEditingController(
      text: widget.initial?.treatmentDays?.toString() ?? '',
    );

    WidgetsBinding.instance.addPostFrameCallback((_) => _emit());
  }

  @override
  void dispose() {
    _mnCtrl.dispose();
    _doseCtrl.dispose();
    _formCtrl.dispose();
    _qtyCtrl.dispose();
    _instrCtrl.dispose();
    _daysCtrl.dispose();
    super.dispose();
  }

  void _emit() {
    final qty = int.tryParse(_qtyCtrl.text.trim());
    final days = int.tryParse(_daysCtrl.text.trim());
    widget.onChanged(
      Drug(
        mongolianName: _mnCtrl.text.trim(),
        dose: _doseCtrl.text.trim(),
        form: _formCtrl.text.trim(),
        quantity: qty ?? 0,
        instructions: _instrCtrl.text.trim(),
        treatmentDays: days,
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
                      labelText: 'Эмийн нэр ',
                      border: OutlineInputBorder(),
                    ),
                    style: _inputTextStyle,
                    onChanged: (_) => _emit(),
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Эмийн нэр заавал'
                        : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _doseCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Тун ',
                          hintText: 'Жишээ, 500mg',
                          border: OutlineInputBorder(),
                        ),
                        style: _inputTextStyle,
                        onChanged: (_) => _emit(),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _qtyCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Тоо ',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        style: _inputTextStyle,
                        onChanged: (_) => _emit(),
                        validator: (v) => (int.tryParse(v ?? '') ?? 0) <= 0
                            ? 'Тоо зөв оруул'
                            : null,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _formCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Хэлбэр ',
                          hintText: 'Tablet/Syrup',
                          border: OutlineInputBorder(),
                        ),
                        style: _inputTextStyle,
                        onChanged: (_) => _emit(),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _daysCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Хоног ',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        style: _inputTextStyle,
                        onChanged: (_) => _emit(),
                        validator: (v) {
                          final val = int.tryParse(v ?? '');
                          if (val == null || val <= 0) return 'Хоног зөв';
                          return null;
                        },
                      ),
                    ],
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
