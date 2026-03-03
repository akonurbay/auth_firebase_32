import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import '../../models/note_model.dart';

abstract class NotesState extends Equatable {
  @override
  List<Object?> get props => [];
}

class NotesInitial extends NotesState {}

class NotesLoading extends NotesState {}

class NotesLoaded extends NotesState {
  final List<NoteModel> notes;
  final bool hasMore;           // есть ли ещё страницы
  final bool isLoadingMore;     // грузим следующую страницу
  final DocumentSnapshot? lastDocument; // для пагинации
  final String searchQuery;
  final NoteStatus? statusFilter;
  final NoteCategory? categoryFilter;

  NotesLoaded({
    required this.notes,
    this.hasMore = false,
    this.isLoadingMore = false,
    this.lastDocument,
    this.searchQuery = '',
    this.statusFilter,
    this.categoryFilter,
  });

  NotesLoaded copyWith({
    List<NoteModel>? notes,
    bool? hasMore,
    bool? isLoadingMore,
    DocumentSnapshot? lastDocument,
    String? searchQuery,
    NoteStatus? statusFilter,
    NoteCategory? categoryFilter,
    bool clearStatusFilter = false,
    bool clearCategoryFilter = false,
  }) {
    return NotesLoaded(
      notes: notes ?? this.notes,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      lastDocument: lastDocument ?? this.lastDocument,
      searchQuery: searchQuery ?? this.searchQuery,
      statusFilter: clearStatusFilter ? null : statusFilter ?? this.statusFilter,
      categoryFilter: clearCategoryFilter ? null : categoryFilter ?? this.categoryFilter,
    );
  }

  @override
  List<Object?> get props => [
        notes,
        hasMore,
        isLoadingMore,
        searchQuery,
        statusFilter,
        categoryFilter,
      ];
}

class NotesEmpty extends NotesState {}

class NotesError extends NotesState {
  final String message;
  NotesError(this.message);
  @override List<Object?> get props => [message];
}

class NoteOperationSuccess extends NotesState {
  final String message;
  NoteOperationSuccess(this.message);
  @override List<Object?> get props => [message];
}