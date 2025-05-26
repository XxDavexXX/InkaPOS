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

class CrearMetodoDePago extends StatefulWidget {
  const CrearMetodoDePago({super.key});
  @override
  State<CrearMetodoDePago> createState() => _CrearMetodoDePagoState();
}

class _CrearMetodoDePagoState extends State<CrearMetodoDePago> {

  // Estructura de un método de pago
  // E.g.: {abreviatura:'S/',nombre:'Efectivo soles',tipo:'efectivo',divisa:'soles'},

  String _tipo = 'electrónico';
  void _editTipo()async{
    final List<String> tipos = ['electrónico','tarjeta','efectivo'];
    int? index = await choose(context,tipos,text:'Tipo:');
    if(index==null)return;
    setState(()=>_tipo=tipos[index!]);
  }
  String _nombre = '';
  void _editNombre()async{
    String? newVal = await prompt(context,text:'Nombre:',initialValue:_nombre);
    if(newVal==null)return;
    setState(()=>_nombre=newVal!);
  }
  String _divisa = 'PEN';
  void _editDivisa()async{
    String? newVal = await prompt(context,text:'Divisa (Ejemplos: PEN, USD, etc):',initialValue:_divisa);
    if(newVal==null)return;
    setState(()=>_divisa=newVal!);
  }
  String _abreviatura = 'S/';
  void _editAbreviatura()async{
    String? newVal = await prompt(context,text:'Abreviatura (Ejemplos: S/, \$, MC):',initialValue:_abreviatura,maxCharacters:2);
    if(newVal==null)return;
    setState(()=>_abreviatura=newVal!);
  }
  
  void _crearMetodoDePago()async{
    if(_nombre.isEmpty){alert(context,'Ingresa un nombre');return;}
    doLoad(context);
    try{
      Map map = {'abreviatura':_abreviatura,'nombre':_nombre,'tipo':_tipo,'divisa':_divisa};
      await addMetodoDePago(map);
      back(context);back(context,data:true);
    }catch(e){await alert(context,'Ocurrió un error');back(context);}
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
                DialogTitle('Crear método de pago'),
                EditableData('Nombre',_nombre,_editNombre),sep,
                EditableData('Tipo',_tipo,_editTipo),sep,
                EditableData('Divisa',_divisa,_editDivisa),sep,
                EditableData('Abreviatura',_abreviatura,_editAbreviatura),sep,
                sep,sep,
                Button(P('Crear método de pago'),_crearMetodoDePago),
                sep,
              ],
            ),
          ],
        ),
      ),
    );
  }
}