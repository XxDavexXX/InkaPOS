import 'package:flutter/material.dart';
import 'div.dart';
import 'p.dart';

class EditableData extends StatelessWidget {
  final String title;
  final dynamic value;
  final VoidCallback edit;
  const EditableData(this.title,this.value,this.edit,{super.key});
  @override
  Widget build(BuildContext context)=>Column(
    children: [
      P(title,color:Colors.black,align:TextAlign.center,bold:true),
      InkWell(
        onTap: edit,
        child: Div(
          width:MediaQuery.of(context).size.width*0.9,
          padding: const EdgeInsets.symmetric(vertical:7,horizontal:16),
          borderRadius: 23,
          background: const Color.fromRGBO(212,212,212,1),
          child: P('$value',color:Colors.black),
        ),
      ),
      const SizedBox(height:12),
    ],
  );
}