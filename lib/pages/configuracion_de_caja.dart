import 'package:flutter/material.dart';
import '../services/helper.dart';
import '../widgets/default_background.dart';
import '../widgets/simple_white_box.dart';
import '../widgets/editable_data.dart';
import '../widgets/dialog_title.dart';
import '../widgets/my_check.dart';
import '../widgets/my_icon.dart';

class ConfiguracionDeCaja extends StatefulWidget {
  const ConfiguracionDeCaja({super.key});
  @override
  State<ConfiguracionDeCaja> createState() => _ConfiguracionDeCajaState();
}

class _ConfiguracionDeCajaState extends State<ConfiguracionDeCaja> {

  String _precuenta = '';
  String _factura = '';
  String _boleta = '';
  int _lineasCabecera = 0;
  int _lineasPie = 0;
  int _nroSerieFactura = 0;
  int _nroSerieBoleta = 0;
  
  // Checkbox variables
  String _section = 'Principal';
  // Principal
  bool _esPedidoLibre = false;
  bool _firmarDocYGenerarCodQr = false;
  bool _agregarMensajeEnCabeceraDeDocs = false;
  bool _pedidoRapidoSinComanda = false;
  bool _imprimirComandaYDoc = false;
  bool _noExigirEnvioDeComandas = false;
  bool _imprimirTicketUnitario = false;
  bool _primeroPagaYLuegoMandarComanda = false;
  bool _imprimirPrecuentaSoloDeProductosEnviados = false;
  // Confirmación
  bool _confirmarEnvioDeComandas = false;
  bool _confirmarCreacionDeDocs = false;
  bool _confirmarGeneracionDePagos = false;
  bool _confirmarCreacionDePedidos = false;
  // Seguridad
  bool _exigirAutorizacionAlEliminarItemEnviado = false;
  bool _exigirUsuarioAlEliminarDoc = false;
  bool _exigirUsuarioAlCambiarPrecioDescYRecargos = false;
  bool _exigirUsuarioAlGenerarDocInterno = false;
  bool _exigirUsuarioAlEliminarPedido = false;

  Future<void> _loadData()async{
    //TODO
    setState((){
      _precuenta = 'IPCAJA';
      _factura = 'IPCAJA';
      _boleta = 'IPCAJA';
      _lineasCabecera = 2;
      _lineasPie = 3;
      _nroSerieFactura = 1;
      _nroSerieBoleta = 1;
      _esPedidoLibre = true;
      _firmarDocYGenerarCodQr = true;
      _agregarMensajeEnCabeceraDeDocs = true;
      _pedidoRapidoSinComanda = true;
      _imprimirComandaYDoc = true;
      _noExigirEnvioDeComandas = true;
      _imprimirTicketUnitario = true;
      _primeroPagaYLuegoMandarComanda = true;
      _imprimirPrecuentaSoloDeProductosEnviados = true;
      _confirmarEnvioDeComandas = true;
      _confirmarCreacionDeDocs = true;
      _confirmarGeneracionDePagos = true;
      _confirmarCreacionDePedidos = true;
      _exigirAutorizacionAlEliminarItemEnviado = true;
      _exigirUsuarioAlEliminarDoc = true;
      _exigirUsuarioAlCambiarPrecioDescYRecargos = true;
      _exigirUsuarioAlGenerarDocInterno = true;
      _exigirUsuarioAlEliminarPedido = true;
    });
  }
  
  void _editPrecuenta()async{
    String? x = await prompt(context,initialValue:_precuenta,text:'Precuenta:');
    if(x==null)return;
    setState(()=>_precuenta=x!.trim());
    //TODO: Update the db too
  }
  void _editFactura()async{
    String? x = await prompt(context,initialValue:_factura,text:'Emite documentos (factura):');
    if(x==null)return;
    setState(()=>_factura=x!.trim());
    //TODO: Update the db too
  }
  void _editBoleta()async{
    String? x = await prompt(context,initialValue:_boleta,text:'Emite documentos (boleta):');
    if(x==null)return;
    setState(()=>_boleta=x!.trim());
    //TODO: Update the db too
  }
  
