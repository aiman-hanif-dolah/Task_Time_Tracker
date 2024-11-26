import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lottie/lottie.dart';
import 'task.dart';

class TaskDetailPage extends StatefulWidget {
  final Task task;
  final String documentId;

  const TaskDetailPage({super.key, required this.task, required this.documentId});

  @override
  _TaskDetailPageState createState() => _TaskDetailPageState();
}

class _TaskDetailPageState extends State<TaskDetailPage> {
  late DateTime dueDateTime;
  late TextEditingController _taskNameController;
  late TextEditingController _taskDescriptionController;
  late bool isMobileApp;
  late bool isWebOnPhone;

  Timer? _timer;
  String _timeRemaining = '';

  @override
  void initState() {
    super.initState();
    dueDateTime = widget.task.dueDateTime;
    _taskNameController = TextEditingController(text: widget.task.taskName);
    _taskDescriptionController = TextEditingController(text: widget.task.taskDescription);
    _timeRemaining = _calculateTimeRemaining();
    _startTimer();
  }

  @override
  void dispose() {
    _taskNameController.dispose();
    _taskDescriptionController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _timeRemaining = _calculateTimeRemaining();
      });
    });
  }

  String _calculateTimeRemaining() {
    final now = DateTime.now();
    final difference = dueDateTime.difference(now);

    if (difference.isNegative) {
      return 'Task is overdue';
    }

    final hours = difference.inHours;
    final minutes = difference.inMinutes % 60;
    final seconds = difference.inSeconds % 60;

    return '$hours hours, $minutes minutes, $seconds seconds';
  }

  Future<void> _saveChanges() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      widget.task.taskName = _taskNameController.text;
      widget.task.taskDescription = _taskDescriptionController.text;
      widget.task.dueDateTime = dueDateTime;

      final taskDoc = FirebaseFirestore.instance.collection('tasks').doc(widget.documentId);
      await taskDoc.update({
        'taskName': widget.task.taskName,
        'dueDateTime': dueDateTime,
        'taskDescription': widget.task.taskDescription,
      });

      Navigator.pop(context);
    }
  }

  Future<void> _deleteTask() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final taskDoc = FirebaseFirestore.instance.collection('tasks').doc(widget.documentId);
      await taskDoc.delete();

      Navigator.pop(context);
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime currentDate = DateTime.now();
    final DateTime initialDate = dueDateTime.isBefore(currentDate) ? currentDate : dueDateTime;

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: currentDate,
      lastDate: DateTime(2100),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: Colors.deepPurple,
            hintColor: Colors.deepPurple,
            colorScheme: const ColorScheme.light(primary: Colors.deepPurple),
            buttonTheme: const ButtonThemeData(textTheme: ButtonTextTheme.primary),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null && pickedDate != dueDateTime) {
      setState(() {
        dueDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          dueDateTime.hour,
          dueDateTime.minute,
        );
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(dueDateTime),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: Colors.deepPurple,
            hintColor: Colors.deepPurple,
            colorScheme: const ColorScheme.light(primary: Colors.deepPurple),
            buttonTheme: const ButtonThemeData(textTheme: ButtonTextTheme.primary),
          ),
          child: child!,
        );
      },
    );

    if (pickedTime != null) {
      setState(() {
        dueDateTime = DateTime(
          dueDateTime.year,
          dueDateTime.month,
          dueDateTime.day,
          pickedTime.hour,
          pickedTime.minute,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    isMobileApp = defaultTargetPlatform == TargetPlatform.android || defaultTargetPlatform == TargetPlatform.iOS;
    isWebOnPhone = kIsWeb && MediaQuery.of(context).size.width < 600;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text(
              'Edit the Task',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            Lottie.asset('assets/animations/hourglass.json', width: 50, height: 50),
          ],
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.check, color: Colors.white),
            onPressed: _saveChanges,
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.white),
            onPressed: () async {
              final shouldDelete = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  backgroundColor: Colors.white,
                  title: const Text('Delete Task🗑️', style: TextStyle(fontWeight: FontWeight.bold)),
                  content: const Text('Are you sure you want to delete this task?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel', style: TextStyle(color: Colors.red)),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Delete', style: TextStyle(color: Colors.green)),
                    ),
                  ],
                ),
              );
              if (shouldDelete == true) {
                _deleteTask();
              }
            },
          ),
        ],
        backgroundColor: Colors.deepPurple,
      ),
      body: isMobileApp
          ? _buildMobileView()
          : (isWebOnPhone ? _buildMobileView() : _buildDesktopView()),
    );
  }

  Widget _buildMobileView() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.deepPurple.shade100, Colors.blue.shade100],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TextFormField(
            controller: _taskNameController,
            decoration: InputDecoration(
              labelText: 'Task Name',
              labelStyle: const TextStyle(color: Colors.deepPurple),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.deepPurple),
                borderRadius: BorderRadius.circular(10.0),
              ),
              filled: true,
              fillColor: Colors.white.withOpacity(0.6),
            ),
            cursorColor: Colors.deepPurple,
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _taskDescriptionController,
            decoration: InputDecoration(
              labelText: 'Task Description',
              labelStyle: const TextStyle(color: Colors.deepPurple),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.deepPurple),
                borderRadius: BorderRadius.circular(10.0),
              ),
              filled: true,
              fillColor: Colors.white.withOpacity(0.6),
            ),
            cursorColor: Colors.deepPurple,
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              const Icon(Icons.calendar_today, color: Colors.deepPurple),
              const SizedBox(width: 10),
              Text(
                "Due on: ${DateFormat('y MMM d, E HH:mm').format(dueDateTime)}",
                style: const TextStyle(fontSize: 16, color: Colors.deepPurple),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () => _selectDate(context),
            icon: const Icon(Icons.date_range, color: Colors.white),
            label: const Text("Select Due Date"),
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.deepPurple,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
          ),
          const SizedBox(height: 10),
          ElevatedButton.icon(
            onPressed: () => _selectTime(context),
            icon: const Icon(Icons.access_time, color: Colors.white),
            label: const Text("Select Due Time"),
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.deepPurple,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            "Time Remaining:",
            style: TextStyle(fontSize: 16, color: Colors.deepPurple),
          ),
          Text(
            _timeRemaining,
            style: const TextStyle(fontSize: 16, color: Colors.deepPurple),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopView() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.deepPurple.shade100, Colors.blue.shade100],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                TextFormField(
                  controller: _taskNameController,
                  decoration: InputDecoration(
                    labelText: 'Task Name',
                    labelStyle: const TextStyle(color: Colors.deepPurple),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.deepPurple),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.6),
                  ),
                  cursorColor: Colors.deepPurple,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _taskDescriptionController,
                  decoration: InputDecoration(
                    labelText: 'Task Description',
                    labelStyle: const TextStyle(color: Colors.deepPurple),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.deepPurple),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.6),
                  ),
                  cursorColor: Colors.deepPurple,
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    const Icon(Icons.calendar_today, color: Colors.deepPurple),
                    const SizedBox(width: 10),
                    Text(
                      "Due on: ${DateFormat('y MMM d, E HH:mm').format(dueDateTime)}",
                      style: const TextStyle(fontSize: 16, color: Colors.deepPurple),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () => _selectDate(context),
                  icon: const Icon(Icons.date_range, color: Colors.white),
                  label: const Text("Select Due Date"),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.deepPurple,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  onPressed: () => _selectTime(context),
                  icon: const Icon(Icons.access_time, color: Colors.white),
                  label: const Text("Select Due Time"),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.deepPurple,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Time Remaining:",
                  style: TextStyle(fontSize: 16, color: Colors.deepPurple),
                ),
                Text(
                  _timeRemaining,
                  style: const TextStyle(fontSize: 16, color: Colors.deepPurple),
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            flex: 2,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text(
                    "Task Details:",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.deepPurple),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Name: ${widget.task.taskName}",
                    style: const TextStyle(fontSize: 16, color: Colors.deepPurple),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Description: ${widget.task.taskDescription}",
                    style: const TextStyle(fontSize: 16, color: Colors.deepPurple),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Due Date: ${DateFormat('y MMM d, E HH:mm').format(widget.task.dueDateTime)}",
                    style: const TextStyle(fontSize: 16, color: Colors.deepPurple),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Remaining Time:",
                    style: TextStyle(fontSize: 16, color: Colors.deepPurple),
                  ),
                  Text(
                    _timeRemaining,
                    style: const TextStyle(fontSize: 16, color: Colors.deepPurple),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
