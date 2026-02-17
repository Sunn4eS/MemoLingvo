import 'package:equatable/equatable.dart';
import 'package:lingo_cards/features/cards/domain/entites/word_card.dart';


//part of 'cards_bloc.dart';

abstract class CardsEvent extends Equatable {
  const CardsEvent();

  @override
  List<Object> get props => [];
}

class SubscribeToCards extends CardsEvent {}

class _CardsUpdated extends CardsEvent {
  final List<WordCard> cards;

  const _CardsUpdated(this.cards);

  @override
  List<Object> get props => [cards];
}

class AddCardEvent extends CardsEvent {
  final String originalWord;

  const AddCardEvent(this.originalWord);

  @override
  List<Object> get props => [originalWord];
}

class DeleteCardEvent extends CardsEvent {
  final int id;

  const DeleteCardEvent(this.id);

  @override
  List<Object> get props => [id];
}

