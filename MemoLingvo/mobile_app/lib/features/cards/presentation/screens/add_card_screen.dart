import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:memo_lingvo/core/localization/l10n/app_localizations.dart';
import 'package:memo_lingvo/features/cards/data/repositories/card_repository.dart';
import 'package:memo_lingvo/core/database/app_database.dart' as db; // <-- Добавили импорт БД

class AddCardScreen extends StatefulWidget {
  final String deckId;
  final db.Card? cardToEdit; // <-- Добавили параметр (если null - создаем новую)

  const AddCardScreen({super.key, required this.deckId, this.cardToEdit});

  @override
  State<AddCardScreen> createState() => _AddCardScreenState();
}

class _AddCardScreenState extends State<AddCardScreen> {
  final _formKey = GlobalKey<FormState>();

  final _wordController = TextEditingController();
  final _translationController = TextEditingController();
  final _transcriptionController = TextEditingController();
  final _meaningController = TextEditingController();
  final List<TextEditingController> _examplecontrollers = [];

  // Добавляем заполнение полей при старте экрана
  @override
  void initState() {
    super.initState();
    if (widget.cardToEdit != null) {
      _wordController.text = widget.cardToEdit!.word;
      _translationController.text = widget.cardToEdit!.translation;
      _transcriptionController.text = widget.cardToEdit!.transcription ?? '';
      _meaningController.text = widget.cardToEdit!.meaning;

      if (widget.cardToEdit!.examples != null) {
        for (var example in widget.cardToEdit!.examples!) {
          _examplecontrollers.add(TextEditingController(text: example));
        }
      }
    }
  }

  void _addExampleField() {
    setState(() {
      _examplecontrollers.add(TextEditingController());
    });
  }

  void _removeExampleField(int index) {
    setState(() {
      _examplecontrollers[index].dispose();
      _examplecontrollers.removeAt(index);
    });
  }

  @override
  void dispose() {
    _wordController.dispose();
    _transcriptionController.dispose();
    _translationController.dispose();
    _meaningController.dispose();

    for (var i in _examplecontrollers) {
      i.dispose();
    }
    super.dispose();
  }

 Future<void> _saveCard() async {
    if (_formKey.currentState!.validate()) {
      final examples = _examplecontrollers
          .map((i) => i.text.trim())
          .where((text) => text.isNotEmpty)
          .toList();

      final rep = context.read<CardRepository>();
      final transcription = _transcriptionController.text.trim().isEmpty ? null : _transcriptionController.text.trim();

      // Если мы редактируем карточку
      if (widget.cardToEdit != null) {
        await rep.updateCard(
          id: widget.cardToEdit!.id,
          word: _wordController.text.trim(),
          translation: _translationController.text.trim(),
          transcription: transcription,
          meaning: _meaningController.text.trim(),
          examples: examples.isEmpty ? null : examples,
        );
      } else {
        // Если создаем новую
        await rep.addCard(
          deckId: widget.deckId,
          word: _wordController.text.trim(),
          translation: _translationController.text.trim(),
          transcription: transcription,
          meaning: _meaningController.text.trim(),
          examples: examples.isEmpty ? null : examples,
        );
      }

      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.add_card_screen__new_card),
        actions: [
          IconButton(onPressed: _saveCard, icon: const Icon(Icons.check)),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildTextField(
              _wordController,
              l10n.add_card_screen__word,
              isRequired: true,
            ),
            const SizedBox(height: 12),
            _buildTextField(
              _translationController,
              l10n.add_card_screen__translation,
              isRequired: true,
            ),
            const SizedBox(height: 12),
            _buildTextField(
              _transcriptionController,
              l10n.add_card_screen__transcription,
            ),
            const SizedBox(height: 12),
            _buildTextField(
              _meaningController,
              l10n.add_card_screen__meaning,
              maxLines: 2,
              //isRequired: true,
            ),

            const Divider(height: 40),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.add_card_screen__examples,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                TextButton.icon(
                  onPressed: _addExampleField,
                  icon: const Icon(Icons.add),
                  label: Text(l10n.add_card_screen__add_example),
                ),
              ],
            ),

            ..._examplecontrollers.asMap().entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: entry.value,
                        decoration: InputDecoration(
                          hintText: l10n.add_card_screen__add_example_hint,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)
                          ),
                        ),
                      ),
                  
                    ),
                    IconButton(
                      onPressed: () => _removeExampleField(entry.key), 
                      icon: const Icon(Icons.delete_outline, color: Colors.red,),
                    ),
                  ],
                ),
              );            
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    bool isRequired = false,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      validator: (value) {
        if (isRequired && (value == null || value.trim().isEmpty)) {
          return AppLocalizations.of(context)!.add_card_screen__required_field;
        }
        return null;
      },
    );
  }
}
