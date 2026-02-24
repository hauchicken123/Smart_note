import 'package:flutter/material.dart';

class TodoItemWidget extends StatelessWidget {
  final String id;
  final String text;
  final bool done;
  final TimeOfDay? time;
  final ValueChanged<bool?> onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const TodoItemWidget({
    super.key,
    required this.id,
    required this.text,
    required this.done,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
    this.time,
  });

  String _formatTime(TimeOfDay? t) {
    if (t == null) return '';
    final h = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    final period = t.period == DayPeriod.am ? 'AM' : 'PM';
    final min = t.minute.toString().padLeft(2, '0');
    return '$h:$min $period';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      opacity: done ? 0.65 : 1.0,
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
          leading: Checkbox(value: done, onChanged: onToggle),
          title: Text(
            text,
            style: theme.textTheme.titleMedium?.copyWith(
              decoration: done ? TextDecoration.lineThrough : null,
              color: done ? Colors.grey : null,
              fontSize: 16,
            ),
          ),
          subtitle: time != null ? Text(_formatTime(time), style: theme.textTheme.bodySmall) : null,
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                tooltip: 'Sửa',
                icon: Icon(Icons.edit, color: theme.colorScheme.primary),
                onPressed: onEdit,
              ),
              IconButton(
                tooltip: 'Xóa',
                icon: Icon(Icons.delete_outline, color: Colors.redAccent),
                onPressed: onDelete,
              ),
            ],
          ),
          onTap: onEdit,
        ),
      ),
    );
  }
}
