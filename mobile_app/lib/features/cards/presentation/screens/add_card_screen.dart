import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:memo_lingvo/core/localization/l10n/app_localizations.dart';
import 'package:memo_lingvo/features/cards/data/repositories/card_repository.dart';

class AddCardScreen extends StatefulWidget {
  final int deckId;
  const AddCardScreen({super.key, required this.deckId});

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

  void addExampleField() {
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

      await context.read<CardRepository>().addCard(
        deckId: widget.deckId,
        word: _wordController.text.trim(),
        translation: _translationController.text.trim(),
        transcription: _transcriptionController.text.trim().isEmpty
            ? null
            : _wordController.text.trim(),
        meaning: _meaningController.text.trim().isEmpty
            ? null
            : _meaningController.text.trim(),
        examples: examples.isEmpty ? null : examples,
      );
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.add_card_screen__new_card),
      )
    );
  }
}
