import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:test/domain/entities/todo.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../data/repositories/firebase_todo_repository_impl.dart';
import '../../domain/repositories/todo_repository.dart';
import '../../presentation/providers/todo_provider.dart';
import '../../presentation/providers/auth_provider.dart'as authPro;
import '../../presentation/providers/language_provider.dart';

final GetIt sl = GetIt.instance;
Future<void> init() async {
  // Initialize Hive first
  await Hive.initFlutter();
  Hive.registerAdapter(TodoAdapter());
  Hive.registerAdapter(SubTaskAdapter());

  // Then open the box
  final todoBox = await Hive.openBox<Todo>('todos');

  // Register dependencies
  sl.registerLazySingleton(() => todoBox);

  // External
  sl.registerLazySingleton(() => FirebaseFirestore.instance);
  sl.registerLazySingleton(() => FirebaseAuth.instance);

  // Repositories
  sl.registerLazySingleton<TodoRepository>(
    () => FirebaseTodoRepositoryImpl(
      firestore: sl(),
      auth: sl(),
    ),
  );

  // Providers
  sl.registerFactory(
      () => TodoProvider(repository: sl(), authProvider: authPro.AuthProvider()));
  sl.registerFactory(() => authPro.AuthProvider());
  sl.registerFactory(() => LanguageProvider());
}
