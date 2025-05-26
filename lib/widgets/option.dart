import 'package:flutter/material.dart';
import 'div.dart';

class Option extends StatelessWidget {
	final String text;
	final Widget? leading;
	final Widget? trailing;
	final bool isActive;
	final VoidCallback onTap;
	final Color? color;
	final Color? textColor;
	final double textSize;
	final bool isBold;
	final EdgeInsets padding;
	const Option(this.text,this.isActive,this.onTap,{
		this.leading,
		this.trailing,
		this.color,
		this.textColor,
		this.textSize=15.0,
		this.isBold=false,
		this.padding=const EdgeInsets.symmetric(vertical: 5, horizontal:16),
		super.key,
	});
	@override
	Widget build(BuildContext context)=>InkWell(
		onTap: onTap,
		child: Div(
			background: isActive?
				color??Theme.of(context).colorScheme.primary
				:const Color.fromRGBO(140,140,140,1),
			borderRadius: 16,
			padding: padding,
			child: UnconstrainedBox(
				child: Row(
					children: [
						if(leading!=null)Padding(
							padding: const EdgeInsets.only(right:3.6),
							child: leading!,
						),
						Text(
							text,
							style: TextStyle(
								color: isActive?
									textColor??Theme.of(context).colorScheme.onPrimary
									:Colors.white,
								fontWeight: isBold?FontWeight.bold:FontWeight.normal,
								fontSize: textSize,
							),
							overflow: TextOverflow.ellipsis,
							textAlign: TextAlign.start,
						),
						if(trailing!=null)Padding(
							padding: const EdgeInsets.only(left:3.6),
							child: trailing!,
						),
					],
				),
			),
		),
	);
}