import 'package:flutter/material.dart';
import '../services/helper.dart';
import '../widgets/default_background.dart';
import '../widgets/simple_white_box.dart';
import '../widgets/editable_data.dart';
import '../widgets/dialog_title.dart';
import '../widgets/my_icon.dart';
import '../widgets/button.dart';
import '../widgets/p.dart';
import 'selecciona_rango_de_fechas.dart';

class VentasPorVendedor extends StatefulWidget {
  const VentasPorVendedor({super.key});
  @override
  State<VentasPorVendedor> createState() => _VentasPorVendedorState();
}

class _VentasPorVendedorState extends State<VentasPorVendedor> {

  final Duration _oneDay = Duration(days:1);
  late DateTime _from;
  late DateTime _to;
  List<Map> _sellers = [];
  
  @override
  void initState(){
    super.initState();
    //TODO fetch from db
    _sellers = [
      {'id':'111','nombre':'Mario','ventas':1053.0},
      {'id':'222','nombre':'Carlos','ventas':720.0},
      {'id':'333','nombre':'Alejandro','ventas':470.0},
      {'id':'444','nombre':'Manuel','ventas':360.0},
    ];
    // Set the range from yesterday to today
    DateTime now = DateTime.now();
    _from = DateTime(now.year,now.month,now.day);
    _to = DateTime(now.year,now.month,now.day);
    _from.subtract(const Duration(days:1));
    _to.add(const Duration(days:1));
  }

  void _onSellTap(Map seller)async{
    // TODO
  }

  String _displayDate(DateTime date)=>getDateString(
    date.millisecondsSinceEpoch,
    'day/month/year - hour:minute:second',
  );

  Future<void> _reloadResults()async=>loadThis(context,()async{
    //TODO: Load the _sellers based on _from & _to
  });
  void _selectDateRange()async{
    DateTime tomorrow = DateTime.now();
    tomorrow = DateTime(tomorrow.year,tomorrow.month,tomorrow.day);
    tomorrow.add(const Duration(days:1));
    List<DateTime>? newRange = await goTo(context,SeleccionaRangoDeFechas(
      firstDate: DateTime(1900),
      lastDate: tomorrow,
      initialDateFrom: _from,
      initialDateTo: _to,
      text: 'Escoge rango de fechas',
    ));
    if(newRange==null)return;
    _from = newRange.first;
    _to = newRange.last;
    _reloadResults();
  }
  void _previousDay()async{
    _from.subtract(_oneDay);
    _to.subtract(_oneDay);
    _reloadResults();
  }
  void _nextDay()async{
    _from.add(_oneDay);
    _to.add(_oneDay);
    _reloadResults();
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
          MyIcon(Icons.print,_imprimir),
          MyIcon(Icons.arrow_back,()=>back(context)),sep,
        ],
      ),
      body: DefaultBackground(
        addPadding: true,
        child: Column(
          children: [
            SimpleWhiteBox(
              children: [
                DialogTitle('Ventas por vendedor'),
                sep,
                EditableData('Desde:',_displayDate(_from),(){}),
                EditableData('Hasta:',_displayDate(_to),(){}),
                sep,
                ..._sellers.map<Widget>((Map seller)=>Card(
                  elevation: 4.7,
                  child: ListTile(
                    onTap: ()=>_onSellTap(seller),
                    title: P(seller['nombre'],bold:true),
                    trailing: P(seller['ventas'].toString()),
                  ),
                )),
                sep,
                Wrap(
                  alignment: WrapAlignment.spaceEvenly,
                  spacing: 7,
                  runSpacing: 7,
                  children: [
                    Button(P('Anterior',bold:true),_previousDay),
                    Button(P('Siguiente',bold:true),_nextDay),
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