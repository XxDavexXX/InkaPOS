import 'package:flutter/material.dart';
import '../services/helper.dart';
import '../services/hive_helper.dart';
import '../widgets/default_background.dart';
import '../widgets/simple_white_box.dart';
import '../widgets/editable_data.dart';
import '../widgets/dialog_title.dart';
import '../widgets/my_icon.dart';
import '../widgets/input.dart';
import '../widgets/p.dart';
import 'selecciona_rango_de_fechas.dart';
import 'imprimir_paloteo.dart';

class ReporteDePaloteo extends StatefulWidget {
  const ReporteDePaloteo({super.key});
  @override
  State<ReporteDePaloteo> createState() => _ReporteDePaloteoState();
}

class _ReporteDePaloteoState extends State<ReporteDePaloteo> {

  late final TextEditingController _search;
  String _filter = '';
  List<Map> _products = [];
  final String _dateTemplate = 'day/month/year';
  late DateTime _desde;
  late DateTime _hasta;
  bool _productsIsMatch(Map p)=>p['nombre'].toLowerCase().contains(_filter);
  void _editRangoDeFechas()async{
    List<DateTime>? range = await goTo(context,SeleccionaRangoDeFechas(
      firstDate: DateTime(1900),
      lastDate: DateTime(DateTime.now().year+1),
      initialDateFrom: _desde,
      initialDateTo: _hasta,
    ));
    if(range==null)return;
    setState((){
      _desde = range.first;
      _hasta = range.last;
    });
  }

  List<Map> getProductsFromTheDateRange(){
    List<Map> products = [];
    getAllRegistrosDeVenta().forEach((Map reg){
      bool inRange = _desde.millisecondsSinceEpoch <= reg['fecha'] && reg['fecha'] <= _hasta.millisecondsSinceEpoch;
      if(inRange)reg['productos'].forEach((prod)=>products.add(prod));
    });
    return products;
  }
  
  @override
  void initState(){
    super.initState();
    _search = TextEditingController();
    //El rango inicial de fechas es del mes actual
    DateTime now = DateTime.now();
    _desde = DateTime(now.year,now.month,1);
    _hasta = DateTime(
      _desde.month==12?_desde.year+1:_desde.year,
      _desde.month==12?1:_desde.month+1,
      1,
    );
    //Agregar los productos de los registros de venta
    _products = getProductsFromTheDateRange();
  }

  @override
  void dispose(){
    _search.dispose();
    super.dispose();
  }

  void _imprimir()async{
    if((await confirm(context,'¿Imprimir?'))!=true)return;
    goTo(context,ImprimirPaloteo({
      'productos': _products.where(_productsIsMatch).toList(),
      'desde': getDateString(_desde.millisecondsSinceEpoch,_dateTemplate),
      'hasta': getDateString(_hasta.millisecondsSinceEpoch,_dateTemplate),
    }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
    	backgroundColor:Theme.of(context).colorScheme.surface,
    	appBar: AppBar(
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
                DialogTitle('Reporte de paloteo'),
                sep,
                EditableData(
                  'Rango de fechas:',
                  getDateString(_desde.millisecondsSinceEpoch,_dateTemplate)+' - '+getDateString(_hasta.millisecondsSinceEpoch,_dateTemplate),
                  _editRangoDeFechas,
                ),
                sep,
                Input(
                  _search,
                  hint: 'Producto...',
                  hintColor: Colors.grey,
                  leading: Icon(Icons.search,color:Colors.white),
                  onSubmitted: (x)=>setState(()=>_filter=x.trim().toLowerCase()),
                  trailing: IconButton(
                    icon: Icon(Icons.close,color:Colors.white),
                    onPressed: ()=>setState(()=>_filter=''),
                  ),
                ),
                sep,
                ..._products.where(_productsIsMatch).map<Widget>((Map prod)=>Card(
                  elevation: 4.7,
                  shadowColor: const Color.fromRGBO(84,84,84,1),
                  child: ListTile(
                    title: P(prod['nombre'],bold:true),
                    subtitle: P('Cantidad: ${prod['cantidad']}',size:14),
                    trailing: P('Total:\n${(prod['precioUnit'] * prod['cantidad']).toStringAsFixed(2)}',align:P.center,size:14),
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