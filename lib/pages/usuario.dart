import 'package:flutter/material.dart';
import '../services/helper.dart';
import '../services/hive_helper.dart';
import '../widgets/default_background.dart';
import '../widgets/simple_white_box.dart';
import '../widgets/editable_data.dart';
import '../widgets/dialog_title.dart';
import '../widgets/my_icon.dart';
import '../widgets/input.dart';
import '../widgets/header_button.dart';
import '../widgets/div.dart';
import '../widgets/p.dart';

class Usuario extends StatefulWidget {
  final Map user;
  const Usuario(this.user,{super.key});
  @override
  State<Usuario> createState() => _UsuarioState();
}

class _UsuarioState extends State<Usuario> {

  dynamic _get(String x)=>widget.user[x];
  dynamic _set(String x,dynamic y)=>widget.user[x]=y;
  void _editGrupo()async{
    final List<Map> groups = getAllGruposDeUsuarios().where((Map g)=>g['activo']==true).toList();
    final List<String> groupsNames = groups.map<String>((g)=>g['nombre']).toList();
    groupsNames.add('Quitar grupo');
    int? opt = await choose(context,groupsNames,text:'Escoge nuevo grupo:');
    if(opt==null)return;
    if(groupsNames[opt!]=='Quitar grupo'){
      setState(()=>_set('grupo',null));
      return;
    }
    setState(()=>_set('grupo',groups[opt!]));
  }
  void _editNombre()async{
    String? x = await prompt(context,text:'Nombre:',initialValue:_get('usuario'));
    if(x==null)return;
    setState(()=>_set('usuario',x!.trim()));
  }
  void _editContrasena()async{
    String? x = await prompt(context,text:'Contraseña:',initialValue:_get('contraseña'));
    if(x==null)return;
    if(x!.length < 3){alert(context,'La contraseña no puede ser menos de 3 caracteres');return;}
    setState(()=>_set('contraseña',x!.trim()));
  }
  void _editActivo()async{
    int? x = await choose(context,['Activo', 'No activo'],text:'¿Está activo?');
    if(x==null)return;
    setState(()=>_set('activo',x==0));
  }

  @override
  Widget build(BuildContext context) {
    p('widget.user');
    p(widget.user);
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
          MyIcon(Icons.arrow_back,()=>back(context)),sep,
        ],
      ),
      body: DefaultBackground(
        addPadding: true,
        child: Column(
          children: [
            SimpleWhiteBox(
              children: [
                DialogTitle('Usuario'),
                sep,
                EditableData('Código',_get('id').toString(),(){}),
                EditableData('Usuario',_get('usuario'),_editNombre),
                EditableData('Contraseña','••••••••',_editContrasena),
                EditableData('Grupo de usuario',_get('grupo')!=null?_get('grupo')['nombre']:'Sin grupo',_editGrupo),
                EditableData('Activo',_get('activo')?'ACTIVO':'NO ACTIVO',_editActivo),
                sep,
              ],
            ),
          ],
        ),
      ),
    );
  }
}