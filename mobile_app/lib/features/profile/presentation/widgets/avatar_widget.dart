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
      onTap: () => _pickAndUpdateAvatar(context),
      child: CircleAvatar(
        radius: size / 2,
        backgroundImage: avatarPath != null && File(avatarPath!).existsSync()
            ? FileImage(File(avatarPath!))
            : null,
        child: avatarPath == null
            ? Icon(Icons.camera_alt, size: size * 0.4)
            : null,
      ),
    );
  }

  Future<void> _pickAndUpdateAvatar(BuildContext context) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final file = File(pickedFile.path);
      await context.read<ProfileCubit>().updateAvatar(file);
    }
  }
}