import 'package:equatable/equatable.dart';
import '../../models/note_model.dart';

abstract class NotesEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

// Загрузить первые 10 заметок
class NotesFetch extends NotesEvent {
  final String uid;
  NotesFetch(this.uid);
  @override List<Object?> get props => [uid];
}

// Загрузить следующие 10 (пагинация)
class NotesFetchMore extends NotesEvent {
  final String uid;
  NotesFetchMore(this.uid);
  @override List<Object?> get props => [uid];
}

// Realtime stream подписка
class NotesSubscribe extends NotesEvent {
  final String uid;
  NotesSubscribe(this.uid);
  @override List<Object?> get props => [uid];
}

// Поиск по title
class NotesSearch extends NotesEvent {
  final String uid;
  final String query;
  NotesSearch(this.uid, this.query);
  @override List<Object?> get props => [uid, query];
}

// Фильтр по статусу
class NotesFilterByStatus extends NotesEvent {
  final String uid;
  final NoteStatus? status; // null = показать все
  NotesFilterByStatus(this.uid, this.status);
  @override List<Object?> get props => [uid, status];
}

// Фильтр по категории
class NotesFilterByCategory extends NotesEvent {
  final String uid;
  final NoteCategory? category; // null = показать все
  NotesFilterByCategory(this.uid, this.category);
  @override List<Object?> get props => [uid, category];
}

// Сбросить фильтры
class NotesClearFilters extends NotesEvent {
  final String uid;
  NotesClearFilters(this.uid);
  @override List<Object?> get props => [uid];
}

// Добавить заметку
class NotesAdd extends NotesEvent {
  final String uid;
  final NoteModel note;
  NotesAdd(this.uid, this.note);
  @override List<Object?> get props => [uid, note];
}

// Редактировать заметку
class NotesUpdate extends NotesEvent {
  final String uid;
  final NoteModel note;
  NotesUpdate(this.uid, this.note);
  @override List<Object?> get props => [uid, note];
}

// Удалить заметку
class NotesDelete extends NotesEvent {
  final String uid;
  final String noteId;
  NotesDelete(this.uid, this.noteId);
  @override List<Object?> get props => [uid, noteId];
}