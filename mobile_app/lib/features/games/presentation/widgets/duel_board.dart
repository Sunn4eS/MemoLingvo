import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:memo_lingvo/features/games/logic/word_duel_cubit.dart';

class DuelBoard extends StatelessWidget {
  final WordDuelState state;
  const DuelBoard({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: LinearProgressIndicator(
                  value: state.round / state.totalRounds,
                  backgroundColor: Colors.grey.shade300,
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
                  minHeight: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text('${state.totalTimeLeft} сек',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Счёт: ${state.playerScore}'),
              Text('Раунд ${state.round + 1}/${state.totalRounds}'),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            state.promptWord,
            style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 8,
            children: List.generate(state.playerAnswer.length, (index) {
              return GestureDetector(
                onTap: () => context.read<WordDuelCubit>().removeLetter(index),
                child: Chip(
                  label: Text(state.playerAnswer[index],
                      style: const TextStyle(fontSize: 24)),
                  backgroundColor: Colors.green.shade100,
                  deleteIcon: const Icon(Icons.close, size: 18),
                ),
              );
            }),
          ),
          const Divider(height: 32),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: state.shuffledLetters.map((letter) {
              return GestureDetector(
                onTap: () => context.read<WordDuelCubit>().addLetter(letter),
                child: Container(
                  width: 48,
                  height: 48,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue),
                  ),
                  child: Text(
                    letter,
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
              );
            }).toList(),
          ),
          const Spacer(),
          ElevatedButton.icon(
            onPressed: () => context.read<WordDuelCubit>().skipRound(),
            icon: const Icon(Icons.skip_next),
            label: const Text('Пропустить'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
            ),
          ),
        ],
      ),
    );
  }
}