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

class EditarArea extends StatefulWidget {
  final Map area;
  const EditarArea(this.area,{super.key});
  @override
  State<EditarArea> createState() => _EditarAreaState();
}

class _EditarAreaState extends State<EditarArea> {

  late Map _area;

  @override
  void initState(){
    super.initState();
    _area = {...widget.area};
  }

  Future<String?> _prompt(String title,String initial,{bool isNum=false})async=>await prompt(
    context,
    text: title,
    initialValue: initial,
    type: isNum?TextInputType.number:TextInputType.text,
  );

  void _editNombre()=>loadThis(context,()async{
    String? val = await _prompt('Nombre:',_area['nombre']);
    if(val==null||val.trim().length==0)return;
    setState(()=>_area['nombre']=val.trim());
  });

  void _editActivo()=>loadThis(context,()async{
    int? opt = await choose(context,['SI','NO'],text:'Activo:');
    if(opt==null)return;
    setState(()=>_area['activo']= opt==0);
  });

  void _saveChanges()async{
    if((await confirm(context,'¿Guardar cambios?'))!=true)return;
    loadThis(context,()async{
      await setArea(_area);
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
                DialogTitle('Área'),
                EditableData('Código (autogenerado)',_area['id'],(){}),sep,
                EditableData('Nombre',_area['nombre'],_editNombre),sep,
                EditableData('Activo',_area['activo']?'ACTIVO':'NO ACTIVO',_editActivo),sep,
                sep,
                Center(child: Button(P('Guardar cambios',bold:true),_saveChanges)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}