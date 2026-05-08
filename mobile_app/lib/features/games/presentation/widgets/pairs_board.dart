import 'package:flutter/material.dart';
import 'package:memo_lingvo/features/games/logic/sprint_pairs_cubit.dart';

class PairsBoard extends StatelessWidget {
  final SprintPairsState state;
  final void Function(String id) onSelectLeft;
  final void Function(String id) onSelectRight;

  const PairsBoard({
    super.key,
    required this.state,
    required this.onSelectLeft,
    required this.onSelectRight,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Информационная панель
          _InfoPanel(state: state),
          const SizedBox(height: 16),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _PairColumn(
                    items: state.leftItems,
                    title: 'Слово',
                    selectedId: state.selectedLeftId,
                    onTap: onSelectLeft,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _PairColumn(
                    items: state.rightItems,
                    title: 'Перевод',
                    selectedId: state.selectedRightId,
                    onTap: onSelectRight,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoPanel extends StatelessWidget {
  final SprintPairsState state;
  const _InfoPanel({required this.state});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Column(
            children: [
              const Text('Вы', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('${state.playerScore}'),
            ],
          ),
          Column(
            children: [
              const Text('Бот', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('${state.botScore}'),
            ],
          ),
          Column(
            children: [
              const Text('Пары'),
              Text('${state.pairedCount}/${state.totalPairs}'),
            ],
          ),
          Column(
            children: [
              const Text('Время'),
              Text('${state.timeLeft}с'),
            ],
          ),
          Column(
            children: [
              const Text('Ошибки'),
              Text('${state.mistakes}'),
            ],
          ),
        ],
      ),
    );
  }
}

class _PairColumn extends StatelessWidget {
  final List<PairItem> items;
  final String title;
  final String? selectedId;
  final void Function(String) onTap;

  const _PairColumn({
    required this.items,
    required this.title,
    required this.selectedId,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              final isSelected = item.id == selectedId;
              final isMatched = item.matched;

              return GestureDetector(
                onTap: isMatched ? null : () => onTap(item.id),
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 2),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isMatched
                        ? Colors.green.shade100
                        : isSelected
                            ? Colors.blue.shade100
                            : Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isMatched
                          ? Colors.green
                          : isSelected
                              ? Colors.blue
                              : Colors.grey.shade400,
                      width: 1.5,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      item.text,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        decoration: isMatched ? TextDecoration.lineThrough : null,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}