import 'package:flutter/material.dart';
import '../services/helper.dart';
import '../services/hive_helper.dart';
import '../widgets/default_background.dart';
import '../widgets/dialog_title.dart';
import '../widgets/simple_white_box.dart';
import '../widgets/my_icon.dart';
import '../widgets/editable_data.dart';
import '../widgets/button.dart';
import '../widgets/header_button.dart';
import '../widgets/div.dart';
import '../widgets/p.dart';

class EditarGrupo extends StatefulWidget {
  final Map group;
  const EditarGrupo(this.group,{super.key});
  @override
  State<EditarGrupo> createState() => _EditarGrupoState();
}

class _EditarGrupoState extends State<EditarGrupo> {

  //E.g.: {id: int, nombre: String, activo: bool}
  late Map _grupo;

  @override
  void initState(){
    super.initState();
    _grupo = {...widget.group};
  }

  Future<String?> _prompt(String title,String initial,{bool isNum=false})async=>await prompt(
    context,
    text: title,
    initialValue: initial,
    type: isNum?TextInputType.number:TextInputType.text,
  );

  void _editNombre()=>loadThis(context,()async{
    String? val = await _prompt('Nombre:',_grupo['nombre']);
    if(val==null||val.trim().length==0)return;
    setState(()=>_grupo['nombre']=val.trim());
  });

  void _editActivo()=>loadThis(context,()async{
    int? opt = await choose(context,['SI','NO'],text:'Activo:');
    if(opt==null)return;
    setState(()=>_grupo['activo']=opt==0);
  });

  void _guardarCambios()async{
    if((await confirm(context,'¿Guardar cambios?'))!=true)return;
    loadThis(context,()async{
      await setGrupo(_grupo);
      back(context);
    });
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
                DialogTitle('Grupo'),
                EditableData('Código (autogenerado)',_grupo['id'],(){}),sep,
                EditableData('Nombre',_grupo['nombre'],_editNombre),sep,
                EditableData('Activo',_grupo['activo']?'ACTIVO':'NO ACTIVO',_editActivo),sep,
                sep,
                Center(child: Button(P('Guardar',bold:true),_guardarCambios)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}