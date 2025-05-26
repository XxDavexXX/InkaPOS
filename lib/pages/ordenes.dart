import 'package:flutter/material.dart';
import '../services/helper.dart';
import '../widgets/default_background.dart';
import '../widgets/my_icon.dart';
import '../widgets/input.dart';
import '../widgets/div.dart';
import '../widgets/p.dart';

class Ordenes extends StatefulWidget {
  const Ordenes({super.key});
  @override
  State<Ordenes> createState() => _OrdenesState();
}

class _OrdenesState extends State<Ordenes> {

  late final TextEditingController _search;
  String _filter = '';
  List<Map> _orders = [];

  void _onOrderTap(Map order)async{
    //TODO
  }

  @override
  void initState() {
    super.initState();
    _search = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_)async{
      doLoad(context);
      try{
        //TODO
        List<Map> orders = [
          {'id':'111','name':'Alejandro Casas','date':1725916223672,'money':1600.0},
          {'id':'222','name':'María Gomez','date':1725915223672,'money':1500.0},
          {'id':'333','name':'David Mesa','date':1725917223672,'money':1200.0},
          {'id':'444','name':'Omar Torres','date':1725918223672,'money':1100.0},
        ];
        setState(()=>_orders=orders);
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
          MyIcon(Icons.shopping_cart,(){}),sep,
          MyIcon(Icons.description,(){}),sep,
          MyIcon(Icons.arrow_back,()=>Navigator.pop(context)),sep,
        ],
      ),
    	body: DefaultBackground(
    		addPadding: true,
    		child: ListView(
    			children: [
    				sep,
            Input(
              _search,
              hint: 'Buscar orden',
              leading: Icon(Icons.search,color:Colors.white),
              trailing: IconButton(icon:Icon(Icons.close,color:Colors.white),onPressed:(){
                setState((){
                  _filter='';
                  _search.text='';
                });
              }),
              onSubmitted: (x)=>setState(()=>_filter=x.trim().toLowerCase()),
            ),
            sep,sep,
            ..._orders.where((Map c){
              return c['name'].trim().toLowerCase().contains(_filter);
            }).map<Widget>((Map order)=>OrderCard(
              order,
              ()=>_onOrderTap(order),
            )).toList(),
            if(_orders.isEmpty)P('No hay ordenes',align:TextAlign.center),
            sep,
    			],
    		),
    	),
    );
  }
}

class OrderCard extends StatelessWidget {
  final Map order;
  final VoidCallback onOrderTap;
  const OrderCard(this.order,this.onOrderTap,{super.key});
  @override
  Widget build(BuildContext context)=>Padding(
    padding: const EdgeInsets.only(bottom:16),
    child: Div(
      borderRadius: 16,
      borderColor: prim(context),
      child: ListTile(
        onTap: onOrderTap,
        title: P(order['name'],bold:true),
        subtitle: P(getDateString(order['date'],'day/month/year hour:minute:second')),
        trailing: P(order['money'].toString(),bold:true),
      ),
    ),
  );
}