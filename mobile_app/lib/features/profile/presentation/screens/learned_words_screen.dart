import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:memo_lingvo/core/database/app_database.dart' as dba;
import 'package:memo_lingvo/features/profile/data/repositories/profile_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fuzzy/fuzzy.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LearnedWordsScreen extends StatefulWidget {
  const LearnedWordsScreen({super.key});

  @override
  State<LearnedWordsScreen> createState() => _LearnedWordsScreenState();
}

class _LearnedWordsScreenState extends State<LearnedWordsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  List<({dba.Card card, dba.CardProgressData progress})> _allItems = [];
  List<({dba.Card card, dba.CardProgressData progress})> _filteredItems = [];

  @override
  void initState() {
    super.initState();
    _loadLearnedWords();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
        _filterItems();
      });
    });
  }

  Future<void> _loadLearnedWords() async {
    final prefs = await SharedPreferences.getInstance();

    final db = context.read<dba.AppDatabase>();
    final repo = ProfileRepository(db, prefs);

    final user = FirebaseAuth.instance.currentUser;
    if (user == null || user.email == null) return;
    final serverId = await db.getServerUserId(user.email!);
    if (serverId == null) return;

    final stream = repo.watchLearnedCardsWithProgress(serverId);
    stream.listen((items) {
      setState(() {
        _allItems = items;
        _filterItems();
      });
    });
  }

  void _filterItems() {
    if (_searchQuery.trim().isEmpty) {
      setState(() {
        _filteredItems = List.from(_allItems);
      });
    } else {
      final fuse = Fuzzy<({dba.Card card, dba.CardProgressData progress})>(
        _allItems,
        options: FuzzyOptions(
          findAllMatches: true,
          threshold: 0.4,
          keys: [
            WeightedKey(
              name: 'word',
              getter: (item) => item.card.word,
              weight: 1.0,
            ),
            WeightedKey(
              name: 'translation',
              getter: (item) => item.card.translation,
              weight: 0.8,
            ),
            WeightedKey(
              name: 'meaning',
              getter: (item) => item.card.meaning ?? '',
              weight: 0.5,
            ),
          ],
        ),
      );

      final result = fuse.search(_searchQuery);
      setState(() {
        _filteredItems = result.map((r) => r.item).toList();
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Выученные слова'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Поиск слова, перевода или значения...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
          ),
        ),
      ),
      body: _filteredItems.isEmpty
          ? const Center(child: Text('Нет выученных слов'))
          : ListView.builder(
              itemCount: _filteredItems.length,
              itemBuilder: (context, index) {
                final item = _filteredItems[index];
                final card = item.card;
                final progress = item.progress;
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  child: ListTile(
                    title: Text(
                      card.word,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(card.translation),
                        if (card.meaning != null)
                          Text(
                            card.meaning!,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                      ],
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${progress.repetitions} повт.',
                          style: const TextStyle(fontSize: 12),
                        ),
                        Text(
                          'инт: ${progress.interval} дн.',
                          style: const TextStyle(fontSize: 10),
                        ),
                      ],
                    ),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: Text(card.word),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Перевод: ${card.translation}'),
                              if (card.transcription != null)
                                Text('Транскрипция: [${card.transcription}]'),
                              if (card.meaning != null)
                                Text('Значение: ${card.meaning}'),
                              if (card.examples != null &&
                                  card.examples!.isNotEmpty)
                                Text('Примеры: ${card.examples!.join(', ')}'),
                              const Divider(),
                              Text('Повторений: ${progress.repetitions}'),
                              Text('Интервал: ${progress.interval} дней'),
                              Text(
                                'EF: ${progress.easinessFactor.toStringAsFixed(2)}',
                              ),
                            ],
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Закрыть'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
