import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../bloc/notes/notes_bloc.dart';
import '../../../bloc/notes/notes_event.dart';
import '../../../bloc/notes/notes_state.dart';
import '../../../models/note_model.dart';

class NotesScreen extends StatefulWidget {
  final String uid;
  const NotesScreen({super.key, required this.uid});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  final _searchCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    context.read<NotesBloc>().add(NotesSubscribe(widget.uid));

    // Пагинация при скролле вниз
    _scrollCtrl.addListener(() {
      if (_scrollCtrl.position.pixels >= _scrollCtrl.position.maxScrollExtent - 200) {
        context.read<NotesBloc>().add(NotesFetchMore(widget.uid));
      }
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Мои заметки'),
        actions: [
          // Фильтр по статусу
          PopupMenuButton<NoteStatus?>(
            icon: const Icon(Icons.filter_list),
            onSelected: (status) {
              context.read<NotesBloc>().add(NotesFilterByStatus(widget.uid, status));
            },
            itemBuilder: (_) => [
              const PopupMenuItem(value: null, child: Text('Все')),
              const PopupMenuItem(value: NoteStatus.active, child: Text('Активные')),
              const PopupMenuItem(value: NoteStatus.done, child: Text('Выполненные')),
            ],
          ),
          // Фильтр по категории
          PopupMenuButton<NoteCategory?>(
            icon: const Icon(Icons.category),
            onSelected: (category) {
              context.read<NotesBloc>().add(NotesFilterByCategory(widget.uid, category));
            },
            itemBuilder: (_) => [
              const PopupMenuItem(value: null, child: Text('Все категории')),
              const PopupMenuItem(value: NoteCategory.personal, child: Text('Личное')),
              const PopupMenuItem(value: NoteCategory.work, child: Text('Работа')),
              const PopupMenuItem(value: NoteCategory.study, child: Text('Учёба')),
              const PopupMenuItem(value: NoteCategory.other, child: Text('Другое')),
            ],
          ),
        ],
      ),

      body: Column(
        children: [
          // ── Поиск ──────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: 'Поиск по заметкам...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchCtrl.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchCtrl.clear();
                          context.read<NotesBloc>().add(NotesClearFilters(widget.uid));
                        },
                      )
                    : null,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onChanged: (query) {
                context.read<NotesBloc>().add(NotesSearch(widget.uid, query));
              },
            ),
          ),

          // ── Список ─────────────────────────────────────────────
          Expanded(
            child: BlocConsumer<NotesBloc, NotesState>(
              listener: (ctx, state) {
                if (state is NoteOperationSuccess) {
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
                if (state is NotesError) {
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              builder: (ctx, state) {
                if (state is NotesLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is NotesEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.note_alt_outlined, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text('Заметок пока нет', style: TextStyle(color: Colors.grey)),
                        SizedBox(height: 8),
                        Text('Нажмите + чтобы добавить',
                            style: TextStyle(color: Colors.grey, fontSize: 12)),
                      ],
                    ),
                  );
                }

                if (state is NotesError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 64, color: Colors.red),
                        const SizedBox(height: 16),
                        Text(state.message),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => context
                              .read<NotesBloc>()
                              .add(NotesFetch(widget.uid)),
                          child: const Text('Повторить'),
                        ),
                      ],
                    ),
                  );
                }

                if (state is NotesLoaded) {
                  return ListView.builder(
                    controller: _scrollCtrl,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: state.notes.length + (state.hasMore ? 1 : 0),
                    itemBuilder: (ctx, index) {
                      // Индикатор загрузки следующей страницы
                      if (index == state.notes.length) {
                        return const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }

                      final note = state.notes[index];
                      return _NoteCard(
                        note: note,
                        uid: widget.uid,
                        onEdit: () => context.push(
                          '/notes/edit',
                          extra: {'uid': widget.uid, 'note': note},
                        ),
                        onDelete: () => _confirmDelete(context, note),
                        onToggleStatus: () {
                          final updated = note.copyWith(
                            status: note.status == NoteStatus.active
                                ? NoteStatus.done
                                : NoteStatus.active,
                          );
                          context.read<NotesBloc>().add(NotesUpdate(widget.uid, updated));
                        },
                      );
                    },
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(
          '/notes/edit',
          extra: {'uid': widget.uid, 'note': null},
        ),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _confirmDelete(BuildContext context, NoteModel note) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Удалить заметку?'),
        content: Text(note.title),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<NotesBloc>().add(NotesDelete(widget.uid, note.id));
            },
            child: const Text('Удалить', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

// ─── Note Card Widget ──────────────────────────────────────────────────────
class _NoteCard extends StatelessWidget {
  final NoteModel note;
  final String uid;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onToggleStatus;

  const _NoteCard({
    required this.note,
    required this.uid,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleStatus,
  });

  Color get _categoryColor {
    switch (note.category) {
      case NoteCategory.personal: return Colors.purple;
      case NoteCategory.work:     return Colors.blue;
      case NoteCategory.study:    return Colors.orange;
      case NoteCategory.other:    return Colors.grey;
    }
  }

  String get _categoryLabel {
    switch (note.category) {
      case NoteCategory.personal: return 'Личное';
      case NoteCategory.work:     return 'Работа';
      case NoteCategory.study:    return 'Учёба';
      case NoteCategory.other:    return 'Другое';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDone = note.status == NoteStatus.done;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),

        // Чекбокс статуса
        leading: IconButton(
          icon: Icon(
            isDone ? Icons.check_circle : Icons.radio_button_unchecked,
            color: isDone ? Colors.green : Colors.grey,
            size: 28,
          ),
          onPressed: onToggleStatus,
        ),

        title: Text(
          note.title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            decoration: isDone ? TextDecoration.lineThrough : null,
            color: isDone ? Colors.grey : null,
          ),
        ),

        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (note.content.isNotEmpty)
              Text(
                note.content,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 13),
              ),
            const SizedBox(height: 6),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: _categoryColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: _categoryColor.withOpacity(0.4)),
                  ),
                  child: Text(
                    _categoryLabel,
                    style: TextStyle(fontSize: 11, color: _categoryColor),
                  ),
                ),
              ],
            ),
          ],
        ),

        // Edit / Delete
        trailing: PopupMenuButton(
          itemBuilder: (_) => [
            const PopupMenuItem(value: 'edit', child: Text('✏️ Редактировать')),
            const PopupMenuItem(value: 'delete', child: Text('🗑️ Удалить')),
          ],
          onSelected: (value) {
            if (value == 'edit') onEdit();
            if (value == 'delete') onDelete();
          },
        ),
      ),
    );
  }
}