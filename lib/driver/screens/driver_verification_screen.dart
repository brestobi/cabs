import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../common/providers/storage_provider.dart';
import '../../common/providers/user_provider.dart';
import '../../auth/providers/auth_provider.dart';

class DriverVerificationScreen extends ConsumerStatefulWidget {
  const DriverVerificationScreen({super.key});

  @override
  ConsumerState<DriverVerificationScreen> createState() => _DriverVerificationScreenState();
}

class _DriverVerificationScreenState extends ConsumerState<DriverVerificationScreen> {
  final _licenseController = TextEditingController();
  File? _licenseImage;
  File? _selfieImage;
  bool _isUploading = false;

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(bool isLicense) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        if (isLicense) {
          _licenseImage = File(image.path);
        } else {
          _selfieImage = File(image.path);
        }
      });
    }
  }

  Future<void> _submit() async {
    if (_licenseController.text.isEmpty || _licenseImage == null || _selfieImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please complete all fields')));
      return;
    }

    setState(() => _isUploading = true);

    try {
      final authState = ref.read(authProvider);
      final storage = ref.read(storageServiceProvider);
      final userId = authState.user!.id;

      final licenseUrl = await storage.uploadFile(
        bucket: 'driver-documents',
        path: '$userId/license',
        file: _licenseImage!,
      );

      final selfieUrl = await storage.uploadFile(
        bucket: 'driver-documents',
        path: '$userId/selfie',
        file: _selfieImage!,
      );

      if (licenseUrl != null && selfieUrl != null) {
        await ref.read(userProvider.notifier).updateDriverVerification(
          licenseNumber: _licenseController.text,
          licensePhotoUrl: licenseUrl,
          selfiePhotoUrl: selfieUrl,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Verification submitted!')));
          // Navigation logic will be handled by the router/provider
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Driver Verification')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: Main_AxisAlignment.start,
          children: [
            const Text('Submit your documents for review', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            TextField(
              controller: _licenseController,
              decoration: const InputDecoration(labelText: 'Driver License Number', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 24),
            _ImagePickerTile(
              label: 'License Photo',
              image: _licenseImage,
              onTap: () => _pickImage(true),
            ),
            const SizedBox(height: 16),
            _ImagePickerTile(
              label: 'Selfie with ID',
              image: _selfieImage,
              onTap: () => _pickImage(false),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _isUploading ? null : _submit,
              style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
              child: _isUploading ? const CircularProgressIndicator() : const Text('SUBMIT FOR VERIFICATION'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ImagePickerTile extends StatelessWidget {
  final String label;
  final File? image;
  final VoidCallback onTap;

  const _ImagePickerTile({required this.label, this.image, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 150,
        width: double.infinity,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(12),
        ),
        child: image != null
            ? ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.file(image!, fit: BoxImage.cover))
            : Column(
                mainAxisAlignment: Main_AxisAlignment.center,
                children: [
                  const Icon(Icons.add_a_photo, size: 40, color: Colors.grey),
                  const SizedBox(height: 8),
                  Text(label, style: const TextStyle(color: Colors.grey)),
                ],
              ),
      ),
    );
  }
}
