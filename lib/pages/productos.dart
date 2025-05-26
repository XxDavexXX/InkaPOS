import 'package:flutter/material.dart';
import '../services/helper.dart';
import '../services/hive_helper.dart';
import '../widgets/default_background.dart';
import '../widgets/dialog_title.dart';
import '../widgets/simple_white_box.dart';
import '../widgets/input.dart';
import '../widgets/my_icon.dart';
import '../widgets/editable_data.dart';
import '../widgets/button.dart';
import '../widgets/div.dart';
import '../widgets/p.dart';

class Productos extends StatefulWidget {
  const Productos({super.key});
  @override
  State<Productos> createState() => _ProductosState();
}

class _ProductosState extends State<Productos> {

  String _filter = '';
  late final TextEditingController _search;
  List<Map> _products = [];

  @override
  void initState() {
    super.initState();
    _search = TextEditingController();
    _products = getProducts();
  }

  void _onProductTap(Map product)async{
    await goTo(context,EditProduct(product));
    setState(()=>_products=getProducts());
  }

  void _onProductSelected(Map product){
    setState(()=>product['activo']=!(product['activo']??false));
  }

  bool _filterProducts(Map p)=>p['nombre'].toLowerCase().contains(_filter);

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
                DialogTitle('Productos'),
                Input(
                  _search,
                  leading: Icon(Icons.search,color:Colors.white),
                  hint: 'Buscar productos...',
                  onSubmitted: (x)=>setState(()=>_filter=x.trim().toLowerCase()),
                ),sep,
                ..._products.where(_filterProducts).map<Widget>((Map product)=>ProductCard(
                  product,
                  ()=>_onProductTap(product),
                  ()=>_onProductSelected(product),
                )),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ProductCard extends StatelessWidget {
  final Map product;
  final VoidCallback onProductTap;
  final VoidCallback onProductSelected;
  const ProductCard(this.product,this.onProductTap,this.onProductSelected,{super.key});
  @override
  Widget build(BuildContext context)=>Padding(
    padding: const EdgeInsets.only(bottom:16),
    child: Div(
      borderColor: prim(context),
      borderRadius: 23,
      padding: const EdgeInsets.symmetric(horizontal:12,vertical:5),
      child: ListTile(
        onTap: onProductTap,
        title: P(product['nombre'],color:Colors.black),
        subtitle: P('${product['precioUnit']}',color:Colors.black,size:14),
        trailing: IconButton(
          icon: Icon(
            (product['activo']??false)?Icons.check_box:Icons.check_box_outline_blank,
            color:prim(context),
          ),
          onPressed: onProductSelected,
        ),
      ),
    ),
  );
}


class EditProduct extends StatefulWidget {
  final Map product;
  const EditProduct(this.product,{super.key});
  @override
  State<EditProduct> createState() => _EditProductState();
}

class _EditProductState extends State<EditProduct> {

  dynamic? _prod(String x)=>widget.product[x];

  Future<String?> _prompt(String title,String initial,{bool isNum=false})async{
    return await prompt(
      context,
      text: title,
      initialValue: initial,
      type: isNum?TextInputType.number:TextInputType.text,
    );
  }

  void _editNombre()async{
    loadThis(context,()async{
      String? val = await _prompt('Nombre:',_prod('nombre'));
      if(val==null||val.trim().length==0)return;
      setState(()=>widget.product['nombre']=val.trim());
    });
  }
  void _editNombreCorto()async{
    String? val = await _prompt('Nombre corto:',_prod('nombreCorto'));
    if(val==null||val.trim().length==0)return;
    setState(()=>widget.product['nombreCorto']=val.trim());
  }
  void _editPrecioLocal()async{
    String? val = await _prompt('Precio local:',_prod('precioLocal'),isNum:true);
    if(val==null||val.trim().length==0)return;
    setState(()=>widget.product['precioLocal']=val.trim());
  }
  void _editPrecioDelivery()async{
    String? val = await _prompt('Precio delivery:',_prod('precioDelivery'),isNum:true);
    if(val==null||val.trim().length==0)return;
    setState(()=>widget.product['precioDelivery']=val.trim());
  }
  void _editPrecioVentanilla()async{
    String? val = await _prompt('Precio ventanilla:',_prod('precioVentanilla'),isNum:true);
    if(val==null||val.trim().length==0)return;
    setState(()=>widget.product['precioVentanilla']=val.trim());
  }
  void _editCodigoDeBarras()async{
    String? val = await _prompt('Código de barras:',_prod('codigoDeBarras'));
    if(val==null||val.trim().length==0)return;
    setState(()=>widget.product['codigoDeBarras']=val.trim());
  }
  void _editGrupo()async{
    List<String> groups = ['Tickets','Comida','Hamburguesas'];
    int? index = await choose(context,groups,text:'Grupos:');
    if(index==null)return;
    setState(()=>widget.product['grupo']=groups[index]);
  }
  void _editSubgrupo()async{
    List<String> subgroups = ['Tickets 2','Comida 2','Hamburguesas 2'];
    int? index = await choose(context,subgroups,text:'Grupos:');
    if(index==null)return;
    setState(()=>widget.product['subgrupo']=subgroups[index]);
  }
  void _editCombo()async{
    setState(()=>widget.product['combo']=!widget.product['combo']);
  }
  void _editFlexible()async{
    setState(()=>widget.product['flexible']=!widget.product['flexible']);
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
                DialogTitle('Producto'),
                EditableData('Código',_prod('id'),(){}),
                EditableData('Nombre',_prod('nombre'),_editNombre),
                EditableData('Nombre corto',_prod('nombreCorto'),_editNombreCorto),
                EditableData('Precio local',_prod('precioLocal'),_editPrecioLocal),
                EditableData('Precio delivery',_prod('precioDelivery'),_editPrecioDelivery),
                EditableData('Precio ventanilla',_prod('precioVentanilla'),_editPrecioVentanilla),
                EditableData('Código de barras (opcional)',_prod('codigoDeBarras'),_editCodigoDeBarras),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    MyCheckBox('Combo',_prod('combo'),_editCombo),
                    sep,
                    MyCheckBox('Flexible',_prod('flexible'),_editFlexible),
                  ],
                ),
                EditableData('Grupo',_prod('grupo'),_editGrupo),
                EditableData('Subgrupo',_prod('subgrupo'),_editSubgrupo),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class MyCheckBox extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  const MyCheckBox(this.label,this.active,this.onTap,{super.key});
  @override
  Widget build(BuildContext context)=>InkWell(
    onTap: onTap,
    child: Row(
      children: [
        Icon(active?Icons.check_box:Icons.check_box_outline_blank,color:prim(context)),
        const SizedBox(width:7),
        P(label),
      ],
    ),
  );
}