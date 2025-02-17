import 'package:flow_state/models/task_model.dart';
import 'package:flow_state/services/database_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum TaskStatus { all, completed, pending }

// Task Repository
final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  return TaskRepository();
});

class TaskRepository {
  Future<List<Task>> getTasks({TaskStatus filter = TaskStatus.all}) async {
    final db = DatabaseService.database;
    String where = '';
    List<dynamic> whereArgs = [];

    if (filter == TaskStatus.completed) {
      where = 'isCompleted = ?';
      whereArgs = [1]; // 1 represents completed tasks
    } else if (filter == TaskStatus.pending) {
      where = 'isCompleted = ?';
      whereArgs = [0]; // 0 represents pending tasks
    }

    final List<Map<String, dynamic>> maps = await db.query(
      'tasks',
      where: where.isNotEmpty ? where : null,
      whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
    );

    return List.generate(maps.length, (i) {
      return Task.fromMap(maps[i]);
    });
  }

  Future<void> addTask(Task task) async {
    final db = DatabaseService.database;
    await db.insert('tasks', task.toMap());
  }

  Future<void> updateTask(Task task) async {
    final db = DatabaseService.database;
    await db.update(
      'tasks',
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  Future<void> deleteTask(int id) async {
    final db = DatabaseService.database;
    await db.delete(
      'tasks',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}

// Task Provider
final taskListProvider =
    StateNotifierProvider<TaskListNotifier, List<Task>>((ref) {
  return TaskListNotifier(ref.read(taskRepositoryProvider));
});

class TaskListNotifier extends StateNotifier<List<Task>> {
  final TaskRepository _taskRepository;
  TaskStatus _taskStatus = TaskStatus.all; // Default filter is all tasks.

  TaskListNotifier(this._taskRepository) : super([]) {
    loadTasks();
  }

  // Load tasks based on the filter
  Future<void> loadTasks() async {
    state = await _taskRepository.getTasks(filter: _taskStatus);
  }

  // Change the filter and reload tasks
  void setFilter(TaskStatus status) {
    _taskStatus = status;
    loadTasks();
  }

  Future<void> addTask(Task task) async {
    await _taskRepository.addTask(task);
    loadTasks();
  }

  Future<void> updateTask(Task task) async {
    await _taskRepository.updateTask(task);
    loadTasks();
  }

  Future<void> deleteTask(int id) async {
    await _taskRepository.deleteTask(id);
    loadTasks();
  }
}