import 'package:flutter/material.dart';
import '../services/helper.dart';
import '../widgets/div.dart';
import '../widgets/my_icon.dart';
import '../widgets/p.dart';
import '../widgets/default_background.dart';
import 'registro_de_ventas.dart';
import 'reporte_de_paloteo.dart';
import 'reporte_de_comandas.dart';
import 'ventas_por_turno.dart';
import 'reporte_turno_z.dart';
import 'ventas_por_vendedor.dart';

class Reportes extends StatelessWidget {
  const Reportes({super.key});
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
      	child: Column(
      		children: [
      			Div(
      				width: width(context)*0.66,
      				borderColor: Colors.grey,
      				borderRadius: 16,
      				padding: const EdgeInsets.symmetric(horizontal:16,vertical:4.7),
      				child:const Row(
      					mainAxisAlignment: MainAxisAlignment.center,
      					children: [
      						Icon(Icons.search,color:Colors.white),
      						sep,
      						P('REPORTES',size:18,bold:true),
      					],
      				),
      			),
      			sep,
      			Wrap(
      				alignment: WrapAlignment.spaceEvenly,
      				spacing: 12,
      				runSpacing: 12,
      				children: [
      					ReportButton(
      						Icons.assignment_turned_in,
      						'REGISTRO DE VENTAS',
      						()=>goTo(context,const RegistroDeVentas()),
      						isGrey: true,
      					),
      					ReportButton(
      						Icons.assignment,
      						'PALOTEO',
      						()=>goTo(context,const ReporteDePaloteo()),
      						isGrey: true,
      					),
      					ReportButton(
      						Icons.article,
      						'REPORTE DE COMANDAS',
      						()=>goTo(context,const ReporteDeComandas()),
      					),
      					ReportButton(
      						Icons.assessment,
      						'VENTAS POR TURNO',
      						()=>goTo(context,const VentasPorTurno()),
      					),
      					ReportButton(
      						'Z',
      						'TURNO Z',
      						()=>goTo(context,const ReporteTurnoZ()),
      						isGrey: true,
      					),
      					ReportButton(
      						Icons.assignment_ind,
      						'VENTAS POR VENDEDOR',
      						()=>goTo(context,const VentasPorVendedor()),
      						isGrey: true,
      					),
      				],
      			),
      		],
      	),
      ),
    );
  }
}

class ReportButton extends StatelessWidget {
	final dynamic icon;
	final String text;
	final VoidCallback onTap;
	final bool isGrey;
	const ReportButton(this.icon,this.text,this.onTap,{this.isGrey=false,super.key});
	@override
	Widget build(BuildContext context)=>InkWell(
		onTap: onTap,
		child: Div(
			height: width(context)*0.42-14,
			width: width(context)*0.42,
			borderRadius: 23,
			shadow: true,
			background: isGrey?const Color.fromRGBO(142,138,147,1):prim(context),
			padding: const EdgeInsets.all(12),
			child: Column(
				mainAxisAlignment: MainAxisAlignment.center,
				children: [
					icon is IconData?
						Icon(icon,size:32,color:isGrey?Colors.white:Colors.black)
						:P(icon,size:42,bold:true,color:isGrey?Colors.white:Colors.black),
					const SizedBox(height:7),
					P(text,bold:true,color:isGrey?Colors.white:Colors.black,overflow:TextOverflow.clip,align:P.center),
				],
			),
		),
	);
}