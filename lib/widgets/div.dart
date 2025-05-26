import 'package:flutter/material.dart';

class Div extends StatelessWidget {
	final Widget child;
	final double? width;
	final double? height;
	final EdgeInsetsGeometry? padding;
	final Color? borderColor;
	final Color shadowColor;
	final double borderRadius;
	final bool shadow;
	final bool circular;
	final Color background;
	final double borderWidth;
  const Div({
  	this.child=const SizedBox(),
  	this.shadowColor=Colors.grey,
  	this.width,
  	this.height,
  	this.padding,
  	this.borderColor,
  	this.borderRadius=0.0,
  	this.borderWidth=2.0,
  	this.shadow=false,
  	this.circular=false,
  	this.background=Colors.transparent,
  	super.key,
  });
  @override
  Widget build(BuildContext ctx) {
    return Container(
    	padding:padding,
    	width:width,
			height:height,
    	decoration: BoxDecoration(
    		color: background,
			  boxShadow: shadow?[
			    BoxShadow(
			      color: shadowColor,
			      blurRadius: 10,
			      spreadRadius: 2,
			      offset: const Offset(2,2),
			    ),
			  ]:null,
			  shape:circular?BoxShape.circle:BoxShape.rectangle,
			  borderRadius:circular?null:BorderRadius.circular(borderRadius),
			  border: borderColor==null?null:Border.all(color:borderColor!,width:borderWidth),
			),
    	child: child,
    );
  }
}