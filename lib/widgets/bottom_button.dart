import 'package:flutter/material.dart';
import 'div.dart';

class BottomButton extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onTap;
  const BottomButton(this.icon,this.text,this.onTap,{super.key});
  @override
  Widget build(BuildContext context)=>Column(
    children: [
      InkWell(
        onTap: onTap,
        child: Div(
          circular: true,
          background: Theme.of(context).primaryColor,
          width: 55,
          height: 55,
          child: Icon(icon,size:32),
        ),
      ),
      const SizedBox(height:5),
      Text(text,style:const TextStyle(color:Colors.white,fontSize:12,fontWeight:FontWeight.bold),textAlign:TextAlign.center),
    ],
  );
}