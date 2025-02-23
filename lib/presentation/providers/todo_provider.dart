import 'package:flutter/foundation.dart';
import 'package:test/presentation/providers/auth_provider.dart';
import '../../domain/entities/todo.dart';
import '../../domain/repositories/todo_repository.dart';

class TodoProvider with ChangeNotifier {
  final TodoRepository repository;
  final AuthProvider authProvider;

  List<Todo> _todos = [];
  bool _isLoading = false;
  String? _error;

  TodoProvider({required this.authProvider, required this.repository}) {
    loadTodos();
  }

  List<Todo> get todos => _todos;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadTodos() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _todos = await repository.getTodos();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addTodo(String title, String description) async {
    try {
      final userId = authProvider.currentUser?.uid;
      if (userId == null) throw Exception('User not authenticated');

      final todo = Todo(
        userId: userId,
        id: DateTime.now().toString(),
        title: title,
        description: description,
        createdAt: DateTime.now(),
      );
      await repository.addTodo(todo);
      await loadTodos();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateTodo(Todo todo) async {
    try {
      await repository.updateTodo(todo);
      await loadTodos();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> deleteTodo(String id) async {
    try {
      await repository.deleteTodo(id);
      await loadTodos();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> toggleTodoStatus(String id) async {
    try {
      await repository.toggleTodoStatus(id);
      await loadTodos();
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
