import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:memo_lingvo/core/database/app_database.dart' as Db;
import 'package:memo_lingvo/core/localization/l10n/app_localizations.dart';
import 'package:memo_lingvo/features/cards/data/repositories/card_repository.dart';

class EditCardScreen extends StatefulWidget {
  final Db.Card card;
  const EditCardScreen({super.key, required this.card});

  @override
  State<StatefulWidget> createState() => _EditCardScreenState();
}

class _EditCardScreenState extends State<EditCardScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _wordController;
  late TextEditingController _translationController;
  late TextEditingController _transcriptionController;
  late TextEditingController _meaningController;
  final List<TextEditingController> _exampleControllers = [];

  @override
  void initState() {
    super.initState();
    _wordController = TextEditingController(text: widget.card.word);
    _translationController = TextEditingController(
      text: widget.card.translation,
    );
    _transcriptionController = TextEditingController(
      text: widget.card.transcription ?? '',
    );
    _meaningController = TextEditingController(text: widget.card.meaning ?? '');

    if (widget.card.examples != null) {
      for (var example in widget.card.examples!) {
        _exampleControllers.add(TextEditingController(text: example));
      }
    }
  }

  Future<void> _saveChanges() async {
    if (_formKey.currentState!.validate()) {
      final examples = _exampleControllers
          .map((c) => c.text.trim())
          .where((text) => text.isNotEmpty)
          .toList();

      final updateCard = widget.card.copyWith(
        word: _wordController.text.trim(),
        translation: _translationController.text.trim(),
        transcription: Value(
          _transcriptionController.text.trim().isEmpty
              ? null
              : _transcriptionController.text.trim(),
        ),
        meaning: Value(
          _meaningController.text.trim().isEmpty
              ? null
              : _meaningController.text.trim(),
        ),
        examples: Value(examples.isEmpty ? null : examples),
      );

      await context.read<CardRepository>().updateCard(updateCard);

      if (mounted) Navigator.pop(context);
    }
  }

  void _addExampleField() {
    setState(() => _exampleControllers.add(TextEditingController()));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.edit_card_screen__edit),
        actions: [
          IconButton(
            onPressed: _saveChanges, 
            icon: const Icon(Icons.done_all)
          )
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildField(_wordController, l10n.edit_card_screen__word, isRequired: true),
            const SizedBox(height: 12),
            _buildField(_translationController, "Перевод", isRequired: true),
            const SizedBox(height: 12),
            _buildField(_transcriptionController, "Транскрипция"),
            const SizedBox(height: 12),
            _buildField(_meaningController, "Значение", maxLines: 2),
            
            const Divider(height: 32),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(l10n.edit_card_screen__examples, style: TextStyle(fontWeight: FontWeight.bold),),
                TextButton.icon(
                  onPressed: _addExampleField, 
                  icon: const Icon(Icons.add),
                  label: Text(l10n.edit_card_screen__add)
                ),
              ],
            ),

            ..._exampleControllers.asMap().entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: entry.value,
                        decoration: const InputDecoration(border: OutlineInputBorder()),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                      onPressed: () => setState(() => _exampleControllers.removeAt(entry.key)),
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

  Widget _buildField(TextEditingController controller, String label, {bool isRequired = false, int maxLines = 1}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      validator: (val) => (isRequired && (val == null || val.isEmpty)) ? "Обязательно" : null,
    );
  }

  @override
  void dispose() {
    _wordController.dispose();
    _translationController.dispose();
    _transcriptionController.dispose();
    _meaningController.dispose();
    for (var c in _exampleControllers) {
      c.dispose();
    }
    super.dispose();
  }


}
