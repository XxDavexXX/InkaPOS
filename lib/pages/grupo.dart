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

class Grupo extends StatefulWidget {
  final Map group;
  const Grupo(this.group,{super.key});
  @override
  State<Grupo> createState() => _GrupoState();
}

class _GrupoState extends State<Grupo> {

  late Map _grupo;
  dynamic _get(String x)=>_grupo[x];
  dynamic _set(String x,dynamic y)=>_grupo[x]=y;

  @override
  void initState(){
    super.initState();
    _grupo = {...widget.group};
  }
  
  void _editNombre()async{
    String? x = await prompt(context,text:'Grupo de usuarios:',initialValue:_get('nombre'));
    if(x==null)return;
    loadThis(context,()async{
      Map map = {..._grupo};
      map['nombre'] = x;
      await setGrupoDeUsuarios(map);
      setState(()=>_set('nombre',x!.trim()));
    });
  }

  void _editActivo()async{
    int? x = await choose(context,['Activo', 'No activo'],text:'¿Está activo?');
    if(x==null)return;
    loadThis(context,()async{
      Map map = {..._grupo};
      map['activo'] = x==0;
      await setGrupoDeUsuarios(map);
      setState(()=>_set('activo',x==0));
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
                DialogTitle('Grupo'),
                sep,
                EditableData('Código',_get('id').toString(),(){}),
                EditableData('Grupo de usuarios',_get('nombre'),_editNombre),
                EditableData('Activo',_get('activo')?'ACTIVO':'NO ACTIVO',_editActivo),
              ],
            ),
          ],
        ),
      ),
    );
  }
}