import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:widgets_to_image/widgets_to_image.dart';
import '../services/helper.dart';
import '../services/hive_helper.dart';
import '../widgets/my_row_data.dart';
import '../widgets/simple_line.dart';
import '../widgets/my_icon.dart';
import '../widgets/div.dart';
import '../widgets/te.dart';
import '../widgets/products_table.dart';
import '../widgets/my_table.dart';
import 'imprimir.dart';

class ImprimirCierreDeTurno extends StatefulWidget {
  final Map datosDelTurno;
  const ImprimirCierreDeTurno(this.datosDelTurno,{super.key});
  @override
  State<ImprimirCierreDeTurno> createState() => _ImprimirCierreDeTurnoState();
}

class _ImprimirCierreDeTurnoState extends State<ImprimirCierreDeTurno> {

  WidgetsToImageController _wti = WidgetsToImageController();

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

  //La plantilla de las fechas en estas pantallas
  final String _dateTemplate = 'day/month/year - hour:minute';
  
  String _caja = '';
  String _local = '';
  String _turnoID = '';
  int _fechaInicio = 0;
  int _fechaCierre = 0;
  double _tipoDeCambioCompra = 0.0;
  double _tipoDeCambioVenta = 0.0;
  double _totalVentaSoles = 0.0;
  double _totalVentaDolares = 0.0;
  int _pedidosEliminadosDeTipoBoleta = 0;// (numero de ellos)
  double _pedidosEliminadosDeTipoBoletaSuma = 0.0;// (la suma de ellos)
  int _pedidosEliminadosDeTipoFactura = 0;// (numero de ellos)
  double _pedidosEliminadosDeTipoFacturaSuma = 0.0;// (la suma de ellos)
  List<Map> _resumenPagosEnEfectivo = [];// (fields: dato, soles, dolares)
  List<Map> _resumenPagosConTarjeta = [];// (fields: dato, soles, dolares)
  List<Map> _resumenPagosElectronicos = [];// (fields: dato, soles, dolares)
  List<Map> _resumenOtrosPagos = [];// (fields: dato, soles, dolares)
  List<Map> _resumenVentaSoles = [];// (fields: dato, soles)
  List<Map> _resumenVentaDolares = [];// (fields: dato, dolares)
  String _usuario = '';
  String _cajero = '';

