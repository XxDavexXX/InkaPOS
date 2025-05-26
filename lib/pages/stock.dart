import 'package:flutter/material.dart';
import '../services/helper.dart';
import '../widgets/default_background.dart';
import '../widgets/dialog_title.dart';
import '../widgets/simple_white_box.dart';
import '../widgets/my_icon.dart';
import '../widgets/header_button.dart';
import '../widgets/p.dart';
import 'caja_principal.dart';

class Stock extends StatefulWidget {
  const Stock({super.key});
  @override
  State<Stock> createState() => _StockState();
}

class _StockState extends State<Stock> {

  /*
    En esta pantalla se podrá modificar la cantidad de los productos
    Y en la de caja_principal.dart
  */

  @override
  Widget build(BuildContext context) {
    return Scaffold(
    	appBar: AppBar(
        leading: Center(
          child: Padding(
            padding: const EdgeInsets.only(left:10),
            child: MyIcon(Icons.menu,()=>back(context)),
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
                const DialogTitle('Stock'),
                sep,
                P('Caja',color:Colors.black,align:P.center,bold:true),
                sep,
                Card(
                  color: const Color.fromRGBO(212,212,212,1),
                  elevation: 4.7,
                  child: ListTile(
                    onTap: ()=>goTo(context,const CajaPrincipal()),
                    leading: Icon(Icons.inventory,color:Colors.black),
                    title: P('Caja principal',color:Colors.black),
                  ),
                ),
                sep,
              ],
            ),
          ],
        ),
      ),
    );
  }
}