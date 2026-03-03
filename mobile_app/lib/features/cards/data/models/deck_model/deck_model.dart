import 'package:freezed_annotation/freezed_annotation.dart';

part 'deck_model.g.dart';
part 'deck_model.freezed.dart';

@freezed
sealed class DeckModel with _$DeckModel {
  const factory DeckModel({
    int? id,
    required String title,
    String? description,
    @Default(0xFF9E9E9E) int color,
  }) = _DeckModel;

  factory DeckModel.fromJson(Map<String, dynamic> json) =>
      _$DeckModelFromJson(json);
}
