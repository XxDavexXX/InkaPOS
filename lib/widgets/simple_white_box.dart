import 'package:flutter/material.dart';
import '../widgets/div.dart';

class SimpleWhiteBox extends StatelessWidget {
	final List<Widget> children;
  final EdgeInsets? padding;
  const SimpleWhiteBox({required this.children,this.padding=const EdgeInsets.all(16),super.key});
  @override
  Widget build(BuildContext context)=>Expanded(
    child: Div(
      background: Colors.white,
      borderRadius: 23,
      padding: padding,
      child: ListView(children: children),
    ),
  );
}