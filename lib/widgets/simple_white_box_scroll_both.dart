import 'package:flutter/material.dart';
import '../widgets/div.dart';

class SimpleWhiteBoxScrollBoth extends StatelessWidget {
	final List<Widget> children;
  const SimpleWhiteBoxScrollBoth({required this.children,super.key});
  @override
  Widget build(BuildContext context)=>Expanded(
    child: Div(
      background: Colors.white,
      borderRadius: 23,
      padding: const EdgeInsets.all(12),
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Column(children: children),
        ),
      ),
    ),
  );
}