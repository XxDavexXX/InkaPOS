import 'package:flutter/material.dart';
import '../services/helper.dart'; 
import '../services/hive_helper.dart';
import '../widgets/default_background.dart';
import '../widgets/dialog_title.dart';
import '../widgets/simple_line.dart';
import '../widgets/simple_white_box.dart';
import '../widgets/my_icon.dart';
import '../widgets/bottom_button.dart';
import '../widgets/div.dart';
import '../widgets/p.dart';
import 'imprimir_cierre_de_turno.dart';
import 'imprimir_cierre_de_turno_z.dart';

class CierreDeTurno extends StatefulWidget {
  const CierreDeTurno({super.key});
  @override
  State<CierreDeTurno> createState() => _CierreDeTurnoState();
}

class _CierreDeTurnoState extends State<CierreDeTurno> {

  String _type = '';
  String _turnID = '';
  int _userID = 0;
  List<Map> _tableData = [];
  String _totalVentasSoles = '';
  String _totalVentasDolares = '';

  void _imprimir()async{
    if((await confirm(context,'¿Imprimir?'))!=true)return;
    // Imprime el cierre de turno pero no cierra el turno
    await goTo(context,ImprimirCierreDeTurno(getTurnoActual()!));
  }

  void _cerrarTurno()async{
    if((await confirm(context,'¿Cerrar turno?'))!=true)return;
    //Imprime el cierre de turno y cierra el turno (volver al dashboard)
    loadThis(context,()async{
      Map datosDelTurno = getTurnoActual()!;
      await cerrarTurnoActual();
      await goTo(context,ImprimirCierreDeTurno(datosDelTurno));
      back(context);
    });
  }

  void _cierreZ()async{
    if((await confirm(context,'¿Cierre Z?'))!=true)return;
    //Imprime el cierre de turno z y cierra el turno (volver al dashboard)
    doLoad(context);
    try{
      Map datosDelTurno = getTurnoActual()!;
      await cerrarTurnoActual();
      await goTo(context,ImprimirCierreDeTurnoZ(datosDelTurno));
      back(context);
    }
    catch(e,tr){await alert(context,'Ocurrió un error');p('$e\n$tr');}
    finally{back(context);}
  }

