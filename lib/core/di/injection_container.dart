import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';
import 'package:test/domain/entities/todo.dart';
import '../../data/repositories/todo_repository_impl.dart';
import '../../domain/repositories/todo_repository.dart';
import '../../presentation/providers/todo_provider.dart';
import '../../presentation/providers/auth_provider.dart';
import '../../presentation/providers/language_provider.dart';

final GetIt sl = GetIt.instance;

Future<void> init() async {
  // Providers
  sl.registerFactory(
      () => TodoProvider(repository: sl(), authProvider: AuthProvider()));
  sl.registerFactory(() => AuthProvider());
  sl.registerFactory(() => LanguageProvider());

  // Repositories
  sl.registerLazySingleton<TodoRepository>(
    () => TodoRepositoryImpl(todoBox: sl()),
  );

  // External
  final todoBox = await Hive.openBox<Todo>('todos');
  sl.registerLazySingleton(() => todoBox);
}
