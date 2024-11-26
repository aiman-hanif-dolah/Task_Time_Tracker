import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:task_time_tracker/media_query_values.dart';

Color getColorForValue(double value, List<double> sortedValues) {
  int count = sortedValues.where((v) => v == value).length;

  if (count >= 2) {
    int firstIndex = sortedValues.indexOf(value);
    int secondIndex = sortedValues.lastIndexOf(value);

    if (firstIndex != secondIndex) {
      // Assign blue to one and green to the other identical value
      if (value == sortedValues[firstIndex]) {
        return Colors.green;
      } else {
        return Colors.blue;
      }
    } else {
      return Colors.green; // If only one identical value, assign green
    }
  } else if (value == sortedValues.last) {
    return Colors.green; // Highest value is green
  } else if (value == sortedValues.first) {
    return Colors.red; // Lowest value is red
  } else {
    int indexOfValue = sortedValues.indexOf(value);
    double previousValue = sortedValues[indexOfValue - 1];
    double nextValue = sortedValues[indexOfValue + 1];
    double middleValue = (previousValue + nextValue) / 2;

    if (value >= middleValue) {
      return Colors.green; // Value greater than or equal to middle value is green
    } else {
      return Colors.orange; // Value less than middle value is orange
    }
  }
}


Widget buildPieChart(Stream<Map<String, String>> stream, String title, Color containerColor) {
  return StreamBuilder<Map<String, String>>(
    stream: stream,
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const CircularProgressIndicator();
      }

      if (snapshot.hasError) {
        return Text('Error: ${snapshot.error}');
      }

      final data = snapshot.data;

      if (data == null || data.isEmpty) {
        return const Text('No data available');
      }

      final List<String> labels = data.keys.toList();
      final List<double> values = data.values.map((value) => double.tryParse(value) ?? 0.0).toList();

      final List<double> sortedValues = List.from(values)..sort(); // Sort the values
      final List<Color> colors = values.map((value) => getColorForValue(value, sortedValues)).toList();

      return SizedBox(
        height: 200,
        child: Container(
          width: context.width * 1,
          height: context.height * 0.1,
          decoration: BoxDecoration(
            color: containerColor,
            borderRadius: BorderRadius.circular(25.0),
          ),
          child: Column(
            children: [
              const SizedBox(height: 14),
              Text(
                title,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: CupertinoColors.white),
              ),
              const SizedBox(height: 8),
              Flexible(
                child: Center(
                  child: PieChart(
                    dataMap: Map.fromEntries(labels.asMap().entries.map((entry) => MapEntry(entry.value, values[entry.key]))),
                    colorList: colors,
                    animationDuration: const Duration(milliseconds: 800),
                    chartLegendSpacing: 10,
                    chartRadius: MediaQuery.of(context).size.width / 3.2,
                    initialAngleInDegree: 0,
                    chartType: ChartType.disc,
                    centerText: '',
                    legendOptions: const LegendOptions(
                      showLegendsInRow: false,
                      legendPosition: LegendPosition.right,
                      showLegends: true,
                      legendTextStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    chartValuesOptions: const ChartValuesOptions(
                      showChartValueBackground: true,
                      showChartValues: true,
                      showChartValuesInPercentage: false,
                      showChartValuesOutside: false,
                      chartValueStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
            ],
          ),
        ),
      );
    },
  );
}

Widget buildPieChartByCategory(Stream<QuerySnapshot> stream, String title, Color containerColor) {
  return StreamBuilder<QuerySnapshot>(
    stream: stream,
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const CircularProgressIndicator();
      }

      if (snapshot.hasError) {
        return Text('Error: ${snapshot.error}');
      }

      final querySnapshot = snapshot.data;

      if (querySnapshot == null || querySnapshot.docs.isEmpty) {
        return const Text('No data available');
      }

      final List<DocumentSnapshot> docs = querySnapshot.docs;

      final List<String> labels = docs.map((doc) => doc['Category_Percentage'] as String).toList();
      final List<String> categoryPercentages = docs.map((doc) => doc['Total'] as String).toList();

      final List<double> totalValues = categoryPercentages.map((total) => double.tryParse(total.replaceAll(',', '')) ?? 0.0).toList();
      final double totalCount = totalValues.fold(0, (sum, value) => sum + value);

      final List<double> percentageValues = totalValues.map((value) => (value / totalCount) * 100).toList();

      final List<Color> colors = [
        Colors.red,
        Colors.orange,
        Colors.green,
      ];

      final Map<String, double> chartData = Map.fromIterables(labels, percentageValues);

      return SizedBox(
        height: 200,
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: context.height * 0.1,
          decoration: BoxDecoration(
            color: containerColor,
            borderRadius: BorderRadius.circular(25.0),
          ),
          child: Column(
            children: [
              const SizedBox(height: 14),
              Text(
                title,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: CupertinoColors.white),
              ),
              const SizedBox(height: 8),
              Flexible(
                child: Center(
                  child: PieChart(
                    dataMap: chartData,
                    colorList: colors,
                    animationDuration: const Duration(milliseconds: 800),
                    chartLegendSpacing: 10,
                    chartRadius: MediaQuery.of(context).size.width / 3.2,
                    initialAngleInDegree: 0,
                    chartType: ChartType.disc,
                    centerText: '',
                    legendOptions: const LegendOptions(
                      showLegendsInRow: false,
                      legendPosition: LegendPosition.right,
                      showLegends: true,
                      legendTextStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    chartValuesOptions: const ChartValuesOptions(
                      showChartValueBackground: true,
                      showChartValues: true,
                      showChartValuesInPercentage: true,
                      showChartValuesOutside: false,
                      chartValueStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
            ],
          ),
        ),
      );
    },
  );
}




