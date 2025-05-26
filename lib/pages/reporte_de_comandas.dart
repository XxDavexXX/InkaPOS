import 'package:flutter/material.dart';
import '../services/helper.dart';
import '../services/hive_helper.dart';
import '../widgets/default_background.dart';
import '../widgets/simple_white_box.dart';
import '../widgets/editable_data.dart';
import '../widgets/dialog_title.dart';
import '../widgets/my_icon.dart';
import '../widgets/option.dart';
import '../widgets/p.dart';
import '../widgets/input.dart';
import 'selecciona_rango_de_fechas.dart';
import 'pre_impresion_registros.dart';
import 'pre_impresion_registros_eliminados.dart';

class ReporteDeComandas extends StatefulWidget {
  const ReporteDeComandas({super.key});
  @override
  State<ReporteDeComandas> createState() => _ReporteDeComandasState();
}

class _ReporteDeComandasState extends State<ReporteDeComandas> {
  
  String _filterCateg = 'Emitidos';

  List<Map> _registros = [];
  String _filtroDeTipo = 'Todos';
  late DateTime _desde;
  late DateTime _hasta;
  
  @override
  void initState(){
    super.initState();
    final DateTime now = DateTime.now();
    //Filtrar registros de el mes presente
    _desde = DateTime(now.year, now.month, 1);
    _hasta = DateTime(now.year, now.month+1, 1);
    _registros = getAllRegistrosDeVenta();
  }

  _onRegisterTap(Map registro)async{
    final List<String> opts = ['Imprimir','Ver detalle','Eliminar'];
    int? opt = await choose(context,opts);
    if(opt==null)return;
    switch(opts[opt!]){
      case 'Imprimir':_imprimirRegistro(registro);break;
      case 'Ver detalle':_verDetalleDeRegistro(registro);break;
      case 'Eliminar':_borrarRegistro(registro);break;
    }
  }

  _onDeletedRegisterTap(Map pedidoEliminado)async{
    final List<String> opts = ['Imprimir','Ver detalle','Eliminar'];
    int? opt = await choose(context,opts);
    if(opt==null)return;
    switch(opts[opt!]){
      case 'Imprimir':_imprimirRegistroEliminado(pedidoEliminado);break;
      case 'Ver detalle':_verDetalleDeRegistroEliminado(pedidoEliminado);break;
      case 'Eliminar':_borrarRegistroEliminado(pedidoEliminado);break;
    }
  }

  _imprimirRegistro(Map registro)async{
    if((await confirm(context,'¿Imprimir venta?'))!=true)return;
    goTo(context,PreImpresionRegistros([registro]));
  }
  _verDetalleDeRegistro(Map registro)async{
    goTo(context,PreImpresionRegistros([registro]));
  }

  _borrarRegistro(Map registro)async{
    if((await confirm(context,'Eliminar venta?'))!=true)return;
    loadThis(context,()async{
      await deleteRegistroDeVenta(registro['id']);
      setState(()=>_registros.remove(registro));
      await alert(context,'Listo');
    });
  }

  _imprimirRegistroEliminado(Map registro)async{
    if((await confirm(context,'¿Imprimir registro eliminado?'))!=true)return;
    goTo(context,PreImpresionRegistrosEliminados([registro]));
  }
  _verDetalleDeRegistroEliminado(Map registro)async{
    goTo(context,PreImpresionRegistrosEliminados([registro]));
  }
  _borrarRegistroEliminado(Map registro)async{
    if((await confirm(context,'¿Borrar registro eliminado?'))!=true)return;
    loadThis(context,()async{
      await deletePedidoBorrado(registro['id']);
      setState((){}); // Refresh the pedidos eliminados section
      await alert(context,'Listo');
    });
  }

