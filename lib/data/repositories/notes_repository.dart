import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_32/models/note_model.dart';
  
class NotesRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Путь к коллекции конкретного пользователя
  CollectionReference _notesRef(String uid) =>
      _firestore.collection('users').doc(uid).collection('notes');

  // ─── REALTIME STREAM ───────────────────────────────────────────
  Stream<List<NoteModel>> notesStream(String uid) {
    return _notesRef(uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => NoteModel.fromFirestore(d)).toList());
  }

  // ─── PAGINATION (первая страница) ──────────────────────────────
  Future<List<NoteModel>> fetchNotes(String uid, {int limit = 10}) async {
    final snap = await _notesRef(uid)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .get();
    return snap.docs.map((d) => NoteModel.fromFirestore(d)).toList();
  }

  // ─── PAGINATION (следующая страница) ───────────────────────────
  Future<List<NoteModel>> fetchMoreNotes(
    String uid, {
    required DocumentSnapshot lastDocument,
    int limit = 10,
  }) async {
    final snap = await _notesRef(uid)
        .orderBy('createdAt', descending: true)
        .startAfterDocument(lastDocument)
        .limit(limit)
        .get();
    return snap.docs.map((d) => NoteModel.fromFirestore(d)).toList();
  }

  // Получить raw DocumentSnapshot для пагинации
  Future<DocumentSnapshot?> getLastDocument(String uid, {int limit = 10}) async {
    final snap = await _notesRef(uid)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .get();
    if (snap.docs.isEmpty) return null;
    return snap.docs.last;
  }

  // ─── SEARCH ────────────────────────────────────────────────────
  Future<List<NoteModel>> searchByTitle(String uid, String query) async {
    // Firestore prefix search trick
    final snap = await _notesRef(uid)
        .orderBy('title')
        .startAt([query])
        .endAt(['$query\uf8ff'])
        .get();
    return snap.docs.map((d) => NoteModel.fromFirestore(d)).toList();
  }

  // ─── FILTER по статусу ─────────────────────────────────────────
  Future<List<NoteModel>> filterByStatus(String uid, NoteStatus status) async {
    final snap = await _notesRef(uid)
        .where('status', isEqualTo: status.name)
        .orderBy('createdAt', descending: true)
        .get();
    return snap.docs.map((d) => NoteModel.fromFirestore(d)).toList();
  }

  // ─── FILTER по категории ───────────────────────────────────────
  Future<List<NoteModel>> filterByCategory(String uid, NoteCategory category) async {
    final snap = await _notesRef(uid)
        .where('category', isEqualTo: category.name)
        .orderBy('createdAt', descending: true)
        .get();
    return snap.docs.map((d) => NoteModel.fromFirestore(d)).toList();
  }

  // ─── CREATE ────────────────────────────────────────────────────
  Future<void> addNote(String uid, NoteModel note) async {
    await _notesRef(uid).add(note.toFirestore());
  }

  // ─── UPDATE ────────────────────────────────────────────────────
  Future<void> updateNote(String uid, NoteModel note) async {
    await _notesRef(uid).doc(note.id).update(note.toFirestore());
  }

  // ─── DELETE ────────────────────────────────────────────────────
  Future<void> deleteNote(String uid, String noteId) async {
    await _notesRef(uid).doc(noteId).delete();
  }
}