import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:widgets_to_image/widgets_to_image.dart';
import '../services/helper.dart';
import '../widgets/printable_doc_deleted_register.dart';
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

class PreImpresionRegistrosEliminados extends StatefulWidget {
  final List<Map> registrosEliminads;
  const PreImpresionRegistrosEliminados(this.registrosEliminads,{super.key});
  @override
  State<PreImpresionRegistrosEliminados> createState() => _PreImpresionRegistrosEliminadosState();
}

class _PreImpresionRegistrosEliminadosState extends State<PreImpresionRegistrosEliminados> {

  WidgetsToImageController _wti = WidgetsToImageController();
  late final List<Map> _registros;

  @override
  void initState() {
    super.initState();
    _registros = widget.registrosEliminads;
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
                children: _registros.map<Widget>((Map reg)=>PrintableDocDeletedRegister(reg)).toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}