import 'package:flutter/material.dart';
import '../services/helper.dart';
import '../services/hive_helper.dart';
import '../services/db.dart';
import '../widgets/button.dart';
import '../widgets/input.dart';
import '../widgets/my_icon.dart';
import '../widgets/div.dart';
import '../widgets/default_background.dart';
import '../widgets/dialog_title.dart';
import '../widgets/p.dart';
import 'pedido.dart';
import 'ordenes.dart';
import 'clientes.dart';
import 'selecciona_vendedor.dart';
import 'selecciona_subgrupo.dart';
import 'registro_de_ventas.dart';

class CrearPedido extends StatefulWidget {
  const CrearPedido({super.key});
  @override
  State<CrearPedido> createState() => _CrearPedidoState();
}

class _CrearPedidoState extends State<CrearPedido> {

  late final TextEditingController _search;
  
  String _tipoDePedido = 'local';
  String _numeroDePedido = '---';
  Map? _clienteSeleccionado;
  int? _date;
  
  String _filter = '';
  String _selectedSubgroup = 'TODOS';
  List<Map> _products = [];
  
  Map? _selectedSeller;
  
  void _onProductTap(Map product)async{
    if(getCart().any((x)=>x['id']==product['id']))return;
    doLoad(context);
    try{
      await addCartItem(product);
      setState((){});
      showSnackBar(context,'Agregado al pedido:',product['nombre'],seconds:1);
    }
    catch(e,tr){await alert(context,'Ocurrió un error');p('$e\n$tr');}
    finally{Navigator.pop(context);}
  }

  bool _productIsMatch(Map product){
    bool correctSubgroup = _selectedSubgroup=='TODOS' || _selectedSubgroup==product['subgrupo'];
    return product['nombre'].toLowerCase().contains(_filter) && correctSubgroup;
  }
  
  @override
  void initState() {
    super.initState();
    _search = TextEditingController();
    _products = getProducts();
    _date = DateTime.now().millisecondsSinceEpoch;
    _numeroDePedido = (getAllPedidosBorrados().length+getAllRegistrosDeVenta().length+1).toString();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _selectClient()async{
    Map? selectedClient = await goTo(context,const Clientes(selectClient:true));
    setState(()=>_clienteSeleccionado = selectedClient);
  }
  void _selectSeller()async{
    Map? selectedSeller = await goTo(context,const SeleccionaVendedor());
    setState(()=>_selectedSeller = selectedSeller);
  }
  
  void _selectSubgroup()async{
    String? selectedSubgroup = await goTo(context,SeleccionaSubgrupo(_products));
    if(selectedSubgroup==null)return;
    setState(()=>_selectedSubgroup = selectedSubgroup!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Center(
          child: Padding(
            padding: const EdgeInsets.only(left:10),
            child: MyIcon(Icons.menu,()=>goTo(context,const Ordenes())),
          ),
        ),
        actions: [
          CartIcon(
            numberOfItems: getCart().length,
            onTap: ()async{
              await goTo(context,Pedido(_clienteSeleccionado,_selectedSeller));
              setState((){
                _numeroDePedido = (getAllPedidosBorrados().length+getAllRegistrosDeVenta().length+1).toString();
              });
            },
          ),sep,
          MyIcon(Icons.description,_selectSubgroup),sep,
          MyIcon(Icons.arrow_back,()=>Navigator.pop(context)),sep,
        ],
      ),
      body: DefaultBackground(
        addPadding: true,
        child: Column(
          children: [
            sep,
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MyRichText('Tipo de pedido: ',_tipoDePedido),sep,
                      MyRichText('Cliente: ',_clienteSeleccionado==null?'':_clienteSeleccionado!['nombre']),
                    ],
                  ),
                ),
                sep,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MyRichText('N°: ',_numeroDePedido),sep,
                      MyRichText('Fecha: ',getDateString(_date,'day/month/year')),
                    ],
                  ),
                ),
              ],
            ),
            sep,
            Input(
              _search,
              leading: Icon(Icons.search,color:Colors.grey),
              hint: 'Buscar producto',
              onChanged: (x)=>setState(()=>_filter=_search.text.trim().toLowerCase()),
            ),
            sep,
            if(_selectedSubgroup!='TODOS')Padding(
              padding: const EdgeInsets.only(bottom:12),
              child: P('Filtrar por subgrupo: $_selectedSubgroup',bold:true,align:P.center),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Wrap(
                  alignment: WrapAlignment.spaceEvenly,
                  children: _products.where(_productIsMatch).map<Widget>((Map product)=>ProductCard(
                    product,
                    ()=>_onProductTap(product),
                  )).toList(),
                ),
              ),
            ),
            sep,
            BottomBar(
              cliente: _selectClient,
              vendedor: _selectSeller,
              pagos: ()=>goTo(context,const RegistroDeVentas()),
            ),
          ],
        ),
      ),
    );
  }
}

