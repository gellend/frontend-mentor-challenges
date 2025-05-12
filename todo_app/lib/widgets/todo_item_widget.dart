import 'package:flutter/material.dart';
import 'package:todo_app/models/todo_model.dart';
// import 'package:todo_app/services/todo_service.dart'; // May not be needed directly here if events are bubbled up

class TodoItemWidget extends StatelessWidget {
  final Todo todo;
  final Function(bool?) onStatusChanged; // Callback for checkbox change
  final Function() onDelete; // Callback for delete action

  const TodoItemWidget({
    super.key,
    required this.todo,
    required this.onStatusChanged,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Checkbox(
          value: todo.isCompleted,
          onChanged: onStatusChanged,
          activeColor: theme.colorScheme.primary,
        ),
        title: Text(
          todo.text,
          style: theme.textTheme.bodyLarge?.copyWith(
            decoration: todo.isCompleted
                ? TextDecoration.lineThrough
                : TextDecoration.none,
            color: todo.isCompleted
                ? theme.textTheme.bodyLarge?.color?.withOpacity(0.6)
                : theme.textTheme.bodyLarge?.color,
          ),
        ),
        trailing: IconButton(
          icon: Icon(Icons.delete_outline, color: theme.colorScheme.error),
          onPressed: onDelete,
          tooltip: 'Delete Todo',
        ),
        // onTap: () => onStatusChanged(!todo.isCompleted), // Alternative way to toggle status
      ),
    );
  }
} 