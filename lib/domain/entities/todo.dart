import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';
part 'todo.g.dart';

// @HiveType(typeId: 3)
enum TaskPriority { high, medium, low }

@HiveType(typeId: 1)
class SubTask extends Equatable {
  final String? id;
  final String? title;
  final bool? isCompleted;

  const SubTask({
    this.id,
    this.title,
    this.isCompleted = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'isCompleted': isCompleted,
      };

  factory SubTask.fromJson(Map<String, dynamic> json) => SubTask(
        id: json['id'] as String,
        title: json['title'] as String,
        isCompleted: json['isCompleted'] as bool,
      );

  SubTask copyWith({
    String? title,
    bool? isCompleted,
  }) {
    return SubTask(
      id: id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  @override
  List<Object?> get props => [id, title, isCompleted];
}

@HiveType(typeId: 0)
class Todo extends Equatable {
  @HiveField(0)
  final String? id;

  @HiveField(1)
  final String? userId;

  @HiveField(2)
  final String? title;

  @HiveField(3)
  final String? description;

  @HiveField(4)
  final bool? isCompleted;

  @HiveField(5)
  final DateTime? createdAt;

  @HiveField(6)
  final TaskPriority? priority;

  @HiveField(7)
  final List<SubTask>? subTasks;

  @HiveField(8)
  final DateTime? dueDate;

  @HiveField(9)
  final DateTime? startDate;

  const Todo({
    this.id,
    this.userId,
    this.title,
    this.description,
    this.isCompleted = false,
    this.createdAt,
    this.priority = TaskPriority.medium,
    this.subTasks = const [],
    this.dueDate,
    this.startDate,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'title': title,
        'description': description,
        'isCompleted': isCompleted,
        'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
        'priority': priority?.index,
        'subTasks': subTasks?.map((st) => st.toJson()).toList(),
        'dueDate': dueDate != null ? Timestamp.fromDate(dueDate!) : null,
        'startDate': startDate != null ? Timestamp.fromDate(startDate!) : null,
      };

  factory Todo.fromJson(Map<String, dynamic> json) => Todo(
        id: json['id'] as String?,
        userId: json['userId'] as String?,
        title: json['title'] as String?,
        description: json['description'] as String?,
        isCompleted: json['isCompleted'] as bool?,
        createdAt: json['createdAt'] != null
            ? (json['createdAt'] as Timestamp).toDate()
            : null,
        priority: json['priority'] != null
            ? TaskPriority.values[json['priority'] as int]
            : null,
        subTasks: json['subTasks'] != null
            ? (json['subTasks'] as List)
                .map((st) => SubTask.fromJson(st as Map<String, dynamic>))
                .toList()
            : null,
        dueDate: json['dueDate'] != null
            ? (json['dueDate'] as Timestamp).toDate()
            : null,
        startDate: json['startDate'] != null
            ? (json['startDate'] as Timestamp).toDate()
            : null,
      );

  Todo copyWith({
    String? title,
    String? description,
    bool? isCompleted,
    TaskPriority? priority,
    List<SubTask>? subTasks,
    DateTime? dueDate,
    DateTime? startDate,
  }) {
    return Todo(
      id: id,
      userId: userId,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt,
      priority: priority ?? this.priority,
      subTasks: subTasks ?? this.subTasks,
      dueDate: dueDate ?? this.dueDate,
      startDate: startDate ?? this.startDate,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        title,
        description,
        isCompleted,
        createdAt,
        priority,
        subTasks,
        dueDate,
        startDate,
      ];
}
