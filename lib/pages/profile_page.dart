import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../models.dart';
import '../services.dart';
import 'patient_form_page.dart';
import 'patient_detail_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final patientService = context.watch<PatientService>();
    final prescriptionService = context.watch<PrescriptionService>();
    final doctorSvc = context.watch<DoctorProfileService>();

    final allPatients = patientService.patients;
    final filteredPatients = allPatients.where((patient) {
      if (_searchQuery.isEmpty) return true;
      final searchLower = _searchQuery.toLowerCase();
      return patient.fullName.toLowerCase().contains(searchLower) ||
          patient.registrationNumber.toLowerCase().contains(searchLower) ||
          patient.phone.contains(_searchQuery);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
        title: const Text('Профайл'),
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: _DoctorProfileHeader(
              name: doctorSvc.profile.name,
              title: doctorSvc.profile.title,
              location: doctorSvc.profile.location,
              phone: doctorSvc.profile.phone,
              clinicName: doctorSvc.profile.clinicName,
              imageAssetPath:
                  doctorSvc.profile.photoPath ??
                  'assets/images/ColoradoBusinessCenter.jpg',
              isFileImage: doctorSvc.profile.photoPath != null,
              onEdit: () => _openEditBottomSheet(context),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              onChanged: (value) => setState(() => _searchQuery = value),
              decoration: InputDecoration(
                hintText: 'Нэр, РД, утас хайх...',
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
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Text(
                  '${filteredPatients.length} өвчтөн',
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
            child: filteredPatients.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.people_outline,
                          size: 64,
                          color: Colors.grey[300],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isNotEmpty
                              ? 'Өвчтөн олдсонгүй'
                              : 'Өвчтөн бүртгэлгүй байна',
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
                    itemCount: filteredPatients.length,
                    itemBuilder: (context, index) {
                      final patient = filteredPatients[index];
                      final prescriptions = prescriptionService
                          .getPrescriptionsByPatient(patient.id);

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: CircleAvatar(
                            radius: 24,
                            backgroundColor: theme.colorScheme.primary
                                .withValues(alpha: 0.1),
                            child: Text(
                              patient.givenName.isNotEmpty
                                  ? patient.givenName[0].toUpperCase()
                                  : 'P',
                              style: TextStyle(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ),
                          title: Text(
                            patient.fullName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: Text(
                            '${patient.age} нас • ${patient.sex.name} • ${prescriptions.length} жор',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                            ),
                          ),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) =>
                                    PatientDetailPage(patient: patient),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 120.0),
        child: FloatingActionButton.extended(
          onPressed: () async {
            final result = await Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const PatientFormPage()));
            if (!context.mounted) return;
            if (result != null) {
              await context.read<PatientService>().savePatient(result);
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Өвчтөн бүртгэгдлээ')),
              );
            }
          },
          icon: const Icon(Icons.person_add),
          label: const Text('Шинэ өвчтөн'),
        ),
      ),
    );
  }
}

class _DoctorProfileHeader extends StatelessWidget {
  const _DoctorProfileHeader({
    required this.name,
    required this.title,
    required this.location,
    required this.phone,
    required this.clinicName,
    required this.imageAssetPath,
    this.isFileImage = false,
    this.onEdit,
  });

