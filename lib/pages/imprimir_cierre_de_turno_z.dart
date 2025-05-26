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
import '../widgets/p.dart';
import '../widgets/products_table.dart';
import '../widgets/my_table.dart';
import 'imprimir.dart';

class ImprimirCierreDeTurnoZ extends StatefulWidget {
  final Map datosDelTurno;
  const ImprimirCierreDeTurnoZ(this.datosDelTurno,{super.key});
  @override
  State<ImprimirCierreDeTurnoZ> createState() => _ImprimirCierreDeTurnoZState();
}

class _ImprimirCierreDeTurnoZState extends State<ImprimirCierreDeTurnoZ> {

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

  String _hourToRange(int hour){
    if(hour==23)return '11:00 p.m. - 0:00 a.m.';
    return '${hour%12}:00 ${hour>=12?'p.m.':'a.m.'} - ${(hour+1)%12}:00 ${(hour+1)>=12?'p.m.':'a.m.'}';
  }

  final String _dateTemplate = 'day/month/year - hour:minute';
  
  //Variables
  String _caja = '';
  int _fechaInicio = 0;
  int _fechaCierre = 0;
  double _tipoDeCambio = 3.732;
  String _operador = 'caja';
  int _nroTransacciones = 4;
  String _nroTicketInicial = '';
  String _nroTicketFinal = '';
  double _valorVentaSoles = 0.0;
  double _totalSoles = 0.0;
  double _granTotalZSoles = 0.0;
  int _nroTicketsAnuladosBoleta = 0;
  double _totalTicketsAnuladosSolesBoleta = 0.0;
  int _nroTicketsAnuladosFactura = 0;
  double _totalTicketsAnuladosSolesFactura = 0.0;
  double _totalTicketBoletaSoles = 369.0;
  double _totalTicketFacturaSoles = 369.0;
  double _totalTicketBoletaDolares = 369.0;
  double _totalTicketFacturaDolares = 369.0;
  double _totalEfectivoSoles = 0.0;
  double _totalTarjetasSoles = 0.0;
  double _totalChequeSoles = 0.0;
  double _totalDepositoSoles = 0.0;
  double _totalPagElecSoles = 0.0;
  double _totalPuntosSoles = 0.0;
  double _totalCreditosSoles = 0.0;
  double _totalNotaCredSoles = 0.0;
  double _totalPorTipoDePagoSoles = 0.0;
  List<List> _ventasPorHora = [];

