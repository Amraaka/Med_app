import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../models.dart';
import '../services.dart';

class DoctorDetailPage extends StatefulWidget {
  const DoctorDetailPage({super.key});

  @override
  State<DoctorDetailPage> createState() => _DoctorDetailPageState();
}

class _DoctorDetailPageState extends State<DoctorDetailPage> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Use read() + select() to only rebuild when profile actually changes
    final profile = context.select<DoctorProfileService, DoctorProfile>(
      (service) => service.profile,
    );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.colorScheme.primary.withOpacity(0.08),
        title: const Text('Эмчийн мэдээлэл'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Засах',
            onPressed: () => _openEditBottomSheet(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 24),
            // Profile Photo
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
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 60,
                    backgroundColor: theme.colorScheme.primary.withValues(
                      alpha: 0.1,
                    ),
                    backgroundImage: profile.photoPath != null
                        ? FileImage(File(profile.photoPath!)) as ImageProvider
                        : const AssetImage(
                            'assets/images/ColoradoBusinessCenter.jpg',
                          ),
                    onBackgroundImageError: (_, __) {},
                  ),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: CircleAvatar(
                      radius: 14,
                      backgroundColor: Colors.green,
                      child: const Icon(
                        Icons.medical_services,
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Name
            Text(
              profile.name,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            // Title
            Text(
              profile.title,
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            // Information Cards
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  if (profile.clinicName.isNotEmpty)
                    _InfoCard(
                      icon: Icons.local_hospital,
                      iconColor: Colors.blue,
                      title: 'Эмнэлэг/Байгууллага',
                      content: profile.clinicName,
                    ),
                  if (profile.location.isNotEmpty)
                    _InfoCard(
                      icon: Icons.location_on,
                      iconColor: Colors.red,
                      title: 'Байршил',
                      content: profile.location,
                    ),
                  if (profile.phone.isNotEmpty)
                    _InfoCard(
                      icon: Icons.phone,
                      iconColor: Colors.green,
                      title: 'Холбоо барих',
                      content: profile.phone,
                    ),
                  if (profile.signaturePath != null)
                    _SignatureCard(signaturePath: profile.signaturePath!),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

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
                    decoration: const InputDecoration(labelText: 'Нэр'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: 'Албан тушаал',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: locationController,
                    decoration: const InputDecoration(labelText: 'Байршил'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: clinicController,
                    decoration: const InputDecoration(
                      labelText: 'Эмнэлэг/байгууллагын нэр',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Утасны дугаар',
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
                          color: Theme.of(
                            context,
                          ).colorScheme.surfaceContainerHighest,
                          border: Border.all(
                            color: Theme.of(
                              context,
                            ).colorScheme.outline.withOpacity(0.3),
                          ),
                          borderRadius: BorderRadius.circular(12),
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
                      Expanded(
                        child: OutlinedButton.icon(
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
                          label: const Text('Сонгох'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (tempSignaturePath != null)
                        IconButton(
                          onPressed: () =>
                              setModalState(() => tempSignaturePath = null),
                          icon: const Icon(Icons.close),
                          tooltip: 'Цэвэрлэх',
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
                          if (ctx.mounted) Navigator.pop(ctx);
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

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.content,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String content;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    content,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SignatureCard extends StatelessWidget {
  const _SignatureCard({required this.signaturePath});

  final String signaturePath;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.purple.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.border_color,
                    color: Colors.purple,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  'Гарын үсэг',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.withOpacity(0.2)),
              ),
              clipBehavior: Clip.antiAlias,
              child: Image.file(File(signaturePath), fit: BoxFit.contain),
            ),
          ],
        ),
      ),
    );
  }
}
