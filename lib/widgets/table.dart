import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'colors.dart';

Widget buildDataTableWidget(Stream<Map<String, String>> stream, String title) {
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

      final List<Color> colors = List.generate(data.length, (index) => getRandomColor(index));

      return Padding(
        padding: const EdgeInsets.all(20.0),
        child: SizedBox(
          height: 300,
          child: Container(
            width: MediaQuery.of(context).size.width * 1,
            height: MediaQuery.of(context).size.height * 0.1,
            decoration: BoxDecoration(
              color: green,
              borderRadius: BorderRadius.circular(25.0),
            ),
            child: Column(
              children: [
                const SizedBox(height: 14), // Add some spacing between title and pie chart
                Text(
                  title,
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: CupertinoColors.white),
                ),
                const SizedBox(height: 8), // Add some spacing between title and pie chart
                Flexible(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('Labels', style: TextStyle(fontSize: 24, color: CupertinoColors.white))),
                        DataColumn(label: Text('Values', style: TextStyle(fontSize: 24, color: CupertinoColors.white))),
                      ],
                      rows: labels.asMap().entries.map((entry) {
                        final label = entry.value;
                        final value = values[entry.key];
                        final color = colors[entry.key];

                        return DataRow(cells: [
                          DataCell(
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(label, style: const TextStyle(color: Colors.white),),
                            ),
                          ),
                          DataCell(
                            Container(
                              width: 50, // Set a fixed width to limit the cell's width
                              decoration: BoxDecoration(
                                color: color,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: const EdgeInsets.all(8),
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text('RM ${value.toStringAsFixed(2)}'),
                              ),
                            ),
                          ),
                        ]);
                      }).toList(),
                    ),
                  ),
                ),
                const SizedBox(height: 32), // Add some spacing between title and bar chart
              ],
            ),
          ),
        ),
      );
    },
  );
}

Color getRandomColor(int index) {
  final random = Random();

  // Generate random RGB values between 0 and 255
  final r = random.nextInt(256);
  final g = random.nextInt(256);
  final b = random.nextInt(256);

  // Create the color using the generated RGB values
  return Color.fromARGB(255, r, g, b);
}
