import 'package:flutter/material.dart';
import '../services/helper.dart';
import '../services/hive_helper.dart';
import '../widgets/default_background.dart';
import '../widgets/dialog_title.dart';
import '../widgets/simple_white_box.dart';
import '../widgets/input.dart';
import '../widgets/my_icon.dart';
import '../widgets/button.dart';
import '../widgets/header_button.dart';
import '../widgets/div.dart';
import '../widgets/p.dart';
import '../widgets/editable_data.dart';

class EditarCliente extends StatefulWidget {
  final Map client;
  const EditarCliente(this.client,{super.key});
  @override
  State<EditarCliente> createState() => _EditarClienteState();
}

class _EditarClienteState extends State<EditarCliente> {

  void _editDocumentType()async{
    List<String> opts = ['DNI','RUC','Carnet de extranjería','Pasaporte'];
    int? opt = await choose(context,opts,text:'Documento:');
    if(opt==null)return;
    loadThis(context,()async{
      Map map = {...widget.client};
      map['documento']=opts[opt!];
      await updateClient(map);
      setState(()=>widget.client['documento']=opts[opt!]);
    });
  }
  void _editDocumentNumber()async{
    String? newDocNum = await prompt(
      context,
      text:'Número de documento:',
      initialValue:widget.client['nroDeDocumento'],
    );
    if(newDocNum==null||newDocNum.trim()=='')return;
    loadThis(context,()async{
      Map map = {...widget.client};
      map['nroDeDocumento']=newDocNum.trim();
      await updateClient(map);
      setState(()=>widget.client['nroDeDocumento']=newDocNum.trim());
    });
  }
  void _editName()async{
    String? newName = await prompt(
      context,
      text:'Nombre:',
      initialValue:widget.client['nombre'],
    );
    if(newName==null||newName.trim()=='')return;
    loadThis(context,()async{
      Map map = {...widget.client};
      map['nombre']=newName.trim();
      await updateClient(map);
      setState(()=>widget.client['nombre']=newName.trim());
    });
  }
  void _editAddress()async{
    String? newAddress = await prompt(
      context,
      text:'Dirección:',
      initialValue:widget.client['direccion'],
    );
    if(newAddress==null)return;
    loadThis(context,()async{
      Map map = {...widget.client};
      map['direccion']=newAddress.trim();
      await updateClient(map);
      setState(()=>widget.client['direccion']=newAddress.trim());
    });
  }
  void _editPhone()async{
    String? newPhone = await prompt(
      context,
      text:'Teléfono:',
      initialValue:widget.client['telefono'],
    );
    if(newPhone==null)return;
    loadThis(context,()async{
      Map map = {...widget.client};
      map['telefono']=newPhone.trim();
      await updateClient(map);
      setState(()=>widget.client['telefono']=newPhone.trim());
    });
  }
  void _editEmail()async{
    String? newEmail = await prompt(
      context,
      text:'Correo:',
      initialValue:widget.client['correo'],
    );
    if(newEmail==null)return;
    loadThis(context,()async{
      Map map = {...widget.client};
      map['correo']=newEmail.trim();
      await updateClient(map);
      setState(()=>widget.client['correo']=newEmail.trim());
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
            child: MyIcon(Icons.menu,(){Navigator.pop(context);Navigator.pop(context);}),
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
                DialogTitle('Cliente'),
                EditableData('Documento',widget.client['documento'],_editDocumentType),
                EditableData('Nro. de documento',widget.client['nroDeDocumento'],_editDocumentNumber),
                EditableData('Nombres',widget.client['nombre'],_editName),
                EditableData('Dirección (opcional)',widget.client['direccion'],_editName),
                EditableData('Teléfono (opcional)',widget.client['telefono'],_editPhone),
                EditableData('Correo (opcional)',widget.client['correo'],_editEmail),
                sep,
              ],
            ),
          ],
        ),
      ),
    );
  }
}