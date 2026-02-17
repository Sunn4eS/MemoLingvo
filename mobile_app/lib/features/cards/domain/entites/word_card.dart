import 'package:equatable/equatable.dart';

class WordCard extends Equatable {
  final int? id;
  final String original;
  final String translated;
  final String? example;

  WordCard({this.id, required this.original, required this.translated, this.example});

  @override
  List<Object?> get props => [id, original, translated, example];
}