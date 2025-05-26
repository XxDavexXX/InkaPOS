import 'package:flutter/material.dart';

class DefaultBackground extends StatelessWidget {
	final Widget child;
  final bool addPadding;
  const DefaultBackground({required this.child,this.addPadding=false,super.key});
  @override
  Widget build(BuildContext ctx)=>SafeArea(
    child: Container(
      padding: EdgeInsets.all(addPadding?16:0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black,
            Colors.black,
            Colors.black,
            Colors.black,
            Colors.black,
            Colors.black,
            Colors.black,
            Colors.black,
            Colors.black,
            Colors.orange,
          ],
        ),
      ),
      child: child,
    )
  );
}