  @override
  void initState(){
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_)async{

      // Estos datos serán necesarios para calcular las variables de este documento
      Map usuario = getUser()!;
      final List<Map> registrosDelTurno = getAllRegistrosDeVenta().where((Map reg)=>reg['turno']==widget.datosDelTurno['id']).toList();
      final List<Map> registrosDelTurnoTipoBoletas = registrosDelTurno.where((Map reg)=>reg['tipo']=='boleta').toList();
      final List<Map> registrosDelTurnoTipoFacturas = registrosDelTurno.where((Map reg)=>reg['tipo']=='factura').toList();
      final List<Map> pedidosBorradosEnElTurno = getAllPedidosBorrados().where((Map reg)=>reg['turno']==widget.datosDelTurno['id']).toList();

      String _caja = usuario['caja'];
      int _fechaInicio = widget.datosDelTurno['id']; //El ID de los turnos es igual a su fecha de inicio en millisecondsSinceEpoch
      int _fechaCierre = DateTime.now().millisecondsSinceEpoch;
      double _tipoDeCambio = widget.datosDelTurno['precioDeVenta'];
      String _operador = getUsuario(widget.datosDelTurno['usuario'])!['usuario'];//El usuario que abrió el turno
      int _nroTransacciones = registrosDelTurno.where((Map reg)=>reg['tipo']!='Documento interno').toList().length;
      int _nroTicketInicial = registrosDelTurno.first['id'];
      int _nroTicketFinal = registrosDelTurno.last['id'];
      
      //TODO: no estoy seguro exactamente que son los 3 valores de abajo
      double _valorVentaSoles = 0.0;
      double _totalSoles = 0.0;
      double _granTotalZSoles = 0.0;
      registrosDelTurno.forEach((Map reg)=>reg['metodosDePago'].forEach((Map mp){
        if(mp['divisa']=='PEN')_valorVentaSoles += mp['monto'];
      }));
      _totalSoles = _valorVentaSoles;
      _granTotalZSoles = _valorVentaSoles;

      int _nroTicketsAnuladosBoleta = pedidosBorradosEnElTurno.where((reg)=>reg['tipo']=='boleta').length;
      int _nroTicketsAnuladosFactura = pedidosBorradosEnElTurno.where((reg)=>reg['tipo']=='factura').length;
      pedidosBorradosEnElTurno.where((reg)=>reg['tipo']=='boleta').forEach((Map pedido){
        double totalDelPedido = 0.0;
        pedido['productos'].forEach((Map prod)=>totalDelPedido = totalDelPedido + (prod['cantidad'] * prod['precioUnit']));
        _totalTicketsAnuladosSolesBoleta += totalDelPedido;
      });
      pedidosBorradosEnElTurno.where((reg)=>reg['tipo']=='factura').forEach((Map pedido){
        double totalDelPedido = 0.0;
        pedido['productos'].forEach((Map prod)=>totalDelPedido = totalDelPedido + (prod['cantidad'] * prod['precioUnit']));
        _totalTicketsAnuladosSolesFactura += totalDelPedido;
      });
      
      double _totalTicketBoletaSoles = 0.0;
      double _totalTicketBoletaDolares = 0.0;
      registrosDelTurnoTipoBoletas.forEach((Map reg)=>reg['metodosDePago'].forEach((Map mp){
        if(mp['divisa']=='PEN')_totalTicketBoletaSoles += mp['monto'];
        if(mp['divisa']=='USD')_totalTicketBoletaDolares += mp['monto'];
      }));
      double _totalTicketFacturaSoles = 0.0;
      double _totalTicketFacturaDolares = 0.0;
      registrosDelTurnoTipoFacturas.forEach((Map reg)=>reg['metodosDePago'].forEach((Map mp){
        if(mp['divisa']=='PEN')_totalTicketFacturaSoles += mp['monto'];
        if(mp['divisa']=='USD')_totalTicketFacturaDolares += mp['monto'];
      }));
      
      double _totalEfectivoSoles = 0.0;
      double _totalTarjetasSoles = 0.0;
      double _totalPagElecSoles = 0.0;
      //TODO: Estos 5 valores de abajo, ¿de donde salen y como se calculan?
      double _totalChequeSoles = 0.0;
      double _totalDepositoSoles = 0.0;
      double _totalPuntosSoles = 0.0;
      double _totalCreditosSoles = 0.0;
      double _totalNotaCredSoles = 0.0;
      registrosDelTurno.forEach((Map reg)=>reg['metodosDePago'].forEach((Map mp){
        switch(mp['tipo']){
          case 'electrónico':
            if(mp['divisa']=='PEN')_totalPagElecSoles += mp['monto'];
            break;
          case 'efectivo':
            if(mp['divisa']=='PEN')_totalEfectivoSoles += mp['monto'];
            break;
          case 'tarjeta':
            if(mp['divisa']=='PEN')_totalTarjetasSoles += mp['monto'];
            break;
        }
      }));
      double _totalPorTipoDePagoSoles = _totalEfectivoSoles+_totalTarjetasSoles+_totalChequeSoles+_totalDepositoSoles+_totalPagElecSoles+_totalPuntosSoles+_totalCreditosSoles+_totalNotaCredSoles;

      //Calculando las ventas por hora
      List<double> hoursOfTheDay = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0];
      registrosDelTurno.forEach((Map registro){
        final DateTime fecha = DateTime.fromMillisecondsSinceEpoch(registro['fecha']);
        hoursOfTheDay[fecha.hour] += registro['total'];
      });
      List<List> _ventasPorHora = [];
      for(int i=0;i<_ventasPorHora.length;i++){
        _ventasPorHora.add([_hourToRange(i),hoursOfTheDay[i]]);
      }
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
                        Te('Caja: $_caja'),
                        const SimpleLine(height:3,color:Colors.black),
                        const Te('DETALLE DE CIERRE DE CAJA (Z)',bold:true),
                        const SimpleLine(height:3,color:Colors.black),
                        sep,
                        MyRowData('FECHA INI:',getDateString(_fechaInicio,_dateTemplate)),
                        MyRowData('FECHA FIN:',getDateString(_fechaCierre,_dateTemplate)),
                        MyRowData('TIPO CAMB:',_tipoDeCambio),
                        MyRowData('Operador:',_operador),
                        sep,
                        
