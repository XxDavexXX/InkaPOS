import 'package:flutter/material.dart';
import '../services/helper.dart';
import '../widgets/default_background.dart';
import '../widgets/my_icon.dart';
import '../widgets/input.dart';
import '../widgets/div.dart';
import '../widgets/p.dart';

class SeleccionaSubgrupo extends StatefulWidget {
  final List<Map> products;
  const SeleccionaSubgrupo(this.products,{super.key});
  @override
  State<SeleccionaSubgrupo> createState() => _SeleccionaSubgrupoState();
}

class _SeleccionaSubgrupoState extends State<SeleccionaSubgrupo> {

  late final TextEditingController _search;
  String _filter = '';
  List<Map> _subgroups = [];

  bool _hasProducts(Map subgroup){
    return widget.products.where((x)=>x['subgrupo'].toLowerCase()==subgroup['name'].toLowerCase()).toList().isNotEmpty;
  }

  @override
  void initState() {
    super.initState();
    _search = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_)async{
      doLoad(context);
      try{
        //TODO: Fetch from db
        List<Map> subgroups = [
          {'id':'111','name':'Botellas'},
          {'id':'222','name':'Cerveza y complementos'},
          {'id':'333','name':'Cockteles'},
          {'id':'444','name':'Comida'},
          {'id':'555','name':'Ticket entrada'},
          {'id':'666','name':'Vaso / copa'},
          {'id':'777','name':'Gaseosas'},
          {'id':'888','name':'Postres'},
          {'id':'999','name':'Abarrotes'},
        ];
        // Considerar solo a los subgrupos que tengan productos
        subgroups = subgroups.where((x)=>_hasProducts(x)).toList();
        setState(()=>_subgroups=subgroups);
      }
      catch(e){await alert(context,'Ocurrió un error');}
      finally{Navigator.pop(context);}
    });
  }

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
    		child: ListView(
    			children: [
    				sep,
            Input(
              _search,
              hint: 'Buscar sub-grupos',
              leading: Icon(Icons.search,color:Colors.white),
              trailing: IconButton(icon:Icon(Icons.close,color:Colors.white),onPressed:(){
                setState((){
                  _filter='';
                  _search.text='';
                });
              }),
              onSubmitted: (x)=>setState(()=>_filter=x.trim().toLowerCase()),
            ),
            sep,
            if(_filter=='')P('TODOS',align:TextAlign.center,bold:true,size:18),
            sep,
            Wrap(
              alignment: WrapAlignment.spaceEvenly,
              children: _subgroups.where((Map subgroup){
                return subgroup['name'].trim().toLowerCase().contains(_filter);
              }).map<Widget>((Map subgroup)=>SubgroupCard(subgroup)).toList(),
            ),
            sep,
            Center(
              child: SubgroupCard({'name':'TODOS','id':''}),
            ),
            sep,
            if(_subgroups.isEmpty)P('No hay subgrupos',align:TextAlign.center),
            sep,
    			],
    		),
    	),
    );
  }
}

class SubgroupCard extends StatelessWidget {
  final Map subgroup;
  const SubgroupCard(this.subgroup,{super.key});
  @override
  Widget build(BuildContext context)=>Padding(
    padding: const EdgeInsets.only(bottom:16),
    child: InkWell(
      onTap: ()=>Navigator.pop(context,subgroup['name']),
      child: Div(
        width: width(context)*0.42,
        height: 66,
        borderRadius: 16,
        borderColor: prim(context),
        child: Center(
          child: P(subgroup['name'],size:15,bold:true,overflow:TextOverflow.clip,align:TextAlign.center),
        ),
      ),
    ),
  );
}