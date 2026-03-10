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
      body: BlocBuilder<DeckCubit, List<Deck>>(
        builder: (context, decks) {
          if (decks.isEmpty) {
            return Center(child: Text(l10n.decks_view_no_decks));
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: decks.length,
            itemBuilder: (context, index) {
              final deck = decks[index];
              return _DeckCard(deck: deck);
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
  final Deck deck;
  const _DeckCard({required this.deck});

  @override
  Widget build(BuildContext context) {
    return material.Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        onTap: () {
          //TODO Переход к карточкам
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.folder_open, size: 40, color: Colors.blue),
            const SizedBox(height: 8),
            Text(
              deck.title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            //TODO счетчик карты из бд
          ],
        ),
      ),
    );
  }
}
