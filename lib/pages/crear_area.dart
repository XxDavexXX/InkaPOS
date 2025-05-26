import 'package:flutter/material.dart';
import '../services/helper.dart';
import '../services/db.dart';
import '../services/hive_helper.dart';
import '../widgets/default_background.dart';
import '../widgets/simple_white_box.dart';
import '../widgets/editable_data.dart';
import '../widgets/dialog_title.dart';
import '../widgets/simple_line.dart';
import '../widgets/my_icon.dart';
import '../widgets/button.dart';
import '../widgets/input.dart';
import '../widgets/div.dart';
import '../widgets/p.dart';

class CrearArea extends StatefulWidget {
  const CrearArea({super.key});
  @override
  State<CrearArea> createState() => _CrearAreaState();
}

class _CrearAreaState extends State<CrearArea> {

  // E.g.: {id: int, nombre: String, activo: bool}
  
  late final TextEditingController _nombre;
  bool _activo = true;
  
  void _editActivo()=>loadThis(context,()async{
    int? opt = await choose(context,['SI','NO'],text:'Activo:');
    if(opt==null)return;
    setState(()=>_activo= opt==0);
  });
  
  void _crearArea()async{
    String nombre = _nombre.text.trim();
    if(nombre==''){alert(context,'Ingresa un nombre del área');return;}
    if((await confirm(context,'¿Crear área?'))!=true)return;
    loadThis(context,()async{
      await addArea({'nombre':nombre,'activo':_activo});
      back(context);
    });
  }
  
  @override
  void initState(){
    super.initState();
    _nombre = TextEditingController();
  }

  @override
  void dispose(){
    _nombre.dispose();
    super.dispose();
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
                DialogTitle('Crear área'),
                sep,
                P('Nombre del área:',color:Colors.black),
                Input(_nombre, hint: 'Nombre'),sep,
                EditableData('Activo',_activo?'ACTIVO':'NO ACTIVO',_editActivo),sep,
                sep,
                Center(child: Button(P('Crear área',bold:true),_crearArea)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}