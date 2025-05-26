import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class Svg extends StatelessWidget {
  final String asset;
  final Color? color;
  final double width;
  final double height;
  const Svg(this.asset,{
    this.color,
    this.width=36.0,
    this.height=36.0,
    super.key,
  });
  @override
  Widget build(BuildContext ctx)=>SvgPicture.asset(
    'assets/$asset.svg',
    width: width,
    height: height,
    colorFilter: color==null?null:ColorFilter.mode(color!,BlendMode.srcIn),
  );
}