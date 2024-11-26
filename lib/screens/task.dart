import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class Task {
  String taskName;
  DateTime createdAt;
  DateTime dueDateTime;
  String taskDescription;
  bool completed;
  String documentId;

  Task(this.taskName, this.createdAt, this.dueDateTime, {this.taskDescription = '', this.completed = false, required this.documentId});

  double getProgress() {
    final totalDuration = dueDateTime.difference(createdAt).inSeconds;
    final elapsedDuration = DateTime.now().difference(createdAt).inSeconds;
    return (elapsedDuration / totalDuration).clamp(0.0, 1.0);
  }

  String getTimeRemainingText() {
    final now = DateTime.now();
    final difference = dueDateTime.difference(now);
    if (difference.isNegative) {
      return "Overdue";
    } else {
      final days = difference.inDays;
      final hours = difference.inHours % 24;
      final minutes = difference.inMinutes % 60;
      return "$days days, $hours hours, $minutes minutes remaining";
    }
  }

  String getTimeRemaining() {
    final now = DateTime.now();
    final duration = dueDateTime.difference(now);
    if (duration.isNegative) {
      return "Time's up!";
    } else {
      return "${duration.inDays} days, ${duration.inHours % 24} hours, ${duration.inMinutes % 60} minutes, ${duration.inSeconds % 60} seconds";
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'taskName': taskName,
      'created_At': createdAt.millisecondsSinceEpoch,
      'dueDateTime': dueDateTime.millisecondsSinceEpoch,
      'taskDescription': taskDescription,
      'completed': completed,
    };
  }

  static Task fromJson(Map<String, dynamic> json, String id) {
    return Task(
      json['taskName'],
      DateTime.fromMillisecondsSinceEpoch(json['created_At']),
      DateTime.fromMillisecondsSinceEpoch(json['dueDateTime']),
      taskDescription: json['taskDescription'],
      completed: json['completed'] ?? false,
      documentId: id,
    );
  }

  static Future<void> saveTasks(List<Task> tasks) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> tasksJson = tasks.map((task) => jsonEncode(task.toJson())).toList();
    await prefs.setStringList('tasks', tasksJson);
  }

  static Future<List<Task>> loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? tasksJson = prefs.getStringList('tasks');
    if (tasksJson != null) {
      return tasksJson.map((taskString) => Task.fromJson(jsonDecode(taskString), '')).toList();
    } else {
      return [];
    }
  }
}
