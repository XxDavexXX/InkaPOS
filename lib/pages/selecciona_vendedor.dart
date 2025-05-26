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

class SeleccionaVendedor extends StatefulWidget {
  const SeleccionaVendedor({super.key});
  @override
  State<SeleccionaVendedor> createState() => _SeleccionaVendedorState();
}

class _SeleccionaVendedorState extends State<SeleccionaVendedor> {
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
          MyIcon(Icons.arrow_back,()=>back(context)),sep,
        ],
      ),
      body: DefaultBackground(
        addPadding: true,
        child: Column(
          children: [
            SimpleWhiteBox(
              children: [
                DialogTitle('Selecciona vendedor'),
                ...getAllUsuarios().where((x)=>x['activo']==true).toList().map((Map usuario)=>Card(
                  elevation: 4.7,
                  child: ListTile(
                    onTap: ()=>back(context,data:usuario),
                    leading: Icon(Icons.person,color:Colors.black),
                    title: P(usuario['usuario']??'SIN NOMBRE',bold:true),
                  ),
                )),
              ],
            ),
          ],
        ),
      ),
    );
  }
}