import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:widgets_to_image/widgets_to_image.dart';
import '../services/helper.dart';
import '../widgets/printable_doc_precuenta.dart';
import '../widgets/printable_doc_boleta.dart';
import '../widgets/printable_doc_factura.dart';
import '../widgets/simple_line.dart';
import '../widgets/my_icon.dart';
import '../widgets/div.dart';
import '../widgets/te.dart';
import '../widgets/p.dart';
import '../widgets/products_table.dart';
import 'imprimir.dart';

class PreImpresionRegistros extends StatefulWidget {
  final List<Map> registros;
  const PreImpresionRegistros(this.registros,{super.key});
  @override
  State<PreImpresionRegistros> createState() => _PreImpresionRegistrosState();
}

class _PreImpresionRegistrosState extends State<PreImpresionRegistros> {

  WidgetsToImageController _wti = WidgetsToImageController();
  late final List<Map> _registros;

  @override
  void initState() {
    super.initState();
    _registros = widget.registros;
  }

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
              child: Column(
                children: _registros.map((Map reg)=>RegisterPrintableDoc(reg)).toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class RegisterPrintableDoc extends StatelessWidget {
  final Map reg;
  const RegisterPrintableDoc(this.reg,{super.key});
  @override
  Widget build(BuildContext context){
    switch(reg['tipo']){
      case 'boleta':
        return PrintableDocBoleta(reg);
        break;
      case 'factura':
        return PrintableDocFactura(reg);
        break;
      case 'precuenta':
        return PrintableDocPrecuenta(reg);
        break;
      default:
        return Div(
          background: Colors.white,
          padding: const EdgeInsets.all(16),
          child: P('Tipo de documento no reconocido',color:Colors.black),
        );
    }
  }
}