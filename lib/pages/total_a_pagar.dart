import 'package:flutter/material.dart';
import '../services/helper.dart';
import '../services/hive_helper.dart';
import '../widgets/default_background.dart';
import '../widgets/dialog_title.dart';
import '../widgets/simple_line.dart';
import '../widgets/my_icon.dart';
import '../widgets/simple_white_box.dart';
import '../widgets/button.dart';
import '../widgets/div.dart';
import '../widgets/p.dart';
import 'comprobantes/boleta.dart';
import 'comprobantes/factura.dart';

class TotalAPagar extends StatefulWidget {
  final Map datos;
  final Map? vendedor;
  const TotalAPagar({
    required this.datos,
    required this.vendedor,
    super.key,
  });
  @override
  State<TotalAPagar> createState() => _TotalAPagarState();
}

class _TotalAPagarState extends State<TotalAPagar> {

  late List<Map> _metodosDePago;

  String _whatIsLeftText='Faltan';
  double _whatIsLeftNumber=0.0;
  
  String _input = '';

  @override
  void initState(){
    super.initState();
    _metodosDePago = getAllMetodosDePago().map((Map mp)=>{...mp, 'activo': false, 'monto':0.0}).toList();
    //Seleccionar al inicio la opción de visa en caso exista
    _metodosDePago.forEach((Map mp){
      if(mp['nombre'].toLowerCase().contains('visa')){
        mp['activo']=true;
        //Cargar el monto exacto con el método de pago tarjeta
        mp['monto']=_total();
      }
    });
  }


  Map _getMetodoDePagoActivo()=>_metodosDePago.where((mp)=>mp['activo']).toList().first;

  void _seleccionarMetodoDePago(Map mp)=>setState((){
    _metodosDePago.forEach((m)=>m['activo']=false);
    mp['activo'] = true;
    _input = mp['monto'].toString();
  });

  //El saldo en soles, si hay dolares, los convierte en soles
  double _saldo(){
    double conversionDolaresSoles = getTurnoActual()!['precioDeVenta'];
    double saldo = 0.0;
    _metodosDePago.forEach((Map mp){
      if(mp['divisa']=='PEN'){
        saldo+=mp['monto'];
      } else {
        saldo+=mp['monto']*conversionDolaresSoles;
      }
    });
    return saldo;
  }
  double _total(){
    double total = 0.0;
    widget.datos['productos'].forEach((Map prod){
      total = total + (prod['cantidad'] * prod['precioUnit']);
    });
    return total;
  }

  void _updateWhatIsLeftToPay(){
    double total=_total();
    double saldo=_saldo();
    if(total < saldo){
      setState((){
        _whatIsLeftText = 'Vuelto';
        _whatIsLeftNumber = saldo-total;
      });
    } else {
      setState((){
        _whatIsLeftText = 'Faltan';
        _whatIsLeftNumber = total-saldo;
      });
    }
  }

  void _pressKey(String theKey)async{
    switch(theKey){
      case 'Delete':
        if(_input.isEmpty)return;
        setState(()=>_input=_input.substring(0,_input.length-1));
        break;
      case 'Ready':
        double price = 0.0;
        try{price = double.parse(_input.trim());}
        catch(e){alert(context,'Número no válido');return;}
        setState((){
          _getMetodoDePagoActivo()['monto']=price;
          _updateWhatIsLeftToPay();
        });
        break;
      default:
        if(_input == '0.0' || _input == '0.' || _input == '0'){
          setState(()=>_input = theKey);
        } else {
          setState(()=>_input += theKey);
        }
    }
  }

