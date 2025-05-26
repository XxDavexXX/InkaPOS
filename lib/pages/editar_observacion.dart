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

class EditarObservacion extends StatefulWidget {
  final Map observation;
  const EditarObservacion(this.observation,{super.key});
  @override
  State<EditarObservacion> createState() => _EditarObservacionState();
}

class _EditarObservacionState extends State<EditarObservacion> {

  //E.g.: {id: int, nombre: String, nombreCorto: String, subgrupos: List<String>, activo: bool}
  late Map _observacion;

  @override
  void initState(){
    super.initState();
    _observacion = widget.observation;
  }

  Future<String?> _prompt(String title,String initial,{bool isNum=false})async=>await prompt(
    context,
    text: title,
    initialValue: initial,
    type: isNum?TextInputType.number:TextInputType.text,
  );

  void _editNombre()=>loadThis(context,()async{
    String? val = await _prompt('Nombre:',_observacion['nombre']);
    if(val==null||val.trim().length==0)return;
    setState(()=>_observacion['nombre']=val.trim());
  });
  void _editNombreCorto()=>loadThis(context,()async{
    String? val = await _prompt('Nombre corto:',_observacion['nombreCorto']);
    if(val==null||val.trim().length==0)return;
    setState(()=>_observacion['nombreCorto']=val.trim());
  });
  void _editSubgrupos()async{
    List<String>? subgroups = await goTo(context,SeleccionaSubgrupos(_observacion['subgrupos']));
    if(subgroups==null)return;
    setState(()=>_observacion['subgrupos']=subgroups);
  }
  void _editActivo()async{
    int? opt = await choose(context,['SI','NO'],text:'Activo:');
    if(opt==null)return;
    setState(()=>_observacion['activo']= opt==0);
  }

  void _guardarCambios()async{
    if((await confirm(context,''))!=true)return;
    loadThis(context,()async{
      await setObservacion(_observacion);
      back(context);
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
                DialogTitle('Editar observación'),
                EditableData('Código (autogenerado)',_observacion['id'],(){}),sep,
                EditableData('Nombre',_observacion['nombre'],_editNombre),sep,
                EditableData('Nombre corto',_observacion['nombreCorto'],_editNombreCorto),sep,
                EditableData('Subgrupos',_observacion['subgrupos'].join(', '),_editSubgrupos),sep,
                EditableData('Activo',_observacion['activo']?'ACTIVO':'NO ACTIVO',_editActivo),sep,
                sep,
                Center(child: Button(P('Guardar cambios',bold:true),_guardarCambios)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}