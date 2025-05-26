import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:widgets_to_image/widgets_to_image.dart';
import '../services/helper.dart';
import '../widgets/printable_doc_precuenta.dart';
import '../widgets/printable_doc_boleta.dart';
import '../widgets/printable_doc_factura.dart';
import '../widgets/simple_line.dart';
import '../widgets/my_row_data.dart';
import '../widgets/my_icon.dart';
import '../widgets/div.dart';
import '../widgets/te.dart';
import '../widgets/p.dart';
import 'imprimir.dart';

class PreImpresionEgresos extends StatefulWidget {
  final List<Map> egresos;
  const PreImpresionEgresos(this.egresos,{super.key});
  @override
  State<PreImpresionEgresos> createState() => _PreImpresionEgresosState();
}

class _PreImpresionEgresosState extends State<PreImpresionEgresos> {

  WidgetsToImageController _wti = WidgetsToImageController();

  void _print()async{
    if(await confirm(context,'¿Imprimir?')==true){
      loadThis(context,()async{
        Uint8List? bytes = await _wti.capture();
        if(bytes==null)return;
        await goTo(context,Imprimir(bytes));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: surf(context),
      appBar: AppBar(
        leading: Center(
          child: Padding(
            padding: const EdgeInsets.only(left:10),
            child: MyIcon(Icons.menu,()=>back(context)),
          ),
        ),
        actions: [
          MyIcon(Icons.print,_print),sep,
          MyIcon(Icons.arrow_back,()=>back(context)),sep,
        ],
      ),
      body: Container(
        width: width(context),
        height: height(context),
        child: SingleChildScrollView(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: WidgetsToImage(
              controller: _wti,
              child: Div(
                width: 320,
                background: Colors.white,
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    sep,
                    Te('TRINETCORP S.A.C.'),
                    sep,
                    Te('IMPRESIÓN DE EGRESOS',bold:true),
                    sep,
                    Te('Fecha de impresión:'),
                    Te(getDateString(
                      DateTime.now().millisecondsSinceEpoch,
                      'day/month/year - hour:minute:second',
                    )),
                    sep,
                    SimpleLine(height:3,color:Colors.black),
                    sep,
                    ...widget.egresos.map((Map eg)=>Column(
                      children: [
                        MyRowData('Monto','S/'+eg['monto'].toStringAsFixed(2)),
                        MyRowData(
                          'Fecha:',
                          getDateString(eg['fecha'],'day/month/year - hour:minute:second'),
                        ),
                        MyRowData('Motivo:',eg['motivo']),
                        SimpleLine(height:3,color:Colors.black),
                      ],
                    )),
                    sep,
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}