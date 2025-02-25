import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/todo.dart';
import '../../domain/repositories/todo_repository.dart';

class FirebaseTodoRepositoryImpl implements TodoRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  FirebaseTodoRepositoryImpl({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> get _todosCollection =>
      _firestore.collection('todos');

  @override
  Future<List<Todo>> getTodos() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('User not authenticated');

    final snapshot = await _todosCollection
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id; // Ensure the document ID is included
      return Todo.fromJson(data);
    }).toList();
  }

  @override
  Future<void> addTodo(Todo todo) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('User not authenticated');

    final todoData = todo.toJson();
    todoData['userId'] = userId;
    todoData['createdAt'] = FieldValue.serverTimestamp();

    await _todosCollection.add(todoData);
  }

  @override
  Future<void> updateTodo(Todo todo) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('User not authenticated');
    if (todo.id == null) throw Exception('Todo ID cannot be null');

    final todoDoc = await _todosCollection.doc(todo.id).get();
    if (!todoDoc.exists) throw Exception('Todo not found');
    if (todoDoc.data()?['userId'] != userId) {
      throw Exception('Not authorized to update this todo');
    }

    await _todosCollection.doc(todo.id).update(todo.toJson());
  }

  @override
  Future<void> deleteTodo(String id) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('User not authenticated');

    final todoDoc = await _todosCollection.doc(id).get();
    if (!todoDoc.exists) throw Exception('Todo not found');
    if (todoDoc.data()?['userId'] != userId) {
      throw Exception('Not authorized to delete this todo');
    }

    await _todosCollection.doc(id).delete();
  }

  @override
  Future<void> toggleTodoStatus(String id) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('User not authenticated');

    final todoDoc = await _todosCollection.doc(id).get();
    if (!todoDoc.exists) throw Exception('Todo not found');
    if (todoDoc.data()?['userId'] != userId) {
      throw Exception('Not authorized to update this todo');
    }

    final currentStatus = todoDoc.data()?['isCompleted'] ?? false;
    final dueDate = todoDoc.data()?['dueDate'] ?? Timestamp.now();
    await _todosCollection.doc(id).update({
      'isCompleted': !currentStatus,
      'dueDate': !currentStatus ? dueDate : null
    });
  }
}
