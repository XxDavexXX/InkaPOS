import 'package:flutter/material.dart';

class SimpleLine extends StatelessWidget {
  final double height;
  final Color color;
  const SimpleLine({this.height=1,this.color=Colors.grey,super.key});
  @override
  Widget build(BuildContext context)=>Column(
    children: [
      const SizedBox(height:12),
      Container(width:MediaQuery.of(context).size.width*0.9,height:height,color:color),
      const SizedBox(height:12),
    ],
  );
}