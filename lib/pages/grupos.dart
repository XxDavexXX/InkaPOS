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
import 'crear_grupo.dart';
import 'editar_grupo.dart';

class Grupos extends StatefulWidget {
  const Grupos({super.key});
  @override
  State<Grupos> createState() => _GruposState();
}

class _GruposState extends State<Grupos> {

  //E.g.: {id: int, nombre: String, activo: bool}
  List<Map> _groups = [];

  @override
  void initState() {
    super.initState();
    _groups = getAllGrupos();
  }

  void _onGroupTap(Map group)async{
    await goTo(context,EditarGrupo(group));
    setState(()=>_groups=getAllGrupos());
  }

  void _onGroupSelected(Map group){
    setState(()=>group['seleccionado']=!(group['seleccionado']??false));
  }

  List<Map> _getSelectedGroups()=>_groups.where((Map g)=>g['seleccionado']==true).toList();

  void _nuevo()async{
    await goTo(context,const CrearGrupo());
    setState(()=>_groups = getAllGrupos());
  }
  
  void _eliminar()async{
    List<Map> selectedGroups = _getSelectedGroups();
    int length = selectedGroups.length;
    if((await confirm(context,'¿Eliminar $length grupos?'))!=true)return;
    loadThis(context,()async{
      for(int i=0; i < length; i++){
        await deleteGrupo(selectedGroups[i]['id']);
      }
      setState(()=>_groups=getAllGrupos());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
    	backgroundColor:Theme.of(context).colorScheme.surface,
    	appBar: AppBar(
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
                const DialogTitle('Grupos'),
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
                ..._groups.map<Widget>((Map group)=>GroupCard(
                  group,
                  ()=>_onGroupTap(group),
                  ()=>_onGroupSelected(group),
                )),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class GroupCard extends StatelessWidget {
  final Map group;
  final VoidCallback onGroupTap;
  final VoidCallback onGroupSelected;
  const GroupCard(this.group,this.onGroupTap,this.onGroupSelected,{super.key});
  @override
  Widget build(BuildContext context)=>Padding(
    padding: const EdgeInsets.only(bottom:16),
    child: Div(
      borderColor: prim(context),
      borderRadius: 23,
      padding: const EdgeInsets.symmetric(horizontal:12,vertical:5),
      child: ListTile(
        onTap: onGroupTap,
        title: P(group['nombre'],color:Colors.black),
        trailing: IconButton(
          icon: Icon(
            (group['seleccionado']??false)?Icons.check_box:Icons.check_box_outline_blank,
            color:prim(context),
          ),
          onPressed: onGroupSelected,
        ),
      ),
    ),
  );
}