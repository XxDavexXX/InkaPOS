import 'package:flutter/material.dart';
import '../../services/helper.dart';
import '../../services/db.dart';
import '../../services/hive_helper.dart';
import '../../widgets/default_background.dart';
import '../../widgets/simple_white_box.dart';
import '../../widgets/editable_data.dart';
import '../../widgets/dialog_title.dart';
import '../../widgets/simple_line.dart';
import '../../widgets/my_icon.dart';
import '../../widgets/button.dart';
import '../../widgets/input.dart';
import '../../widgets/div.dart';
import '../../widgets/p.dart';

class CrearCliente extends StatefulWidget {
  const CrearCliente({super.key});
  @override
  State<CrearCliente> createState() => _CrearClienteState();
}

class _CrearClienteState extends State<CrearCliente> {

  //E.g.: {'id': 111,'nombre': 'Manuel Gomez','documento': 'DNI','nroDeDocumento': '64826459','direccion': 'Address 123','correo': 'manu23g@hotmail.com','telefono': '9993472446'}

  late final TextEditingController _nombre;
  String _documento = 'DNI';
  late final TextEditingController _nroDeDocumento;
  late final TextEditingController _direccion;
  late final TextEditingController _correo;
  late final TextEditingController _telefono;
    
  @override
  void initState(){
    super.initState();
    _nombre = TextEditingController();
    _nroDeDocumento = TextEditingController();
    _direccion = TextEditingController();
    _correo = TextEditingController();
    _telefono = TextEditingController();
  }

  @override
  void dispose(){
    _nombre.dispose();
    _nroDeDocumento.dispose();
    _direccion.dispose();
    _correo.dispose();
    _telefono.dispose();
    super.dispose();
  }

  void _editDocumento()async{
    List<String> opts = ['DNI','RUC','Carnet de extranjería','Pasaporte'];
    int? opt = await choose(context,opts,text:'Documento:');
    if(opt==null)return;
    setState(()=>_documento=opts[opt!]);
  }

    void _crearNuevoCliente()async{
      String nombre = _nombre.text.trim();
      String nroDeDocumento = _nroDeDocumento.text.trim();
      String direccion = _direccion.text.trim();
      String correo = _correo.text.trim();
      String telefono = _telefono.text.trim();

      // Validaciones previas antes de crear cliente
      final nombreRegExp = RegExp(r'^[a-zA-ZÁÉÍÓÚÑáéíóúñ\s]+$');
      final dniRegExp = RegExp(r'^\d{8}$');
      final rucRegExp = RegExp(r'^(10|15|16|17|20)\d{9}$');
      final ceRegExp = RegExp(r'^[a-zA-Z0-9]{9,12}$');
      final passportRegExp = RegExp(r'^[a-zA-Z0-9]{7,12}$');
      final direccionRegExp = RegExp(r'^([A-Za-z0-9\s\.]+),?\s([A-Za-z0-9\s\.]+)?$');
      final telefonoRegExp = RegExp(r'^9\d{8}$');
      // Ejemplo Direcciones válidas
      // Calle 1, 123, Miraflores, Ref: Plaza Asia
      // Av. Los Incas, 456, San Isidro
      // Jr. Huancavelica, 789, La Victoria
      final correoRegExp = RegExp(r'^[\w\.-]+@[\w\.-]+\.\w+$');

      if(nombre.length == 0){alert(context,'Completar:\nNombre');return;}
      if (!nombreRegExp.hasMatch(nombre)) {
        alert(context, 'El nombre no debe contener números ni símbolos');
        return;
      }
      if(nroDeDocumento.length == 0){alert(context,'Completar:\nNúmero de documento');return;}

      if (_documento == 'DNI') {
        if (!dniRegExp.hasMatch(nroDeDocumento)) {
          alert(context, 'El DNI debe tener 8 números y sin símbolos');
          return;
        }
      } else if (_documento == 'RUC') {
        if (!rucRegExp.hasMatch(nroDeDocumento)) {
          alert(context, 'El RUC debe tener 11 dígitos y comenzar con 10, 15, 16, 17 o 20');
          return;
        }
      } else if (_documento == 'Carnet de extranjería') {
        if (!ceRegExp.hasMatch(nroDeDocumento)) {
          alert(context, 'El Carnet de extranjería debe tener entre 9 y 12 caracteres alfanuméricos, sin símbolos');
          return;
        }
      } else if (_documento == 'Pasaporte') {
        if (!passportRegExp.hasMatch(nroDeDocumento)) {
          alert(context, 'El pasaporte debe tener entre 7 y 12 caracteres alfanuméricos, sin símbolos especiales');
          return;
        }
      } 

      if(_documento != 'DNI'){//Al usar DNI, no se debe de exigir dirección
        if(direccion.length == 0){alert(context,'Completar:\nDireccion');return;}
      }

      if (direccion.isNotEmpty && !direccionRegExp.hasMatch(direccion)) {
        alert(context, 'La direccion debe tener un formato válido');
        return;
      }

      if (correo.isNotEmpty && !correoRegExp.hasMatch(correo)) {
        alert(context, 'El correo ingresado no es válido');
        return;
      }

      if (telefono.isNotEmpty && !telefonoRegExp.hasMatch(telefono)) {
        alert(context, 'El teléfono debe tener 9 dígitos numéricos');
        return;
      }
      
      if((await confirm(context,'¿Crear cliente?'))!=true)return;
      loadThis(context,()async{
        await addClient({
          'nombre': nombre,
          'documento': _documento,
          'nroDeDocumento': nroDeDocumento,
          'direccion': direccion,
          'correo': correo,
          'telefono': telefono,
        });
        back(context);
      });
    }

  int? _getNroDeDocumentoMaxChars(){
    switch(_documento){
      case 'DNI': return 8;
      case 'RUC': return 11;
      default: return null;
    }
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
                DialogTitle('Crear cliente'),
                sep,
                P('Nombre:',color:Colors.black),
                Input(_nombre,hint: 'Nombre',capitalization:TextCapitalization.words),sep,
                EditableData('Tipo de documento:',_documento,_editDocumento),sep,
                P('Número de documento:',color:Colors.black),
                Input(_nroDeDocumento,hint: 'Nro de documento',maxCharacters:_getNroDeDocumentoMaxChars()),sep,
                P('Dirección:',color:Colors.black),
                Input(_direccion,hint: 'Direccion'),sep,
                P('Correo:',color:Colors.black),
                Input(_correo,hint: 'Correo',type:TextInputType.emailAddress),sep,
                P('Teléfono:',color:Colors.black),
                Input(_telefono,hint: 'Telefono',type:TextInputType.phone),sep,
                sep,sep,
                Button(P('Crear usuario'),_crearNuevoCliente),
                sep,
              ],
            ),
          ],
        ),
      ),
    );
  }
}