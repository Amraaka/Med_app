import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert' show json;
import 'dart:async';
import 'models.dart';

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

// Singleton cache for drug catalog shared across all DrugInput instances
class _DrugCatalogCache {
  static _DrugCatalogCache? _instance;
  static _DrugCatalogCache get instance => _instance ??= _DrugCatalogCache._();
  _DrugCatalogCache._();

  List<Drug>? _catalog;
  Future<List<Drug>>? _loadingFuture;

  Future<List<Drug>> load() async {
    // Return cached catalog if available
    if (_catalog != null) return _catalog!;

    // Return existing loading operation if in progress
    if (_loadingFuture != null) return _loadingFuture!;

    // Start new loading operation
    _loadingFuture = _loadCatalogInternal();
    try {
      _catalog = await _loadingFuture!;
      return _catalog!;
    } finally {
      _loadingFuture = null;
    }
  }

  Future<List<Drug>> _loadCatalogInternal() async {
    try {
      final raw = await rootBundle.loadString('assets/data/drugs.json');
      final parsed = (json.decode(raw) as List<dynamic>?) ?? const [];
      final items = parsed.map((e) {
        final m = e as Map<String, dynamic>;
        return Drug(
          mongolianName: (m['name'] as String?) ?? '',
          dose: (m['dose'] as String?) ?? '',
          form: (m['form'] as String?) ?? '',
          quantity: (m['quantity'] as num?)?.toInt() ?? 0,
          instructions: (m['instruction'] as String?) ?? '',
          treatmentDays: (m['days'] as num?)?.toInt(),
        );
      }).toList();
      debugPrint('Drug catalog loaded: ${items.length} items');
      return items;
    } catch (e) {
      debugPrint('Failed to load drug catalog: $e');
      return [];
    }
  }

  void clear() {
    _catalog = null;
    _loadingFuture = null;
  }
}

class _DrugInputState extends State<DrugInput> {
  late final TextEditingController _mnCtrl;
  late final FocusNode _mnFocus;
  late final TextEditingController _doseCtrl;
  late final TextEditingController _formCtrl;
  late final TextEditingController _qtyCtrl;
  late final TextEditingController _instrCtrl;
  late final TextEditingController _daysCtrl;

  List<Drug> _catalog = const [];
  bool _loadingCatalog = false;
  Timer? _debounceTimer;

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
    _mnFocus = FocusNode();
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
    _loadDrugCatalog();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _mnCtrl.dispose();
    _mnFocus.dispose();
    _doseCtrl.dispose();
    _formCtrl.dispose();
    _qtyCtrl.dispose();
    _instrCtrl.dispose();
    _daysCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadDrugCatalog() async {
    if (_loadingCatalog) return;
    setState(() => _loadingCatalog = true);
    try {
      final items = await _DrugCatalogCache.instance.load();
      if (mounted) {
        setState(() => _catalog = items);
      }
    } finally {
      if (mounted) setState(() => _loadingCatalog = false);
    }
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

  void _debouncedEmit() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), _emit);
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
                  child: RawAutocomplete<Drug>(
                    textEditingController: _mnCtrl,
                    focusNode: _mnFocus,
                    displayStringForOption: (d) => d.mongolianName,
                    optionsBuilder: (TextEditingValue tev) {
                      final q = tev.text.trim();
                      if (q.isEmpty || _catalog.isEmpty) {
                        return const Iterable<Drug>.empty();
                      }

                      // Fast filtering with early exit
                      final qLower = q.toLowerCase();
                      final results = <Drug>[];
                      final seen = <String>{};

                      for (final drug in _catalog) {
                        if (results.length >= 20)
                          break; // Early exit when we have enough

                        if (drug.mongolianName.isEmpty) continue;

                        final key =
                            '${drug.mongolianName}|${drug.dose}|${drug.form}';
                        if (!seen.add(key)) continue; // Skip duplicates

                        final name = drug.mongolianName.toLowerCase();
                        final form = drug.form.toLowerCase();
                        final dose = drug.dose.toLowerCase();

                        // Check for match
                        if (name.contains(qLower) ||
                            form.contains(qLower) ||
                            dose.contains(qLower)) {
                          results.add(drug);
                        }
                      }

                      return results;
                    },
                    onSelected: (Drug selected) {
                      // Batch updates to avoid multiple rebuilds
                      _mnCtrl.text = selected.mongolianName;
                      _doseCtrl.text = selected.dose;
                      _formCtrl.text = selected.form;
                      if (selected.quantity > 0) {
                        _qtyCtrl.text = selected.quantity.toString();
                      }
                      if ((selected.treatmentDays ?? 0) > 0) {
                        _daysCtrl.text = selected.treatmentDays.toString();
                      }
                      if (selected.instructions.isNotEmpty) {
                        _instrCtrl.text = selected.instructions;
                      }
                      // Immediate emit for selection
                      _emit();
                    },
                    fieldViewBuilder:
                        (context, controller, focusNode, onFieldSubmitted) {
                          return TextFormField(
                            controller: controller,
                            focusNode: focusNode,
                            decoration: InputDecoration(
                              labelText: _loadingCatalog
                                  ? 'Эмийн нэр (унаж байна...)'
                                  : _catalog.isEmpty
                                  ? 'Эмийн нэр'
                                  : 'Эмийн нэр (${_catalog.length} эм)',
                              border: const OutlineInputBorder(),
                              helperText: _catalog.isEmpty && !_loadingCatalog
                                  ? 'Жагсаалт ачаалагдаагүй'
                                  : null,
                            ),
                            style: _inputTextStyle,
                            onChanged: (_) => _debouncedEmit(),
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? 'Эмийн нэр заавал'
                                : null,
                          );
                        },
                    optionsViewBuilder: (context, onSelected, options) {
                      return Align(
                        alignment: Alignment.topLeft,
                        widthFactor: 1.0,
                        child: Material(
                          elevation: 4,
                          borderRadius: BorderRadius.circular(8),
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(
                              maxHeight: 300,
                              minWidth: 200,
                            ),
                            child: ListView.builder(
                              padding: EdgeInsets.zero,
                              itemCount: options.length,
                              itemBuilder: (context, index) {
                                final d = options.elementAt(index);
                                return ListTile(
                                  dense: true,
                                  title: Text(
                                    d.mongolianName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  subtitle: Text(
                                    [
                                      if (d.dose.isNotEmpty) d.dose,
                                      if (d.form.isNotEmpty) d.form,
                                    ].join(' • '),
                                  ),
                                  onTap: () => onSelected(d),
                                );
                              },
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            if (!_loadingCatalog && _catalog.isEmpty) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.info_outline, size: 16),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Эмийн жагсаалтыг ачаалж чадсангүй. Assets бүртгэл шалгана уу.',
                      style: TextStyle(color: Colors.grey[700], fontSize: 12),
                    ),
                  ),
                  TextButton(
                    onPressed: _loadDrugCatalog,
                    child: const Text('Дахин ачаалах'),
                  ),
                ],
              ),
            ],
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
                        onChanged: (_) => _debouncedEmit(),
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
                        onChanged: (_) => _debouncedEmit(),
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
                        onChanged: (_) => _debouncedEmit(),
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
                        onChanged: (_) => _debouncedEmit(),
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
              onChanged: (_) => _debouncedEmit(),
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
