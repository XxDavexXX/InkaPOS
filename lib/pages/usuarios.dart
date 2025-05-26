import 'package:flutter/material.dart';
import '../services/helper.dart';
import '../services/hive_helper.dart';
import '../widgets/default_background.dart';
import '../widgets/simple_white_box.dart';
import '../widgets/editable_data.dart';
import '../widgets/dialog_title.dart';
import '../widgets/my_icon.dart';
import '../widgets/input.dart';
import '../widgets/header_button.dart';
import '../widgets/div.dart';
import '../widgets/p.dart';
import 'grupo_de_usuarios.dart';
import 'crear_usuario.dart';
import 'usuario.dart';

class Usuarios extends StatefulWidget {
  const Usuarios({super.key});
  @override
  State<Usuarios> createState() => _UsuariosState();
}

class _UsuariosState extends State<Usuarios> {
  
  late final TextEditingController _search;
  List<Map> _users = [];
  String _filter = '';
  
  List<Map> _selectedUsers()=>_users.where((u)=>u['selected']==true).toList();
  void _nuevo()async{
    await goTo(context,const CrearUsuario());
    setState(()=>_users = getAllUsuarios());
  }
  void _eliminar()async{
    List<Map> selectedUsers = _selectedUsers();
    if(selectedUsers.isEmpty)return;
    if((await confirm(context,'¿Eliminar ${selectedUsers.length} usuarios?'))!=true)return;
    if((await confirm(context,'¿Seguro de eliminarlos?'))!=true)return;
    List<int> uIDs = selectedUsers.map<int>((u)=>u['id']).toList();
    loadThis(context,()async{
      await Future.wait(uIDs.map<Future>((x)=>deleteUsuario(x)));
    });
    setState(()=>_users=getAllUsuarios());
  }
  bool _userIsMatch(Map user)=>user['usuario'].toLowerCase().contains(_filter);

  @override
  void initState(){
    super.initState();
    _search = TextEditingController();
    _users = getAllUsuarios();
  }

  @override
  void dispose(){
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
            child: MyIcon(Icons.menu,()=>back(context)),
          ),
        ),
        actions: [
          MyIcon(Icons.lock_person,()=>goTo(context,const GrupoDeUsuarios())),sep,
          MyIcon(Icons.arrow_back,()=>back(context)),sep,
        ],
      ),
      body: DefaultBackground(
        addPadding: true,
        child: Column(
          children: [
            SimpleWhiteBox(
              children: [
                DialogTitle('Usuarios'),
                sep,
                Wrap(
                  alignment: WrapAlignment.spaceEvenly,
                  spacing: 4,
                  runSpacing: 4,
                  children: [
                    HeaderButton(Icons.person,'NUEVO',HeaderButton.blue,_nuevo),
                    HeaderButton(Icons.delete,'ELIMINAR',HeaderButton.red,_eliminar),
                  ],
                ),
                sep,
                Input(
                  _search,
                  hint: 'Buscar usuarios...',
                  onSubmitted: (x)=>setState(()=>_filter=x.trim().toLowerCase()),
                  leading: Icon(Icons.search,color:Colors.white),
                  trailing: IconButton(
                    icon: Icon(Icons.close,color:Colors.white),
                    onPressed: (){
                      setState(()=>_filter='');
                      _search.text='';
                    },
                  ),
                ),
                sep,
                ..._users.where(_userIsMatch).map<Widget>((Map user)=>Card(
                  elevation: 4.7,
                  color: Colors.white,
                  child: ListTile(
                    onTap: ()async{
                      await goTo(context,Usuario(user));
                      setState((){});
                    },
                    title: P(user['usuario'],bold:true,color:Colors.black),
                    subtitle: P(user['grupo']?['nombre']??'Sin grupo',color:Colors.black,size:12),
                    trailing: IconButton(
                      icon: Icon(
                        user['selected']==true?Icons.check_box:Icons.check_box_outline_blank,
                        color: prim(context),
                      ),
                      onPressed: ()=>setState(()=>user['selected']=!(user['selected']??false))
                    ),
                  ),
                )),
              ],
            ),
          ],
        ),
      ),
    );
  }
}