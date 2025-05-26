## Tasks that need consultation

- API para consultar DNI y RUC
- Validate the ID of the APK in the server (I need the API for that)

## Tasks for deployment

- Remove unused imports using Android Studio
- iOS setup of permission_handler package is left
https://pub.dev/packages/permission_handler
- Upload the app in Android & iOS

## About packages that failed to work with the bluetooth printer in 2024

  esc_pos_bluetooth
  bluetooth_print
  flutter_bluetooth_printer

## About UI standards

<script>

• widgets/te.dart

A simple P widget but the "text" parameter is dynamic, if double it prints it as a 2 decimal number.

• widgets/default_background.dart

The default gradient black/orange background in the design. In code:
Scaffold(
  body: DefaultBackground(
    addPadding: true,
    child: Column(
      children: [
        // Code...
      ],
    ),
  ),
),

• widgets/simple_white_box.dart

The common rounded white container in screens. In code:

body: DefaultBackground(
  addPadding: true,
  child: Column(
    children: [
      SimpleWhiteBox(
        children: [
          DialogTitle('Mi título'),
          // Code...
        ],
      ),
    ],
  ),
),

• widgets/simple_white_box_scroll_both.dart

The same as widgets/simple_white_box.dart but content can also scroll horizontally.

• AppBar

import '../widgets/my_icon.dart';

appBar: AppBar(
  leading: Center(
    child: Padding(
      padding: const EdgeInsets.only(left:10),
      child: MyIcon(Icons.menu,(){}),
    ),
  ),
  actions: [
    MyIcon(Icons.arrow_back,()=>back(context)),sep,
  ],
),

• Template page

import 'package:flutter/material.dart';
import '../services/helper.dart';
import '../services/db.dart';
import '../services/hive_helper.dart';
import '../widgets/default_background.dart';
import '../widgets/simple_white_box.dart';
import '../widgets/dialog_title.dart';
import '../widgets/simple_line.dart';
import '../widgets/my_icon.dart';
import '../widgets/button.dart';
import '../widgets/input.dart';
import '../widgets/div.dart';
import '../widgets/p.dart';

class ScreenX extends StatefulWidget {
  const ScreenX({super.key});
  @override
  State<ScreenX> createState() => _ScreenXState();
}

class _ScreenXState extends State<ScreenX> {
  
  @override
  void initState(){
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_)async{
      // TODO
    });
  }

  @override
  void dispose(){
    // TODO
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        leading: Center(
          child: Padding(
            padding: const EdgeInsets.only(left:10),
            child: MyIcon(Icons.menu,(){}),
          ),
        ),
        actions: [
          MyIcon(Icons.arrow_back,()=>back(context)),sep,
        ],
      ),
      body: DefaultBackground(
        addPadding: true,
        child: Column(
          children: [
            SimpleWhiteBox(
              children: [
                DialogTitle('ScreenX'),
                //TODO
              ],
            ),
          ],
        ),
      ),
    );
  }
}

• Template for pre printable document

import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:widgets_to_image/widgets_to_image.dart';
import '../services/helper.dart';
import '../widgets/simple_line.dart';
import '../widgets/my_icon.dart';
import '../widgets/div.dart';
import '../widgets/te.dart';
import '../widgets/products_table.dart';
import 'imprimir.dart';

class PreImpresionTemplate extends StatefulWidget {
  final Map data;
  const PreImpresionTemplate(this.data,{super.key});
  @override
  State<PreImpresionTemplate> createState() => _PreImpresionTemplateState();
}

class _PreImpresionTemplateState extends State<PreImpresionTemplate> {

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:Theme.of(context).colorScheme.surface,
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
                        const Te('TITULO',bold:true),
                        Te(data['ruc']),
                        Te(DateTime.now().millisecondsSinceEpoch,'day/month/year - hour:minute'),
                        MyRow('N° PEDIDO:',data['numeroDePedido']),
                        const SimpleLine(height:3,color:Colors.black),
                        ProductsTable(data['productos']),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Te('SubTotal: 111',bold:true),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Te('P. Neto:',bold:true),
                            Te('S/111',bold:true),
                          ],
                        ),
                        Image.asset('assets/business-qr.png',width:width(context)*0.36),
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

class MyRow extends StatelessWidget {
  final String text1;
  final String text2;
  const MyRow(this.text1,this.text2,{super.key});
  @override
  Widget build(BuildContext context)=>Row(
    children: [
      Te(text1,bold:true),
      const SizedBox(width:7),
      Expanded(
        child: Align(
          alignment: Alignment.centerLeft,
          child: Te(text2,align:TextAlign.start),
        ),
      ),
    ],
  );
}

</script>"# InkaPOS" 
"# InkaPOS" 
