import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:test/domain/entities/todo.dart';
import '../../data/repositories/todo_repository_impl.dart';
import '../../domain/repositories/todo_repository.dart';
import '../../presentation/providers/todo_provider.dart';
import '../../presentation/providers/auth_provider.dart';
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

  // Repositories
  sl.registerLazySingleton<TodoRepository>(
    () => TodoRepositoryImpl(todoBox: sl()),
  );

  // Providers
  sl.registerFactory(
      () => TodoProvider(repository: sl(), authProvider: AuthProvider()));
  sl.registerFactory(() => AuthProvider());
  sl.registerFactory(() => LanguageProvider());
}
