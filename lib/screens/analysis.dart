import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'task.dart'; // Import your Task model

class TaskAnalysisChart extends StatelessWidget {
  final List<Task> tasks;

  const TaskAnalysisChart({Key? key, required this.tasks}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Task Completion Analysis',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 300,
              child: PieChart(
                PieChartData(
                  sections: _createData(),
                  borderData: FlBorderData(show: false),
                  sectionsSpace: 0,
                  centerSpaceRadius: 40,
                  pieTouchData: PieTouchData(
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<PieChartSectionData> _createData() {
    final completedTasks = tasks.where((task) => task.completed).length;
    final nonCompletedTasks = tasks.length - completedTasks;

    return [
      PieChartSectionData(
        color: Colors.green,
        value: completedTasks.toDouble(),
        title: '$completedTasks',
        radius: 50,
        titleStyle: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      PieChartSectionData(
        color: Colors.red,
        value: nonCompletedTasks.toDouble(),
        title: '$nonCompletedTasks',
        radius: 50,
        titleStyle: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    ];
  }
}
