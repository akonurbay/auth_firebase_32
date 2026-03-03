import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

enum NoteStatus { active, done }
enum NoteCategory { personal, work, study, other }

class NoteModel extends Equatable {
  final String id;
  final String title;
  final String content;
  final NoteStatus status;
  final NoteCategory category;
  final DateTime createdAt;

  const NoteModel({
    required this.id,
    required this.title,
    required this.content,
    required this.status,
    required this.category,
    required this.createdAt,
  });

  // Firestore → NoteModel
  factory NoteModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return NoteModel(
      id: doc.id,
      title: data['title'] ?? '',
      content: data['content'] ?? '',
      status: NoteStatus.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => NoteStatus.active,
      ),
      category: NoteCategory.values.firstWhere(
        (e) => e.name == data['category'],
        orElse: () => NoteCategory.other,
      ),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  // NoteModel → Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'content': content,
      'status': status.name,
      'category': category.name,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  // Копия с изменениями
  NoteModel copyWith({
    String? id,
    String? title,
    String? content,
    NoteStatus? status,
    NoteCategory? category,
    DateTime? createdAt,
  }) {
    return NoteModel(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      status: status ?? this.status,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [id, title, content, status, category, createdAt];
}