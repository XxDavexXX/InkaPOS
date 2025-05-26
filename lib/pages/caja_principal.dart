import 'package:flutter/material.dart';
import '../services/helper.dart';
import '../services/hive_helper.dart';
import '../widgets/default_background.dart';
import '../widgets/dialog_title.dart';
import '../widgets/editable_data.dart';
import '../widgets/input.dart';
import '../widgets/p.dart';
import '../widgets/my_icon.dart';
import '../widgets/simple_white_box.dart';

class CajaPrincipal extends StatefulWidget {
  const CajaPrincipal({super.key});
  @override
  State<CajaPrincipal> createState() => _CajaPrincipalState();
}

class _CajaPrincipalState extends State<CajaPrincipal> {

  List<Map> _products = [];
  late final TextEditingController _search;
  String _filter = '';

  bool _productIsMatch(Map prod)=>_filter=='' || prod['nombre'].toLowerCase().contains(_filter);

  _editProductQuantity(Map prod)async{
    final String? stringNewQ = await prompt(context,text:'Nueva cantidad:',type:TextInputType.number);
    if(stringNewQ==null)return;
    if(stringNewQ.trim()=='')return;
    late int newQ;
    try {
      newQ = int.parse(stringNewQ.trim());
    } catch (e) {
      alert(context,'El número no es válido');
      return;
    }
    if(newQ < 0){
      alert(context,'La cantidad debe de ser mayor o igual a cero');
      return;
    }
    loadThis(context,()async{
      // Change it in the local DB
      Map x = {...prod};
      x['cantidad'] = newQ;
      await setProduct(x);
      // Change it in the UI
      setState(()=>prod['cantidad'] = newQ);
    });
  }

  @override
  void initState() {
    super.initState();
    _products = getProducts();
    _search = TextEditingController();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Center(
          child: Padding(
            padding: const EdgeInsets.only(left:10),
            child: MyIcon(Icons.menu,()=>back(context)),
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
                const DialogTitle('Caja principal'),
                sep,
                Input(
                  _search,
                  leading: Icon(Icons.search,color:Colors.white),
                  hint: 'Buscar producto',
                  onChanged: (x)=>setState(()=>_filter=x.trim().toLowerCase()),
                ),
                sep,
                ..._products.where(_productIsMatch).map((Map prod)=>Card(
                  color: Colors.white,
                  child: ListTile(
                    onTap: ()=>_editProductQuantity(prod),
                    title: P(prod['nombre'],color:Colors.black,bold:true),
                    trailing: P('Cantidad:\n${prod['cantidad']}',color:Colors.black,align:P.center,size:14),
                  ),
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