import 'package:flutter/material.dart';
import '../services/helper.dart';
import '../services/db.dart';
import '../services/hive_helper.dart';
import '../widgets/default_background.dart';
import '../widgets/simple_white_box.dart';
import '../widgets/dialog_title.dart';
import '../widgets/editable_data.dart';
import '../widgets/simple_line.dart';
import '../widgets/my_icon.dart';
import '../widgets/button.dart';
import '../widgets/input.dart';
import '../widgets/div.dart';
import '../widgets/p.dart';

class CrearUsuario extends StatefulWidget {
  const CrearUsuario({super.key});
  @override
  State<CrearUsuario> createState() => _CrearUsuarioState();
}

class _CrearUsuarioState extends State<CrearUsuario> {

  late final TextEditingController _nombre;
  late final TextEditingController _contrasena;
  Map? _grupo;
  bool _activo = true;

  @override
  void initState(){
    super.initState();
    _nombre = TextEditingController();
    _contrasena = TextEditingController();
  }

  void _editActivo()async{
    int? x = await choose(context,['Activo', 'No activo'],text:'¿Está activo?');
    if(x==null)return;
    setState(()=>_activo=x==0);
  }

  @override
  void dispose(){
    _nombre.dispose();
    _contrasena.dispose();
    super.dispose();
  }

  void _crearNuevoUsuario()async{
    String nombre = _nombre.text.trim().toLowerCase();
    String contrasena = _contrasena.text.trim();
    if(nombre.length < 3){
      alert(context,'Nombre muy corto\nDebe tener al menos 3 caracteres.');return;}
    if(contrasena.length < 3){
      alert(context,'Contraseña muy corta\nDebe tener al menos 3 caracteres.');return;}
    if((await confirm(context,'¿Crear usuario?'))!=true)return;
    doLoad(context);
    try{
      await addUsuario({
        'usuario': nombre,
        'contraseña': contrasena,
        'grupo': _grupo,
        'activo': _activo,
      });
      await alert(context, 'Usuario creado');
      back(context);back(context);
    }catch(e){await alert(context,'Ocurrió un error');back(context);}
  }

  void _escogerGrupo()async{
    List<Map> grupos = getAllGruposDeUsuarios().where((Map g)=>g['activo']).toList();
    List<String> groupsNames = grupos.map<String>((g)=>g['nombre']).toList();
    int? opt = await choose(context,groupsNames,text:'Selecciona un grupo:');
    if(opt==null)return;
    setState(()=>_grupo=grupos[opt!]);
  }

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
        child: Column(
          children: [
            SimpleWhiteBox(
              children: [
                DialogTitle('Crear usuario'),
                sep,
                P('Nombre de usuario:',color:Colors.black,align:P.center),
                Input(_nombre),sep,
                P('Contraseña:',color:Colors.black,align:P.center),
                Input(_contrasena, type: TextInputType.visiblePassword),sep,
                EditableData('Grupo de usuario',_grupo==null?'Sin escoger':_grupo!['nombre'],_escogerGrupo),sep,
                EditableData('Activo',_activo?'ACTIVO':'NO ACTIVO',_editActivo),sep,
                sep,sep,
                Button(P('Crear usuario',bold:true),_crearNuevoUsuario),
                sep,
              ],
            ),
          ],
        ),
      ),
    );
  }
}