  void _editLineasCabecera()async{
    String? x = await prompt(context,text:'Cant. de líneas, cabecera impresión:',initialValue:_lineasCabecera.toString(),type:TextInputType.number);
    if(x==null)return;
    int y = 0;
    try{
      y = int.parse(x!.trim());
      if(y < 0) throw 'Negative value not allowed';
    }catch(e){alert(context,'Número no válido');return;}
    setState(()=>_lineasCabecera=y);
    //TODO: Update in db too
  }
  void _editLineasPie()async{
    String? x = await prompt(context,text:'Cant. de líneas, pie impresión:',initialValue:_lineasPie.toString(),type:TextInputType.number);
    if(x==null)return;
    int y = 0;
    try{
      y = int.parse(x!.trim());
      if(y < 0) throw 'Negative value not allowed';
    }catch(e){alert(context,'Número no válido');return;}
    setState(()=>_lineasPie=y);
    //TODO: Update in db too
  }
  void _editNroSerieFactura()async{
    String? x = await prompt(context,text:'Nro. serie factura:',initialValue:_nroSerieFactura.toString(),type:TextInputType.number);
    if(x==null)return;
    int y = 0;
    try{
      y = int.parse(x!.trim());
      if(y < 0) throw 'Negative value not allowed';
    }catch(e){alert(context,'Número no válido');return;}
    setState(()=>_nroSerieFactura=y);
    //TODO: Update in db too
  }
  void _editNroSerieBoleta()async{
    String? x = await prompt(context,text:'Nro. serie boleta:',initialValue:_nroSerieBoleta.toString(),type:TextInputType.number);
    if(x==null)return;
    int y = 0;
    try{
      y = int.parse(x!.trim());
      if(y < 0) throw 'Negative value not allowed';
    }catch(e){alert(context,'Número no válido');return;}
    setState(()=>_nroSerieBoleta=y);
    //TODO: Update in db too
  }
  
  void _editSection()async{
    List<String> opts = ['Principal','Confirmación','Seguridad'];
    int? opt = await choose(context,opts);
    if(opt==null)return;
    setState(()=>_section=opts[opt!]);
  }
  
