import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../services.dart';
import '../../widgets/animated_press_button.dart';
import '../../widgets/animated_logo_hero.dart';

class SignupPage extends StatefulWidget {
  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _titleController = TextEditingController();
  final _locationController = TextEditingController();
  final _phoneController = TextEditingController();
  final _clinicNameController = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _titleController.dispose();
    _locationController.dispose();
    _phoneController.dispose();
    _clinicNameController.dispose();
    super.dispose();
  }

  void _signup() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final userCredential = await authService.value.createAccount(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (!mounted) return;
      await context.read<DoctorProfileService>().createProfile(
        userId: userCredential.user!.uid,
        name: _nameController.text.trim(),
        title: _titleController.text.trim(),
        location: _locationController.text.trim(),
        phone: _phoneController.text.trim(),
        clinicName: _clinicNameController.text.trim(),
      );

      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/home');
    } on FirebaseAuthException catch (e) {
      setState(() {
        _error = e.message ?? 'Sign up failed';
      });
    } catch (e) {
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const inputDecoration = InputDecoration(
      contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 14),
    );

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Card(
              color: Theme.of(context).cardTheme.color,
              elevation: Theme.of(context).cardTheme.elevation,
              shape: Theme.of(context).cardTheme.shape,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 24,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: Column(
                          children: [
                            const AnimatedLogoHero(
                              size: 100,
                              showFloatingAnimation: true,
                            ),
                            const SizedBox(height: 20),
                            Text(
                              'Эмчийн бүртгэл үүсгэх',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 18),
                          ],
                        ),
                      ),
                      TextFormField(
                        controller: _emailController,
                        decoration: inputDecoration.copyWith(
                          labelText: 'Имэйл',
                          prefixIcon: const Icon(Icons.email),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          final v = value?.trim() ?? '';
                          if (v.isEmpty) return 'Имэйл заавал бөглөх';
                          final emailRegex = RegExp(
                            r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                          );
                          if (!emailRegex.hasMatch(v))
                            return 'Зөв Имэйл оруулна уу';
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _passwordController,
                        decoration: inputDecoration.copyWith(
                          labelText: 'Нууц үг',
                          prefixIcon: const Icon(Icons.lock),
                        ),
                        obscureText: true,
                        validator: (value) {
                          final v = value ?? '';
                          if (v.isEmpty) return 'Нууц үг заавал шаардлагатай';
                          if (v.length < 6)
                            return '6-с дээш оронтой нууц үг оруулна уу';
                          return null;
                        },
                      ),
                      const SizedBox(height: 18),
                      Text(
                        'Эмчийн мэдээлэл',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _nameController,
                        decoration: inputDecoration.copyWith(
                          labelText: 'Бүтэн нэр',
                          prefixIcon: const Icon(Icons.person),
                        ),
                        validator: (value) {
                          final v = value?.trim() ?? '';
                          if (v.isEmpty) return 'Нэр оруулна уу?';
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _titleController,
                        decoration: inputDecoration.copyWith(
                          labelText: 'Эмчийн албан тушаал',
                          prefixIcon: const Icon(Icons.work),
                        ),
                        validator: (value) {
                          final v = value?.trim() ?? '';
                          if (v.isEmpty) return 'Title is required';
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _locationController,
                        decoration: inputDecoration.copyWith(
                          labelText: 'Байршил',
                          prefixIcon: const Icon(Icons.location_on),
                        ),
                        validator: (value) {
                          final v = value?.trim() ?? '';
                          if (v.isEmpty) return 'Location is required';
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _phoneController,
                        decoration: inputDecoration.copyWith(
                          labelText: 'Утасны дугаар',
                          prefixIcon: const Icon(Icons.phone),
                        ),
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _clinicNameController,
                        decoration: inputDecoration.copyWith(
                          labelText: 'Эмнэлгийн нэр',
                          prefixIcon: const Icon(Icons.local_hospital),
                        ),
                      ),
                      if (_error != null) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).colorScheme.error.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Theme.of(
                                context,
                              ).colorScheme.error.withOpacity(0.3),
                            ),
                          ),
                          child: Text(
                            _error!,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 18),
                      AnimatedPressButton(
                        onPressed: _loading ? null : _signup,
                        child: ElevatedButton(
                          onPressed: _loading ? null : _signup,
                          style: Theme.of(context).elevatedButtonTheme.style,
                          child: _loading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text('Бүртгүүлэх'),
                        ),
                      ),
                      const SizedBox(height: 12),
                      AnimatedPressButton(
                        onPressed: _loading
                            ? null
                            : () {
                                Navigator.pop(context);
                              },
                        child: TextButton(
                          onPressed: _loading
                              ? null
                              : () {
                                  Navigator.pop(context);
                                },
                          child: const Text('Нэвтрэх'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
