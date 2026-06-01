// lib/widgets/add_lesson_dialog.dart
import 'package:flutter/material.dart';
import '../models/lesson_plan.dart';

class AddLessonDialog extends StatefulWidget {
  final Function(LessonPlan) onSave;
  final LessonPlan? lessonToEdit; // If this has data, we are editing!

  const AddLessonDialog({super.key, required this.onSave, this.lessonToEdit});

  @override
  State<AddLessonDialog> createState() => _AddLessonDialogState();
}

class _AddLessonDialogState extends State<AddLessonDialog> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _summaryController = TextEditingController();
  final TextEditingController _linkController = TextEditingController();
  
  String _selectedSubject = 'Math';
  List<String> _attachedLinks = [];
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    // If we are editing, pre-fill all the text boxes with the old data!
    if (widget.lessonToEdit != null) {
      _titleController.text = widget.lessonToEdit!.title;
      _summaryController.text = widget.lessonToEdit!.summary;
      _selectedSubject = widget.lessonToEdit!.subject;
      _attachedLinks = List.from(widget.lessonToEdit!.links);
      _selectedDate = widget.lessonToEdit!.lessonDate;
    }
  }

  void _addLink() {
    if (_linkController.text.isNotEmpty) {
      setState(() {
        _attachedLinks.add(_linkController.text);
        _linkController.clear();
      });
    }
  }

  // Pick a date for the lesson
  Future<void> _pickDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (pickedDate != null) {
      setState(() => _selectedDate = pickedDate);
    }
  }

  void _save() {
    if (_titleController.text.isNotEmpty && _summaryController.text.isNotEmpty) {
      final updatedLesson = LessonPlan(
        id: widget.lessonToEdit?.id, // Keep the old ID if editing!
        title: _titleController.text,
        subject: _selectedSubject,
        summary: _summaryController.text,
        links: List.from(_attachedLinks),
        lessonDate: _selectedDate,
      );
      widget.onSave(updatedLesson);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.lessonToEdit == null ? 'New Prep Note' : 'Edit Prep Note'),
      content: SizedBox(
        width: 500,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: _titleController, decoration: const InputDecoration(labelText: 'Lesson Title', border: OutlineInputBorder())),
              const SizedBox(height: 16),
              
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedSubject,
                      decoration: const InputDecoration(labelText: 'Subject', border: OutlineInputBorder()),
                      items: ['Math', 'Physics'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                      onChanged: (value) => setState(() => _selectedSubject = value!),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // The New Date Picker Button
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _pickDate,
                      icon: const Icon(Icons.calendar_month),
                      label: Text(_selectedDate == null 
                          ? 'Set Date' 
                          : '${_selectedDate!.month}/${_selectedDate!.day}/${_selectedDate!.year}'),
                    ),
                  )
                ],
              ),
              
              const SizedBox(height: 16),
              TextField(controller: _summaryController, maxLines: 4, decoration: const InputDecoration(labelText: 'Notes / Summary', border: OutlineInputBorder())),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _linkController,
                      decoration: const InputDecoration(labelText: 'Attach a Link (URL)', border: OutlineInputBorder()),
                      onSubmitted: (_) => _addLink(),
                    ),
                  ),
                  IconButton(icon: const Icon(Icons.add_circle, color: Colors.teal, size: 32), onPressed: _addLink)
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: _attachedLinks.map((link) => Chip(
                  label: Text(link),
                  onDeleted: () => setState(() => _attachedLinks.remove(link)),
                )).toList(),
              )
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
        ElevatedButton(onPressed: _save, child: const Text('Save Lesson')),
      ],
    );
  }
}