  _imprimir()async{
    int? opt = await choose(context,[
      'Imprimir los de tipo: $_filtroDeTipo',
      'Seleccionar registros a imprimir',
    ]);
    if(opt==null)return;
    final List<Map> registros = _registros.where(_registroFiltrado).toList();
    if(opt==0){
      if((await confirm(context,'¿Imprimir?'))!=true)return;
      goTo(context,PreImpresionRegistros(registros));
    }
    if(opt==1){
      List<int>? selectedRegisters = await select(
        context,
        registros.map<String>((Map reg){
          return reg['cliente']['nombre']+'\n'+getDateString(reg['fecha'],'day/month/year - hour:minute')+'\n${_getPrefijoDelID(reg)}${reg['id']}';
        }).toList(),
        text: 'Imprimir:',
        bg: Colors.white,
        color: Colors.black,
      );
      if(selectedRegisters==null)return;
      if(selectedRegisters.isEmpty)return;
      List<Map> registrosPorImprimir = [];
      selectedRegisters.forEach((int regIndex){
        registrosPorImprimir.add(registros[regIndex]);
      });
      if((await confirm(context,'¿Imprimir?'))==true){
        goTo(context,PreImpresionRegistros(registrosPorImprimir));
      }
    }
  }

  bool _registroFiltrado(Map registro){
    DateTime fechaDelRegistro = DateTime.fromMillisecondsSinceEpoch(registro['fecha']);
    return fechaDelRegistro.isAfter(_desde) &&
      fechaDelRegistro.isBefore(_hasta) &&
      (_filtroDeTipo=='Todos' || _filtroDeTipo==registro['tipo']);
  }

  Future<void> _editarRangoDeFechas()async{
    List<DateTime>? newRange = await goTo(context,SeleccionaRangoDeFechas(
      firstDate: DateTime(1900),
      lastDate: DateTime(DateTime.now().year+1),
    ));
    if(newRange==null)return;
    setState((){
      _desde = newRange.first;
      _hasta = newRange.last;
    });
  }

  String _getTotal(List? productos){
    if(productos==null)return '0.0';
    double total = 0.0;
    productos!.forEach((prod)=>total = total + (prod['cantidad'] * prod['precioUnit']));
    return total.toString();
  }

  String _getPrefijoDelID(Map registro){
    switch(registro['tipo']){
      case 'boleta':return 'TB-';
      case 'factura':return 'TF-';
      default: return '';
    }
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
          MyIcon(Icons.print,_imprimir),sep,
          MyIcon(Icons.arrow_back,()=>back(context)),sep,
        ],
      ),
      body: DefaultBackground(
        addPadding: true,
        child: Column(
          children: [
            SimpleWhiteBox(
              children: [
                DialogTitle('Reporte de comandas'),
                sep,
                EditableData(
                  'Rango de fechas:',
                  getDateString(_desde.millisecondsSinceEpoch,'day/month/year')+' - '+getDateString(_hasta.millisecondsSinceEpoch,'day/month/year'),
                  (){},
                ),
                sep,
                P('Tipo:',bold:true,color:Colors.black,align:P.center),
                sep,
                Wrap(
                  alignment: WrapAlignment.spaceEvenly,
                  spacing: 7,
                  runSpacing: 7,
                  children: [
                    Option('Emitidos',_filterCateg=='Emitidos',()=>setState(()=>_filterCateg='Emitidos')),
                    Option('Eliminados',_filterCateg=='Eliminados',()=>setState(()=>_filterCateg='Eliminados')),
                  ],
                ),
                sep,
                if(_filterCateg=='Emitidos')..._registros.where(_registroFiltrado).map<Widget>((Map registro)=>Card(
                  elevation: 4.7,
                  shadowColor: const Color.fromRGBO(84,84,84,1),
                  color: Colors.white,
                  child: ListTile(
                    onTap: ()=>_onRegisterTap(registro),
                    title: P(registro['cliente']['nombre'],size:14,bold:true,color:Colors.black,overflow:TextOverflow.clip),
                    subtitle: P(getDateString(
                      registro['fecha'],
                      'day/month/year - hour:minute',
                    )+'\n${_getPrefijoDelID(registro)}${registro['id']}',color:Colors.black,overflow:TextOverflow.clip,size:12),
                    trailing: P('Total:\n${_getTotal(registro['productos'])}',size:12,align:P.center,color:Colors.black,overflow:TextOverflow.clip),
                  ),
                )),
                if(_filterCateg=='Eliminados')...getAllPedidosBorrados().where((x)=>x['turno']==(getTurnoActual()??{'id':''})['id']).map((pedElim)=>Card(
                  elevation: 4.7,
                  shadowColor: const Color.fromRGBO(84,84,84,1),
                  color: Colors.white,
                  child: ListTile(
                    onTap: ()=>_onDeletedRegisterTap(pedElim),
                    title: P(pedElim['cliente']==null?'':pedElim['cliente']['nombre']??'',size:14,bold:true,color:Colors.black,overflow:TextOverflow.clip),
                    subtitle: P(getDateString(
                      pedElim['fecha'],
                      'day/month/year - hour:minute',
                    ),color:Colors.black,overflow:TextOverflow.clip,size:12),
                    trailing: P('Total:\n${_getTotal(pedElim['productos'])}',size:12,align:P.center,color:Colors.black,overflow:TextOverflow.clip),
                  ),
                )),
                sep,
              ],
            ),
          ],
        ),
      ),
    );
  }
}





















