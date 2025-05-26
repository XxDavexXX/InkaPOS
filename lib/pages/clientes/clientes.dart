import 'package:flutter/material.dart';
import '../../services/helper.dart';
import '../../services/hive_helper.dart';
import '../../widgets/default_background.dart';
import '../../widgets/dialog_title.dart';
import '../../widgets/simple_white_box.dart';
import '../../widgets/input.dart';
import '../../widgets/my_icon.dart';
import '../../widgets/button.dart';
import '../../widgets/header_button.dart';
import '../../widgets/div.dart';
import '../../widgets/p.dart';
import 'editar_cliente.dart';
import 'crear_cliente.dart';

class Clientes extends StatefulWidget {
  final bool selectClient;
  const Clientes({this.selectClient=false,super.key});
  @override
  State<Clientes> createState() => _ClientesState();
}

class _ClientesState extends State<Clientes> {

  String _filter = '';
  late final TextEditingController _search;
  List<Map> _clients = [];

  void _onClientTap(Map client)async{
    if(widget.selectClient){
      back(context,data:client);
    } else {
      await goTo(context,EditarCliente(client));
      setState(()=>_clients=_getClients());
    }
  }

  List<Map> _getClients(){
    List<Map> list=getAllClients();
    list.forEach((Map c)=>c['activo']=false);
    return list;
  }

  void _toggleClientSelected(Map client){
    setState(()=>client['activo']=!client['activo']);
  }

  List<Map> _getSelectedClients()=>_clients.where((Map cliente)=>cliente['activo']==true).toList();
  
  @override
  void initState() {
    super.initState();
    _search = TextEditingController();
    _clients = _getClients();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _nuevo()async{
    await goTo(context,const CrearCliente());
    setState(()=>_clients=_getClients());

  }
  void _eliminar()async{
    List<Map> selectedClients = _getSelectedClients();
    if((await confirm(context,'¿Eliminar ${selectedClients.length} clientes seleccionados?'))!=true)return;
    loadThis(context,()async{
      for(int i = 0; i < selectedClients.length; i++){
        await deleteClient(selectedClients[i]['id']);
      }
      setState(()=>_clients = _getClients());
    });
  }

  bool _filterByNames(Map client)=>client['nombre'].toLowerCase().contains(_filter.toLowerCase());

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
                DialogTitle('Clientes'),
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
                Input(
                  _search,
                  hint: 'Buscar clientes',
                  leading: Icon(Icons.search,color:Colors.grey),
                  onSubmitted: (x)=>setState(()=>_filter=x),
                ),
                sep,
                ..._clients.where(_filterByNames).map<Widget>((Map client)=>ClientCard(
                  client,
                  ()=>_onClientTap(client),
                  ()=>_toggleClientSelected(client),
                )).toList(),
                sep,
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ClientCard extends StatelessWidget {
  final Map client;
  final VoidCallback onClientTap;
  final VoidCallback toggleClientSelected;
  const ClientCard(this.client,this.onClientTap,this.toggleClientSelected,{super.key});
  @override
  Widget build(BuildContext context)=>Card(
    color: Colors.white,
    elevation: 5.5,
    child: ListTile(
      onTap: onClientTap,
      title: P(client['nombre'],bold:true,color:Colors.black),
      subtitle: P('${client['documento']}: ${client['nroDeDocumento']}',color:Colors.black,size:12),
      trailing: IconButton(
        onPressed: toggleClientSelected,
        icon: Icon(client['activo']?Icons.check_box:Icons.check_box_outline_blank,color:prim(context)),
      ),
    ),
  );
}