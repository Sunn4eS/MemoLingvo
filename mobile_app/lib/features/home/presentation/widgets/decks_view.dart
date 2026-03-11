import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:memo_lingvo/core/database/app_database.dart';
import 'package:flutter/material.dart' as material;
import 'package:memo_lingvo/core/localization/l10n/app_localizations.dart';
import 'package:memo_lingvo/features/decks/logic/deck_cubit.dart';

class DecksView extends StatelessWidget {
  DecksView({super.key});

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
      builder: (context) => AlertDialog(
        title: Text(l10n.decks_view__show_add_deck_dialog_new_deck),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: l10n.decks_view__show_add_deck_dialog_hint_title,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(l10n.decks_view__show_add_deck_dialog_cancel),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                context.read<DeckCubit>().addDeck(controller.text, null);
                Navigator.pop(context);
              }
            },
            child: Text(l10n.decks_view__show_add_deck_dialog_create),
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
    return material.Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        onTap: () {
          //TODO Переход к карточкам
        },
        onLongPress: () => _showActionMenu(context, item.deck),
        child: material.Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.folder_open, size: 40, color: Colors.blue),
            const SizedBox(height: 8),
            Text(
              item.deck.title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              "Карточек: ${item.cardCount}",
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            //TODO счетчик карты из бд
          ],
        ),
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
      builder: (context) => SafeArea(
        child: material.Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: Text(l10n.deck_card__show_action_menu_edit_title),
              onTap: () {
                Navigator.pop(context);
                 _showEditDialog(context, deck);
                //TODO edit dialog
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: Text(
                l10n.deck_card__show_action_menu_delete_deck,
                style: TextStyle(color: Colors.red),
              ),
              onTap: () {
                context.read<DeckCubit>().deleteDeck(deck.id);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context, Deck deck) {
    final titleController = TextEditingController(text: deck.title);
    final descriptionController = TextEditingController(
      text: deck.description ?? '',
    );
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.decks_view__show_edit_deck_dialog_edit_deck),
        content: material.Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                hintText: l10n.decks_view__show_edit_deck_dialog_hint_title,
                labelText: l10n.decks_view__show_edit_deck_dialog_title_label,
              ),
              autofocus: true,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descriptionController,
              decoration: InputDecoration(
                hintText:
                    l10n.decks_view__show_edit_deck_dialog_hint_description,
                labelText:
                    l10n.decks_view__show_edit_deck_dialog_description_label,
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.decks_view__show_edit_deck_dialog_cancel),
          ),
          ElevatedButton(
            onPressed: () {
              if (titleController.text.trim().isEmpty) {
                return;
              }
              final updatedDeck = Deck(
                id: deck.id,
                title: titleController.text.trim(),
                description: descriptionController.text.trim(),
              );
              context.read<DeckCubit>().updateDeck(updatedDeck);
              Navigator.pop(context);
            },

            child: Text(l10n.decks_view__show_edit_deck_dialog_save),
          ),
        ],
      ),
    );
  }
}