/*TODO: The entire file before copying from registro_de_ventas.dart

import 'package:flutter/material.dart';
import '../services/helper.dart';
import '../widgets/default_background.dart';
import '../widgets/simple_white_box.dart';
import '../widgets/editable_data.dart';
import '../widgets/dialog_title.dart';
import '../widgets/my_icon.dart';
import '../widgets/option.dart';
import '../widgets/p.dart';

class ReporteDeComandas extends StatefulWidget {
  const ReporteDeComandas({super.key});
  @override
  State<ReporteDeComandas> createState() => _ReporteDeComandasState();
}

class _ReporteDeComandasState extends State<ReporteDeComandas> {

  String _filterCateg = 'Emitidos';
  List<Map> _products = [];
  void _onProducTap(Map product)async{
    // TODO
  }
  bool _productIsMatch(Map prod)=>prod['categoria']==_filterCateg;
  
  @override
  void initState(){
    super.initState();
    //TODO: Fetch from db
    _products = [
      {'id':'111','nombre':'Flor de caña','fecha':1728312946890,'vendedor':'LIBRE','obs':'','categoria':'Emitidos'},
      {'id':'222','nombre':'Avena integral','fecha':1728312946890,'vendedor':'LIBRE','obs':'','categoria':'Emitidos'},
      {'id':'333','nombre':'Ron Cartabio','fecha':1728312946890,'vendedor':'LIBRE','obs':'','categoria':'Eliminados'},
      {'id':'444','nombre':'Coca Cola','fecha':1728312946890,'vendedor':'LIBRE','obs':'','categoria':'Eliminados'},
    ];
  }

  void _imprimir()async{
    if((await confirm(context,'¿Imprimir?'))!=true)return;
    //TODO
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
          MyIcon(Icons.print,_imprimir),sep,
          MyIcon(Icons.arrow_back,()=>back(context)),sep,
        ],
      ),
      body: DefaultBackground(
        addPadding: true,
        child: Column(
          children: [
            SimpleWhiteBox(
              children: [
                DialogTitle('Reporte de comandas'),
                sep,
                EditableData('Fecha inicial','01/08/2024 - 12:00 AM',(){}),
                EditableData('Fecha final','26/08/2024 - 05:18 PM',(){}),
                sep,
                P('Tipo:',bold:true,color:Colors.black,align:P.center),
                sep,
                Wrap(
                  alignment: WrapAlignment.spaceEvenly,
                  spacing: 7,
                  runSpacing: 7,
                  children: [
                    Option('Emitidos',_filterCateg=='Emitidos',()=>setState(()=>_filterCateg='Emitidos')),
                    Option('Eliminados',_filterCateg=='Eliminados',()=>setState(()=>_filterCateg='Eliminados')),
                  ],
                ),
                sep,
                ..._products.where(_productIsMatch).map<Widget>((Map product)=>Card(
                  elevation: 4.7,
                  child: ListTile(
                    onTap: ()=>_onProducTap(product),
                    title: P(product['nombre'],bold:true),
                    subtitle: P(
                      getDateString(product['fecha'],'day/month/year - hour:minute:second'),
                      size: 12,
                    ),
                    trailing: P('Vendedor:\n${product['vendedor']}',align:P.center,size:12),
                  ),
                )),
                sep,
              ],
            ),
          ],
        ),
      ),
    );
  }
}

*/