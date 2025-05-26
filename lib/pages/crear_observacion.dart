import 'package:flutter/material.dart';
import '../services/helper.dart';
import '../services/db.dart';
import '../services/hive_helper.dart';
import '../widgets/default_background.dart';
import '../widgets/editable_data.dart';
import '../widgets/simple_white_box.dart';
import '../widgets/dialog_title.dart';
import '../widgets/simple_line.dart';
import '../widgets/my_icon.dart';
import '../widgets/button.dart';
import '../widgets/input.dart';
import '../widgets/div.dart';
import '../widgets/p.dart';
import 'selecciona_subgrupos.dart';

class CrearObservacion extends StatefulWidget {
  const CrearObservacion({super.key});
  @override
  State<CrearObservacion> createState() => _CrearObservacionState();
}

class _CrearObservacionState extends State<CrearObservacion> {

  //E.g.: {id: int, nombre: String, nombreCorto: String, subgrupos: List<String>, activo: bool}
  late final TextEditingController _nombre;
  late final TextEditingController _nombreCorto;
  List<String> _subgrupos = [];
  bool _activo = true;

  void _editSubgrupos()async{
    List<String>? subgrupos = await goTo(context,SeleccionaSubgrupos(_subgrupos));
    if(subgrupos==null)return;
    setState(()=>_subgrupos=subgrupos);
  }
  void _editActivo()async{
    int? opt = await choose(context,['SI','NO'],text:'Activo:');
    if(opt==null)return;
    setState(()=>_activo= opt==0);
  }

  String _subGrupToString(List<String> subgrupos){
    String x = subgrupos.join(', ');
    return x.length>16 ? x.substring(0,15):x;
  }

  void _crearObservacion()async{
    String nombre = _nombre.text.trim();
    String nombreCorto = _nombreCorto.text.trim();
    if(nombre==''){alert(context,'Falta:\nNombre');return;}
    if(nombreCorto==''){alert(context,'Falta:\nNombre corto');return;}
    loadThis(context,()async{
      await addObservacion({
        'nombre': nombre,
        'nombreCorto': nombreCorto,
        'subgrupos': _subgrupos,
        'activo': _activo,
      });
      back(context);
    });
  }
  
  @override
  void initState(){
    super.initState();
    _nombre = TextEditingController();
    _nombreCorto = TextEditingController();
  }

  @override
  void dispose(){
    _nombre.dispose();
    _nombreCorto.dispose();
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
                DialogTitle('Crear observacion'),
                sep,
                P('Nombre:',color:Colors.black),
                Input(_nombre,capitalization:TextCapitalization.words),sep,
                P('Nombre corto:',color:Colors.black),
                Input(_nombreCorto,capitalization:TextCapitalization.words),sep,
                EditableData('Subgrupos:',_subGrupToString(_subgrupos),_editSubgrupos),sep,
                EditableData('Activo',_activo?'ACTIVO':'NO ACTIVO',_editActivo),sep,
                sep,
                Button(P('Crear observación',bold:true),_crearObservacion),sep,
              ],
            ),
          ],
        ),
      ),
    );
  }
}