class BottomBar extends StatelessWidget {
  final VoidCallback cliente;
  final VoidCallback vendedor;
  final VoidCallback pagos;
  const BottomBar({
    required this.cliente,
    required this.vendedor,
    required this.pagos,
    super.key,
  });
  @override
  Widget build(BuildContext context)=>Center(
    child: Div(
      width: width(context)*0.9,
      background: Colors.black,
      padding: const EdgeInsets.all(7),
      borderRadius: 16,
      child: Row(
        children: [
          BottomBarItem(Icons.account_circle,'CLIENTE',cliente),
          BottomBarItem(Icons.sell,'VENDEDOR',vendedor),
          BottomBarItem(Icons.payments,'PAGOS',pagos),
        ],
      ),
    )
  );
}

class ProductCard extends StatelessWidget {
  final Map product;
  final VoidCallback onProductTap;
  const ProductCard(this.product,this.onProductTap,{super.key});
  @override
  Widget build(BuildContext context)=>Padding(
    padding: const EdgeInsets.all(5),
    child: InkWell(
      onTap: onProductTap,
      child: Div(
        width: 107,
        borderWidth: 1,
        borderColor: prim(context),
        background: Colors.transparent,
        borderRadius: 16,
        padding: const EdgeInsets.all(7),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            P(product['nombre'],bold:true,color:Colors.white,overflow:TextOverflow.clip,align:TextAlign.center),
            P('S/${product['precioUnit']}',color:Colors.white,size:14),
          ],
        ),
      ),
    ),
  );
}

class BottomBarItem extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onTap;
  const BottomBarItem(this.icon,this.text,this.onTap,{super.key});
  @override
  Widget build(BuildContext context)=>Expanded(
    child: Padding(
      padding: const EdgeInsets.all(4),
      child: InkWell(
        onTap: onTap,
        child: Div(
          borderRadius: 16,
          background: prim(context),
          padding: const EdgeInsets.all(7),
          child: Center(
            child: Column(
              children: [
                Icon(icon,size:32),
                const SizedBox(height:4),
                P(text,bold:true,size:12,color:Colors.black),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

class MyRichText extends StatelessWidget {
  final String text1;
  final String text2;
  const MyRichText(this.text1,this.text2,{super.key});
  @override
  Widget build(BuildContext context)=>RichText(
    text: TextSpan(
      text: text1,
      style: TextStyle(color:Colors.white,fontWeight:FontWeight.bold,fontSize:18),
      children: [TextSpan(text:text2,style:TextStyle(fontWeight:FontWeight.normal,fontSize:17))],
    ),
  );
}

class CartIcon extends StatelessWidget {
  final int numberOfItems;
  final VoidCallback onTap;
  const CartIcon({
    required this.numberOfItems,
    required this.onTap,
    super.key,
  });
  @override
  Widget build(BuildContext context)=>InkWell(
    onTap: onTap,
    child: Stack(
      children: [
        Container(
          width: 47,
          height: 47,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius:BorderRadius.circular(16),
          ),
          child: Icon(Icons.shopping_cart,color:Colors.black,size:30),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: Div(
            circular: true,
            width: 23,
            height: 23,
            background: Colors.red,
            child: Center(
              child: P(numberOfItems.toString(),color:Colors.white,bold:true,size:12,align:P.center),
            ),
          ),
        ),
      ],
    ),
  );
}