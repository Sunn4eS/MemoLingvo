import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:memo_lingvo/core/database/app_database.dart';
import 'package:memo_lingvo/core/database/app_database.dart' as app;
import 'package:memo_lingvo/core/localization/l10n/app_localizations.dart';
import 'package:memo_lingvo/features/cards/data/repositories/card_repository.dart';
import 'package:memo_lingvo/features/cards/presentation/screens/add_card_screen.dart';
import 'package:memo_lingvo/features/decks/presentation/widgets/deck_info_section.dart';

class ManageDeckScreen extends StatelessWidget {
  final Deck deck;

  const ManageDeckScreen({super.key, required this.deck});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(deck.title),
        actions: [
          IconButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => AddCardScreen(deckId: deck.id)),
            ),
            icon: const Icon(Icons.add_circle_outline),
          ),
        ],
      ),
      body: Column(
        children: [
          DeckInfoSection(deck: deck),
          const Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              l10n.manage_deck_screen__cards_list_title,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),

          Expanded(
            child: StreamBuilder<List<app.Card>>(
              stream: context.read<CardRepository>().watchCards(deck.id),

              builder: (context, snapshot) {
                snapshot.connectionState == ConnectionState.waiting;

                final cards = snapshot.data ?? [];

                if (cards.isEmpty) {
                  return Center(child: Text(l10n.manage_deck_screen__no_cards));
                }

                return ListView.builder(
                  itemCount: cards.length,
                  itemBuilder: (context, index) {
                    final card = cards[index];
                    return ListTile(
                      title: Text(card.word),
                      subtitle: Text(card.translation),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => AddCardScreen(
                                    deckId: deck.id,
                                    cardToEdit: card,
                                  ),
                                ),
                              );
                            },
                            icon: Icon(Icons.edit, size: 20),
                          ),
                          IconButton(
                            onPressed: () => context
                                .read<CardRepository>()
                                .deleteCard(card.id),
                            icon: const Icon(
                              Icons.delete_outline,
                              color: Colors.red,
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
