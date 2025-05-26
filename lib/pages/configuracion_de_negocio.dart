import 'package:flutter/material.dart';
import '../services/helper.dart';
import '../widgets/default_background.dart';
import '../widgets/simple_white_box.dart';
import '../widgets/editable_data.dart';
import '../widgets/dialog_title.dart';
import '../widgets/simple_line.dart';
import '../widgets/my_icon.dart';
import '../widgets/option.dart';
import '../widgets/div.dart';
import '../widgets/p.dart';

class ConfiguracionDeNegocio extends StatefulWidget {
  const ConfiguracionDeNegocio({super.key});
  @override
  State<ConfiguracionDeNegocio> createState() => _ConfiguracionDeNegocioState();
}

class _ConfiguracionDeNegocioState extends State<ConfiguracionDeNegocio> {

  String _section = 'Negocio';
  void _editSection()async{
    List<String> opts = ['Negocio','Impuesto','Sistema'];
    int? opt = await choose(context,opts);
    if(opt==null)return;
    setState(()=>_section = opts[opt!]);
  }
  
  String _ruc = '';
  String _razonSocial = '';
  String _razonComercial = '';
  String _direccion = '';
  String _telefono = '';
  String _email = '';
  String _webSite = '';

  void _editRuc()async{
    String? newVal = await prompt(context,text:'RUC:',initialValue:_ruc,maxCharacters:11);
    if(newVal==null)return;
    setState(()=>_ruc=newVal);
  }
  void _editRazonSocial()async{
    String? newVal = await prompt(context,text:'Razón social:',initialValue:_razonSocial);
    if(newVal==null)return;
    setState(()=>_razonSocial=newVal);
  }
  void _editRazonComercial()async{
    String? newVal = await prompt(context,text:'Razón comercial:',initialValue:_razonComercial);
    if(newVal==null)return;
    setState(()=>_razonComercial=newVal);
  }
  void _editDireccion()async{
    String? newVal = await prompt(context,text:'Dirección:',initialValue:_direccion);
    if(newVal==null)return;
    setState(()=>_direccion=newVal);
  }
  void _editTelefono()async{
    String? newVal = await prompt(context,text:'Teléfono:',initialValue:_telefono);
    if(newVal==null)return;
    setState(()=>_telefono=newVal);
  }
  void _editEmail()async{
    String? newVal = await prompt(context,text:'Email:',initialValue:_email);
    if(newVal==null)return;
    setState(()=>_email=newVal);
  }
  void _editWebSite()async{
    String? newVal = await prompt(context,text:'Sitio web:',initialValue:_webSite);
    if(newVal==null)return;
    setState(()=>_webSite=newVal);
  }

  bool _tax1Active = true;
  String _tax1Description = '';
  double _tax1Value = 0.0;
  void _editTax1Description()async{
    String? newVal = await prompt(context,initialValue:_tax1Description);
    if(newVal==null)return;
    setState(()=>_tax1Description=newVal);
  }
  void _editTax1Value()async{
    String? newVal = await prompt(context,initialValue:_tax1Value.toString(),type:TextInputType.number);
    if(newVal==null)return;
    setState(()=>_tax1Value=double.parse(newVal));
  }

  bool _tax2Active = true;
  String _tax2Description = '';
  double _tax2Value = 0.0;
  void _editTax2Description()async{
    String? newVal = await prompt(context,initialValue:_tax2Description);
    if(newVal==null)return;
    setState(()=>_tax2Description=newVal);
  }
  void _editTax2Value()async{
    String? newVal = await prompt(context,initialValue:_tax2Value.toString(),type:TextInputType.number);
    if(newVal==null)return;
    setState(()=>_tax2Value=double.parse(newVal));
  }

  bool _tax3Active = true;
  String _tax3Description = '';
  double _tax3Value = 0.0;
  void _editTax3Description()async{
    String? newVal = await prompt(context,initialValue:_tax3Description);
    if(newVal==null)return;
    setState(()=>_tax3Description=newVal);
  }
  void _editTax3Value()async{
    String? newVal = await prompt(context,initialValue:_tax3Value.toString(),type:TextInputType.number);
    if(newVal==null)return;
    setState(()=>_tax3Value=double.parse(newVal));
  }

  bool _exonerado = true;

  String _servidorIP = '';
  String _web = '';
  void _editServidorIP()async{
    String? newVal = await prompt(context,text:'Servidor IP:',initialValue:_servidorIP);
    if(newVal==null)return;
    setState(()=>_servidorIP=newVal);
  }
  void _editWeb()async{
    String? newVal = await prompt(context,text:'Web:',initialValue:_web);
    if(newVal==null)return;
    setState(()=>_web=newVal);
  }

