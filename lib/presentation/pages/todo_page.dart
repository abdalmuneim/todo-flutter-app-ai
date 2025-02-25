import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import '../providers/todo_provider.dart';
import '../widgets/todo_item.dart';
import '../../core/services/notification_service.dart';
import '../../domain/entities/todo.dart';

class TodoPage extends StatelessWidget {
  const TodoPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Tasks'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: theme.colorScheme.surface,
        foregroundColor: theme.colorScheme.onSurface,
      ),
      body: Consumer<TodoProvider>(
        builder: (context, todoProvider, child) {
          if (todoProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (todoProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 48,
                    color: theme.colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Oops! Something went wrong',
                    style: theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    todoProvider.error!,
                    style: theme.textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          } else if (todoProvider.todos.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.task_outlined,
                    size: 64,
                    color: theme.colorScheme.primary.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No tasks yet',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.8),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add your first task by tapping the + button',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          // Group todos by priority
          final groupedTodos = <TaskPriority, List<Todo>>{};
          for (final priority in TaskPriority.values) {
            groupedTodos[priority] = todoProvider.todos
                .where((todo) => todo.priority == priority)
                .toList();
          }

          return CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.only(top: 8),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final priority = TaskPriority.values[index];
                      final todos = groupedTodos[priority] ?? [];
                      if (todos.isEmpty) return const SizedBox.shrink();

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.flag,
                                  size: 20,
                                  color: priority == TaskPriority.high
                                      ? Colors.red
                                      : priority == TaskPriority.medium
                                          ? Colors.orange
                                          : Colors.green,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '${priority.name[0].toUpperCase()}${priority.name.substring(1)} Priority',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    color: theme.colorScheme.onSurface
                                        .withValues(alpha: .8),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.primary
                                        .withValues(alpha: .1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    '${todos.length}',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.primary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          ...todos.map((todo) => TodoItem(todo: todo)),
                        ],
                      );
                    },
                    childCount: TaskPriority.values.length,
                  ),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddTodoDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Add Task'),
      ),
    );
  }

  void _showAddTodoDialog(BuildContext context) {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    DateTime? selectedStartDate;
    TimeOfDay? selectedStartTime; 
    TaskPriority selectedPriority = TaskPriority.medium;
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('New Task', style: theme.textTheme.titleLarge),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                ),
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                ),
                maxLines: 3,
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 16),
              StatefulBuilder(
                builder: (context, setState) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Priority',
                      style: theme.textTheme.titleSmall,
                    ),
                    const SizedBox(height: 8),
                    SegmentedButton<TaskPriority>(
                      segments: [
                        ButtonSegment<TaskPriority>(
                          value: TaskPriority.low,
                          icon: Icon(
                            Icons.flag,
                            color: Colors.green,
                          ),
                          label: Text('Low'),
                        ),
                        ButtonSegment<TaskPriority>(
                          value: TaskPriority.medium,
                          icon: Icon(
                            Icons.flag,
                            color: Colors.orange,
                          ),
                          label: Text('Medium'),
                        ),
                        ButtonSegment<TaskPriority>(
                          value: TaskPriority.high,
                          icon: Icon(
                            Icons.flag,
                            color: Colors.red,
                          ),
                          label: Text('High'),
                        ),
                      ],
                      selected: {selectedPriority},
                      onSelectionChanged: (Set<TaskPriority> selected) {
                        setState(() => selectedPriority = selected.first);
                      },
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Start Date & Time',
                      style: theme.textTheme.titleSmall,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              final date = await DatePicker.showDatePicker(
                                context,
                                currentTime: selectedStartDate ?? DateTime.now(),
                                minTime: DateTime.now(),
                                maxTime: DateTime.now().add(
                                  const Duration(days: 365),
                                ),
                              );
                              if (date != null) {
                                setState(() => selectedStartDate = date);
                              }
                            },
                            icon: const Icon(Icons.calendar_today),
                            label: Text(
                              selectedStartDate != null
                                  ? '${selectedStartDate!.day}/${selectedStartDate!.month}/${selectedStartDate!.year}'
                                  : 'Start Date',
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              final time = await showTimePicker(
                                context: context,
                                initialTime: selectedStartTime ??
                                    TimeOfDay.fromDateTime(DateTime.now()),
                              );
                              if (time != null) {
                                setState(() => selectedStartTime = time);
                              }
                            },
                            icon: const Icon(Icons.access_time),
                            label: Text(
                              selectedStartTime != null
                                  ? selectedStartTime!.format(context)
                                  : 'Start Time',
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel',
                style: TextStyle(color: theme.colorScheme.secondary)),
          ),
          FilledButton(
            onPressed: () {
              if (titleController.text.isNotEmpty &&
                  selectedStartDate != null &&
                  selectedStartTime != null) {
                final startDate = DateTime(
                  selectedStartDate!.year,
                  selectedStartDate!.month,
                  selectedStartDate!.day,
                  selectedStartTime!.hour,
                  selectedStartTime!.minute,
                );

                context.read<TodoProvider>().addTodo(
                      titleController.text,
                      descriptionController.text,
                      startDate: startDate,
                      priority: selectedPriority,
                    );

                // Schedule notification
                NotificationService().scheduleTaskNotification(
                  id: (DateTime.now().millisecondsSinceEpoch % 100000).toInt(),
                  title: 'Upcoming Task: ${titleController.text}',
                  body: 'Your task starts in 10 minutes',
                  scheduledDate: startDate,
                );

                Navigator.pop(context);
              }
            },
            child: const Text('Add Task'),
          ),
        ],
      ),
    );
  }
}
