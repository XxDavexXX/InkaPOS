import 'package:flutter/material.dart';
import '../services/helper.dart';
import '../services/hive_helper.dart';
import '../widgets/default_background.dart';
import '../widgets/simple_white_box.dart';
import '../widgets/editable_data.dart';
import '../widgets/dialog_title.dart';
import '../widgets/my_icon.dart';
import '../widgets/option.dart';
import '../widgets/input.dart';
import '../widgets/p.dart';
import 'pre_impresion_registros.dart';
import 'selecciona_rango_de_fechas.dart';

class RegistroDeVentas extends StatefulWidget {
  const RegistroDeVentas({super.key});
  @override
  State<RegistroDeVentas> createState() => _RegistroDeVentasState();
}

class _RegistroDeVentasState extends State<RegistroDeVentas> {

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

  void _onRegisterTap(Map registro)async{
    final List<String> opts = ['Imprimir','Ver detalle','Eliminar'];
    int? opt = await choose(context,opts);
    if(opt==null)return;
    switch(opts[opt!]){
      case 'Imprimir':_imprimirRegistro(registro);break;
      case 'Ver detalle':_verDetalleDeRegistro(registro);break;
      case 'Eliminar':_borrarRegistro(registro);break;
    }
  }

  void _imprimirRegistro(Map registro)async{
    if((await confirm(context,'¿Imprimir venta?'))!=true)return;
    goTo(context,PreImpresionRegistros([registro]));
  }

  void _verDetalleDeRegistro(Map registro)async{
    goTo(context,PreImpresionRegistros([registro]));
  }
  
  void _borrarRegistro(Map registro)async{
    if((await confirm(context,'Eliminar venta?'))!=true)return;
    loadThis(context,()async{
      await deleteRegistroDeVenta(registro['id']);
      setState(()=>_registros.remove(registro));
      await alert(context,'Listo');
    });
  }

  void _imprimir()async{
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

  String _getTotal(List productos){
    double total = 0.0;
    productos.forEach((prod)=>total = total + (prod['cantidad'] * prod['precioUnit']));
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
                const DialogTitle('Pagos'),
                EditableData(
                  'Rango de fechas:',
                  getDateString(_desde.millisecondsSinceEpoch,'day/month/year') + ' - ' + getDateString(_hasta.millisecondsSinceEpoch,'day/month/year'),
                  _editarRangoDeFechas,
                ),
                P('Tipo:',bold:true,color:Colors.black,align:P.center),
                sep,
                Wrap(
                  alignment: WrapAlignment.spaceEvenly,
                  spacing: 4,
                  runSpacing: 4,
                  children: [
                    Option('Todos',_filtroDeTipo == 'Todos',()=>setState(()=>_filtroDeTipo='Todos')),
                    Option('Boleta',_filtroDeTipo == 'boleta',()=>setState(()=>_filtroDeTipo='boleta')),
                    Option('Factura',_filtroDeTipo == 'factura',()=>setState(()=>_filtroDeTipo='factura')),
                    Option('D.I.',_filtroDeTipo == 'documento interno',()=>setState(()=>_filtroDeTipo='documento interno')),
                  ],
                ),
                sep,
                ..._registros.where(_registroFiltrado).map<Widget>((Map registro)=>Card(
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
                sep,
              ],
            ),
          ],
        ),
      ),
    );
  }
}