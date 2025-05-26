import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:widgets_to_image/widgets_to_image.dart';
import '../services/helper.dart';
import '../services/hive_helper.dart';
import '../widgets/printable_doc_boleta.dart';
import '../widgets/simple_line.dart';
import '../widgets/my_icon.dart';
import '../widgets/div.dart';
import '../widgets/te.dart';
import '../widgets/products_table.dart';
import 'imprimir.dart';

class Boleta extends StatefulWidget {
	final Map data;
  const Boleta(this.data,{super.key});
  @override
  State<Boleta> createState() => _BoletaState();
}

class _BoletaState extends State<Boleta> {

  WidgetsToImageController _wti = WidgetsToImageController();
	late final Map _data;

  @override
  void initState() {
    super.initState();
    _data = widget.data;
  }

  void _verMetodosDePago() {
    final metodos = _data['metodosDePago'];

    String texto = '';

    if (metodos == null) {
      texto = '⚠️ No se encontró la clave "metodosDePago".\n\n_revisa si estás incluyendo esa información al generar la boleta_.';
    } else if (metodos is! List) {
      texto = '⚠️ La clave "metodosDePago" existe, pero no es una lista.\n\nTipo real: ${metodos.runtimeType}';
    } else if (metodos.isEmpty) {
      texto = '⚠️ La lista de métodos de pago está vacía.\n\n_no se registró ningún método al confirmar la venta_.';
    } else {
      for (var m in metodos) {
        texto += '• Tipo: ${m['tipo'] ?? '¿Nulo?'}\n';
        texto += '  Monto: ${m['monto'] ?? '¿Nulo?'}\n';
        texto += '  Divisa: ${m['divisa'] ?? '¿Nulo?'}\n\n';
      }
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Métodos de Pago'),
        content: Text(
          texto.trim().isNotEmpty ? texto : '⚠️ No se pudo generar texto informativo.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }


  void _print()async{
  	bool? ans = await confirm(context,'¿Imprimir?');
  	if(ans!=true)return;
    doLoad(context);
    try{
      Uint8List? bytes = await _wti.capture();
      if(bytes==null)return;
      await goTo(context,Imprimir(bytes));
      //Going back to dashboard.dart
      back(context);back(context);back(context);back(context);
    }
    catch(e){await alert(context,'Ocurrió un error');p(e.toString());}
    finally{Navigator.pop(context);}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
    	backgroundColor:Theme.of(context).colorScheme.surface,
    	appBar: AppBar(
        leading: Center(
          child: Padding(
            padding: const EdgeInsets.only(left:10),
            child: MyIcon(Icons.menu,()=>Navigator.pop(context)),
          ),
        ),
        // actions: [
        //   MyIcon(Icons.print,_print),sep,
        //   MyIcon(Icons.arrow_back,(){
        //     //Back to Dashboard
        //     back(context);back(context);back(context);back(context);
        //   }),sep,
        // ],
        actions: [
          MyIcon(Icons.info, _verMetodosDePago), // <- botón de prueba
          MyIcon(Icons.print, _print),
          sep,
          MyIcon(Icons.arrow_back, () {
            back(context); back(context); back(context); back(context);
          }),
          sep,
        ],

      ),
      body: Container(
        width: width(context),
        height: height(context),
        child: SingleChildScrollView(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Column(
              children: [
                WidgetsToImage(
                  controller: _wti,
                  child: PrintableDocBoleta(_data),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}