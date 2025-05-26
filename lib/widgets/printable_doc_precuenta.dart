import 'package:flutter/material.dart';
import '../services/helper.dart';
import 'products_table.dart';
import 'my_row_data.dart';
import 'simple_line.dart';
import 'div.dart';
import 'te.dart';
import 'p.dart';

class PrintableDocPrecuenta extends StatelessWidget {
  final Map reg;
  const PrintableDocPrecuenta(this.reg,{super.key});

  String _getTotal(){
    double total = 0;
    reg['productos'].forEach((Map prod){
      total = total + (prod['cantidad']*prod['precioUnit']);
    });
    return total.toStringAsFixed(2);
  }
  
  @override
  Widget build(BuildContext context)=>Div(
    width: 320,
    background: Colors.white,
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        sep,
        Te('PRECUENTA',bold:true),
        Te('TRINETCORP S.A.C.'),
        Te('TRINETSOFT'),
        if(reg['cliente']!=null)Te(reg['cliente']!['ruc']??''),
        if(reg['cliente']!=null)Te(reg['cliente']!['direccion']??''),
        sep,
        MyRowData('N° PEDIDO:',reg['numeroDePedido']),
        MyRowData(
          'FECHA:',
          getDateString(reg['fecha'],'day/month/year - hour:minute:second'),
        ),
        MyRowData('CAJA:','caja'),
        MyRowData('VENDEDOR:',reg['vendedor']['nombre']),
        const SimpleLine(height:3,color:Colors.black),
        ProductsTable(reg['productos']),
        const SimpleLine(height:3,color:Colors.black),
        Align(
          alignment: Alignment.centerRight,
          child: Te('Total: '+_getTotal(),bold:true),
        ),
        const SimpleLine(height:3,color:Colors.black),
        //MyRowData('R. Social:',''),
        //MyRowData('R.U.C.:',''),
        const SimpleLine(height:3,color:Colors.black),
        const Te('GRACIAS POR SU COMPRA'),
        const SimpleLine(height:3,color:Colors.black),
        const Te('Un software de TriNetSoft'),
        const Te('www.trinetsoft.com'),
      ],
    ),
  );
}