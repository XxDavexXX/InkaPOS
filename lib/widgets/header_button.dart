import 'package:flutter/material.dart';
import 'div.dart';
import 'p.dart';

/* Wrap them in:
Wrap(
  alignment: WrapAlignment.spaceEvenly,
  spacing: 4,
  runSpacing: 4,
  children: <HeaderButton>[...]
),
*/

class HeaderButton extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;
  final VoidCallback onTap;
  const HeaderButton(this.icon,this.text,this.color,this.onTap,{super.key});
  static const Color blue = Color.fromRGBO(65,138,249,1);
  static const Color red = Color.fromRGBO(206,0,0,1);
  static const Color green = Color.fromRGBO(32,211,93,1);
  @override
  Widget build(BuildContext context)=>InkWell(
    onTap: onTap,
    child: Div(
      width: 104,
      background: color,
      padding: const EdgeInsets.symmetric(vertical:10,horizontal:0),
      borderRadius: 7,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon,color:Colors.white,size:21),
          P(text,size:12,bold:true),
        ],
      ),
    ),
  );
}