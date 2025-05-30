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

  Future<void> _fetchDataFromSunat() async {
    doLoad(context);
    final result = await DB.tipoDeCambioSunat();
    Navigator.pop(context); // Cierra el loader

    if (result == null) {
      await alert(context, '❌ No se pudo obtener el tipo de cambio desde SUNAT.');
      return;
    }

    final compra = result['precioDeCompra']!;
    final venta = result['precioDeVenta']!;

    await dialog(
      context,
      background: Colors.white,
      children: [
        DialogTitle('Tipo de cambio SUNAT'),
        sep,
        P('Fecha: ${getDateString(DateTime.now().millisecondsSinceEpoch, 'day/month/year')}', color: Colors.black, size: 14),
        sep,
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Column(
              children: [
                P('Compra', bold: true, size: 16, color: Colors.black),
                sep,
                P('S/ ${compra.toStringAsFixed(3)}', size: 20, bold: true, color: Colors.green.shade700),
              ],
            ),
            Column(
              children: [
                P('Venta', bold: true, size: 16, color: Colors.black),
                sep,
                P('S/ ${venta.toStringAsFixed(3)}', size: 20, bold: true, color: Colors.blue.shade700),
              ],
            ),
          ],
        ),
        sep,
        P('¿Aplicar este tipo de cambio?', align: P.center, size: 14, color: Colors.black),
        sep,
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Button(P('Salir', bold: true, color: Colors.white), () {
              Navigator.pop(context); // solo cierra
            }),
            sep,
            Button(P('Usar', bold: true, color: Colors.white), () {
              setState(() {
                _precioDeCompra = compra;
                _precioDeVenta = venta;
              });
              Navigator.pop(context); // cierra el popup
            }),
          ],
        )
      ],
    );
  }



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

  void _aceptar() {
    if (getCajaActual() == null) {
      alert(context, 'Debes seleccionar una caja activa');
      return;
    }

    back(context, data: {
      'id': DateTime.now().millisecondsSinceEpoch,
      'precioDeCompra': _precioDeCompra,
      'precioDeVenta': _precioDeVenta,
      'fondoInicialSoles': _fondoInicialSoles,
      'fondoInicialDolares': _fondoInicialDolares,
      'usuarioID': getUser()!['id'],
      'cajaID': getCajaActual()?['codigo'],
      'fechaApertura': DateTime.now().toIso8601String(),
    });
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