  @override
  void initState(){
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_)async{
      Map? turnoActual = getTurnoActual();
      if(turnoActual==null){await alert(context,'No se ha abierto un turno aún.');back(context);return;}
      doLoad(context);
      try{
        int userID = getUser()!['id'];
        //Sacando los datos de los registro del turno
        List<Map> registros=getAllRegistrosDeVenta().where((reg)=>reg['turno']==turnoActual['id']).toList();
        double ventasEfectivoSoles = 0.0;
        double ventasEfectivoDolares = 0.0;
        double ventasTarjetasSoles = 0.0;
        double ventasTarjetasDolares = 0.0;
        double ventasElectronicosSoles = 0.0;
        double ventasElectronicosDolares = 0.0;
        registros.forEach((Map reg){
          reg['metodosDePago'].forEach((mp){
            // Metodo e.g. {abreviatura:'S/',nombre:'Soles',tipo:'efectivo',divisa:'soles',monto:10.0},
            if(mp['divisa']=='PEN'){
              if(mp['tipo']=='efectivo')ventasEfectivoSoles+=mp['monto'];
              if(mp['tipo']=='tarjeta')ventasTarjetasSoles+=mp['monto'];
              if(mp['tipo']=='electrónico')ventasElectronicosSoles+=mp['monto'];
            }
            if(mp['divisa']=='USD'){
              if(mp['tipo']=='efectivo')ventasEfectivoDolares+=mp['monto'];
              if(mp['tipo']=='tarjeta')ventasTarjetasDolares+=mp['monto'];
              if(mp['tipo']=='electrónico')ventasElectronicosDolares+=mp['monto'];
            }
          });
        });
        List<Map> tableData = [
          {'dato':'Fondo inicial','soles':turnoActual!['fondoInicialSoles'],'dolares':turnoActual!['fondoInicialDolares']},
          {'dato':'Ventas efectivo','soles':ventasEfectivoSoles,'dolares':ventasEfectivoDolares},
          {'dato':'Ventas tarjetas','soles':ventasTarjetasSoles,'dolares':ventasTarjetasDolares},
          {'dato':'Pagos electrónicos','soles':ventasElectronicosSoles,'dolares':ventasElectronicosDolares},
          //TODO: Egreso es lo que el usuario sacó en efectivo del monto de las ventas en efectivo. Esto se registra en la pantalla de egresos.dart
          {'dato':'Egresos','soles':'0.00','dolares':'0.00'},
          //TODO: Despues me explicarán que es esto
          {'dato':'Notas de crédito','soles':'0.00','dolares':'0.00'},
        ];
        double totalVentasSoles = 0.0;
        double totalVentasDolares = 0.0;
        registros.forEach((Map registro){
          registro['metodosDePago'].forEach((mp){
            if(mp['divisa']=='PEN')totalVentasSoles += mp['monto'];
            if(mp['divisa']=='USD')totalVentasDolares += mp['monto'];
          });
        });
        setState((){
          _turnID = turnoActual!['id'].toString();
          _userID = userID;
          _tableData = tableData;
          _totalVentasSoles = totalVentasSoles.toString();
          _totalVentasDolares = totalVentasDolares.toString();
        });
      }
      catch(e,tr){await alert(context,'Ocurrió un error');p('$e\n$tr');}
      finally{Navigator.pop(context);}
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
          MyIcon(Icons.arrow_back,()=>Navigator.pop(context)),sep,
        ],
      ),
      body: DefaultBackground(
        addPadding: true,
        child: Column(
          children: [
            P('CIERRE DE TURNO',color:Colors.white,size:19,bold:true,align:TextAlign.center),
            P('($_turnID)',color:Colors.white,bold:true,align:TextAlign.center),
            sep,
            SimpleWhiteBox(
              children: [
                DialogTitle('Resumen de ventas'),
                TableHeader(),
                const SizedBox(height:7),
                ..._tableData.map<Widget>((Map row)=>MySpecialRow(
                  row['dato'].toString(),
                  row['soles'].toString(),
                  row['dolares'].toString(),
                )),
                SimpleLine(),
                MySpecialRow(
                  'Total a ventas',
                  _totalVentasSoles,
                  _totalVentasDolares,
                  allBold: true,
                ),
              ],
            ),
            sep,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                BottomButton(Icons.print,'IMPRIMIR',_imprimir),
                BottomButton(Icons.lock,'CERRAR TURNO',_cerrarTurno),
                BottomButton(Icons.key,'CIERRE Z',_cierreZ),
              ],
            ),
            sep,
            P('Turno: $_turnID',align:P.center,size:14),
            P('Usuario: $_userID',align:P.center,size:14),
            sep,
          ],
        ),
      ),
    );
  }
}

class MySpecialRow extends StatelessWidget {
  final String col1;
  final String col2;
  final String col3;
  final bool allBold;
  const MySpecialRow(this.col1,this.col2,this.col3,{this.allBold=false,super.key});
  @override
  Widget build(BuildContext context)=>Padding(
    padding: const EdgeInsets.only(bottom:12),
    child: Row(
      children: [
        Expanded(
          child: P(col1,align:P.start,bold:true,size:14,color:Colors.black),
        ),
        SizedBox(
          width: 66,
          child: P(col2,align:P.center,bold:allBold,color:Colors.black,size:13),
        ),
        SizedBox(
          width: 66,
          child: P(col3,align:P.center,bold:allBold,color:Colors.black,size:13),
        ),
      ],
    ),
  );
}

class TableHeader extends StatelessWidget {
  const TableHeader({super.key});
  @override
  Widget build(BuildContext context)=>Row(
    children: [
      Expanded(child: const SizedBox()),
      SizedBox(
        width: 66,
        child: Center(
          child: Div(
            background: const Color.fromRGBO(49,200,101,1),
            borderRadius: 12,
            width: 42,
            height: 42,
            padding: const EdgeInsets.all(4.7),
            child: Center(
              child: Div(
                circular: true,
                borderColor: Colors.black,
                child: Center(child:P('S/',color:Colors.black,size:12,bold:true)),
              ),
            ),
          ),
        ),
      ),
      SizedBox(
        width: 66,
        child: Center(
          child: Div(
            background: const Color.fromRGBO(49,200,101,1),
            borderRadius: 12,
            width: 42,
            height: 42,
            padding: const EdgeInsets.all(4.7),
            child: Center(
              child: Div(
                circular: true,
                borderColor: Colors.black,
                child: Center(child:P(r'$',color:Colors.black,bold:true)),
              ),
            ),
          ),
        ),
      ),
    ],
  );
}