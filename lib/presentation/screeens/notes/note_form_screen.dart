import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../bloc/notes/notes_bloc.dart';
import '../../../bloc/notes/notes_event.dart';
import '../../../bloc/notes/notes_state.dart';
import '../../../models/note_model.dart';

class NoteFormScreen extends StatefulWidget {
  final String uid;
  final NoteModel? note; // null = создание, not null = редактирование

  const NoteFormScreen({super.key, required this.uid, this.note});

  @override
  State<NoteFormScreen> createState() => _NoteFormScreenState();
}

class _NoteFormScreenState extends State<NoteFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _contentCtrl = TextEditingController();

  late NoteStatus _selectedStatus;
  late NoteCategory _selectedCategory;

  bool get _isEditing => widget.note != null;

  @override
  void initState() {
    super.initState();
    // Если редактирование — заполняем поля
    _titleCtrl.text = widget.note?.title ?? '';
    _contentCtrl.text = widget.note?.content ?? '';
    _selectedStatus = widget.note?.status ?? NoteStatus.active;
    _selectedCategory = widget.note?.category ?? NoteCategory.personal;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _contentCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final note = _isEditing
        ? widget.note!.copyWith(
            title: _titleCtrl.text.trim(),
            content: _contentCtrl.text.trim(),
            status: _selectedStatus,
            category: _selectedCategory,
          )
        : NoteModel(
            id: '',
            title: _titleCtrl.text.trim(),
            content: _contentCtrl.text.trim(),
            status: _selectedStatus,
            category: _selectedCategory,
            createdAt: DateTime.now(),
          );

    if (_isEditing) {
      context.read<NotesBloc>().add(NotesUpdate(widget.uid, note));
    } else {
      context.read<NotesBloc>().add(NotesAdd(widget.uid, note));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Редактировать' : 'Новая заметка'),
      ),
      body: BlocListener<NotesBloc, NotesState>(
        listener: (ctx, state) {
          if (state is NoteOperationSuccess) {
            context.pop();
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
        child: BlocBuilder<NotesBloc, NotesState>(
          builder: (ctx, state) {
            final isLoading = state is NotesLoading;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // ── Title ───────────────────────────────────
                    const Text('Заголовок', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _titleCtrl,
                      decoration: InputDecoration(
                        hintText: 'Введите заголовок...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Заголовок обязателен';
                        }
                        if (val.trim().length < 3) {
                          return 'Минимум 3 символа';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 20),

                    // ── Content ─────────────────────────────────
                    const Text('Содержание', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _contentCtrl,
                      maxLines: 5,
                      decoration: InputDecoration(
                        hintText: 'Введите текст заметки...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignLabelWithHint: true,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ── Category ─────────────────────────────────
                    const Text('Категория', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    _CategorySelector(
                      selected: _selectedCategory,
                      onChanged: (cat) => setState(() => _selectedCategory = cat),
                    ),

                    const SizedBox(height: 20),

                    // ── Status ───────────────────────────────────
                    const Text('Статус', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    _StatusSelector(
                      selected: _selectedStatus,
                      onChanged: (status) => setState(() => _selectedStatus = status),
                    ),

                    const SizedBox(height: 32),

                    // ── Submit Button ────────────────────────────
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : Text(
                                _isEditing ? 'Сохранить' : 'Добавить заметку',
                                style: const TextStyle(fontSize: 16),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// ─── Category Selector ────────────────────────────────────────────────────
class _CategorySelector extends StatelessWidget {
  final NoteCategory selected;
  final ValueChanged<NoteCategory> onChanged;

  const _CategorySelector({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      children: NoteCategory.values.map((cat) {
        final isSelected = cat == selected;
        final label = switch (cat) {
          NoteCategory.personal => '👤 Личное',
          NoteCategory.work     => '💼 Работа',
          NoteCategory.study    => '📚 Учёба',
          NoteCategory.other    => '📌 Другое',
        };
        return ChoiceChip(
          label: Text(label),
          selected: isSelected,
          onSelected: (_) => onChanged(cat),
        );
      }).toList(),
    );
  }
}

// ─── Status Selector ──────────────────────────────────────────────────────
class _StatusSelector extends StatelessWidget {
  final NoteStatus selected;
  final ValueChanged<NoteStatus> onChanged;

  const _StatusSelector({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: NoteStatus.values.map((status) {
        final isSelected = status == selected;
        final label = status == NoteStatus.active ? '🔵 Активная' : '✅ Выполнена';
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(label),
              selected: isSelected,
              onSelected: (_) => onChanged(status),
              showCheckmark: false,
            ),
          ),
        );
      }).toList(),
    );
  }
}