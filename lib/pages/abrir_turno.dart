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

class AbrirTurno extends StatefulWidget {
  const AbrirTurno({super.key});
  @override
  State<AbrirTurno> createState() => _AbrirTurnoState();
}

class _AbrirTurnoState extends State<AbrirTurno> {

  double _precioDeCompra = 3.75;
  double _precioDeVenta = 3.85;
  double _fondoInicialSoles = 0;
  double _fondoInicialDolares = 0;

  Future<void> _fetchDataFromSunat()=>loadThis(context,()async{
    Map<String,double>? result = await DB.tipoDeCambioSunat();
    if(result==null){await alert(context,'No se pudo establecer conexión con la SUNAT');return;}
    setState((){
      _precioDeCompra = result!['precioDeCompra']!;
      _precioDeVenta = result!['precioDeVenta']!;
    });
  });

  void _editPrecioDeCompra()async{
    String? newVal = await prompt(
      context,
      text: 'Precio de compra:',
      initialValue: _precioDeCompra.toString(),
      type: TextInputType.number,
    );
    if(newVal==null)return;
    double price = 0;
    try{price = double.parse(newVal!);}
    catch(e){alert(context,'Precio no válido');return;}
    if(price <= 0){alert(context,'Precio no válido');return;}
    setState(()=>_precioDeCompra=price);
  }
  void _editPrecioDeVenta()async{
    String? newVal = await prompt(
      context,
      text: 'Precio de venta:',
      initialValue: _precioDeVenta.toString(),
      type: TextInputType.number,
    );
    if(newVal==null)return;
    double price = 0;
    try{price = double.parse(newVal!);}
    catch(e){alert(context,'Precio no válido');return;}
    if(price <= 0){alert(context,'Precio no válido');return;}
    setState(()=>_precioDeVenta=price);
  }
  void _editFondoInicialSoles()async{
    String? newVal = await prompt(
      context,
      text: 'Fondo inicial (soles):',
      initialValue: _fondoInicialSoles==0.0?'':_fondoInicialSoles.toString(),
      type: TextInputType.number,
    );
    if(newVal==null)return;
    double price = 0;
    try{price = double.parse(newVal!);}
    catch(e){alert(context,'Precio no válido');return;}
    if(price < 0){alert(context,'Precio no válido');return;}
    setState(()=>_fondoInicialSoles=price);
  }
  void _editFondoInicialDolares()async{
    String? newVal = await prompt(
      context,
      text: 'Fondo inicial (dólares):',
      initialValue: _fondoInicialDolares==0.0?'':_fondoInicialDolares.toString(),
      type: TextInputType.number,
    );
    if(newVal==null)return;
    double price = 0;
    try{price = double.parse(newVal!);}
    catch(e){alert(context,'Precio no válido');return;}
    if(price < 0){alert(context,'Precio no válido');return;}
    setState(()=>_fondoInicialDolares=price);
  }

  void _aceptar()=>back(context,data:{
    'id': DateTime.now().millisecondsSinceEpoch,
    'precioDeCompra': _precioDeCompra,
    'precioDeVenta': _precioDeVenta,
    'fondoInicialSoles': _fondoInicialSoles,
    'fondoInicialDolares': _fondoInicialDolares,
    'usuarioID': getUser()!['id'],
  });

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
                DialogTitle('Abrir turno'),
                P('Tipo de cambio',size:17,align:TextAlign.center,color:Colors.black),
                Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(7),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            P('Compra',bold:true,color:Colors.black),
                            SimpleBox('S/$_precioDeCompra',_editPrecioDeCompra),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(7),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            P('Venta',bold:true,color:Colors.black),
                            SimpleBox('S/$_precioDeVenta',_editPrecioDeVenta),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                sep,
                Center(
                  child: Button(P('Consultar a SUNAT',bold:true),_fetchDataFromSunat),
                ),
                sep,P('Fondo inicial',size:17,align:TextAlign.center,color:Colors.black),sep,
                SimpleBox('S/$_fondoInicialSoles',_editFondoInicialSoles),sep,
                SimpleBox('\$$_fondoInicialDolares',_editFondoInicialDolares),sep,
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Button(P('Aceptar',color:Colors.white),_aceptar),
                    sep,
                    Button(P('Cancelar',color:Colors.white),()=>back(context)),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class SimpleBox extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  const SimpleBox(this.text,this.onTap,{super.key});
  @override
  Widget build(BuildContext context)=>InkWell(
    onTap: onTap,
    child: Div(
      width: width(context),
      height: 42,
      background: const Color.fromRGBO(79,80,82,1),
      borderRadius: 16,
      child: Center(
        child: P(text,color:Colors.white),
      ),
    ),
  );
}