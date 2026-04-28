import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:memo_lingvo/core/database/app_database.dart' hide Card;
import 'package:memo_lingvo/core/localization/l10n/app_localizations.dart';
import 'package:memo_lingvo/features/cards/presentation/screens/training_screen.dart';
import 'package:memo_lingvo/features/decks/logic/deck_cubit.dart';
import 'package:memo_lingvo/features/decks/presentation/screens/manage_deck_screen.dart';
import 'package:share_plus/share_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DecksView extends StatelessWidget {
  const DecksView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: BlocBuilder<DeckCubit, List<DeckWithCount>>(
        builder: (context, items) {
          if (items.isEmpty) {
            return Center(child: Text(l10n.decks_view_no_decks));
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final deck = items[index];
              return _DeckCard(item: deck);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDeckDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddDeckDialog(BuildContext context) {
    final controller = TextEditingController();
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.decks_view__show_add_deck_dialog_new_deck),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: l10n.decks_view__show_add_deck_dialog_hint_title,
              ),
              autofocus: true,
            ),
            const SizedBox(height: 16),
            const Divider(),
            // КНОПКА ИМПОРТА
            TextButton.icon(
              icon: const Icon(Icons.download),
              label: const Text("Или импортировать по коду"),
              onPressed: () {
                Navigator.pop(dialogContext); // Закрываем этот диалог
                _showImportDialog(context); // Открываем диалог импорта
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.decks_view__show_add_deck_dialog_cancel),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                context.read<DeckCubit>().addDeck(controller.text.trim(), null);
                Navigator.pop(dialogContext);
              }
            },
            child: Text(l10n.decks_view__show_add_deck_dialog_create),
          ),
        ],
      ),
    );
  }

  // НОВЫЙ МЕТОД ДЛЯ ДИАЛОГА ИМПОРТА
  void _showImportDialog(BuildContext context) {
    final codeController = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text("Импорт колоды"),
        content: TextField(
          controller: codeController,
          decoration: const InputDecoration(
            hintText: "Вставьте код колоды (например: ID_ID)",
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text("Отмена"),
          ),
          ElevatedButton(
            onPressed: () async {
              final code = codeController.text.trim();
              if (code.isNotEmpty) {
                Navigator.pop(dialogContext);
                try {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('📥 Идет скачивание...')),
                  );
                  await context.read<DeckCubit>().importDeckByCode(code);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('✅ Колода успешно импортирована!'),
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('❌ Ошибка: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text("Импортировать"),
          ),
        ],
      ),
    );
  }
}

class _DeckCard extends StatelessWidget {
  final DeckWithCount item;
  const _DeckCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Stack(
        children: [
          InkWell(
            onTap: () {
              // НОВАЯ ЛОГИКА ПЕРЕХОДОВ
              if (item.cardCount > 0) {
                // Если карточки есть -> идем тренироваться
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TrainingScreen(deckId: item.deck.id),
                  ),
                );
              } else {
                // Если колода пустая -> открываем управление колодой (чтобы добавить карточки)
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ManageDeckScreen(deck: item.deck),
                  ),
                );
              }
            },
            onLongPress: () => _showActionMenu(context, item.deck),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.folder_open, size: 40, color: Colors.blue),
                  const SizedBox(height: 8),
                  Text(
                    item.deck.title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    "Карточек: ${item.cardCount}",
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),

          Positioned(
            top: 4,
            right: 4,
            child: IconButton(
              onPressed: () => _showActionMenu(context, item.deck),
              icon: const Icon(Icons.more_vert, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  void _showActionMenu(BuildContext context, Deck deck) {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (bottomSheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: Text(l10n.deck_card__show_action_menu_edit_title),
              onTap: () {
                Navigator.pop(bottomSheetContext);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ManageDeckScreen(deck: deck),
                  ),
                );
              },
            ),
            // НОВАЯ КНОПКА: Поделиться
            ListTile(
              leading: const Icon(Icons.share, color: Colors.blue),
              title: const Text("Поделиться колодой"),
              onTap: () async {
                Navigator.pop(bottomSheetContext);
                final db = context.read<AppDatabase>();
                final email = FirebaseAuth.instance.currentUser?.email;
                if (email != null) {
                  final serverId = await db.getServerUserId(email);
                  if (serverId != null) {
                    final shareCode = "${serverId}_${deck.id}";
                    Share.share(
                      'Я создал классную колоду "${deck.title}"! \nСкачай её себе в MemoLingvo, используя этот код импорта:\n\n$shareCode',
                    );
                  }
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: Text(
                l10n.deck_card__show_action_menu_delete_deck,
                style: const TextStyle(color: Colors.red),
              ),
              onTap: () {
                context.read<DeckCubit>().deleteDeck(deck.id);
                Navigator.pop(bottomSheetContext);
              },
            ),
          ],
        ),
      ),
    );
  }
}
