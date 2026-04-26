import 'package:flutter/material.dart';
import 'package:flutter/material.dart' as material;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:drift/drift.dart' as drift; // ДОБАВИЛИ ИМПОРТ DRIFT
import 'package:memo_lingvo/core/database/app_database.dart';
import 'package:memo_lingvo/core/localization/l10n/app_localizations.dart';
import 'package:memo_lingvo/features/decks/logic/deck_cubit.dart';

class DeckInfoSection extends StatelessWidget {
  final Deck deck;
  const DeckInfoSection({required this.deck});

  @override
  Widget build(BuildContext context) {
    return material.Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    deck.title,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
                IconButton(
                  onPressed: () => _showEditDialog(context, deck), 
                  icon: const Icon(Icons.edit),
                ),
              ],
            ),
            if (deck.description != null && deck.description!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                deck.description!,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
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
                hintText: l10n.decks_view__show_edit_deck_dialog_hint_description,
                labelText: l10n.decks_view__show_edit_deck_dialog_description_label,
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
              
              // ИСПРАВЛЕНИЕ: Берем ТЕКУЩУЮ колоду и обновляем в ней поля
              final updatedDeck = deck.copyWith(
                title: titleController.text.trim(),
                description: drift.Value(
                  descriptionController.text.trim().isEmpty 
                      ? null 
                      : descriptionController.text.trim()
                ),
                isDirty: true,
                updateAt: DateTime.now().toUtc(),
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