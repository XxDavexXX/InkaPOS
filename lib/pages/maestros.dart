import 'package:flutter/material.dart';
import '../services/helper.dart';
import '../widgets/default_background.dart';
import '../widgets/my_icon.dart';
import '../widgets/div.dart';
import '../widgets/p.dart';
import 'grupos.dart';
import 'subgrupos.dart';
import 'productos.dart';
import 'usuarios.dart';
import 'areas.dart';
import 'impresoras.dart';
import 'stock.dart';
import 'metodos_de_pago.dart';
import 'clientes.dart';
import 'observaciones.dart';
import 'egresos.dart';

class Maestros extends StatelessWidget {
  const Maestros({super.key});
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
          MyIcon(Icons.arrow_back,()=>Navigator.pop(context)),sep,
        ],
      ),
    	body: DefaultBackground(
    		addPadding: true,
    		child: ListView(
    			children: [
    				const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.description,color:Colors.white,size:32),
                sep,
                P('MAESTROS',color:Colors.white,size:19,bold:true),
              ],
            ),
            sep,sep,
            Wrap(
              alignment: WrapAlignment.spaceEvenly,
              spacing: 16,
              runSpacing: 16,
              children: [
                MasterButton(Icons.group,'GRUPO',()=>goTo(context,const Grupos()),isGrey:true),
                MasterButton(Icons.group,'SUBGRUPO',()=>goTo(context,const Subgrupos()),isGrey:true),
                MasterButton(Icons.crop_square,'PRODUCTOS',()=>goTo(context,const Productos())),
                MasterButton(Icons.account_circle,'USUARIO',()=>goTo(context,const Usuarios())),
                MasterButton(Icons.house,'ÁREA',()=>goTo(context,const Areas()),isGrey:true),
                MasterButton(Icons.print,'IMPRESORA',()=>goTo(context,const Impresoras()),isGrey:true),
                MasterButton(Icons.assignment,'STOCK',()=>goTo(context,const Stock())),
                MasterButton(Icons.payments,'MÉTODO DE PAGO',()=>goTo(context,const MetodosDePago())),
                MasterButton(Icons.person,'CLIENTE',()=>goTo(context,const Clientes()),isGrey:true),
                MasterButton(Icons.visibility,'OBS.',()=>goTo(context,const Observaciones()),isGrey:true),
                MasterButton(Icons.currency_exchange,'EGRESOS',()=>goTo(context,const Egresos()),isGrey:false),
              ],
            ),
    			],
    		),
    	),
    );
  }
}

class MasterButton extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onTap;
  final bool isGrey;
  const MasterButton(this.icon,this.text,this.onTap,{this.isGrey=false,super.key});
  @override
  Widget build(BuildContext context)=>InkWell(
    onTap: onTap,
    child: Div(
      borderRadius: 23,
      width: width(context)*0.36,
      height: 120,
      background: isGrey?const Color.fromRGBO(144,141,152,1):prim(context),
      padding: const EdgeInsets.all(7),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,size:36,color:isGrey?Colors.white:Colors.black),
            const SizedBox(height: 7),
            P(text,size:14,bold:true,color:isGrey?Colors.white:Colors.black,overflow:TextOverflow.clip,align:TextAlign.center),
          ],
        ),
      ),
    ),
  );
}