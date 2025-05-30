import 'package:flutter/material.dart';
import '../services/helper.dart';
import 'products_table_precuenta.dart';
import 'my_row_data.dart';
import 'simple_line.dart';
import 'div.dart';
import 'te.dart';
import '../services/logic.dart';
import '../services/hive_helper.dart';
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
    // padding: const EdgeInsets.all(16),
    padding: const EdgeInsets.only(top: 12, left: 16, right: 16, bottom: 16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Te('PRECUENTA',bold:true),
        Te('TRINETCORP S.A.C.'),
        Te('TRINETSOFT'),
        // if(reg['cliente']!=null)Te(reg['cliente']!['ruc']??''),
        // if(reg['cliente']!=null)Te(reg['cliente']!['direccion']??''),
        Te('RUC: ' + reg['datosDelNegocio']['ruc']),
        Te(reg['datosDelNegocio']['direccion']),
        sep,
        // MyRowData('N° PEDIDO:',reg['numeroDePedido']),
        MyRowData('N° PEDIDO:', reg['numeroDePedido'].toString().padLeft(10, '0')),

        MyRowData(
          'FECHA:',
          getDateString(reg['fecha'],'day/month/year - hour:minute:second'),
        ),
        // MyRowData('CAJA:','caja'),
        Row(
            children: [
              Te('CAJA:', bold: true),
              sep,
              Te(
                getCajaActual()?['nombre'] ??
                    getCajaActual()?['codigo'] ??
                    'CAJA',
              ),
            ],
          ),
        MyRowData('VENDEDOR:',reg['vendedor']['nombre']),
        // const SimpleLine(height:3,color:Colors.black),
        ProductsTablePrecuenta(reg['productos']),
        const SimpleLine(height:2,color:Colors.black),
        Align(
          alignment: Alignment.centerRight,
          child: RichText(
            text: TextSpan(
              style: const TextStyle(color: Colors.black, fontSize: 14),
              children: [
                const TextSpan(
                  text: 'TOTAL: ',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(
                  text: 'S/ ${_getTotal()}',
                  style: const TextStyle(fontWeight: FontWeight.normal),
                ),
              ],
            ),
          ),
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: Te(
            Logic.turnPriceToWords(double.parse(_getTotal())),
            size: 12,
            bold: false,
          ),
        ),

        //MyRowData('R. Social:',''),
        //MyRowData('R.U.C.:',''),
        const SimpleLine(height:2,color:Colors.black),
        const Te('GRACIAS POR SU COMPRA'),
        ColorFiltered(
          colorFilter: const ColorFilter.matrix(<double>[
            0.2126, 0.7152, 0.0722, 0, 0,
            0.2126, 0.7152, 0.0722, 0, 0,
            0.2126, 0.7152, 0.0722, 0, 0,
            0,      0,      0,      1, 0,
          ]),
          child: Image.asset(
            'assets/logo with panel.png',
            width: width(context) * 0.30,
          ),
        ),
        const SimpleLine(height:2,color:Colors.black),
        const Te('Un software de TriNetSoft'),
        const Te('www.trinetsoft.com'),
        const SimpleLine(height:2,color:Colors.black),
        const Te('¡GRACIAS POR SU PREFERENCIA VUELVA'),
        const Te('PRONTO!'),
      ],
    ),
  );
}