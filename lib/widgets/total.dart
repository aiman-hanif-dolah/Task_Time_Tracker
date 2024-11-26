import 'package:auto_size_text/auto_size_text.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:task_time_tracker/media_query_values.dart';

class TotalWidget extends StatelessWidget {
  final String title;
  final String value;

  const TotalWidget({super.key, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: context.width * 1,
        height: context.height * 1,
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 22.0),
        decoration: BoxDecoration(
          color: CupertinoColors.activeBlue.withOpacity(0.9),
          borderRadius: BorderRadius.circular(25.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: AutoSizeText(
                    title,
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge!
                        .copyWith(
                        color: CupertinoColors.secondarySystemGroupedBackground,
                        fontWeight: FontWeight.bold,
                        fontSize: 20
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.star_outlined,
                      color: CupertinoColors.systemYellow,
                      size: 30.0,
                    ),
                    SizedBox(
                      width: context.width * 0.001,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 40),
            Flexible(
              child: Row(
                children: [
                  SizedBox(
                    width: context.width * 0.001,
                  ),
                  FittedBox(
                    child: Text(
                      value,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8), // Add some spacing between title and bar chart
          ],
        ),
      ),
    );
  }
}

Widget buildTotalWidget<T>(Stream<T> stream, String title) {
  return StreamBuilder<T>(
    stream: stream,
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      }

      if (snapshot.hasError) {
        return Center(child: Text('Error: ${snapshot.error}'));
      }

      final value = snapshot.data;
      if (value is double && value % 1 != 0) {
        final formattedValue = 'RM ${NumberFormat('#,##0.00').format(value)}';
        return TotalWidget(title: title, value: formattedValue);
      } else {
        return TotalWidget(title: title, value: '$value');
      }
    },
  );
}







