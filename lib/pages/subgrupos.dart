import 'package:flutter/material.dart';
import '../services/helper.dart';
import '../widgets/default_background.dart';
import '../widgets/dialog_title.dart';
import '../widgets/simple_white_box.dart';
import '../widgets/input.dart';
import '../widgets/my_icon.dart';
import '../widgets/button.dart';
import '../widgets/div.dart';
import '../widgets/p.dart';

class Subgrupos extends StatefulWidget {
  const Subgrupos({super.key});
  @override
  State<Subgrupos> createState() => _SubgruposState();
}

class _SubgruposState extends State<Subgrupos> {

  String _filter = '';
  late final TextEditingController _search;
  List<Map> _subgroups = [];

  //TODO: do it in hive_helper.dart
  List<Map> _getSubgroups()=>[
    {'nombre':'Botellas','activo':false},
    {'nombre':'Ticket','activo':false},
    {'nombre':'Comida','activo':false},
    {'nombre':'Cockteles','activo':false},
  ];

  @override
  void initState() {
    super.initState();
    _search = TextEditingController();
    _subgroups = _getSubgroups();
  }

  void _onSubgroupTap(Map subgroup){
  	setState(()=>subgroup['activo']=!subgroup['activo']);
  }

  bool _filterList(Map s)=>s['nombre'].toLowerCase().contains(_filter);

  @override
  void dispose() {
    _search.dispose();
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
          MyIcon(Icons.arrow_back,()=>back(context)),sep,
        ],
      ),
      body: DefaultBackground(
        addPadding: true,
        child: Column(
          children: [
            SimpleWhiteBox(
              children: [
                DialogTitle('Subgrupos'),
                Input(
                  _search,
                  leading: Icon(Icons.search,color:Colors.white),
                  hint: 'Buscar subgrupos...',
                  onSubmitted: (x)=>setState(()=>_filter=x.trim().toLowerCase()),
                ),
                sep,
                ..._subgroups.where(_filterList).map<Widget>((Map subgroup)=>SubgroupCard(
                  subgroup,
                  ()=>_onSubgroupTap(subgroup),
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

class SubgroupCard extends StatelessWidget {
  final Map subgroup;
  final VoidCallback onSubgroupTap;
  const SubgroupCard(this.subgroup,this.onSubgroupTap,{super.key});
  @override
  Widget build(BuildContext context)=>Padding(
    padding: const EdgeInsets.only(bottom:16),
    child: Div(
      borderColor: prim(context),
      borderRadius: 23,
      padding: const EdgeInsets.symmetric(horizontal:12,vertical:5),
      child: ListTile(
        onTap: onSubgroupTap,
        title: P(subgroup['nombre'],color:Colors.black),
        trailing: Icon(
          (subgroup['activo']??false)?Icons.check_box:Icons.check_box_outline_blank,
          color:prim(context),
          size:32,
        ),
      ),
    ),
  );
}