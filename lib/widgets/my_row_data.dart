import 'package:flutter/material.dart';
import '../widgets/te.dart';

class MyRowData extends StatelessWidget {
  final dynamic text1;
  final dynamic text2;
  const MyRowData(this.text1,this.text2,{super.key});
  String _getText(dynamic text){
    if(text is String)return text;
    if(text is double)return text.toStringAsFixed(2);
    return text.toString();
  }
  @override
  Widget build(BuildContext context)=>Row(
    children: [
      Te(_getText(text1),bold:true),
      const SizedBox(width:7),
      Expanded(
        child: Align(
          alignment: Alignment.centerLeft,
          child: Te(_getText(text2),align:TextAlign.start),
        ),
      ),
    ],
  );
}