  @override
  void initState(){
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_)async{
      //TODO: Fecth from hive_helper
      setState((){
        _ruc = '63835751324';
        _razonSocial = 'Razón social';
        _razonComercial = 'Razón comercial 1';
        _direccion = 'Avenida 123';
        _telefono = '+51 999360280';
        _email = 'correo@example.com';
        _webSite = 'google.com';
        _tax1Active = false;
        _tax2Active = false;
        _tax3Active = false;
        _tax1Description = 'I.G.V.';
        _tax2Description = '';
        _tax3Description = 'ICBPER';
        _tax1Value = 18.0;
        _tax2Value = 0.0;
        _tax3Value = 0.5;
        _exonerado = true;
        _servidorIP = '01001100101';
        _web = 'google.com';
      });
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
                DialogTitle('Configuración de negocio'),
                sep,
                EditableData('Sección:',_section,_editSection),
                SimpleLine(),
                if(_section=='Negocio')Column(children:[
                  EditableData('R.U.C.:',_ruc,(){}),
                  EditableData('Razón social:',_razonSocial,(){}),
                  EditableData('Razón comercial:',_razonComercial,(){}),
                  EditableData('Dirección:',_direccion,(){}),
                  EditableData('Teléfono:',_telefono,(){}),
                  EditableData('Email:',_email,(){}),
                  EditableData('Sitio web:',_webSite,(){}),
                ]),
                if(_section=='Impuesto')Column(children:[
                  P('Impuesto',bold:true,align:P.center),
                  TaxRow(
                    '',
                    P('Descripción',bold:true,align:P.center,color:Colors.black,size:12),
                    P('Valor %',bold:true,align:P.center,color:Colors.black,size:12),
                    P('¿Si?',bold:true,align:P.center,color:Colors.black,size:12),
                  ),
                  TaxRow(
                    'Impuesto 1',
                    InkWell(
                      onTap: _editTax1Description,
                      child: GreyDiv(_tax1Description),
                    ),
                    InkWell(
                      onTap: _editTax1Value,
                      child: GreyDiv(_tax1Value),
                    ),
                    IconButton(
                      onPressed: ()=>setState(()=>_tax1Active=!_tax1Active),
                      icon: Icon(_tax1Active?Icons.check_box:Icons.check_box_outline_blank,color:prim(context)),
                    ),
                  ),
                  TaxRow(
                    'Impuesto 2',
                    InkWell(
                      onTap: _editTax2Description,
                      child: GreyDiv(_tax2Description),
                    ),
                    InkWell(
                      onTap: _editTax2Value,
                      child: GreyDiv(_tax2Value),
                    ),
                    IconButton(
                      onPressed: ()=>setState(()=>_tax2Active=!_tax2Active),
                      icon: Icon(_tax2Active?Icons.check_box:Icons.check_box_outline_blank,color:prim(context)),
                    ),
                  ),
                  TaxRow(
                    'Impuesto 3',
                    InkWell(
                      onTap: _editTax3Description,
                      child: GreyDiv(_tax3Description),
                    ),
                    InkWell(
                      onTap: _editTax3Value,
                      child: GreyDiv(_tax3Value),
                    ),
                    IconButton(
                      onPressed: ()=>setState(()=>_tax3Active=!_tax3Active),
                      icon: Icon(_tax3Active?Icons.check_box:Icons.check_box_outline_blank,color:prim(context)),
                    ),
                  ),
                  sep,
                  P('¿Exonerado?',color:Colors.black,bold:true,align:P.center),
                  sep,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Option('Si',_exonerado,()=>setState(()=>_exonerado=true),padding: const EdgeInsets.symmetric(vertical:5,horizontal:30),isBold:true),
                      Option('No',!_exonerado,()=>setState(()=>_exonerado=false),padding: const EdgeInsets.symmetric(vertical:5,horizontal:30),isBold:true),
                    ],
                  ),
                ]),
                if(_section=='Sistema')Column(children:[
                  P('Principal',bold:true,align:P.center,color:Colors.black),
                  sep,
                  EditableData('Servidor IP:',_servidorIP,(){}),
                  EditableData('Web:',_web,(){}),
                ]),
                sep,
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class GreyDiv extends StatelessWidget {
  final dynamic child;
  const GreyDiv(this.child,{super.key});
  Widget _getChild(){
    if(child is String){
      return P(child,bold:true,align:P.center,color:Colors.black);
    } else if(child is double) {
      return P(child.toStringAsFixed(2),bold:true,align:P.center,color:Colors.black);
    } else {
      return P(child.toString(),bold:true,align:P.center,color:Colors.black);
    }
  }
  @override
  Widget build(BuildContext context)=>Div(
    borderRadius: 16,
    background: const Color.fromRGBO(212,212,212,1),
    padding: const EdgeInsets.symmetric(horizontal:12,vertical:3.6),
    child: _getChild(),
  );
}

class TaxRow extends StatelessWidget {
  final String cell1;
  final Widget cell2;
  final Widget cell3;
  final Widget cell4;
  const TaxRow(this.cell1,this.cell2,this.cell3,this.cell4,{super.key});
  @override
  Widget build(BuildContext context)=>Row(
    children: [
      SizedBox(width: 72, child: P(cell1,bold:true,align:P.center,color:Colors.black,size:12,overflow:TextOverflow.clip)),
      Expanded(child: Padding(
        padding: const EdgeInsets.symmetric(horizontal:2.4),
        child: cell2,
      )),
      Expanded(child: Padding(
        padding: const EdgeInsets.symmetric(horizontal:2.4),
        child: cell3,
      )),
      SizedBox(width: 47, child: cell4),
    ],
  );
}