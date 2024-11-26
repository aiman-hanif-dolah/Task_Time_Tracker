import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

const Color primaryColor = Color(0xFF5A3CD0);
const Color background = CupertinoColors.white;
const Color secondaryColor = CupertinoColors.white;
const Color blue = CupertinoColors.activeBlue;
const Color red = CupertinoColors.destructiveRed;
const Color green = CupertinoColors.systemGreen;
const Color yellow = CupertinoColors.systemYellow;
const Color pink = CupertinoColors.systemPink;
const Color grey = CupertinoColors.systemGrey;
const Color indigo = CupertinoColors.systemIndigo;
const Color deepPurple = Colors.deepPurple;
const Color orange = CupertinoColors.activeOrange;
const Color mint = CupertinoColors.systemTeal;
Color randomColor = getRandomColor();

Color getRandomColor() {
  final Random random = Random();
  return Color.fromRGBO(
    random.nextInt(256), // Red value (0-255)
    random.nextInt(256), // Green value (0-255)
    random.nextInt(256), // Blue value (0-255)
    1.0, // Alpha (1.0 for fully opaque)
  );
}