  @override
  void initState(){
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_)async=>await _loadData());
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
          MyIcon(Icons.arrow_back,()=>back(context)),sep,
        ],
      ),
      body: DefaultBackground(
        addPadding: true,
        child: Column(
          children: [
            SimpleWhiteBox(
              children: [
                DialogTitle('Configuración de caja'),
                EditableData('Precuenta:',_precuenta,_editPrecuenta),
                EditableData('Emite documentos (factura):',_factura,_editFactura),
                EditableData('Emite documentos (boleta):',_boleta,_editBoleta),
                EditableData('Cant. de líneas, cabecera impresión:',_lineasCabecera.toString(),_editLineasCabecera),
                EditableData('Cant. de líneas, pie impresión:',_lineasPie.toString(),_editLineasPie),
                EditableData('Nro. serie factura:',_nroSerieFactura.toString(),_editNroSerieFactura),
                EditableData('Nro. serie boleta:',_nroSerieBoleta.toString(),_editNroSerieBoleta),
                sep,
                EditableData('Sección:',_section,_editSection),
                sep,
                if(_section=='Principal')Column(children:[
                  MyCheck('¿Es pedido libre rápido?',_esPedidoLibre,()=>setState(()=>_esPedidoLibre=!_esPedidoLibre)),
                  MyCheck('Firmar documento y generar código QR',_firmarDocYGenerarCodQr,()=>setState(()=>_firmarDocYGenerarCodQr=!_firmarDocYGenerarCodQr)),
                  MyCheck('¿Agregar mensaje (Electrónica) en cabecera de documentos?',_agregarMensajeEnCabeceraDeDocs,()=>setState(()=>_agregarMensajeEnCabeceraDeDocs=!_agregarMensajeEnCabeceraDeDocs)),
                  MyCheck('¿Es pedido rápido sin comanda?',_pedidoRapidoSinComanda,()=>setState(()=>_pedidoRapidoSinComanda=!_pedidoRapidoSinComanda)),
                  MyCheck('Imprimir comanda y documento',_imprimirComandaYDoc,()=>setState(()=>_imprimirComandaYDoc=!_imprimirComandaYDoc)),
                  MyCheck('No exigir envío de comandas',_noExigirEnvioDeComandas,()=>setState(()=>_noExigirEnvioDeComandas=!_noExigirEnvioDeComandas)),
                  MyCheck('¿Imprimir ticket unitario?',_imprimirTicketUnitario,()=>setState(()=>_imprimirTicketUnitario=!_imprimirTicketUnitario)),
                  MyCheck('¿Primero paga y luego mandar la comanda?',_primeroPagaYLuegoMandarComanda,()=>setState(()=>_primeroPagaYLuegoMandarComanda=!_primeroPagaYLuegoMandarComanda)),
                  MyCheck('Imprimir precuenta solo de productos enviados',_imprimirPrecuentaSoloDeProductosEnviados,()=>setState(()=>_imprimirPrecuentaSoloDeProductosEnviados=!_imprimirPrecuentaSoloDeProductosEnviados)),
                ]),
                if(_section=='Confirmación')Column(children:[
                  MyCheck('¿Confirmar envío de comandas?',_confirmarEnvioDeComandas,()=>setState(()=>_confirmarEnvioDeComandas=!_confirmarEnvioDeComandas)),
                  MyCheck('¿Confirmar la creación de documentos?',_confirmarCreacionDeDocs,()=>setState(()=>_confirmarCreacionDeDocs=!_confirmarCreacionDeDocs)),
                  MyCheck('¿Confirmar la generación de pagos?',_confirmarGeneracionDePagos,()=>setState(()=>_confirmarGeneracionDePagos=!_confirmarGeneracionDePagos)),
                  MyCheck('¿Confirmar creación de pedidos?',_confirmarCreacionDePedidos,()=>setState(()=>_confirmarCreacionDePedidos=!_confirmarCreacionDePedidos)),
                ]),
                if(_section=='Seguridad')Column(children:[
                  MyCheck('¿Exigir autorización al eliminar ítem enviado?',_exigirAutorizacionAlEliminarItemEnviado,()=>setState(()=>_exigirAutorizacionAlEliminarItemEnviado=!_exigirAutorizacionAlEliminarItemEnviado)),
                  MyCheck('¿Exigir usuario al eliminar documento?',_exigirUsuarioAlEliminarDoc,()=>setState(()=>_exigirUsuarioAlEliminarDoc=!_exigirUsuarioAlEliminarDoc)),
                  MyCheck('¿Exigir usuario al cambiar precio, descuento y recargos?',_exigirUsuarioAlCambiarPrecioDescYRecargos,()=>setState(()=>_exigirUsuarioAlCambiarPrecioDescYRecargos=!_exigirUsuarioAlCambiarPrecioDescYRecargos)),
                  MyCheck('¿Exigir usuario al generar documento interno?',_exigirUsuarioAlGenerarDocInterno,()=>setState(()=>_exigirUsuarioAlGenerarDocInterno=!_exigirUsuarioAlGenerarDocInterno)),
                  MyCheck('¿Exigir usuario al eliminar pedido?',_exigirUsuarioAlEliminarPedido,()=>setState(()=>_exigirUsuarioAlEliminarPedido=!_exigirUsuarioAlEliminarPedido)),
                ]),
                sep,
              ],
            ),
          ],
        ),
      ),
    );
  }
}