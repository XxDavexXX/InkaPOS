import 'package:flutter/material.dart';
import '../services/helper.dart';
import '../services/hive_helper.dart';
import '../services/logic.dart';
import 'products_table.dart';
import 'my_row_data.dart';
import 'simple_line.dart';
import 'div.dart';
import 'te.dart';
import 'p.dart';

class PrintableDocDeletedRegister extends StatelessWidget {
  final Map reg;
  const PrintableDocDeletedRegister(this.reg,{super.key});

  String _getTotal(){
    double subtotal = 0;
    reg['productos'].forEach((prod){
      subtotal = subtotal + (prod['cantidad']*prod['precioUnit']);
    });
    return subtotal.toStringAsFixed(2);
  }

  String _precioNeto(){
    double precioNeto = 0.0;
    reg['productos'].forEach((prod){
      double productTotal = prod['cantidad'] * prod['precioUnit'];
      double productRealPriceWithoutIGV = productTotal / (1.0 + (prod['igv']/100));
      precioNeto += productRealPriceWithoutIGV;
    });
    return precioNeto.toStringAsFixed(2);
  }
  
  String _descuentoDelIgv(){
    double total = double.parse(_getTotal());
    double netPrice = double.parse(_precioNeto());
    int igvDisccount = int.parse((total*100).toStringAsFixed(2).split('.').first) - int.parse((netPrice*100).toStringAsFixed(2).split('.').first);
    return (igvDisccount/100).toString();
  }

  @override
  Widget build(BuildContext context){
    return Div(
      width: 320,
      background: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          sep,
          Te('TRINETCORP S.A.C.'),
          sep,
          Te('PEDIDO ELIMINADO',bold:true),
          Te(reg['id']),
          sep,
          Row(
            children: [
              Te('Fecha:',bold:true),
              sep,
              Te(getDateString(reg['fecha'],'day/month/year hour:minute:second')),
            ],
          ),
          Row(
            children: [
              Te('Caja:',bold:true),
              sep,
              Te('${getUser()!['usuarios']??'CAJA'}'),
            ],
          ),
          sep,
          SimpleLine(height:3,color:Colors.black),
          Te('Motivo de la eliminación:'),
          Te(reg['motivo']),
          SimpleLine(height:3,color:Colors.black),
          ProductsTable(reg['productos']),
          Align(
            alignment: Alignment.centerRight,
            child: Te('SubTotal: '+_getTotal(),bold:true),
          ),
          sep,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Te('P. Neto:',bold:true),
              Te('S/${_precioNeto()}',bold:true),
            ],
          ),
          SimpleLine(height:3,color:Colors.black),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Te('TOTAL:',size:16,bold:true),
              Expanded(child:const SizedBox()),
              Te('S/ ${_getTotal()}',size:16,bold:true),
            ],
          ),
          SimpleLine(height:3,color:Colors.black),
          Te('REPRESENTACIÓN IMPRESA DE PEDIDO ELIMINADO'),
          SimpleLine(height:3,color:Colors.black),
          sep,
          Image.asset('assets/logo for documents.png',width:width(context)*0.36),
        ],
      ),
    );
  }
}