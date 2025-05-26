import 'package:flutter/material.dart';
import '../services/helper.dart';
import '../services/db.dart';
import '../services/hive_helper.dart';
import '../widgets/default_background.dart';
import '../widgets/simple_white_box.dart';
import '../widgets/editable_data.dart';
import '../widgets/dialog_title.dart';
import '../widgets/simple_line.dart';
import '../widgets/my_icon.dart';
import '../widgets/button.dart';
import '../widgets/header_button.dart';
import '../widgets/input.dart';
import '../widgets/div.dart';
import '../widgets/p.dart';
import 'selecciona_rango_de_fechas.dart';
import 'pre_impresion_egresos.dart';

class Egresos extends StatefulWidget {
  const Egresos({super.key});
  @override
  State<Egresos> createState() => _EgresosState();
}

class _EgresosState extends State<Egresos> {

  //{'id':'111','motivo':'Motivo 1','monto':36,'fecha':1234567}
  List<Map> _egresos = [];

  late int _from;
  late int _to;
  void _editDateRange()async{
    final DateTime now = DateTime.now();
    List<DateTime>? newRange = await goTo(context,SeleccionaRangoDeFechas(
      firstDate: DateTime(1900),
      lastDate: DateTime(now.year+1),
      initialDateFrom: DateTime.fromMillisecondsSinceEpoch(_from),
      initialDateTo: DateTime.fromMillisecondsSinceEpoch(_to),
      text: 'Selecciona rango de fechas:',
    ));
    if(newRange==null)return;
    setState((){
      _from = newRange.first.millisecondsSinceEpoch;
      _to = newRange.last.millisecondsSinceEpoch;
    });
  }
  
  void _onEgresoTap(Map egreso)async{
    final List<String> opts = [
      'Editar',
      'Eliminar',
    ];
    int? opt = await choose(context,opts);
    if(opt==null)return;
    switch(opts[opt]){
      case 'Editar':_editEgreso(egreso);break;
      case 'Eliminar':_deleteEgreso(egreso);break;
    }
  }
  void _editEgreso(Map egreso)async{
    int? index = await choose(context,['Motivo','Monto'],text:'Editar:');
    if(index==0){//Motivo
      String? newReason = await prompt(context,text:'Motivo',initialValue:egreso['motivo']);
      if(newReason==null || newReason.trim()=='')return;
      doLoad(context);
      try{
        //Locally
        setState(()=>egreso['motivo']=newReason.trim());
        //Remotely
        await setEgreso(egreso);
      } catch(e) {
        await alert(context,'Ocurrió un error');
      } finally {
        Navigator.pop(context);
      }
    }
    if(index==1){//Monto
      String? newAmount = await prompt(context,text:'Monto',initialValue:egreso['monto'].toString(),type:TextInputType.number);
      if(newAmount==null)return;
      late int amount;
      try{amount = int.parse(newAmount);}
      catch(e){alert(context,'Monto no válido');return;}
      loadThis(context,()async{
        //Locally
        setState(()=>egreso['monto']=amount);
        //Remotely
        await setEgreso(egreso);
      });
    }
  }
  void _deleteEgreso(Map egreso)async{
    if((await confirm(context,'¿Eliminar egreso?'))!=true)return;
    loadThis(context,()async{
      //Delete remotely
      await deleteEgreso(egreso['id']);
      //Delete locally
      setState(()=>_egresos.remove(egreso));
    });
  }
  void _nuevo()async{
    String? motivo = await prompt(context,text:'Motivo:');
    if(motivo==null || motivo.trim()=='')return;
    String? montoString = await prompt(context,text:'Monto:',type:TextInputType.number);
    if(montoString==null || montoString.trim()=='')return;
    late int monto;
    try{monto = int.parse(montoString);}
    catch(e){alert(context,'Monto no válido');return;}
    loadThis(context,()async{
      //Remotely
      final Map map = {
        'monto': monto,
        'motivo': motivo.trim(),
        'fecha': DateTime.now().millisecondsSinceEpoch,
      };
      final int egresoID = await addEgreso(map);
      //Localy
      setState(()=>_egresos.add({'id':egresoID,...map}));
    });
  }
  void _imprimir()async{
    if((await confirm(context,'¿Imprimir?'))!=true)return;
    goTo(context,PreImpresionEgresos(_egresos.where(_egresoIsMatch).toList()));
  }
  bool _egresoIsMatch(Map eg)=>_from <= eg['fecha'] && eg['fecha'] <= _to;

  @override
  void initState(){
    super.initState();
    final DateTime now = DateTime.now();
    _from = DateTime(now.year).millisecondsSinceEpoch;
    _to = DateTime(now.year+1).millisecondsSinceEpoch;
    _egresos = getAllEgresos();
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
                DialogTitle('Egresos'),
                Wrap(
                  alignment: WrapAlignment.spaceEvenly,
                  spacing: 7,
                  runSpacing: 7,
                  children: [
                    HeaderButton(Icons.add,'NUEVO',HeaderButton.blue,_nuevo),
                    HeaderButton(Icons.add,'IMPRIMIR',HeaderButton.green,_imprimir),
                  ],
                ),
                sep,
                EditableData(
                  'Rango de fechas:',
                  getDateString(_from,'day/month/year')+' - '+getDateString(_to,'day/month/year'),
                  _editDateRange,
                ),
                sep,
                if(_egresos.isEmpty)P('No hay egresos que mostrar',align:P.center,color:Colors.grey),
                ..._egresos.where(_egresoIsMatch).map<Widget>((Map egreso)=>Card(
                  color: Colors.white,
                  child: ListTile(
                    onTap: ()=>_onEgresoTap(egreso),
                    title: P('${egreso['motivo']}\nMonto: S/${egreso['monto'].toStringAsFixed(2)}',bold:true,color:Colors.black),
                    subtitle: P(getDateString(egreso['fecha'],'day/month/year - hour:minute:second'),color:Colors.black),
                  ),
                )),
              ],
            ),
          ],
        ),
      ),
    );
  }
}