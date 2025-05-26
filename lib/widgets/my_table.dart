import 'package:flutter/material.dart';
import 'p.dart';

/*
MyTable([
  [
    Cell('Cant',width:55,bold:true),
    Cell('Producto',bold:true),
    Cell('Precio unitario',width:100,bold:true),
    Cell('Subtotal',width:63,bold:true),
  ],
  [
    Cell(2,width:55),
    Cell('Producto 1'),
    Cell(36.0,width:100),
    Cell(72.0,width:63),
  ],
])
*/

class MyTable extends StatelessWidget {
	final List<List<Cell>> data;
  const MyTable(this.data,{super.key});
  @override
  Widget build(BuildContext context) {
  	return Column(
  		children: data.map<Widget>((List<Cell> row)=>Row(children: row)).toList(),
  	);
  }
}

class Cell extends StatelessWidget {
  final dynamic text;
  final double? width;
  final double fontSize;
  final bool bold;
  const Cell(this.text,{
    this.width,
    this.fontSize=12.0,
    this.bold=false,
    super.key,
  });
  String _getText(){
    if(text is String)return text;
    if(text is int)return text.toString();
    if(text is double)return text.toStringAsFixed(2);
    return '$text';
  }
  @override
  Widget build(BuildContext context){
    if(width==null)return Expanded(child:P(_getText(),bold:bold,size:fontSize,color:Colors.black));
    return SizedBox(width:width!,child:P(_getText(),bold:bold,size:fontSize,color:Colors.black));
  }
}