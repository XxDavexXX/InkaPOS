import 'package:flutter/material.dart';

class P extends StatelessWidget {
	final String text;
	final Color color;
	final double size;
	final bool bold;
	final bool underline;
	final TextAlign? align;
	final String? family;
	final TextOverflow overflow;
  const P(this.text,{
  	this.color=Colors.white,
		this.size=15,
		this.overflow=TextOverflow.ellipsis,
		this.bold=false,
		this.underline=false,
		this.align,
		this.family,
  	super.key
  });
  static const TextAlign center = TextAlign.center;
  static const TextAlign justify = TextAlign.justify;
  static const TextAlign start = TextAlign.start;
  static const TextAlign end = TextAlign.end;
  @override
  Widget build(BuildContext context)=>Text(
  	text,
  	style: TextStyle(
  		color: color,
  		fontSize: size,
  		fontWeight:bold?FontWeight.bold:null,
  		decoration: underline?TextDecoration.underline:TextDecoration.none,
  		fontFamily: family??'Gotham',
  	),
  	textAlign: align,
  	overflow: overflow,
  );
}