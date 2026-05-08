import 'package:flutter/material.dart';
import 'package:memo_lingvo/features/games/logic/word_duel_cubit.dart';

class DuelBoard extends StatelessWidget {
  final WordDuelState state;
  final void Function(String letter) onLetterTap;
  final void Function(int index) onRemoveLetter;

  const DuelBoard({
    super.key,
    required this.state,
    required this.onLetterTap,
    required this.onRemoveLetter,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Верхняя панель прогресса (канат)
          _ProgressBar(
            playerProgress: state.playerProgress,
            botProgress: state.botProgress,
            playerScore: state.playerScore,
            botScore: state.botScore,
          ),
          const SizedBox(height: 16),
          // Таймер
          _TimerDisplay(timeLeft: state.timeLeft),
          const SizedBox(height: 12),
          // Подсказка
          Text(
            state.promptWord,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 24),
          // Выбранные буквы
          _SelectedLettersRow(
            letters: state.playerAnswer,
            onTap: onRemoveLetter,
          ),
          const Divider(height: 32, thickness: 2),
          // Доступные буквы
          Expanded(
            child: _ShuffledLettersGrid(
              letters: state.shuffledLetters,
              onTap: onLetterTap,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  final double playerProgress;
  final double botProgress;
  final int playerScore;
  final int botScore;
  const _ProgressBar({
    required this.playerProgress,
    required this.botProgress,
    required this.playerScore,
    required this.botScore,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Вы: $playerScore',
                style: const TextStyle(fontWeight: FontWeight.bold)),
            Text('Бот: $botScore',
                style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Stack(
            children: [
              Container(
                height: 24,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              // Прогресс игрока (слева)
              FractionallySizedBox(
                widthFactor: playerProgress.clamp(0.0, 1.0),
                child: Container(
                  height: 24,
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(10),
                      bottomLeft: Radius.circular(10),
                    ),
                  ),
                ),
              ),
              // Разделитель "каната" (можно точку)
              Center(
                child: Container(
                  height: 32,
                  width: 4,
                  color: Colors.black,
                ),
              ),
              // Прогресс бота (справа) – растёт слева направо
              Align(
                alignment: Alignment.centerRight,
                child: FractionallySizedBox(
                  widthFactor: botProgress.clamp(0.0, 1.0),
                  child: Container(
                    height: 24,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(10),
                        bottomRight: Radius.circular(10),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TimerDisplay extends StatelessWidget {
  final int timeLeft;
  const _TimerDisplay({required this.timeLeft});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.timer, color: timeLeft <= 5 ? Colors.red : Colors.grey),
        const SizedBox(width: 4),
        Text(
          '$timeLeft сек',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: timeLeft <= 5 ? Colors.red : null,
          ),
        ),
      ],
    );
  }
}

class _SelectedLettersRow extends StatelessWidget {
  final List<String> letters;
  final void Function(int) onTap;
  const _SelectedLettersRow({required this.letters, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(letters.length, (i) {
        return GestureDetector(
          onTap: () => onTap(i),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: 36,
            height: 40,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.black26),
            ),
            alignment: Alignment.center,
            child: Text(
              letters[i].toUpperCase(),
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
        );
      }),
    );
  }
}

class _ShuffledLettersGrid extends StatelessWidget {
  final List<String> letters;
  final void Function(String) onTap;
  const _ShuffledLettersGrid({required this.letters, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
      ),
      itemCount: letters.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () => onTap(letters[index]),
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blueAccent, width: 2),
              boxShadow: const [
                BoxShadow(color: Colors.black12, blurRadius: 2)
              ],
            ),
            alignment: Alignment.center,
            child: Text(
              letters[index].toUpperCase(),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
            ),
          ),
        );
      },
    );
  }
}