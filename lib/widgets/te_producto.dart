import 'package:flutter/material.dart';
import 'p.dart';

class Teprod extends StatelessWidget {
  final dynamic text;
  final bool bold;
  final TextAlign align;
  final double size;
  const Teprod(
    this.text, {
    this.bold = false,
    this.align = TextAlign.left,
    this.size = 13,
    super.key,
  });
  @override
  Widget build(BuildContext context) {
    late String t;
    if (text is String) {
      t = text;
    } else if (text is double) {
      t = text.toStringAsFixed(2);
    } else {
      t = text.toString();
    }
    return P(
      t,
      bold: bold,
      align: align,
      size: size,
      color: Colors.black,
      overflow: TextOverflow.clip,
    );
  }
}