  final String name;
  final String title;
  final String location;
  final String phone;
  final String clinicName;
  final String imageAssetPath;
  final bool isFileImage;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(width: 64), // space for avatar below
                  TextButton.icon(
                    onPressed: onEdit,
                    style: TextButton.styleFrom(
                      foregroundColor: theme.colorScheme.onSurface,
                      backgroundColor: theme.colorScheme.surface,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    icon: const Icon(Icons.edit, size: 16),
                    label: const Text('Засах'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Avatar centered with subtle white ring
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 40,
                      backgroundColor: theme.colorScheme.primary.withValues(
                        alpha: 0.1,
                      ),
                      backgroundImage: isFileImage
                          ? FileImage(File(imageAssetPath)) as ImageProvider
                          : AssetImage(imageAssetPath),
                      onBackgroundImageError: (_, __) {},
                    ),
                  ),
                  Positioned(
                    right: -2,
                    bottom: -2,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: CircleAvatar(
                        radius: 10,
                        backgroundColor: Colors.green,
                        child: const Icon(
                          Icons.medical_services,
                          size: 14,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                title,
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.location_on,
                    size: 16,
                    color: Colors.black54,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    location,
                    style: const TextStyle(fontSize: 13, color: Colors.black54),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              if (clinicName.isNotEmpty)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.local_hospital,
                      size: 16,
                      color: Colors.black54,
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        clinicName,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.black54,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              if (phone.isNotEmpty) ...[
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.phone, size: 16, color: Colors.black54),
                    const SizedBox(width: 4),
                    Text(
                      phone,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

extension on _ProfilePageState {
  Future<void> _openEditBottomSheet(BuildContext context) async {
    final doctorSvc = context.read<DoctorProfileService>();
    final profile = doctorSvc.profile;
    final nameController = TextEditingController(text: profile.name);
    final titleController = TextEditingController(text: profile.title);
    final locationController = TextEditingController(text: profile.location);
    final phoneController = TextEditingController(text: profile.phone);
    final clinicController = TextEditingController(text: profile.clinicName);
    String? tempPhotoPath = profile.photoPath;
    String? tempSignaturePath = profile.signaturePath;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        final bottomPadding = MediaQuery.of(ctx).viewInsets.bottom;
        return Padding(
          padding: EdgeInsets.only(bottom: bottomPadding),
          child: StatefulBuilder(
            builder: (ctx, setModalState) => SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          CircleAvatar(
                            radius: 36,
                            backgroundImage: tempPhotoPath != null
                                ? FileImage(File(tempPhotoPath!))
                                : const AssetImage(
                                        'assets/images/ColoradoBusinessCenter.jpg',
                                      )
                                      as ImageProvider,
                          ),
                          Positioned(
                            bottom: -4,
                            right: -4,
                            child: IconButton.filled(
                              onPressed: () async {
                                final picker = ImagePicker();
                                final picked = await picker.pickImage(
                                  source: ImageSource.gallery,
                                  maxWidth: 1024,
                                );
                                if (picked != null) {
                                  // Persist a copy via service
                                  final saved = await doctorSvc.savePickedImage(
                                    File(picked.path),
                                  );
                                  if (saved != null) {
                                    setModalState(() => tempPhotoPath = saved);
                                  }
                                }
                              },
                              icon: const Icon(Icons.camera_alt, size: 18),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Профайл зураг',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Нэр',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: 'Албан тушаал',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: locationController,
                    decoration: const InputDecoration(
                      labelText: 'Байршил',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: clinicController,
                    decoration: const InputDecoration(
                      labelText: 'Эмнэлэг/байгууллагын нэр',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Утасны дугаар',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Эмчийн гарын үсэг (зураг)',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        width: 120,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: tempSignaturePath == null
                            ? Center(
                                child: Text(
                                  'Байхгүй',
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                              )
                            : Image.file(
                                File(tempSignaturePath!),
                                fit: BoxFit.contain,
                              ),
                      ),
                      const SizedBox(width: 12),
                      OutlinedButton.icon(
                        onPressed: () async {
                          final picker = ImagePicker();
                          final picked = await picker.pickImage(
                            source: ImageSource.gallery,
                            maxWidth: 1024,
                          );
                          if (picked != null) {
                            final saved = await doctorSvc.savePickedImage(
                              File(picked.path),
                            );
                            if (saved != null) {
                              setModalState(() => tempSignaturePath = saved);
                            }
                          }
                        },
                        icon: const Icon(Icons.border_color),
                        label: const Text('Гарын үсэг сонгох'),
                      ),
                      const SizedBox(width: 8),
                      if (tempSignaturePath != null)
                        TextButton(
                          onPressed: () =>
                              setModalState(() => tempSignaturePath = null),
                          child: const Text('Цэвэрлэх'),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('Болих'),
                      ),
                      const SizedBox(width: 8),
                      FilledButton(
                        onPressed: () async {
                          final updated = DoctorProfile(
                            name: nameController.text.trim(),
                            title: titleController.text.trim(),
                            location: locationController.text.trim(),
                            photoPath: tempPhotoPath,
                            phone: phoneController.text.trim(),
                            clinicName: clinicController.text.trim(),
                            signaturePath: tempSignaturePath,
                          );
                          await doctorSvc.updateProfile(updated);
                          if (mounted) Navigator.pop(ctx);
                        },
                        child: const Text('Хадгалах'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
