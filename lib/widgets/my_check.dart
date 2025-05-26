import 'package:flutter/material.dart';

class MyCheck extends StatelessWidget {
	final String text;
	final bool checked;
	final VoidCallback onTap;
	const MyCheck(this.text,this.checked,this.onTap,{super.key});
	@override
	Widget build(BuildContext context)=>Padding(
		padding: const EdgeInsets.only(bottom:10),
		child: InkWell(
			onTap: onTap,
			child: Row(
				children: [
					Icon(
						checked?Icons.check_box:Icons.check_box_outline_blank,
						color: Theme.of(context).primaryColor
					),
					const SizedBox(width: 7),
					Expanded(
						child: Text(text,style:TextStyle(fontSize:15),textAlign:TextAlign.left),
					),
				],
			),
		),
	);
}