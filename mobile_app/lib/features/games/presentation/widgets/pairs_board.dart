import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:memo_lingvo/features/games/logic/sprint_pairs_cubit.dart';

class PairsBoard extends StatelessWidget {
  final SprintPairsState state;
  const PairsBoard({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<SprintPairsCubit>();
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        children: [
          // Прогресс-бары и таймер
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    LinearProgressIndicator(
                      value: state.playerProgress,
                      backgroundColor: Colors.grey.shade300,
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
                      minHeight: 14,
                    ),
                    const Text('Вы'),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  children: [
                    LinearProgressIndicator(
                      value: state.botProgress,
                      backgroundColor: Colors.grey.shade300,
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.red),
                      minHeight: 14,
                    ),
                    const Text('Бот'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text('Осталось: ${state.timeLeft} сек', style: const TextStyle(fontSize: 18)),
          const SizedBox(height: 16),
          Expanded(
            child: Row(
              children: [
                // Левая колонка
                Expanded(
                  child: ListView(
                    children: state.leftColumn.map((word) {
                      final isSelected = state.selectedLeft == word;
                      return GestureDetector(
                        onTap: () => cubit.selectLeft(word),
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.green.shade100 : Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: isSelected ? Border.all(color: Colors.green, width: 2) : null,
                          ),
                          child: Text(
                            word,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(width: 16),
                // Правая колонка
                Expanded(
                  child: ListView(
                    children: state.rightColumn.map((translation) {
                      final isSelected = state.selectedRight == translation;
                      return GestureDetector(
                        onTap: () => cubit.selectRight(translation),
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.green.shade100 : Colors.orange.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: isSelected ? Border.all(color: Colors.green, width: 2) : null,
                          ),
                          child: Text(
                            translation,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      );
                    }).toList(),
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