                        //TODO:Asi como aquí hay una sección de boleta, debería tmb haber la de factura
                        const SimpleLine(height:3,color:Colors.black),
                        const Te('SOLES',bold:true),
                        const SimpleLine(height:3,color:Colors.black),
                        const Te('BOLETA',bold:true),
                        const SimpleLine(height:3,color:Colors.black),
                        sep,
                        MyRowData('Nro Transacciones:',_nroTransacciones),
                        MyRowData('Nro ticket inicial:',_nroTicketInicial),
                        MyRowData('Nro ticket final:',_nroTicketFinal),
                        MyRowData('Valor venta s/:',_valorVentaSoles),
                        const SimpleLine(height:3,color:Colors.black),
                        MyRowData('Total S/:',_totalSoles),
                        sep,
                        const SimpleLine(height:3,color:Colors.black),
                        MyRowData('GRAN TOTAL (Z)  S/:',_granTotalZSoles),
                        const SimpleLine(height:3,color:Colors.black),
                        sep,
                        const SimpleLine(height:3,color:Colors.black),
                        Te('DETALLE ANULADOS',bold:true),
                        const SimpleLine(height:3,color:Colors.black),
                        sep,
                        MyRowData('TICKETS BOLETA',''),
                        MyRowData('Nro tickets anulado',_nroTicketsAnuladosBoleta),
                        MyRowData('Tot tickets anul S/',_totalTicketsAnuladosSolesBoleta),
                        sep,
                        MyRowData('TICKETS FACTURA',''),
                        MyRowData('Nro tickets anulado',_nroTicketsAnuladosFactura),
                        MyRowData('Tot tickets anul S/',_totalTicketsAnuladosSolesFactura),
                        sep,
                        const SimpleLine(height:3,color:Colors.black),
                        Te('VENTAS POR TIPO DE DOC',bold:true),
                        const SimpleLine(height:3,color:Colors.black),
                        MyRowData('Total Tick. Bole S/',_totalTicketBoletaSoles),
                        MyRowData('Total Tick. Fact S/',_totalTicketFacturaSoles),
                        MyRowData('Total por TD S/',_totalTicketBoletaSoles+_totalTicketFacturaSoles),
                        sep,
                        MyRowData('Total Tick. Bole \$',_totalTicketBoletaDolares),
                        MyRowData('Total Tick. Fact \$',_totalTicketFacturaDolares),
                        MyRowData('Total por TD \$',_totalTicketBoletaDolares+_totalTicketFacturaDolares),
                        sep,
                        const SimpleLine(height:3,color:Colors.black),
                        Te('VENTAS POR TIPO DE PAGO',bold:true),
                        const SimpleLine(height:3,color:Colors.black),
                        MyRowData('TOTAL EFECTIVO S/',_totalEfectivoSoles),
                        MyRowData('TOTAL TARJETAS S/',_totalTarjetasSoles),
                        MyRowData('TOTAL CHEQUE S/',_totalChequeSoles),
                        MyRowData('TOTAL DEPOSITO S/',_totalDepositoSoles),
                        MyRowData('TOTAL PAG.ELEC S/',_totalPagElecSoles),
                        MyRowData('TOTAL PUNTOS S/',_totalPuntosSoles),
                        MyRowData('TOTAL CRÉDITOS S/',_totalCreditosSoles),
                        MyRowData('TOTAL NOTACRED S/',_totalNotaCredSoles),
                        const SimpleLine(height:3,color:Colors.black),
                        MyRowData('TOTAL POR TP S/:',_totalPorTipoDePagoSoles),
                        const SimpleLine(height:3,color:Colors.black),
                        sep,
                        const SimpleLine(height:3,color:Colors.black),
                        Te('VENTAS POR HORA',bold:true),
                        const SimpleLine(height:3,color:Colors.black),
                        ..._ventasPorHora.map((List ventaPorHora)=>MyRowData(
                          ventaPorHora[0],
                          ventaPorHora[1],
                        )),
                        sep,
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