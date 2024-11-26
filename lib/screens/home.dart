import 'dart:async';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lottie/lottie.dart';
import '../widgets/glassmorphic.dart';
import 'analysis.dart';
import 'notification_helper_stub.dart';
import 'task.dart';
import 'add.dart';
import 'details.dart';
import 'notification_helper.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late StreamSubscription<QuerySnapshot> _tasksStream;
  List<Task> tasks = [];
  late bool isMobileApp;
  late bool isWebOnPhone;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadTasks();
    if (!kIsWeb) {
      NotificationHelper.initialize();
    } else {
      NotificationHelper.requestPermission();
    }
  }

  @override
  void dispose() {
    _tasksStream.cancel(); // Cancel the stream when the widget is disposed
    super.dispose();
  }

  Future<void> _loadTasks() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _tasksStream = FirebaseFirestore.instance
          .collection('tasks')
          .where('uid', isEqualTo: user.uid)
          .snapshots()
          .listen((QuerySnapshot snapshot) {
        final loadedTasks = snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return Task(
            data['taskName'] ?? '',
            (data['created_at'] as Timestamp).toDate(),
            (data['dueDateTime'] as Timestamp).toDate(),
            taskDescription: data['taskDescription'] ?? '',
            completed: data['completed'] ?? false,
            documentId: doc.id,
          );
        }).toList();

        setState(() {
          tasks = loadedTasks;
        });

        // Check for tasks nearing their due date and show notifications
        for (final task in tasks) {
          final now = DateTime.now();
          final difference = task.dueDateTime.difference(now).inMinutes;

          if (difference > 0 && difference <= 30) {
            // Show notification for tasks due within the next 30 minutes
            NotificationHelper.showNotification('Task Reminder', 'The task "${task.taskName}" is due soon.');
          }
        }
      });
    }
  }

  void addTask(Task newTask) {
    Task.saveTasks(tasks);
  }

  void showAddTaskDialog(BuildContext context) {
    showDialog<Task>(
      context: context,
      builder: (BuildContext context) {
        return const AddTaskDialog();
      },
    ).then((newTask) {
      if (newTask != null) {
        addTask(newTask);
      }
    });
  }

  void _toggleTaskCompletion(Task task) {
    setState(() {
      task.completed = !task.completed;
    });
    FirebaseFirestore.instance
        .collection('tasks')
        .doc(task.documentId)
        .update({'completed': task.completed});
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushReplacementNamed('/login'); // Navigate to login page
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
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
              'Task Time Tracker',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        backgroundColor: Colors.deepPurple,
        actions: [
          GestureDetector(
            onTap: _logout,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                decoration : BoxDecoration(color: Colors.red ,borderRadius: BorderRadius.circular(3.0), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10, offset: Offset(0, 5))]),
                  child: const Text("Logout", style: TextStyle(color: Colors.white))),
            ),
          ),
        ],
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.deepPurple.shade100, Colors.blue.shade100],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: isMobileApp
            ? _buildMobileView()
            : (isWebOnPhone ? _buildMobileView() : _buildDesktopView()),
      ),
      floatingActionButton: FloatingActionButton(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
        splashColor: Colors.deepPurple,
        onPressed: () => showAddTaskDialog(context),
        backgroundColor: Colors.green,
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: isMobileApp ? _buildBottomNavigationBar() : null,
    );
  }

  Widget _buildMobileView() {
    return _selectedIndex == 0 ? _buildTaskListView() : _buildSummaryView();
  }

  Widget _buildTaskListView() {
    return tasks.isEmpty
        ? Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          Center(
            child: Text(
              'Start adding your tasks\nto be reminded now!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                color: Colors.deepPurple[400],
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    )
        : ListView.builder(
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return TaskCard(
          task: task,
          onToggleComplete: _toggleTaskCompletion,
        );
      },
    );
  }

  Widget _buildSummaryView() {
    return SingleChildScrollView(
      child: Container(
        width: double.infinity,
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
          children: [
            const Text(
              'Task Summary',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 20),
            TaskAnalysisChart(tasks: tasks), // Add the analysis chart
            ...tasks.map((task) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Text(
                task.taskName,
                style: TextStyle(
                  fontSize: 18,
                  color: task.completed ? Colors.green : Colors.red,
                  decoration: task.completed
                      ? TextDecoration.lineThrough
                      : TextDecoration.none,
                ),
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopView() {
    return tasks.isEmpty
        ? Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          Center(child: Lottie.asset('assets/animations/task.json', width: 200, height: 200)),
          const SizedBox(height: 20),
          Text(
            'Start adding your tasks\nto be reminded now!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              color: Colors.deepPurple[400],
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    )
        : Row(
      children: [
        Expanded(
          flex: 2,
          child: ListView.builder(
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];
              return TaskCard(
                task: task,
                onToggleComplete: _toggleTaskCompletion,
              );
            },
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          flex: 1,
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(20.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Task Summary',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple,
                        ),
                      ),
                      const SizedBox(height: 20),
                      TaskAnalysisChart(tasks: tasks), // Add the analysis chart
                      ...tasks.map((task) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Text(
                          task.taskName,
                          style: TextStyle(
                            fontSize: 18,
                            color: task.completed ? Colors.green : Colors.red,
                            decoration: task.completed
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                          ),
                        ),
                      )),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.list),
          label: 'Tasks',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.bar_chart),
          label: 'Summary',
        ),
      ],
      currentIndex: _selectedIndex,
      selectedItemColor: Colors.deepPurple,
      onTap: _onItemTapped,
    );
  }
}

