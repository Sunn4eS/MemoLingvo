import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:memo_lingvo/core/database/app_database.dart';
import 'package:flutter/material.dart' as material;
import 'package:memo_lingvo/core/localization/l10n/app_localizations.dart';
import 'package:memo_lingvo/features/cards/presentation/screens/add_card_screen.dart';
import 'package:memo_lingvo/features/decks/logic/deck_cubit.dart';
import 'package:memo_lingvo/features/decks/presentation/screens/manage_deck_screen.dart';

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
      child: Stack(
        children: [
          InkWell(
            onTap: () {
              //TODO train screen

              // Navigator.push(
              //   context,
              //   MaterialPageRoute(
              //     builder: (context) => AddCardScreen(deckId: item.deck.id),
              //   ),
              // );
            },

            //onLongPress: () => _showActionMenu(context, item.deck),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
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
      builder: (context) => SafeArea(
        child: material.Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: Text(l10n.deck_card__show_action_menu_edit_title),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context, 
                  MaterialPageRoute(
                    builder: (_) => ManageDeckScreen(deck: deck),
                  ),
                );
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
}
