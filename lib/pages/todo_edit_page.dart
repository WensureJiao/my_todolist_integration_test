// pages/todo_edit_page.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/todo.dart';

class TodoEditPage extends StatefulWidget {
  final Todo? todo;
  final ValueChanged<Todo> onSave;

  const TodoEditPage({Key? key, this.todo, required this.onSave})
    : super(key: key);

  @override
  State<TodoEditPage> createState() => _TodoEditPageState();
}

class _TodoEditPageState extends State<TodoEditPage> {
  final titleController = TextEditingController();
  final subtitleController = TextEditingController();
  final descriptionController = TextEditingController();
  DateTime? startTime;
  DateTime? endTime;
  TodoStatus status = TodoStatus.waiting;

  @override
  void initState() {
    super.initState();
    if (widget.todo != null) {
      titleController.text = widget.todo!.title;
      subtitleController.text = widget.todo!.subtitle ?? '';
      descriptionController.text = widget.todo!.description ?? '';
      startTime = widget.todo!.startTime;
      endTime = widget.todo!.endTime;
      status = widget.todo!.status;
    }
  }

  Future<void> _pickDateTime(bool isStart) async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(now),
    );
    if (time == null) return;

    final pickedDateTime = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );

    setState(() {
      if (isStart) {
        startTime = pickedDateTime;
        if (endTime != null && endTime!.isBefore(startTime!)) {
          endTime = startTime;
        }
      } else {
        if (startTime != null && pickedDateTime.isBefore(startTime!)) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('End time must be after start time')),
          );
          return;
        }
        endTime = pickedDateTime;
      }
    });
  }

  void _save() {
    if (titleController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Title is required')));
      return;
    }
    final todo = Todo(
      title: titleController.text,
      subtitle: subtitleController.text.isEmpty
          ? null
          : subtitleController.text,
      description: descriptionController.text.isEmpty
          ? null
          : descriptionController.text,
      startTime: startTime,
      endTime: endTime,
      status: status,
    );
    widget.onSave(todo); // 由外部处理 Navigator.pop
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.todo == null ? 'Add TODO' : 'Edit TODO'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Title *'),
            ),
            TextField(
              controller: subtitleController,
              decoration: const InputDecoration(
                labelText: 'Subtitle (optional)',
              ),
            ),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description (optional)',
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Text(
                    startTime == null
                        ? 'No start time'
                        : 'Start: ${DateFormat('yyyy-MM-dd HH:mm').format(startTime!)}',
                  ),
                ),
                ElevatedButton(
                  onPressed: () => _pickDateTime(true),
                  child: const Text('Pick Start'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text(
                    endTime == null
                        ? 'No end time'
                        : 'End: ${DateFormat('yyyy-MM-dd HH:mm').format(endTime!)}',
                  ),
                ),
                ElevatedButton(
                  onPressed: () => _pickDateTime(false),
                  child: const Text('Pick End'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _save, child: const Text('Save')),
          ],
        ),
      ),
    );
  }
}
