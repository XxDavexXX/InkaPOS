import 'package:flutter/material.dart';
import '../services/helper.dart';
import '../services/hive_helper.dart';
import '../widgets/default_background.dart';
import '../widgets/dialog_title.dart';
import '../widgets/simple_white_box.dart';
import '../widgets/input.dart';
import '../widgets/my_icon.dart';
import '../widgets/editable_data.dart';
import '../widgets/header_button.dart';
import '../widgets/button.dart';
import '../widgets/div.dart';
import '../widgets/p.dart';
import 'selecciona_subgrupos.dart';
import 'crear_observacion.dart';
import 'editar_observacion.dart';

class Observaciones extends StatefulWidget {
  const Observaciones({super.key});
  @override
  State<Observaciones> createState() => _ObservacionesState();
}

class _ObservacionesState extends State<Observaciones> {

  // Son detalles que se le puede asignar a los productos. Ejemplo: a una gaseosa se le pueden asignar las observaciones: "Helada", "Sin helar", etc.
  //E.g.: {id:'111',nombre:'Sin helar',nombreCorto:'Helar',subgrupos:[], activo: true},
  List<Map> _observaciones = [];
  String _filter = '';
  late final TextEditingController _input;

  @override
  void initState() {
    super.initState();
    _input = TextEditingController();
    _observaciones = getAllObservaciones();
    _observaciones.forEach((obs)=>obs['selecionado']=false);
  }

  void _onObservationTap(Map observation)async{
    await goTo(context,EditarObservacion(observation));
    setState(()=>_observaciones=getAllObservaciones());
  }

  void _onObservationSelected(Map observation){
    setState(()=>observation['selecionado']=!(observation['selecionado']??false));
  }

  bool _filterObservations(Map o)=>o['nombre'].toLowerCase().contains(_filter);

  void _nuevo()async{
    await goTo(context,const CrearObservacion());
    setState(()=>_observaciones = getAllObservaciones());
  }
  void _eliminar()async{
    List<Map> observacionesSelecionadas = _observaciones.where((obs)=>obs['selecionado']).toList();
    int length = observacionesSelecionadas.length;
    if((await confirm(context,'¿Eliminar $length observaciones?'))!=true)return;
    loadThis(context,()async{
      for(int i=0; i < length; i++){
        await deleteObservacion(observacionesSelecionadas[i]['id']);
      }
      setState((){
        _observaciones = getAllObservaciones();
        _observaciones.forEach((obs)=>obs['selecionado']=false);
      });
    });
  }

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
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
            SimpleWhiteBox(
              children: [
                DialogTitle('Observaciones'),
                Wrap(
                  alignment: WrapAlignment.spaceEvenly,
                  spacing: 4,
                  runSpacing: 4,
                  children: [
                    HeaderButton(Icons.person,'NUEVO',const Color.fromRGBO(64,138,252,1),_nuevo),
                    HeaderButton(Icons.delete,'ELIMINAR',const Color.fromRGBO(205,1,0,1),_eliminar),
                  ],
                ),
                sep,
                Input(
                  _input,
                  leading: Icon(Icons.search,color:Colors.white),
                  hint: 'Buscar observaciones...',
                  onSubmitted: (x)=>setState(()=>_filter=x.trim().toLowerCase()),
                ),
                sep,
                ..._observaciones.where(_filterObservations).map<Widget>((Map observation)=>ObservationCard(
                  observation,
                  ()=>_onObservationTap(observation),
                  ()=>_onObservationSelected(observation),
                )),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ObservationCard extends StatelessWidget {
  final Map observation;
  final VoidCallback onObservationTap;
  final VoidCallback onObservationSelected;
  const ObservationCard(this.observation,this.onObservationTap,this.onObservationSelected,{super.key});
  @override
  Widget build(BuildContext context)=>Padding(
    padding: const EdgeInsets.only(bottom:16),
    child: Div(
      borderColor: prim(context),
      borderRadius: 23,
      padding: const EdgeInsets.symmetric(horizontal:12,vertical:5),
      child: ListTile(
        onTap: onObservationTap,
        title: P(observation['nombre'],color:Colors.black),
        trailing: IconButton(
          icon: Icon(
            (observation['selecionado']??false)?Icons.check_box:Icons.check_box_outline_blank,
            color:prim(context),
          ),
          onPressed: onObservationSelected,
        ),
      ),
    ),
  );
}