  @override
  void initState(){
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_)async{
      Map user = getUser()!;
      setState((){
        _caja = user['caja']??'CAJA';
        _local = user['local']??'LOCAL';
        Map turno = widget.datosDelTurno;
        _turnoID = turno['id'].toString();
        _fechaInicio = int.parse('${turno['id']}');//En este caso, el ID del turno son los millisecondsSinceEpoch
        _fechaCierre = DateTime.now().millisecondsSinceEpoch;
        _tipoDeCambioCompra = turno['precioDeCompra'];
        _tipoDeCambioVenta = turno['precioDeVenta'];
        
        List<Map> registros = getAllRegistrosDeVenta().where((x)=>x['turno'].toString()==turno['id'].toString()).toList();
        
        registros.forEach((reg)=>reg['metodosDePago'].forEach((mp){
          if(mp['divisa']=='PEN')_totalVentaSoles+=mp['monto'];
          if(mp['divisa']=='USD')_totalVentaDolares+=mp['monto'];
        }));

        List<Map> pedidoEliminados = getAllPedidosBorrados().where((Map ped)=>ped['turno']==turno['id'].toString()).toList();
        _pedidosEliminadosDeTipoBoleta = pedidoEliminados.where((x)=>x['tipo']=='boleta').length;
        pedidoEliminados.where((x)=>x['tipo']=='boleta').forEach((Map pedido){
          double totalDelPedido = 0.0;
          pedido['productos'].forEach((Map prod)=>totalDelPedido = totalDelPedido + (prod['cantidad'] * prod['precioUnit']));
          _pedidosEliminadosDeTipoBoletaSuma += totalDelPedido;
        });
        _pedidosEliminadosDeTipoFactura = pedidoEliminados.where((x)=>x['tipo']=='factura').length;
        pedidoEliminados.where((x)=>x['tipo']=='factura').forEach((Map pedido){
          double totalDelPedido = 0.0;
          pedido['productos'].forEach((Map prod)=>totalDelPedido = totalDelPedido + (prod['cantidad'] * prod['precioUnit']));
          _pedidosEliminadosDeTipoFacturaSuma += totalDelPedido;
        });
        _usuario = user['usuario']??'USUARIO';
        _cajero = user['cajero']??'CAJERO';

        double pagosEnEfectivoDeVentasEnSoles = 0.0;
        double pagosEnEfectivoDeVentasEnDolares = 0.0;
        double pagosEnEfectivoDePropinasEnSoles = 0.0;
        double pagosEnEfectivoDePropinasEnDolares = 0.0;
        double pagosConTarjetaDeVentasEnSoles = 0.0;
        double pagosConTarjetaDeVentasEnDolares = 0.0;
        double pagosConTarjetaDePropinasEnSoles = 0.0;
        double pagosConTarjetaDePropinasEnDolares = 0.0;
        double pagosElectronicosDeVentasEnSoles = 0.0;
        double pagosElectronicosDeVentasEnDolares = 0.0;
        double pagosElectronicosDePropinasEnSoles = 0.0;
        double pagosElectronicosDePropinasEnDolares = 0.0;

        registros.forEach((Map reg)=>reg['metodosDePago'].forEach((Map mp){
          switch(mp['tipo']){
            case 'efectivo':
              if(mp['divisa']=='PEN')pagosEnEfectivoDeVentasEnSoles += mp['monto'];
              if(mp['divisa']=='USD')pagosEnEfectivoDeVentasEnDolares += mp['monto'];
              break;
            case 'electrónico':
              if(mp['divisa']=='PEN')pagosElectronicosDeVentasEnSoles += mp['monto'];
              if(mp['divisa']=='USD')pagosElectronicosDeVentasEnDolares += mp['monto'];
              break;
            case 'tarjeta':
              if(mp['divisa']=='PEN')pagosConTarjetaDeVentasEnSoles += mp['monto'];
              if(mp['divisa']=='USD')pagosConTarjetaDeVentasEnDolares += mp['monto'];
              break;
          }
        }));
        _resumenPagosEnEfectivo = [
          {'dato':'Ventas','soles':pagosEnEfectivoDeVentasEnSoles,'dolares':pagosEnEfectivoDeVentasEnDolares},
          {'dato':'Propinas','soles':pagosEnEfectivoDePropinasEnSoles,'dolares':pagosEnEfectivoDePropinasEnDolares},
          {'dato':'Total','soles':pagosEnEfectivoDeVentasEnSoles+pagosEnEfectivoDePropinasEnSoles,'dolares':pagosEnEfectivoDeVentasEnDolares+pagosEnEfectivoDePropinasEnDolares},
        ];// (fields: dato, soles, dolares)
        _resumenPagosConTarjeta = [
          {'dato':'Ventas','soles':pagosConTarjetaDeVentasEnSoles,'dolares':pagosConTarjetaDeVentasEnDolares},
          {'dato':'Propinas','soles':pagosConTarjetaDePropinasEnSoles,'dolares':pagosConTarjetaDePropinasEnDolares},
          {'dato':'Total','soles':pagosConTarjetaDeVentasEnSoles+pagosConTarjetaDePropinasEnSoles,'dolares':pagosConTarjetaDeVentasEnDolares+pagosConTarjetaDePropinasEnDolares},
        ];// (fields: dato, soles, dolares)
        _resumenPagosElectronicos = [
          {'dato':'Ventas','soles':pagosElectronicosDeVentasEnSoles,'dolares':pagosElectronicosDeVentasEnDolares},
          {'dato':'Propinas','soles':pagosElectronicosDePropinasEnSoles,'dolares':pagosElectronicosDePropinasEnDolares},
          {'dato':'Total','soles':pagosElectronicosDeVentasEnSoles+pagosElectronicosDePropinasEnSoles,'dolares':pagosElectronicosDeVentasEnDolares+pagosElectronicosDePropinasEnDolares},
        ];// (fields: dato, soles, dolares)
        
        _resumenOtrosPagos = [
          {'dato':'Ventas','soles':'0.00','dolares':'0.00'},
          {'dato':'Propinas','soles':'0.00','dolares':'0.00'},
          {'dato':'Total','soles':'0.00','dolares':'0.00'},
        ];// (fields: dato, soles, dolares)

        _resumenVentaSoles = [
          {'dato':'Tot efectivo:','soles':pagosEnEfectivoDeVentasEnSoles+pagosEnEfectivoDePropinasEnSoles},
          {'dato':'Tot tarjetas:','soles':pagosConTarjetaDeVentasEnSoles+pagosConTarjetaDePropinasEnSoles},
          {'dato':'Tot P.Electr:','soles':pagosElectronicosDeVentasEnSoles+pagosElectronicosDePropinasEnSoles},
          {'dato':'Tot Otros:','soles':'0.00'},
        ];// (fields: dato, soles)
        _resumenVentaDolares = [
          {'dato':'Tot efectivo:','dolares':pagosEnEfectivoDeVentasEnDolares+pagosEnEfectivoDePropinasEnDolares},
          {'dato':'Tot tarjetas:','dolares':pagosConTarjetaDeVentasEnDolares+pagosConTarjetaDePropinasEnDolares},
          {'dato':'Tot P.Electr:','dolares':pagosElectronicosDeVentasEnDolares+pagosElectronicosDePropinasEnDolares},
          {'dato':'Tot Otros:','dolares':'0.00'},
        ];// (fields: dato, dolares)

      });
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
                        Te(getDateString(DateTime.now().millisecondsSinceEpoch,_dateTemplate)),
                        Te('Local: $_local'),
                        Te('Caja: $_caja'),
                        Te('Turno: $_turnoID'),
                        Te('F. inicio: '+getDateString(_fechaInicio,_dateTemplate)),
                        Te('F. cierre: '+getDateString(_fechaCierre,_dateTemplate)),
                        sep,
                        MyRowData('T.C. COM:',_tipoDeCambioCompra),
                        MyRowData('T.C. VENT:',_tipoDeCambioVenta),
                        sep,
                        const SimpleLine(height:3,color:Colors.black),
                        Te('DOCUMENTOS GENERADOS',bold:true),
                        const SimpleLine(height:3,color:Colors.black),
                        MyRowData('TOTAL VENTA S/:',_totalVentaSoles),
                        MyRowData('TOTAL VENTA \$:',_totalVentaDolares),
                        sep,
                        Te('SOLES',bold:true),
                        const SimpleLine(height:3,color:Colors.black),
                        Te('DOCUMENTOS ELIMINADOS',bold:true),
                        const SimpleLine(height:3,color:Colors.black),
                        Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,children:[
                          Te('TK. BOLETA'),
                          Te(_pedidosEliminadosDeTipoBoleta),
                          Te(_pedidosEliminadosDeTipoBoletaSuma),
                        ]),
                        Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,children:[
                          Te('TK. FACTURA'),
                          Te(_pedidosEliminadosDeTipoFactura),
                          Te(_pedidosEliminadosDeTipoFacturaSuma),
                        ]),
                        const SimpleLine(height:3,color:Colors.black),
                        Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,children:[
                          Te('TOTALES:'),
                          Te('${_pedidosEliminadosDeTipoBoleta + _pedidosEliminadosDeTipoFactura}'),
                          Te('${_pedidosEliminadosDeTipoBoletaSuma + _pedidosEliminadosDeTipoFacturaSuma}'),
                        ]),
                        sep,
                        const SimpleLine(height:3,color:Colors.black),
                        Te('INGRESOS',bold:true),
                        const SimpleLine(height:3,color:Colors.black),
                        sep,
                        Te('RESÚMEN - PAGOS EN EFECTIVO',bold:true),
                        MyTable([
                          const [
                            Cell('',bold:true),
                            Cell('S/',bold:true,width:66),
                            Cell('\$',bold:true,width:66),
                          ],
                          ..._resumenPagosEnEfectivo.map<List<Cell>>((Map data)=>[
                            Cell(data['dato']),
                            Cell(data['soles'],width:66),
                            Cell(data['dolares'],width:66),
                          ]),
                        ]),
                        sep,
                        Te('RESÚMEN - PAGOS CON TARJETAS',bold:true),
                        MyTable([
                          const [
                            Cell('',bold:true),
                            Cell('S/',bold:true,width:66),
                            Cell('\$',bold:true,width:66),
                          ],
                          ..._resumenPagosConTarjeta.map<List<Cell>>((Map data)=>[
                            Cell(data['dato']),
                            Cell(data['soles'],width:66),
                            Cell(data['dolares'],width:66),
                          ]),
                        ]),
                        sep,
                        Te('RESÚMEN - PAGOS ELECTRÓNICOS',bold:true),
                        MyTable([
                          const [
                            Cell('',bold:true),
                            Cell('S/',bold:true,width:66),
                            Cell('\$',bold:true,width:66),
                          ],
                          ..._resumenPagosElectronicos.map<List<Cell>>((Map data)=>[
                            Cell(data['dato']),
                            Cell(data['soles'],width:66),
                            Cell(data['dolares'],width:66),
                          ]),
                        ]),
                        sep,
                        Te('RESÚMEN - OTROS PAGOS',bold:true),
                        MyTable([
                          const [
                            Cell('',bold:true),
                            Cell('S/',bold:true,width:66),
                            Cell('\$',bold:true,width:66),
                          ],
                          ..._resumenOtrosPagos.map<List<Cell>>((Map data)=>[
                            Cell(data['dato']),
                            Cell(data['soles'],width:66),
                            Cell(data['dolares'],width:66),
                          ]),
                        ]),
                        sep,
                        Te('RESÚMEN - VENTA SOLES',bold:true),
                        MyTable([
                          const [
                            Cell('',bold:true),
                            Cell('S/',bold:true,width:66),
                          ],
                          ..._resumenVentaSoles.map<List<Cell>>((Map data)=>[
                            Cell(data['dato']),
                            Cell(data['soles'],width:66),
                          ]),
                        ]),
                        sep,
                        Te('RESÚMEN - VENTA DÓLARES',bold:true),
                        MyTable([
                          const [
                            Cell('',bold:true),
                            Cell('\$',bold:true,width:66),
                          ],
                          ..._resumenVentaDolares.map<List<Cell>>((Map data)=>[
                            Cell(data['dato']),
                            Cell(data['dolares'],width:66),
                          ]),
                        ]),
                        MyRowData('USUARIO:',_usuario),
                        MyRowData('CAJERO(A):',_cajero),
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