import 'package:flutter/material.dart';
import 'package:memo_lingvo/features/home/presentation/widgets/decks_view.dart';
import 'package:memo_lingvo/features/settings/presentation/settings_screen.dart';

// --- НОВЫЕ ИМПОРТЫ ДЛЯ СИНХРОНИЗАЦИИ ---
import 'package:memo_lingvo/core/database/app_database.dart';
import 'package:memo_lingvo/core/network/api_client.dart';
import 'package:memo_lingvo/features/sync/sync_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
//import 'package:memo_lingvo/core/utils.dart';

class MainWrapper extends StatefulWidget {
  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    Center(child: DecksView()), // ЛР №1: Страница 1
    const Center(child: Text("Выбор игры")), // ЛР №1: Страница 2
    const Center(child: Text("Профиль")),
    SettingsScreen(), // ЛР №1: Страница 3
  ];

  // Динамические заголовки для верхней панели (AppBar)
  final List<String> _titles = [
    "Мои колоды",
    "Игры",
    "Профиль",
    "Настройки",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // --- ДОБАВЛЯЕМ ВЕРХНЮЮ ПАНЕЛЬ (AppBar) С КНОПКОЙ ---
      appBar: AppBar(
        title: Text(_titles[_currentIndex]), // Название меняется при переключении
        centerTitle: true,
        actions: [
          // Кнопка синхронизации
          IconButton(
            icon: const Icon(Icons.sync),
            tooltip: 'Синхронизировать данные',
            onPressed: () async {
              print("🔘 Нажата кнопка синхронизации!"); // Проверка клика
              
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
                  print("🔍 ID для синхронизации: $serverId"); // Логируем ID
                  
                  if (serverId != null) {
                    await syncService.pushDirtyData();
                    await syncService.pullServerData(serverId);
                    
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('✅ Синхронизация завершена!')),
                      );
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
                  // Прячем предыдущий Снекбар "Синхронизация..."
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  
                  // Показываем человечную ошибку
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
      
      // Округлое меню внизу
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
              onTap: (index) => setState(() => _currentIndex = index),
              type: BottomNavigationBarType.fixed,
              showSelectedLabels: false,
              showUnselectedLabels: false,
              items: const [
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
    );
  }
}