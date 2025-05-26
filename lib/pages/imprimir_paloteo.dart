import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:widgets_to_image/widgets_to_image.dart';
import '../services/helper.dart';
import '../widgets/my_row_data.dart';
import '../widgets/simple_line.dart';
import '../widgets/my_icon.dart';
import '../widgets/div.dart';
import '../widgets/te.dart';
import '../widgets/products_table.dart';
import 'imprimir.dart';

class ImprimirPaloteo extends StatefulWidget {
  //{List<Map> productos, String desde, String hasta}
  final Map data;
  const ImprimirPaloteo(this.data,{super.key});
  @override
  State<ImprimirPaloteo> createState() => _ImprimirPaloteoState();
}

class _ImprimirPaloteoState extends State<ImprimirPaloteo> {

  WidgetsToImageController _wti = WidgetsToImageController();
  late final Map data;

  @override
  void initState() {
    super.initState();
    data = widget.data;
  }

  void _print()async{
    bool? ans = await confirm(context,'¿Imprimir?');
    if(ans!=true)return;
    doLoad(context);
    try{
      Uint8List? bytes = await _wti.capture();
      if(bytes==null)return;
      await goTo(context,Imprimir(bytes));
    }
    catch(e){await alert(context,'Ocurrió un error');p(e.toString());}
    finally{Navigator.pop(context);}
  }

  String _total(){
    double total = 0.0;
    data['productos'].forEach((Map prod){
      total += prod['cantidad'] * prod['precioUnit'];
    });
    return total.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
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
            child: Column(
              children: [
                WidgetsToImage(
                  controller: _wti,
                  child: Div(
                    width: 320,
                    background: Colors.white,
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        sep,
                        const Te('Paloteo',bold:true),
                        sep,
                        MyRowData('Fecha inicial:',data['desde']),
                        MyRowData('Fecha final:',data['hasta']),
                        sep,
                        const SimpleLine(height:3,color:Colors.black),
                        sep,
                        ProductsTable(data['productos']),
                        sep,
                        Align(
                          alignment: Alignment.centerRight,
                          child: Te('Total: '+_total(),bold:true),
                        ),
                        sep,
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}