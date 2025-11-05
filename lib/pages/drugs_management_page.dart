import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';

class DrugItem {
  final String name;
  final String dose;
  final String form;
  final int quantity;
  final int days;
  final String instruction;

  DrugItem({
    required this.name,
    required this.dose,
    required this.form,
    required this.quantity,
    required this.days,
    required this.instruction,
  });

  factory DrugItem.fromJson(Map<String, dynamic> json) {
    return DrugItem(
      name: json['name'] ?? '',
      dose: json['dose'] ?? '',
      form: json['form'] ?? '',
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
      days: (json['days'] as num?)?.toInt() ?? 0,
      instruction: json['instruction'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'dose': dose,
      'form': form,
      'quantity': quantity,
      'days': days,
      'instruction': instruction,
    };
  }
}

class DrugsManagementPage extends StatefulWidget {
  const DrugsManagementPage({super.key});

  @override
  State<DrugsManagementPage> createState() => _DrugsManagementPageState();
}

class _DrugsManagementPageState extends State<DrugsManagementPage> {
  List<DrugItem> _drugs = [];
  List<DrugItem> _filteredDrugs = [];
  String _searchQuery = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDrugs();
  }

  Future<void> _loadDrugs() async {
    setState(() => _isLoading = true);
    try {
      final String response = await rootBundle.loadString(
        'assets/data/drugs.json',
      );
      final List<dynamic> data = json.decode(response);
      _drugs = data.map((json) => DrugItem.fromJson(json)).toList();
      _filteredDrugs = List.from(_drugs);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Эмийн жагсаалт ачаалахад алдаа гарлаа: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _filterDrugs(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredDrugs = List.from(_drugs);
      } else {
        _filteredDrugs = _drugs.where((drug) {
          final searchLower = query.toLowerCase();
          return drug.name.toLowerCase().contains(searchLower) ||
              drug.dose.toLowerCase().contains(searchLower) ||
              drug.form.toLowerCase().contains(searchLower);
        }).toList();
      }
    });
  }

  Future<void> _addDrug() async {
    final result = await showDialog<DrugItem>(
      context: context,
      builder: (ctx) => _DrugFormDialog(),
    );

    if (result != null) {
      setState(() {
        _drugs.add(result);
        _filterDrugs(_searchQuery);
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Эм амжилттай нэмэгдлээ')));
      }
    }
  }

  Future<void> _editDrug(int index) async {
    final drug = _filteredDrugs[index];
    final originalIndex = _drugs.indexWhere((d) => d.name == drug.name);

    final result = await showDialog<DrugItem>(
      context: context,
      builder: (ctx) => _DrugFormDialog(existingDrug: drug),
    );

    if (result != null && originalIndex != -1) {
      setState(() {
        _drugs[originalIndex] = result;
        _filterDrugs(_searchQuery);
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Эм амжилттай шинэчлэгдлээ')),
        );
      }
    }
  }

  Future<void> _deleteDrug(int index) async {
    final drug = _filteredDrugs[index];
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Эм устгах'),
        content: Text('${drug.name}-г устгах уу?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Үгүй'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Устгах'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() {
        _drugs.removeWhere((d) => d.name == drug.name);
        _filterDrugs(_searchQuery);
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Эм устгагдлаа')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
        title: const Text('Эмийн жагсаалт'),
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              onChanged: _filterDrugs,
              decoration: InputDecoration(
                hintText: 'Эмийн нэр, тун, хэлбэр хайх...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Text(
                        '${_filteredDrugs.length} эм',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: _filteredDrugs.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.medication_outlined,
                                size: 64,
                                color: Colors.grey[300],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _searchQuery.isNotEmpty
                                    ? 'Эм олдсонгүй'
                                    : 'Эм байхгүй байна',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _filteredDrugs.length,
                          itemBuilder: (context, index) {
                            final drug = _filteredDrugs[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: ExpansionTile(
                                leading: CircleAvatar(
                                  backgroundColor: theme.colorScheme.primary
                                      .withValues(alpha: 0.1),
                                  child: Icon(
                                    Icons.medication,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                                title: Text(
                                  drug.name,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                subtitle: Text(
                                  '${drug.dose} • ${drug.form}',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        _infoRow(
                                          'Тоо ширхэг',
                                          drug.quantity.toString(),
                                        ),
                                        _infoRow('Хоног', drug.days.toString()),
                                        _infoRow('Заавар', drug.instruction),
                                        const SizedBox(height: 12),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            TextButton.icon(
                                              onPressed: () => _editDrug(index),
                                              icon: const Icon(
                                                Icons.edit,
                                                size: 16,
                                              ),
                                              label: const Text('Засах'),
                                            ),
                                            const SizedBox(width: 8),
                                            TextButton.icon(
                                              onPressed: () =>
                                                  _deleteDrug(index),
                                              icon: const Icon(
                                                Icons.delete,
                                                size: 16,
                                                color: Colors.red,
                                              ),
                                              label: const Text(
                                                'Устгах',
                                                style: TextStyle(
                                                  color: Colors.red,
                                                ),
                                              ),
                                            ),
                                          ],
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addDrug,
        icon: const Icon(Icons.add),
        label: const Text('Эм нэмэх'),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }
}

class _DrugFormDialog extends StatefulWidget {
  final DrugItem? existingDrug;

  const _DrugFormDialog({this.existingDrug});

  @override
  State<_DrugFormDialog> createState() => _DrugFormDialogState();
}

class _DrugFormDialogState extends State<_DrugFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _doseController;
  late TextEditingController _formController;
  late TextEditingController _quantityController;
  late TextEditingController _daysController;
  late TextEditingController _instructionController;

  @override
  void initState() {
    super.initState();
    final drug = widget.existingDrug;
    _nameController = TextEditingController(text: drug?.name ?? '');
    _doseController = TextEditingController(text: drug?.dose ?? '');
    _formController = TextEditingController(text: drug?.form ?? '');
    _quantityController = TextEditingController(
      text: drug?.quantity.toString() ?? '',
    );
    _daysController = TextEditingController(text: drug?.days.toString() ?? '');
    _instructionController = TextEditingController(
      text: drug?.instruction ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _doseController.dispose();
    _formController.dispose();
    _quantityController.dispose();
    _daysController.dispose();
    _instructionController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final drug = DrugItem(
      name: _nameController.text.trim(),
      dose: _doseController.text.trim(),
      form: _formController.text.trim(),
      quantity: int.tryParse(_quantityController.text.trim()) ?? 0,
      days: int.tryParse(_daysController.text.trim()) ?? 0,
      instruction: _instructionController.text.trim(),
    );

    Navigator.pop(context, drug);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.existingDrug == null ? 'Эм нэмэх' : 'Эм засах'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Эмийн нэр',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Нэр заавал' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _doseController,
                decoration: const InputDecoration(
                  labelText: 'Тун (ж: 500 мг)',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Тун заавал' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _formController,
                decoration: const InputDecoration(
                  labelText: 'Хэлбэр (ж: шахмал, капсул)',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Хэлбэр заавал' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _quantityController,
                decoration: const InputDecoration(
                  labelText: 'Тоо ширхэг',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Тоо заавал';
                  if (int.tryParse(v) == null) return 'Тоо буруу';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _daysController,
                decoration: const InputDecoration(
                  labelText: 'Хоног',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Хоног заавал';
                  if (int.tryParse(v) == null) return 'Тоо буруу';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _instructionController,
                decoration: const InputDecoration(
                  labelText: 'Хэрэглэх заавар',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Заавар заавал' : null,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Болих'),
        ),
        FilledButton(onPressed: _save, child: const Text('Хадгалах')),
      ],
    );
  }
}
