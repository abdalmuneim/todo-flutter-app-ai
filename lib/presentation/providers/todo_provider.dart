import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/todo.dart';
import '../../domain/repositories/todo_repository.dart';
import 'auth_provider.dart';

class TodoProvider with ChangeNotifier {
  final TodoRepository repository;
  final AuthProvider authProvider;
  List<Todo> _todos = [];
  String? _error;
  bool _isLoading = false;

  TodoProvider({
    required this.repository,
    required this.authProvider,
  }) {
    _loadTodos();
  }

  List<Todo> get todos => _todos;
  String? get error => _error;
  bool get isLoading => _isLoading;

  Future<void> _loadTodos() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _todos = await repository.getTodos();
      _todos.sort((a, b) {
        // First sort by priority (high to low)
        final priorityCompare = (b.priority?.index ?? 1).compareTo(a.priority?.index ?? 1);
        if (priorityCompare != 0) return priorityCompare;
        
        // Then sort by date (newest to oldest)
        return (b.createdAt ?? DateTime.now()).compareTo(a.createdAt ?? DateTime.now());
      });
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addTodo(
    String title,
    String description, {
    TaskPriority priority = TaskPriority.medium,
  }) async {
    try {
      _error = null;
      final todo = Todo(
        title: title,
        description: description,
        createdAt: DateTime.now(),
        isCompleted: false,
        priority: priority,
        subTasks: [],
      );

      await repository.addTodo(todo);
      await _loadTodos(); // Reload to get the server-generated ID
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> toggleTodoStatus(String id) async {
    try {
      _error = null;
      await repository.toggleTodoStatus(id);
      await _loadTodos(); // Reload to get the updated state
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateTodo(Todo todo) async {
    try {
      _error = null;
      await repository.updateTodo(todo);
      await _loadTodos(); // Reload to get the updated state
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> deleteTodo(String id) async {
    try {
      _error = null;
      await repository.deleteTodo(id);
      await _loadTodos(); // Reload to get the updated state
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  int get completedTasks =>
      _todos.where((todo) => todo.isCompleted ?? false).length;
  int get pendingTasks =>
      _todos.where((todo) => !(todo.isCompleted ?? false)).length;
}
