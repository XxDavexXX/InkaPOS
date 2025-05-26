import 'package:flutter/material.dart';
import '../services/helper.dart';
import '../services/hive_helper.dart';
import '../widgets/default_background.dart';
import '../widgets/my_icon.dart';
import '../widgets/input.dart';
import '../widgets/button.dart';
import '../widgets/div.dart';
import '../widgets/p.dart';

class SeleccionaSubgrupos extends StatefulWidget {
  final List<String> selectedSubgroups;
  const SeleccionaSubgrupos(this.selectedSubgroups,{super.key});
  @override
  State<SeleccionaSubgrupos> createState() => _SeleccionaSubgruposState();
}

class _SeleccionaSubgruposState extends State<SeleccionaSubgrupos> {

  late final TextEditingController _input;
  String _filter = '';
  late List<Map> _subgroups;

  @override
  void initState() {
    super.initState();
    _input = TextEditingController();
    _subgroups = getAllSubgrupos();
    //Check the initial selected ones
    _subgroups.forEach((Map sg)=>sg['seleccionado'] = widget.selectedSubgroups.contains(sg['nombre']));
  }

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  void _select(){
    back(context,data:_subgroups.where((sg)=>sg['seleccionado']).map<String>((sg)=>sg['nombre']).toList());
  }

  bool _subgroupIsMatch(Map sg)=>sg['nombre'].trim().toLowerCase().contains(_filter);

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
    		child: ListView(
    			children: [
    				sep,
            Input(
              _input,
              hint: 'Buscar sub-grupos',
              leading: Icon(Icons.search,color:Colors.white),
              trailing: IconButton(
                icon: Icon(Icons.close,color:Colors.white),
                onPressed:()=>setState((){
                  _filter='';
                  _input.text='';
                }),
              ),
              onSubmitted: (x)=>setState(()=>_filter=x.trim().toLowerCase()),
            ),
            sep,
            Wrap(
              alignment: WrapAlignment.spaceEvenly,
              children: _subgroups.where(_subgroupIsMatch).map<Widget>((Map subgroup)=>Card(
                elevation: 4.7,
                child: ListTile(
                  title: P(subgroup['nombre'],bold:true),
                  trailing: IconButton(
                    onPressed: ()=>setState(()=>subgroup['seleccionado']=!subgroup['seleccionado']),
                    icon: Icon(subgroup['seleccionado']?Icons.check_box:Icons.check_box_outline_blank,color:prim(context)),
                  ),
                ),
              )).toList(),
            ),
            if(_subgroups.isEmpty)P('No hay subgrupos',align:TextAlign.center),
            sep,
            Center(child: Button(P('Seleccionar',bold:true),_select)),
    			],
    		),
    	),
    );
  }
}