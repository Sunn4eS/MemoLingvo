import 'package:flutter/material.dart';
import 'package:memo_lingvo/features/games/presentation/screens/games_menu_screen.dart';
import 'package:memo_lingvo/features/home/presentation/widgets/decks_view.dart';
import 'package:memo_lingvo/features/profile/presentation/screens/profile_screen.dart';
import 'package:memo_lingvo/features/settings/presentation/settings_screen.dart';
import 'package:memo_lingvo/core/database/app_database.dart';
import 'package:memo_lingvo/core/network/api_client.dart';
import 'package:memo_lingvo/features/sync/sync_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:memo_lingvo/features/profile/logic/profile_cubit.dart'; 
import 'package:memo_lingvo/core/network/network_cubit.dart';
import 'package:memo_lingvo/core/notifications/notification_service.dart';

class MainWrapper extends StatefulWidget {
  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  int _currentIndex = 0;
  
  final List<Widget> _pages = [
  const Center(child: DecksView()),
  const GamesMenuScreen(),   // ← было Center(child: Text("Выбор игры"))
  const Center(child: ProfileScreen()),
  SettingsScreen(),
];
  
  final List<String> _titles =[
    "Мои колоды",
    "Игры",
    "Профиль",
    "Настройки",
  ];

   @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final db = context.read<AppDatabase>();
      NotificationService().scheduleWordOfTheDay(db);
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<NetworkCubit, NetworkState>(
      listener: (context, state) {
        if (state == NetworkState.offline) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Row(
                children:[
                  Icon(Icons.wifi_off, color: Colors.white),
                  SizedBox(width: 10),
                  Text('Нет подключения к интернету'),
                ],
              ),
              backgroundColor: Colors.red,
              duration: Duration(days: 1), // Висит пока не появится сеть
            ),
          );
        } else if (state == NetworkState.online) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Row(
                children:[
                  Icon(Icons.wifi, color: Colors.white),
                  SizedBox(width: 10),
                  Text('Подключение восстановлено'),
                ],
              ),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }
      },
      child: Scaffold(
      appBar: AppBar(
        title: Text(_titles[_currentIndex]),
        centerTitle: true,
        actions:[
          IconButton(
            icon: const Icon(Icons.sync),
            tooltip: 'Синхронизировать данные',
            onPressed: () async {
              print("🔘 Нажата кнопка синхронизации!");
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('🔄 Синхронизация с сервером...')),
              );
              try {
                final db = context.read<AppDatabase>();
                final apiClient = ApiClient();
                final syncService = SyncService(db, apiClient);
                final firebaseUser = FirebaseAuth.instance.currentUser;
                
                if (firebaseUser != null && firebaseUser.email != null) {
                  final serverId = await db.getServerUserId(firebaseUser.email!);
                  print("🔍 ID для синхронизации: $serverId");
                  
                  if (serverId != null) {
                    await syncService.pushDirtyData();
                    await syncService.pullServerData(serverId);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('✅ Синхронизация завершена!')),
                      );
                      // Обновляем статистику профиля после синхронизации
                      context.read<ProfileCubit>().loadProfile();
                    }
                  } else {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('❌ Ошибка: Локальный профиль не найден.')),
                      );
                    }
                  }
                }
              } catch (e) {
                print("❌ Ошибка при синхронизации: $e");
                if (context.mounted) {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('❌ Нет связи с сервером. Проверьте интернет.'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
          ),
        ],
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: SafeArea(
        child: Container(
          margin: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 10,
          ),
          height: 70,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(30),
            boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10)],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: (index) {
                // ИЗМЕНЕНИЕ: Обновляем профиль при переходе на вкладку Профиля (индекс 2)
                if (index == 2) {
                  context.read<ProfileCubit>().loadProfile();
                }
                setState(() => _currentIndex = index);
              },
              type: BottomNavigationBarType.fixed,
              showSelectedLabels: false,
              showUnselectedLabels: false,
              items: const[
                BottomNavigationBarItem(
                  icon: Icon(Icons.home_rounded),
                  label: "",
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.videogame_asset_rounded),
                  label: "",
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person_rounded),
                  label: "",
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.settings_rounded),
                  label: "",
                ),
              ],
            ),
          ),
        ),
      ),
      ),
    );
  }
}