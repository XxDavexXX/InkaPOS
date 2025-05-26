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
import 'crear_metodo_de_pago.dart';
import 'editar_metodo_de_pago.dart';

class MetodosDePago extends StatefulWidget {
  const MetodosDePago({super.key});
  @override
  State<MetodosDePago> createState() => _MetodosDePagoState();
}

class _MetodosDePagoState extends State<MetodosDePago> {

  // Estructura de un método de pago
  // E.g.: {abreviatura:'S/','nombre':'Efectivo soles','tipo':'efectivo','divisa':'PEN'},

  late List<Map> _methods;

  @override
  void initState() {
    super.initState();
    _methods = getAllMetodosDePago();
  }

  List<Map> _getSelectedMethods()=>_methods.where((met)=>met['activo']==true).toList();

  void _onMethodSelected(Map method)=>setState(()=>method['activo']=!(method['activo']??false));

  void _onMethodTap(Map method)async{
    await goTo(context,EditarMetodoDePago(method));
    setState(()=>_methods=getAllMetodosDePago());
  }

  void _nuevo()async{
    bool? update = await goTo(context,const CrearMetodoDePago());
    if(update==true)setState(()=>_methods = getAllMetodosDePago());
  }

  void _eliminar()async{
    List<Map> selectedMethod = _getSelectedMethods();
    if(selectedMethod.isEmpty)return;
    if((await confirm(context,'¿Eliminar ${selectedMethod.length} método${selectedMethod.length==1?'':'s'} de pago?',dismissible:true))!=true)return;
    doLoad(context);
    try{
      for(int i=0;i<selectedMethod.length;i++){
        Map method = selectedMethod[i];
        await deleteMetodoDePago(method['id']);
        setState(()=>_methods.remove(method));
      }
    }
    catch(e){await alert(context,'Ocurrió un error eliminando los métodos');}
    finally{back(context);}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
    	backgroundColor:Theme.of(context).colorScheme.surface,
    	appBar: AppBar(
        actions: [MyIcon(Icons.arrow_back,()=>back(context)),sep],
      ),
      body: DefaultBackground(
        addPadding: true,
        child: Column(
          children: [
            SimpleWhiteBox(
              children: [
                DialogTitle('Métodos de pago'),
                Wrap(
                  alignment: WrapAlignment.spaceEvenly,
                  spacing: 4,
                  runSpacing: 4,
                  children: [
                    HeaderButton(Icons.person,'NUEVO',const Color.fromRGBO(64,138,252,1),_nuevo),
                    HeaderButton(Icons.delete,'ELIMINAR',const Color.fromRGBO(205,1,0,1),_eliminar),
                  ],
                ),
                sep,
                if(_methods.isEmpty)P('No hay métodos de pago creados',align:P.center,color:Colors.black),
                ..._methods.map<Widget>((Map method)=>MethodCard(
                  method,
                  ()=>_onMethodTap(method),
                  ()=>_onMethodSelected(method),
                )),
                sep,
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class MethodCard extends StatelessWidget {
  final Map method;
  final VoidCallback onMethodTap;
  final VoidCallback onMethodSelected;
  const MethodCard(this.method,this.onMethodTap,this.onMethodSelected,{super.key});
  @override
  Widget build(BuildContext context)=>Padding(
    padding: const EdgeInsets.only(bottom:16),
    child: Div(
      borderColor: prim(context),
      borderRadius: 23,
      padding: const EdgeInsets.symmetric(horizontal:12,vertical:5),
      child: ListTile(
        onTap: onMethodTap,
        title: P(method['nombre'],color:Colors.black),
        subtitle: P(method['abreviatura'],color:Colors.grey),
        trailing: IconButton(
          icon: Icon(
            (method['activo']??false)?Icons.check_box:Icons.check_box_outline_blank,
            color:prim(context),
          ),
          onPressed: onMethodSelected,
        ),
      ),
    ),
  );
}