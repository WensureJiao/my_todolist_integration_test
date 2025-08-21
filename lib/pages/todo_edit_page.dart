import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/todo.dart';

class TodoEditPage extends StatelessWidget {
  final Todo? todo;
  final ValueChanged<Todo> onSave;

  const TodoEditPage({Key? key, this.todo, required this.onSave})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final titleController = TextEditingController(text: todo?.title ?? '');
    final subtitleController = TextEditingController(
      text: todo?.subtitle ?? '',
    );
    final descriptionController = TextEditingController(
      text: todo?.description ?? '',
    );
    DateTime? startTime = todo?.startTime;
    DateTime? endTime = todo?.endTime;
    TodoStatus status = todo?.status ?? TodoStatus.waiting;

    Future<void> pickDateTime(bool isStart) async {
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
    }

    void save() {
      if (titleController.text.isEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Title is required')));
        return;
      }
      final newTodo = Todo(
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
      onSave(newTodo);
    }

    return Scaffold(
      appBar: AppBar(title: Text(todo == null ? 'Add TODO' : 'Edit TODO')),
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
                  onPressed: () => pickDateTime(true),
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
                  onPressed: () => pickDateTime(false),
                  child: const Text('Pick End'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: save, child: const Text('Save')),
          ],
        ),
      ),
    );
  }
}
