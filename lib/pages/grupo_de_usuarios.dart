import 'package:flutter/material.dart';
import '../services/helper.dart';
import '../services/hive_helper.dart';
import '../widgets/default_background.dart';
import '../widgets/simple_white_box.dart';
import '../widgets/editable_data.dart';
import '../widgets/dialog_title.dart';
import '../widgets/my_icon.dart';
import '../widgets/button.dart';
import '../widgets/p.dart';
import 'grupo.dart';

class GrupoDeUsuarios extends StatefulWidget {
  const GrupoDeUsuarios({super.key});
  @override
  State<GrupoDeUsuarios> createState() => _GrupoDeUsuariosState();
}

class _GrupoDeUsuariosState extends State<GrupoDeUsuarios> {

  List<Map> _groups = [];

  void _nuevo()async{
    String? nombre = await prompt(context,text:'Nombre de nuevo grupo de usuarios:');
    if(nombre==null)return;
    Map map = {'nombre':nombre,'activo':true};
    int id = await addGrupoDeUsuarios(map);
    map['id'] = id;
    setState(()=>_groups.add(map));
  }

  void _onGroupTap(Map group)async{
    await goTo(context,Grupo(group));
    setState(()=>_groups = getAllGruposDeUsuarios());
  }

  void _groupMenu(Map group)async{
    final List<String> opts = ['Eliminar','Cancelar'];
    int? opt = await choose(context,opts);
    if(opt==null)return;
    switch(opt!){
      case 'Eliminar':_deleteGroup(group);break;
    }
  }

  void _deleteGroup(Map group)async{
    if((await confirm(context,'¿Eliminar grupo?'))!=true)return;
    loadThis(context,()async{
      _groups.remove(group);
      await deleteGrupoDeUsuarios(group['id']);
    });
  }
  
  @override
  void initState(){
    super.initState();
    _groups = getAllGruposDeUsuarios();
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
                DialogTitle('Grupo de usuarios'),
                sep,
                Center(
                  child: SizedBox(
                    width: 160,
                    child: Button(
                      Row(mainAxisAlignment:MainAxisAlignment.center,children:[
                        Icon(Icons.add,color:Colors.white),
                        Icon(Icons.group,color:Colors.white),
                        const SizedBox(width:7),
                        P('Nuevo',bold:true),
                      ]),
                      _nuevo,
                    ),
                  ),
                ),
                sep,
                ..._groups.map<Widget>((Map group)=>Card(
                  elevation: 4.7,
                  color: Colors.white,
                  child: ListTile(
                    onTap: ()=>_onGroupTap(group),
                    onLongPress: ()=>_groupMenu(group),
                    title: P(group['nombre'],color:Colors.black),
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