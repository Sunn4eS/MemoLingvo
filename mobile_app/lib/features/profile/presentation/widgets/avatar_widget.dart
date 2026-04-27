import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:memo_lingvo/features/profile/logic/profile_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AvatarWidget extends StatelessWidget {
  final String? avatarPath;
  final double size;

  const AvatarWidget({super.key, this.avatarPath, this.size = 80});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showPickerOptions(context),
      child: CircleAvatar(
        radius: size / 2,
        backgroundColor: Colors.grey.shade200,
        backgroundImage: avatarPath != null && File(avatarPath!).existsSync()
            ? FileImage(File(avatarPath!))
            : null,
        child: avatarPath == null
            ? Icon(Icons.person, size: size * 0.5, color: Colors.grey.shade400)
            : null,
      ),
    );
  }

  void _showPickerOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (bottomSheetContext) => SafeArea(
        child: Wrap(
          children:[
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Фото профиля',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Colors.blue),
              title: const Text('Сделать фото'),
              onTap: () {
                Navigator.of(bottomSheetContext).pop();
                _pickAndUpdateAvatar(context, ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Colors.blue),
              title: const Text('Выбрать из галереи'),
              onTap: () {
                Navigator.of(bottomSheetContext).pop();
                _pickAndUpdateAvatar(context, ImageSource.gallery);
              },
            ),
            if (avatarPath != null)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Удалить фото', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.of(bottomSheetContext).pop();
                  context.read<ProfileCubit>().removeAvatar();
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickAndUpdateAvatar(BuildContext context, ImageSource source) async {
    final picker = ImagePicker();
    try {
      final pickedFile = await picker.pickImage(
        source: source,
        imageQuality: 70, // Сжимаем фото, чтобы не забивать память
        maxWidth: 800,
      );
      
      if (pickedFile != null && context.mounted) {
        final file = File(pickedFile.path);
        await context.read<ProfileCubit>().updateAvatar(file);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка при выборе фото: $e')),
        );
      }
    }
  }
}