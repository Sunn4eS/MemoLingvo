import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../logic/profile_cubit.dart';
import '../../logic/profile_state.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Мой Профиль")),
      body: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, state) {
          // Вместо: if (state is ProfileLoading)
          if (state is ProfileInitial || state is ProfileLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is ProfileError) return Center(child: Text(state.message));

          if (state is ProfileLoaded) {
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const SizedBox(height: 20),
                // Аватарка
                Center(
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundImage: state.avatarUrl != null
                            ? NetworkImage(state.avatarUrl!)
                            : const AssetImage(
                                    'assets/images/default_avatar.png',
                                  )
                                  as ImageProvider,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: CircleAvatar(
                          backgroundColor: Colors.blue,
                          radius: 20,
                          child: IconButton(
                            icon: const Icon(
                              Icons.camera_alt,
                              size: 18,
                              color: Colors.white,
                            ),
                            onPressed: () =>
                                context.read<ProfileCubit>().updateAvatar(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Имя пользователя
                Center(
                  child: Text(
                    state.nickname,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                // Ранг
                Center(
                  child: Chip(
                    label: Text(state.rank),
                    backgroundColor: Colors.blue.shade50,
                  ),
                ),

                const Divider(height: 40),

                // Статистика
                ListTile(
                  leading: const Icon(Icons.star, color: Colors.orange),
                  title: const Text("Очки опыта (XP)"),
                  trailing: Text(
                    "${state.xp}",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),

                const ListTile(
                  leading: Icon(Icons.workspace_premium, color: Colors.green),
                  title: Text("Место в лиге"),
                  trailing: Text(
                    "#12",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