class TaskCard extends StatelessWidget {
  final Task task;
  final ValueChanged<Task> onToggleComplete;

  const TaskCard({Key? key, required this.task, required this.onToggleComplete}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: GlassmorphicContainer(
        child: Row(
          children: [
            Container(
              width: 80,
              height: 80,
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: task.completed
                  ? Lottie.asset('assets/animations/tick.json', width: 50, height: 50)
                  : Lottie.asset('assets/animations/waiting.json', width: 50, height: 50),
            ),
            Expanded(
              child: ListTile(
                title: Row(
                  children: [
                    Expanded(
                      child: Text(
                        task.taskName,
                        style: const TextStyle(color: Colors.deepPurple, fontSize: 25, fontWeight: FontWeight.bold),
                      ).animate().fade(duration: 500.ms).scale(),
                    ),
                    Switch(
                      activeColor: Colors.green,
                      activeTrackColor: Colors.green[100],
                      inactiveThumbColor: Colors.red,
                      inactiveTrackColor: Colors.red[100],
                      value: task.completed,
                      onChanged: (value) {
                        onToggleComplete(task);
                      },
                    ),
                  ],
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.taskDescription,
                      style: const TextStyle(fontSize: 16, color: Colors.black54),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.calendar_month, size: 20, color: CupertinoColors.activeBlue),
                        const SizedBox(width: 4),
                        Text(
                          'Due on:\n${DateFormat('y MMM d, E HH:mm').format(task.dueDateTime)}',
                          style: const TextStyle(fontSize: 14, color: Colors.deepPurple),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.access_time, size: 16, color: Colors.deepOrange),
                        const SizedBox(width: 4),
                        Expanded(
                          child: AutoSizeText(
                            task.getTimeRemainingText(),
                            style: const TextStyle(fontSize: 14, color: Colors.black, fontWeight: FontWeight.bold),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TaskDetailPage(task: task, documentId: task.documentId),
                  ),
                ),
              ).animate().slide(),
            ),
          ],
        ),
      ),
    );
  }
}

class TimeProgressIndicator extends StatefulWidget {
  final DateTime createdAt;
  final DateTime dueDate;

  const TimeProgressIndicator({Key? key, required this.createdAt, required this.dueDate}) : super(key: key);

  @override
  _TimeProgressIndicatorState createState() => _TimeProgressIndicatorState();
}

class _TimeProgressIndicatorState extends State<TimeProgressIndicator> {
  late Timer _timer;
  double _progress = 0;
  Color _progressColor = Colors.green;

  @override
  void initState() {
    super.initState();
    _updateProgress();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateProgress();
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _updateProgress() {
    final now = DateTime.now();
    final totalTime = widget.dueDate.difference(widget.createdAt).inSeconds;
    final elapsedDuration = now.difference(widget.createdAt).inSeconds;
    setState(() {
      _progress = (elapsedDuration / totalTime).clamp(0.0, 1.0);
      _progressColor = now.isAfter(widget.dueDate)
          ? Colors.red
          : (_progress > 0.8 ? Colors.red : (_progress > 0.5 ? Colors.orange : Colors.green));
    });
  }

  @override
  Widget build(BuildContext context) {
    return LinearProgressIndicator(
      value: _progress,
      backgroundColor: Colors.white,
      valueColor: AlwaysStoppedAnimation<Color>(_progressColor),
    );
  }
}
