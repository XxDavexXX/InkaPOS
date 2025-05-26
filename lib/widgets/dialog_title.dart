import 'package:flutter/material.dart';

class DialogTitle extends StatelessWidget {
  final String text;
  const DialogTitle(this.text,{super.key});
  @override
  Widget build(BuildContext context)=>Column(
    children: [
      Text(text,style:TextStyle(color:Theme.of(context).primaryColor,fontSize:19,fontWeight:FontWeight.bold),textAlign:TextAlign.center),
      const SizedBox(height:12),
      Container(width:MediaQuery.of(context).size.width*0.9,height:1,color:Colors.grey),
      const SizedBox(height:12),
    ],
  );
}