import 'package:flutter/material.dart';

class Button extends StatelessWidget {
  final Widget text;
  final VoidCallback onTap;
  final Color? color;
  final Color? borderColor;
  final double borderRadius;
  final double borderWidth;
  const Button(this.text,this.onTap,{
    this.color,
    this.borderRadius=7.0,
    this.borderWidth=2.0,
    this.borderColor,
    super.key
  });
  @override
  Widget build(BuildContext ctx)=>ElevatedButton(
    style: ElevatedButton.styleFrom(
      backgroundColor: color??Theme.of(ctx).colorScheme.primary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        side: borderColor==null?BorderSide.none:BorderSide(color:borderColor!,width:borderWidth),
      ),
    ),
    child: text,
    onPressed: onTap,
  );
}