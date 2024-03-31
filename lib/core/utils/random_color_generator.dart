import 'dart:math';

import 'package:flutter/material.dart';

List<Color> colors = [
  Colors.red,
  Colors.blue,
  Colors.green,
  Colors.purple,
  Colors.pink,
  Colors.brown,
  Colors.teal,
  Colors.indigo,
  Colors.cyan,
  Colors.blueGrey,
  const Color.fromRGBO(187, 63, 221, 1),
  const Color.fromRGBO(251, 109, 169, 1),
  const Color.fromRGBO(255, 159, 124, 1),
  const Color.fromRGBO(52, 51, 67, 1),
];

Color getRandomColor() {
  return colors[Random().nextInt(colors.length)];
}
