import 'package:flutter/material.dart';
import 'button.dart';

class TwoButtons extends StatelessWidget {
	final Button button1;
	final Button button2;
	const TwoButtons(this.button1,this.button2,{super.key});
	@override
	Widget build(BuildContext context)=>Row(
	  children: [
	    Expanded(child: button1),
	    const SizedBox(width:12),
	    Expanded(child: button2),
	  ],
	);
}