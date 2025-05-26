import 'package:flutter/material.dart';
import '../services/helper.dart';
import '../services/hive_helper.dart';
import '../widgets/default_background.dart';
import '../widgets/dialog_title.dart';
import '../widgets/simple_white_box.dart';
import '../widgets/my_icon.dart';
import '../widgets/editable_data.dart';
import '../widgets/header_button.dart';
import '../widgets/button.dart';
import '../widgets/div.dart';
import '../widgets/p.dart';

class EditarMetodoDePago extends StatefulWidget {
  final Map method;
  const EditarMetodoDePago(this.method,{super.key});
  @override
  State<EditarMetodoDePago> createState() => _EditarMetodoDePagoState();
}

class _EditarMetodoDePagoState extends State<EditarMetodoDePago> {

  dynamic? _meth(String x)=>widget.method[x];

  Future<String?> _prompt(String title,String initial,{bool isNum=false, int? maxCharacters})async{
    return await prompt(
      context,
      text: title,
      initialValue: initial,
      type: isNum?TextInputType.number:TextInputType.text,
      maxCharacters: maxCharacters??0,
    );
  }

  void _editNombre()=>loadThis(context,()async{
    String? val = await _prompt('Nombre:',_meth('nombre'));
    if(val==null||val.trim().length==0)return;
    setState(()=>widget.method['nombre']=val.trim());
  });
  void _editTipo()=>loadThis(context,()async{
    final List<String> tipos = ['electrónico','tarjeta','efectivo'];
    int? index = await choose(context,tipos,text:'Tipo:');
    if(index==null)return;
    setState(()=>widget.method['tipo']=tipos[index!]);
  });
  void _editDivisa()=>loadThis(context,()async{
    String? val = await _prompt('Divisa:',_meth('divisa'));
    if(val==null||val.trim().length==0)return;
    setState(()=>widget.method['divisa']=val.trim());
  });
  void _editAbreviatura()=>loadThis(context,()async{
    String? val = await _prompt('Abreviatura:',_meth('abreviatura'),maxCharacters:2);
    if(val==null||val.trim().length==0)return;
    setState(()=>widget.method['abreviatura']=val.trim());
  });

  void _guardarCambios()async{
    if((await confirm(context,'¿Guardar cambios?'))!=true)return;
    doLoad(context);
    try{
      await setMetodoDePago(widget.method);
      back(context);back(context);
    }catch(e){await alert(context,'Ocurrió un error');back(context);}
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
                DialogTitle('Editar Método de pago'),
                EditableData('Código (autogenerado)',_meth('id'),(){}),
                EditableData('Nombre',_meth('nombre'),_editNombre),sep,
                EditableData('Tipo',_meth('tipo'),_editTipo),sep,
                EditableData('Divisa',_meth('divisa'),_editDivisa),sep,
                EditableData('Abreviatura',_meth('abreviatura'),_editAbreviatura),sep,
                sep,sep,
                Button(P('Guardar cambios'),_guardarCambios),
                sep,
              ],
            ),
          ],
        ),
      ),
    );
  }
}