import 'package:flutter/material.dart';
import '../services/helper.dart';
import '../services/hive_helper.dart';
import '../widgets/default_background.dart';
import '../widgets/dialog_title.dart';
import '../widgets/simple_white_box.dart';
import '../widgets/my_icon.dart';
import '../widgets/button.dart';
import '../widgets/header_button.dart';
import '../widgets/div.dart';
import '../widgets/p.dart';
import 'editar_area.dart';
import 'crear_area.dart';

class Areas extends StatefulWidget {
  const Areas({super.key});
  @override
  State<Areas> createState() => _AreasState();
}

class _AreasState extends State<Areas> {

  // E.g.: {id: int, nombre: String, activo: bool}
  List<Map> _areas = [];

  @override
  void initState() {
    super.initState();
    _areas = getAllAreas();
    _areas.forEach((Map ar)=>ar['selecionado']=false);
  }

  void _onAreaTap(Map area)async{
    await goTo(context,EditarArea(area));
    setState(()=>_areas=getAllAreas());
  }

  void _onAreaSelected(Map area)=>setState(()=>area['selecionado']=!area['selecionado']);

  List<Map> _getSelectedAreas()=>_areas.where((ar)=>ar['selecionado']).toList();

  void _eliminar()async{
    List<Map> areasSelecionadas = _getSelectedAreas();
    int length = areasSelecionadas.length;
    if((await confirm(context,'¿Eliminar $length áreas?'))!=true);
    loadThis(context,()async{
      for(int i=0; i < length; i++){
        await deleteArea(areasSelecionadas[i]['id']);
      }
      setState((){
        _areas = getAllAreas();
        _areas.forEach((Map ar)=>ar['selecionado']=false);
      });
    });
  }

  void _nuevo()async{
    await goTo(context,const CrearArea());
    setState(()=>_areas=getAllAreas());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
    	backgroundColor:Theme.of(context).colorScheme.surface,
    	appBar: AppBar(
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
                DialogTitle('Áreas'),
                Wrap(
                  alignment: WrapAlignment.spaceEvenly,
                  spacing: 4,
                  runSpacing: 4,
                  children: [
                    HeaderButton(Icons.person,'NUEVO',HeaderButton.blue,_nuevo),
                    HeaderButton(Icons.delete,'ELIMINAR',HeaderButton.red,_eliminar),
                  ],
                ),
                sep,
                ..._areas.map<Widget>((Map area)=>AreaCard(
                  area,
                  ()=>_onAreaTap(area),
                  ()=>_onAreaSelected(area),
                )),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class AreaCard extends StatelessWidget {
  final Map area;
  final VoidCallback onAreaTap;
  final VoidCallback onAreaSelected;
  const AreaCard(this.area,this.onAreaTap,this.onAreaSelected,{super.key});
  @override
  Widget build(BuildContext context)=>Padding(
    padding: const EdgeInsets.only(bottom:16),
    child: Div(
      borderColor: prim(context),
      borderRadius: 23,
      child: ListTile(
        onTap: onAreaTap,
        title: P(area['nombre'],color:Colors.black),
        trailing: IconButton(
          icon: Icon(
            (area['selecionado']??false)?Icons.check_box:Icons.check_box_outline_blank,
            color:prim(context),
          ),
          onPressed: onAreaSelected,
        ),
      ),
    ),
  );
}