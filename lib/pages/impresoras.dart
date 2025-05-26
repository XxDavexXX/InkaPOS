import 'package:flutter/material.dart';
import '../services/helper.dart';
import '../widgets/default_background.dart';
import '../widgets/dialog_title.dart';
import '../widgets/simple_white_box.dart';
import '../widgets/input.dart';
import '../widgets/my_icon.dart';
import '../widgets/div.dart';
import '../widgets/p.dart';

class Impresoras extends StatefulWidget {
  const Impresoras({super.key});
  @override
  State<Impresoras> createState() => _ImpresorasState();
}

class _ImpresorasState extends State<Impresoras> {

  List<Map> _printers = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_)async{
      doLoad(context);
      try{
      	//TODO: Fetch real data
        setState((){
          _printers = [
            {
              'codigo': '1',
              'nombre': 'IPCAJA',
              'nombreDeRed': '192.168.1.211',
              'nroDeSerie': '001',
              'nroDeActualizacion': '007',
              'isDocument': true,
              'active': false,
            },
            {
              'codigo': '2',
              'nombre': 'IPCAJA 2',
              'nombreDeRed': '192.168.1.216',
              'nroDeSerie': '002',
              'nroDeActualizacion': '009',
              'isDocument': false,
              'active': true,
            },
          ];
        });
      }
      catch(e){await alert(context,'Ocurrió un error');}
      finally{Navigator.pop(context);}
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
          MyIcon(Icons.arrow_back,()=>Navigator.pop(context)),sep,
        ],
      ),
      body: DefaultBackground(
        addPadding: true,
        child: Column(
          children: [
            SimpleWhiteBox(
              children: [
                DialogTitle('Impresoras'),
                sep,
                ..._printers.map<Widget>((Map printer)=>PrinterCard(
                  printer,
                  ()=>goTo(context,PrinterScreen(printer)),
                  ()=>setState(()=>printer['active']=!printer['active']),
                )).toList(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class PrinterCard extends StatelessWidget {
  final Map printer;
  final VoidCallback onPrinterTap;
  final VoidCallback toggleActive;
  const PrinterCard(this.printer,this.onPrinterTap,this.toggleActive,{super.key});
  @override
  Widget build(BuildContext context)=>Padding(
    padding: const EdgeInsets.only(bottom:7),
    child: Row(
      children: [
        Expanded(
          child: InkWell(
            onTap: onPrinterTap,
            child: Div(
              borderColor: prim(context),
              borderRadius: 23,
              padding: const EdgeInsets.symmetric(vertical:7,horizontal:16),
              child: Row(
                children: [
                  Icon(Icons.print,color:prim(context)),sep,
                  Expanded(
                    child: P(printer['nombre'],color:Colors.black,bold:true,overflow:TextOverflow.clip),
                  ),
                ],
              ),
            ),
          ),
        ),
        sep,
        IconButton(
          icon: Icon(printer['active']?Icons.check_box:Icons.check_box_outline_blank,color:prim(context)),
          onPressed: toggleActive,
        ),
      ],
    ),
  );
}



class PrinterScreen extends StatefulWidget {
  final Map printer;
  const PrinterScreen(this.printer,{super.key});
  @override
  State<PrinterScreen> createState() => _PrinterScreenState();
}

class _PrinterScreenState extends State<PrinterScreen> {

  late final TextEditingController _codigo;
  late final TextEditingController _nombre;
  late final TextEditingController _nombreDeRed;
  late final TextEditingController _nroDeSerie;
  late final TextEditingController _nroDeActualizacion;
  late bool _isDocument;

  @override
  void initState() {
    super.initState();
    _codigo = TextEditingController();
    _nombre = TextEditingController();
    _nombreDeRed = TextEditingController();
    _nroDeSerie = TextEditingController();
    _nroDeActualizacion = TextEditingController();
    _codigo.text = widget.printer['codigo'];
    _nombre.text = widget.printer['nombre'];
    _nombreDeRed.text = widget.printer['nombreDeRed'];
    _nroDeSerie.text = widget.printer['nroDeSerie'];
    _nroDeActualizacion.text = widget.printer['nroDeActualizacion'];
    _isDocument = widget.printer['isDocument'];
  }

  @override
  void dispose() {
    _codigo.dispose();
    _nombre.dispose();
    _nombreDeRed.dispose();
    _nroDeSerie.dispose();
    _nroDeActualizacion.dispose();
    super.dispose();
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
          MyIcon(Icons.arrow_back,()=>Navigator.pop(context)),sep,
        ],
      ),
      body: DefaultBackground(
        addPadding: true,
        child: Column(
          children: [
            SimpleWhiteBox(
              children: [
                const DialogTitle('Impresora'),
                const P('Código',bold:true,color:Colors.black),
                Input(_codigo),sep,
                const P('Nombre',bold:true,color:Colors.black),
                Input(_nombre),sep,
                const P('Nombre de red',bold:true,color:Colors.black),
                Input(_nombreDeRed),sep,
                const P('Nro. de serie',bold:true,color:Colors.black),
                Input(_nroDeSerie),sep,
                const P('Nro. de actualización',bold:true,color:Colors.black),
                Input(_nroDeActualizacion),sep,
                const P('Para:',bold:true,color:Colors.black),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    MyRadio('Documento',_isDocument,()=>setState(()=>_isDocument=true)),
                    MyRadio('Precuenta',!_isDocument,()=>setState(()=>_isDocument=false)),
                  ],
                ),
                sep,
                Center(
                  child: InkWell(
                    onTap: ()=>setState(()=>widget.printer['active']=!widget.printer['active']),
                    child: Div(
                      borderRadius: 23,
                      background: widget.printer['active']?prim(context):const Color.fromRGBO(142,142,142,1),
                      padding: const EdgeInsets.symmetric(horizontal:23,vertical:7),
                      child: Center(
                        child: P(widget.printer['active']?'ACTIVO':'INACTIVO',bold:true,size:17),
                      ),
                    ),
                  ),
                ),
                sep,
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class MyRadio extends StatelessWidget {
  final String text;
  final bool selected;
  final VoidCallback onTap;
  const MyRadio(this.text,this.selected,this.onTap,{super.key});
  @override
  Widget build(BuildContext context)=>InkWell(
    onTap: onTap,
    child: Row(
      children: [
        Icon(selected?Icons.radio_button_on:Icons.radio_button_unchecked,color:prim(context)),
        const SizedBox(width: 7),
        P(text,color:Colors.black,bold:true),
      ],
    ),
  );
}