  void _pagar()async{
    //Verificar que el saldo sea mayor o igual al total a pagar
    double total = _total();
    double saldo = _saldo();
    if(total > saldo){alert(context,'Faltan: S/${(total-saldo).toStringAsFixed(2)}');return;}
    if(_whatIsLeftNumber != 0 && _metodosDePago.where((mp)=>mp['monto']>0).toList().any((mp)=>mp['tipo']!='efectivo')){
      alert(context,'Solo puede haber vuelto si el método de pago es efectivo');
      return;
    }
    Map datos = {
      ...widget.datos,
      'vuelto': _whatIsLeftNumber,
      // E.g. {abreviatura:'S/',nombre:'Soles',tipo:'efectivo',divisa:'soles',monto:10.0},
      'metodosDePago': _metodosDePago.where((mp)=>mp['monto']>0).map<Map>((Map mp){
        Map map = {...mp};
        map.remove('activo');
        return map;
      }).toList(),
    };

    final serieCaja = getSerieActiva(); // función definida abajo

    // datos['numeroDeComprobante'] = await generarNumeroDeComprobantePorCaja(
    //   tipo: datos['tipo'],
    //   serie: serie,
    // );
    datos['numeroDeComprobante'] = await generarNumeroDeComprobantePorCaja(
      tipo: 'boleta',
      serie: getSerieActiva()
    );

    datos['nroDeSerie'] = serieCaja; // lo puedes guardar por auditoría

    //Guardar el pedido en registros de ventas
    await loadThis(context,()async{
      await addRegistroDeVenta(datos);
      await deleteAllCartItem();
      showSnackBar(context,'Pedido guardado','En registros de ventas',seconds:2);
    });
    //Abrir la pantalla para imprimir la cosa
    if(datos['tipo']=='boleta')goTo(context,Boleta(datos));
    if(datos['tipo']=='factura')goTo(context,Factura(datos));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
    	backgroundColor:Theme.of(context).colorScheme.surface,
    	appBar: AppBar(
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
                DialogTitle('Total a pagar: ${_total()}'),
                ..._metodosDePago.map((Map mp)=>InkWell(
                  onTap: ()=>_seleccionarMetodoDePago(mp),
                  child: RowData(
                    abreviatura: mp['abreviatura'],
                    field: mp['nombre'],
                    value: mp['monto'],
                    selected: mp['activo'],
                  ),
                )),
                SimpleLine(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    P('$_whatIsLeftText: ${_whatIsLeftNumber.toStringAsFixed(2)}',bold:true,color:Colors.black),
                    P('Saldo: ${_saldo().toStringAsFixed(2)}',bold:true,color:Colors.black),
                  ],
                ),
                sep,
                Div(
                  borderRadius: 16,
                  background: Colors.grey,
                  width: width(context)*0.66,
                  height: 55,
                  child: Center(child: P(_input,color:Colors.white,size:19,bold:true)),
                ),
                sep,
                MyKeyboard(_pressKey,_pagar),
                sep,
              ],
            ),
          ],
    		),
    	),
    );
  }
}

class MyKeyboard extends StatelessWidget {
  final Function pk;
  final VoidCallback pagar;
  const MyKeyboard(this.pk,this.pagar,{super.key});
  @override
  Widget build(BuildContext context)=>Wrap(
    alignment: WrapAlignment.spaceEvenly,
    spacing: 7,
    runSpacing: 7,
    children: [
      SimpleKey('1',pk),
      SimpleKey('2',pk),
      SimpleKey('3',pk),
      SimpleKey('4',pk),
      SimpleKey('5',pk),
      SimpleKey('6',pk),
      SimpleKey('7',pk),
      SimpleKey('8',pk),
      SimpleKey('9',pk),
      ComplexKey(
        const Icon(Icons.backspace,color:Colors.white,size:32),
        Colors.red,
        'Delete',
        pk,
      ),
      SimpleKey('0',pk),
      ComplexKey(
        const Icon(Icons.check,color:Colors.white,size:32),
        Colors.green,
        'Ready',
        pk,
      ),
      SimpleKey('.',pk),
      InkWell(
        onTap: pagar,
        child: Div(
          width: width(context)*0.50,
          height: 42,
          borderRadius: 16,
          background: prim(context),
          child: Center(child: P('Pagar',bold:true)),
        ),
      ),
    ],
  );
}

class SimpleKey extends StatelessWidget {
  final String text;
  final Function pressKey;
  const SimpleKey(this.text,this.pressKey,{super.key});
  @override
  Widget build(BuildContext context)=>InkWell(
    onTap: ()=>pressKey(text),
    child: Div(
      width: width(context)*0.21,
      height: 42,
      borderRadius: 16,
      background: Colors.grey,
      child: Center(
        child: P(text,size:19,bold:true)
      ),
    ),
  );
}

class ComplexKey extends StatelessWidget {
  final Widget content;
  final Color color;
  final String theKey;
  final Function pk;
  const ComplexKey(this.content,this.color,this.theKey,this.pk,{super.key});
  @override
  Widget build(BuildContext context)=>InkWell(
    onTap: ()=>pk(theKey),
    child: Div(
      width: width(context)*0.21,
      height: 42,
      borderRadius: 16,
      background: color,
      child: Center(
        child: content,
      ),
    ),
  );
}

class RowData extends StatelessWidget {
  final String abreviatura;
  final String field;
  final double value;
  final bool selected;
  const RowData({
    required this.abreviatura,
    required this.field,
    required this.value,
    required this.selected,
    super.key,
  });
  @override
  Widget build(BuildContext context)=>Padding(
    padding: const EdgeInsets.only(bottom:4),
    child: Row(
      children: [
        Expanded(
          child: Row(
            children: [
              Div(
                width: 32,
                height: 32,
                background: selected?Colors.green:Colors.grey,
                circular: true,
                child: Center(child:P(abreviatura,bold:true)),
              ),
              sep,
              P(field,bold:true,color:Colors.black),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(7),
          child: P(value.toStringAsFixed(2),bold:true,color:Colors.black)
        ),
      ],
    ),
  );
}