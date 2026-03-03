import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/notes_repository.dart';
import '../../models/note_model.dart';
import 'notes_event.dart';
import 'notes_state.dart';

class NotesBloc extends Bloc<NotesEvent, NotesState> {
  final NotesRepository notesRepository;
  StreamSubscription? _notesSubscription;
  DocumentSnapshot? _lastDocument;

  NotesBloc({required this.notesRepository}) : super(NotesInitial()) {
    on<NotesFetch>(_onFetch);
    on<NotesFetchMore>(_onFetchMore);
    on<NotesSubscribe>(_onSubscribe);
    on<NotesSearch>(_onSearch);
    on<NotesFilterByStatus>(_onFilterByStatus);
    on<NotesFilterByCategory>(_onFilterByCategory);
    on<NotesClearFilters>(_onClearFilters);
    on<NotesAdd>(_onAdd);
    on<NotesUpdate>(_onUpdate);
    on<NotesDelete>(_onDelete);
  }

  // ─── FETCH (первая загрузка) ───────────────────────────────────
  Future<void> _onFetch(NotesFetch event, Emitter<NotesState> emit) async {
    emit(NotesLoading());
    try {
      final notes = await notesRepository.fetchNotes(event.uid);

      if (notes.isEmpty) {
        emit(NotesEmpty());
        return;
      }

      // Сохраняем последний документ для пагинации
      _lastDocument = await notesRepository.getLastDocument(event.uid);

      emit(NotesLoaded(
        notes: notes,
        hasMore: notes.length == 10,
      ));
    } catch (e) {
      emit(NotesError('Ошибка загрузки: ${e.toString()}'));
    }
  }

  // ─── FETCH MORE (пагинация) ────────────────────────────────────
  Future<void> _onFetchMore(NotesFetchMore event, Emitter<NotesState> emit) async {
    final currentState = state;
    if (currentState is! NotesLoaded) return;
    if (!currentState.hasMore || currentState.isLoadingMore) return;
    if (_lastDocument == null) return;

    emit(currentState.copyWith(isLoadingMore: true));

    try {
      final moreNotes = await notesRepository.fetchMoreNotes(
        event.uid,
        lastDocument: _lastDocument!,
      );

      if (moreNotes.isEmpty) {
        emit(currentState.copyWith(hasMore: false, isLoadingMore: false));
        return;
      }

      // Получаем новый lastDocument
      final allNotes = [...currentState.notes, ...moreNotes];
      _lastDocument = await notesRepository.getLastDocument(
        event.uid,
        limit: allNotes.length,
      );

      emit(currentState.copyWith(
        notes: allNotes,
        hasMore: moreNotes.length == 10,
        isLoadingMore: false,
      ));
    } catch (e) {
      emit(NotesError('Ошибка загрузки: ${e.toString()}'));
    }
  }

  // ─── SUBSCRIBE (realtime) ──────────────────────────────────────
  Future<void> _onSubscribe(NotesSubscribe event, Emitter<NotesState> emit) async {
    emit(NotesLoading());

    await _notesSubscription?.cancel();

    await emit.forEach(
      notesRepository.notesStream(event.uid),
      onData: (List<NoteModel> notes) {
        if (notes.isEmpty) return NotesEmpty();
        return NotesLoaded(notes: notes, hasMore: false);
      },
      onError: (error, _) => NotesError('Ошибка: ${error.toString()}'),
    );
  }

  // ─── SEARCH ────────────────────────────────────────────────────
  Future<void> _onSearch(NotesSearch event, Emitter<NotesState> emit) async {
    emit(NotesLoading());
    try {
      final notes = event.query.isEmpty
          ? await notesRepository.fetchNotes(event.uid)
          : await notesRepository.searchByTitle(event.uid, event.query);

      if (notes.isEmpty) {
        emit(NotesEmpty());
        return;
      }

      emit(NotesLoaded(
        notes: notes,
        hasMore: false,
        searchQuery: event.query,
      ));
    } catch (e) {
      emit(NotesError('Ошибка поиска: ${e.toString()}'));
    }
  }

  // ─── FILTER BY STATUS ──────────────────────────────────────────
  Future<void> _onFilterByStatus(
      NotesFilterByStatus event, Emitter<NotesState> emit) async {
    emit(NotesLoading());
    try {
      final notes = event.status == null
          ? await notesRepository.fetchNotes(event.uid)
          : await notesRepository.filterByStatus(event.uid, event.status!);

      if (notes.isEmpty) {
        emit(NotesEmpty());
        return;
      }

      emit(NotesLoaded(
        notes: notes,
        hasMore: false,
        statusFilter: event.status,
      ));
    } catch (e) {
      emit(NotesError('Ошибка фильтрации: ${e.toString()}'));
    }
  }

  // ─── FILTER BY CATEGORY ────────────────────────────────────────
  Future<void> _onFilterByCategory(
      NotesFilterByCategory event, Emitter<NotesState> emit) async {
    emit(NotesLoading());
    try {
      final notes = event.category == null
          ? await notesRepository.fetchNotes(event.uid)
          : await notesRepository.filterByCategory(event.uid, event.category!);

      if (notes.isEmpty) {
        emit(NotesEmpty());
        return;
      }

      emit(NotesLoaded(
        notes: notes,
        hasMore: false,
        categoryFilter: event.category,
      ));
    } catch (e) {
      emit(NotesError('Ошибка фильтрации: ${e.toString()}'));
    }
  }

  // ─── CLEAR FILTERS ─────────────────────────────────────────────
  Future<void> _onClearFilters(
      NotesClearFilters event, Emitter<NotesState> emit) async {
    add(NotesFetch(event.uid));
  }

  // ─── ADD ───────────────────────────────────────────────────────
  Future<void> _onAdd(NotesAdd event, Emitter<NotesState> emit) async {
    try {
      await notesRepository.addNote(event.uid, event.note);
      emit(NoteOperationSuccess('Заметка добавлена ✅'));
      add(NotesFetch(event.uid));
    } catch (e) {
      emit(NotesError('Ошибка добавления: ${e.toString()}'));
    }
  }

  // ─── UPDATE ────────────────────────────────────────────────────
  Future<void> _onUpdate(NotesUpdate event, Emitter<NotesState> emit) async {
    try {
      await notesRepository.updateNote(event.uid, event.note);
      emit(NoteOperationSuccess('Заметка обновлена ✅'));
      add(NotesFetch(event.uid));
    } catch (e) {
      emit(NotesError('Ошибка обновления: ${e.toString()}'));
    }
  }

  // ─── DELETE ────────────────────────────────────────────────────
  Future<void> _onDelete(NotesDelete event, Emitter<NotesState> emit) async {
    try {
      await notesRepository.deleteNote(event.uid, event.noteId);
      emit(NoteOperationSuccess('Заметка удалена 🗑️'));
      add(NotesFetch(event.uid));
    } catch (e) {
      emit(NotesError('Ошибка удаления: ${e.toString()}'));
    }
  }

  @override
  Future<void> close() {
    _notesSubscription?.cancel();
    return super.close();
  }
}