import 'package:freezed_annotation/freezed_annotation.dart';

part 'word_model.freezed.dart';
part 'word_model.g.dart';

@freezed
sealed class WordModel with _$WordModel {
  const factory WordModel({
    int? id,
    required int deckId,
    required String word,
    required String translation,
    String? meaning,
    String? transcription,
    List<String>? examples,
    required List<String> themes,
}) = _WordModel;

  factory WordModel.fromJson(Map<String, dynamic> json) => _$WordModelFromJson(json);
}