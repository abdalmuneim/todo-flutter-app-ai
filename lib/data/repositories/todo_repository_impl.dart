import 'package:hive/hive.dart';
import '../../domain/entities/todo.dart';
import '../../domain/repositories/todo_repository.dart';

class TodoRepositoryImpl implements TodoRepository {
  final Box<Todo> todoBox;

  TodoRepositoryImpl({required this.todoBox});

  @override
  Future<List<Todo>> getTodos() async {
    return todoBox.values.toList();
  }

  @override
  Future<void> addTodo(Todo todo) async {
    await todoBox.put(todo.id, todo);
  }

  @override
  Future<void> updateTodo(Todo todo) async {
    await todoBox.put(todo.id, todo);
  }

  @override
  Future<void> deleteTodo(String id) async {
    await todoBox.delete(id);
  }

  @override
  Future<void> toggleTodoStatus(String id) async {
    final todo = todoBox.get(id);
    if (todo != null) {
      final updatedTodo =
          todo.copyWith(isCompleted: !(todo.isCompleted ?? false));
      await todoBox.put(id, updatedTodo);
    }
  }
}
