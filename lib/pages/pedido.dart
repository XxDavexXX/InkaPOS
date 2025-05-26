import 'package:flutter/material.dart';
import '../services/helper.dart';
import '../services/hive_helper.dart';
import '../widgets/default_background.dart';
import '../widgets/dialog_title.dart';
import '../widgets/simple_white_box.dart';
import '../widgets/my_icon.dart';
import '../widgets/bottom_button.dart';
import '../widgets/button.dart';
import '../widgets/input.dart';
import '../widgets/div.dart';
import '../widgets/p.dart';
import 'total_a_pagar.dart';
import 'precuenta.dart';
import 'clientes.dart';

class Pedido extends StatefulWidget {
  final Map? cliente;
  final Map? vendedor;
  const Pedido(this.cliente,this.vendedor,{super.key});
  @override
  State<Pedido> createState() => _PedidoState();
}

class _PedidoState extends State<Pedido> {

	List<Map> _items = [];
  Map? _cliente;

  Map _getData({required String tipo}){
    //TODO: Mock data
    int now = DateTime.now().millisecondsSinceEpoch;
    return {
      'id': now.toString(),
      'turno': getTurnoActual()!['id'],
      'tipo': tipo,
      'datosDelNegocio': _getDatosDelNegocio(),
      'fecha': now,
      'numeroDePedido': (getAllRegistrosDeVenta().length+1).toString(),
      'caja': getUser()!['caja']??'CAJA',
      'cliente': _cliente??{'nombre':'PÚBLICO GENERAL'},
      //Si el vendedor no ha sido espeficado, se usan los datos del usuario que abrió el turno
      'vendedor': widget.vendedor??{'nombre':getUsuario(getTurnoActual()!['usuarioID'])!['usuario']},
      'productos': _items,
      'igv': _getAverageIGV(),
      'qr': 'texto del qr',
      //Puede ser CONTADO (pago en fectivo, tarjeta, pagos electronico) o CREDITO
      'tipoDeOperacion': 'CONTADO',
    };
  }

  Map<String,dynamic> _getDatosDelNegocio(){
    //TODO: Mock data
    return {
      'logo': 'assets/business-logo.png',
      'nombre': 'Mister Chang',
      'direccion': 'Av. Gran Chimu 1877 - S.J.L.',
      'ruc': '20550401925',
    };
  }

  String _getAverageIGV(){
    //Usually all the items have the same IGV, but in case they don't, get the average
    bool allItemsHaveTheSameIGV = _items.map((prod)=>prod['igv']).toList().toSet().toList().length==1;
    if(allItemsHaveTheSameIGV)return _items.first['igv'].toStringAsFixed(2);
    double sum = 0.0;
    _items.forEach((Map prod)=>sum += prod['igv']);
    double igv = sum / _items.length;
    return igv.toStringAsFixed(2);
  }

  void _addUnit(Map item)async{
    Map map = {...item};
    map['cantidad']++;
    doLoad(context);
    try{
      await setCartItem(map);
      setState(()=>item['cantidad']++);
    }catch(e){await alert(context,'Ocurrió un error');}
    finally{Navigator.pop(context);}
  }
  
  void _removeUnit(Map item)async{
    int units = item['cantidad'];
    if(units==1){
      if((await confirm(context,'Eliminar item?'))!=true)return;
      doLoad(context);
      try{
        await deleteCartItem(item['id']);
        setState(()=>_items.remove(item));
      }catch(e){await alert(context,'Ocurrió un error');}
      finally{Navigator.pop(context);}
    } else {
      Map map = {...item};
      map['cantidad']--;
      doLoad(context);
      try{
        await setCartItem(map);
        setState(()=>item['cantidad']--);
      }catch(e){await alert(context,'Ocurrió un error');}
      finally{Navigator.pop(context);}
    }
  }

  void _removeWholeItem(Map item)=>loadThis(context,()async{
    await deleteCartItem(item['id']);
    setState(()=>_items.remove(item));
  });

  void _editUnits(Map item)async{
    String? newUnitsString = await prompt(
      context,
      text: 'Nueva cantidad',
      initialValue: item['cantidad'].toString(),
      type: TextInputType.number,
    );
    if(newUnitsString==null)return;
    int newUnits=int.parse(newUnitsString!);
    if(newUnits < 1){alert(context,'Cantidad no válida');return;}
    Map map = {...item};
    map['cantidad']=newUnits;
    doLoad(context);
    try{
      await setCartItem(map);
      setState(()=>item['cantidad']=newUnits);
    }catch(e){await alert(context,'Unidades no válidas');}
    finally{Navigator.pop(context);}
  }

  void _deleteOrder()async{
    if((await confirm(context,'¿Eliminar pedido?'))!=true)return;
    String? reason = await prompt(context,text:'Ingrese motivo');
    if(reason==null||reason.trim()==''){alert(context,'Ingrese un motivo válido');return;}
    doLoad(context);
    try{
      Map datosDePedidoBorrado = {
        'turno': getTurnoActual()!['id'],
        'fecha': DateTime.now().millisecondsSinceEpoch,
        'motivo': reason,
        'productos': _items,
        'cliente': _cliente??{'nombre':'PÚBLICO GENERAL'},
        'vendedor': widget.vendedor??{'nombre':''},
      };
      await addPedidoBorrado(datosDePedidoBorrado);
      await deleteAllCartItem();
      Navigator.pop(context);
    }
    catch(e){await alert(context,'Ocurrió un error');}
    finally{Navigator.pop(context);}
  }

  void _onItemTap(Map item)async{
    List<String> opts = [
      'Editar observaciones',
      'Editar precio',
    ];
    if(item['observacion']!=null)opts.add('Eliminar observaciones');
    if(item['descuento']!=null||item['nuevoPrecio']!=null)opts.add('Devolver a precio original');
    int? opt = await choose(context,opts,text:item['nombre']);
    if(opt==null)return;
    switch(opts[opt!]){
      case 'Editar observaciones':_editItemObservationsDialog(item);break;
      case 'Editar precio':_editItemPriceDialog(item);break;
      case 'Eliminar observaciones':_eliminarObservaciones(item);break;
      case 'Devolver a precio original':_devolverPrecioOriginal(item);break;
    }
  }

  void _eliminarObservaciones(Map item)=>setState(()=>item.remove('observacion'));
  void _devolverPrecioOriginal(Map item)=>setState(()=>item.remove('nuevoPrecio'));

  void _editItemObservationsDialog(Map item)async{
    final TextEditingController controller = TextEditingController();
    controller.text=item['observacion']??'';
    String? newObservation = await dialog(
      context,
      background: Colors.white,
      width: width(context)*0.9,
      dismissible: false,
      children: [
        DialogTitle('Ingrese observación'),
        P(item['nombre'],size:17,bold:true,color:Colors.black),
        sep,
        Div(
          background: const Color.fromRGBO(236,236,236,1),
          width: width(context)*0.9,
          height: 47,
          child: Center(
            child: Input(controller,hint:'Observaciones'),
          ),
        ),
        sep,
        ...(item['observaciones']??<String>[]).map<Widget>((String ob)=>Center(
          child: SizedBox(
            width: width(context)*0.9,
            child: Button(
              P(ob.toUpperCase(),color:Colors.white),
              ()=>controller.text = ob,
              color: Colors.grey,
            ),
          ),
        )),
        sep,
        Button(P('Aceptar',color:Colors.white),()=>Navigator.pop(context,controller.text.trim())),
        sep,
        Button(P('Cancelar',color:Colors.white),()=>Navigator.pop(context)),
      ],
    );
    Future.delayed(const Duration(seconds:1),()=>controller.dispose());
    if(newObservation==null||newObservation=='')return;
    setState(()=>item['observacion'] = newObservation!);
  }

  void _editItemPriceDialog(Map item)async{
    List<String> opts = ['Descuento','Cambio de precio'];
    int? opt = await choose(context,opts,text:'Editar precio');
    switch(opts[opt!]){
      case 'Descuento':_addDiscountToItem(item);break;
      case 'Cambio de precio':_changePriceOfItem(item);break;
    }
  }

  void _addDiscountToItem(Map item)async{
    if((item['nuevoPrecio']!=null)&&(await confirm(context,'Al agregar un descuento, estarías eliminando el cambio de precio antes hecho en este producto, ya que el descuento se hará en base al precio original. ¿Eliminar el cambio de precio para proseguir con agregar descuento?'))!=true)return;
    String? newDiscount = await prompt(
      context,
      text: 'Descuento (%):',
      initialValue: (item['descuento']??0).toString(),
      type: TextInputType.number,
    );
    if(newDiscount==null)return;
    double x = double.parse(newDiscount!);
    if(0 > x || x > 100){alert(context,'El % debe estar entre 0 y 100');return;}
    setState((){
      item.remove('nuevoPrecio');
      item['descuento'] = x;
    });
  }
  void _changePriceOfItem(Map item)async{
    if((item['descuento']!=null)&&(await confirm(context,'Al cambiar el precio, estarías borrando el descuento agregado a este producto, ¿Eliminar el descuento agregado previamente para proseguir con el cambio de precio?'))!=true)return;
    String? newPrice = await prompt(
      context,
      text: 'Precio nuevo',
      initialValue: (item['nuevoPrecio']??item['precioUnit']).toString(),
      type: TextInputType.number,
    );
    if(newPrice==null)return;
    double x = double.parse(double.parse(newPrice!).toStringAsFixed(2));
    if(x < 0){alert(context,'El precio no puede ser menor a 0');return;}
    setState((){
      item.remove('descuento');
      item['nuevoPrecio'] = x;
    });
  }

  void _boleta(){
    goTo(context,TotalAPagar(
      datos: _getData(tipo: 'boleta'),
      vendedor: widget.vendedor,
    ));
  }
  void _factura()async{
    if(_cliente==null){
      await alert(context,'Debes seleccionar un cliente');
      Map? selectedClient = await goTo(context,const Clientes(selectClient:true));
      if(selectedClient==null)return;
      _cliente = selectedClient!;
    }
    goTo(context,TotalAPagar(
      datos: _getData(tipo: 'factura'),
      vendedor: widget.vendedor,
    ));
  }
  void _precuenta()async{
    await goTo(context,Precuenta(_getData(tipo: 'precuenta')));
  }
  void _otros()async{
    return showDialog(
      context:context,
      builder:(BuildContext context){
        bool showButton = false;
        return StatefulBuilder(
          builder:(context,setState)=>SimpleDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(23)),
            backgroundColor: Colors.white,
            children: [
              DialogTitle('Otras opciones'),
              if(showButton)Center(
                child: Button(P('Documento interno'),(){
                  back(context);
                  _guardarComoDocumentoInterno();
                }),
              ),
              if(!showButton)Center(child: Button(P('Configuraciones'),(){})),
              sep,
              GestureDetector(
                onLongPress: ()=>setState(()=>showButton=true),
                onTap: ()=>back(context),
                child: Center(
                  child: Button(P('Salir'),()=>back(context)),
                ),
              ),
            ],
          ),
        );
      }
    );
  }

  void _guardarComoDocumentoInterno()async{
    doLoad(context);
    try{
      await addRegistroDeVenta(_getData(tipo: 'documento interno'));
      await deleteAllCartItem();
      await alert(context,'Documento interno guardado');
      back(context);//Close load
      back(context);//Crear pedido
      back(context);//Dashboard
    } catch(e) {
      await alert(context,'Ocurrió un error');
      back(context);
    }
  }

  String _getBalance(){
    double balance = 0.0;
    _items.forEach((Map prod){
      double precioUnitario = prod['nuevoPrecio']??prod['precioUnit'];
      double precioDelProducto = (prod['cantidad'] * precioUnitario);
      if(prod['descuento']!=null){
        precioDelProducto = precioDelProducto*(prod['descuento']/100);
      }
      balance = balance + precioDelProducto;
    });
    return balance.toString();
  }

  void _datosGenerales()async{
    List<String> opts = [
      'Eliminar todas las observaciones',
      'Eliminar todos los descuentos',
      'Eliminar todos los cambios de precio',
      'Definir IGV general',
      'Definir % de descuento general',
      'Cancelar',
    ];
    int? opt = await choose(context,opts);
    if(opt==null)return;
    if(opt==0)_removerTodasLasObservaciones();
    if(opt==1)_removerTodosLosDescuentos();
    if(opt==2)_removerTodosLosCambiosDePrecio();
    if(opt==3)_definirIgvGeneral();
    if(opt==4)_definirDescuentoGeneral();
  }
  void doneSnackBar(String text)=>showSnackBar(context,'¡Listo!',text,seconds:1,icon:Icon(Icons.check,color:Colors.green));
  void _removerTodasLasObservaciones()async{
    if((await confirm(context,'¿Remover todas las observaciones de los productos?'))!=true)return;
    setState(()=>_items.forEach((Map it)=>it.remove('observacion')));
    doneSnackBar('Observaciones removidas');
  }
  void _removerTodosLosDescuentos()async{
    if((await confirm(context,'¿Eliminar todos los descuentos de los productos?'))!=true)return;
    setState(()=>_items.forEach((Map it)=>it.remove('descuento')));
    doneSnackBar('Descuentos removidos');
  }
  void _removerTodosLosCambiosDePrecio()async{
    if((await confirm(context,'¿Remover todos los cambios de los precio?'))!=true)return;
    setState(()=>_items.forEach((Map it)=>it.remove('nuevoPrecio')));
    doneSnackBar('Cambios de precios revertidos');
  }
  void _definirIgvGeneral()async{
    if((await confirm(context,'¿Definir un IGV general para todos los productos?'))!=true)return;
    String? igvString = await prompt(context,text:'IGV general (%):',type:TextInputType.number);
    if(igvString==null)return;
    late double igv;
    try{igv = double.parse(igvString);}
    catch(e){alert(context,'Ocurrió un error\nNúmero no válido');return;}
    if(0 > igv || igv > 100){alert(context,'El IGV en % debe de estar entre 1 y 100');return;}
    setState(()=>_items.forEach((Map it)=>it['igv']=igv));
  }
  void _definirDescuentoGeneral()async{
    if((await confirm(context,'¿Definir un % de descuento general para todos los productos?'))!=true)return;
    String? discountString = await prompt(context,text:'% de descuento general:',type:TextInputType.number);
    if(discountString==null)return;
    late double discount;
    try{discount = double.parse(discountString);}
    catch(e){alert(context,'Ocurrió un error\nNúmero no válido');return;}
    if(0 > discount || discount > 100){alert(context,'El % debe de estar entre 1 y 100');return;}
    setState(()=>_items.forEach((Map it)=>it['descuento']=discount));
  }

  @override
  void initState() {
    super.initState();
    _items = getCart();
    _cliente = widget.cliente;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
    	backgroundColor:Theme.of(context).colorScheme.surface,
    	appBar: AppBar(
        leading: Center(
          child: Padding(
            padding: const EdgeInsets.only(left:10),
            child: MyIcon(Icons.menu,(){
              back(context);back(context);//To dashboard
            }),
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
              padding: const EdgeInsets.all(20),
              children: [
                DialogTitle('Pedido'),
                ..._items.map<Widget>((Map item)=>ItemCard(
                  item,
                  ()=>_addUnit(item),
                  ()=>_removeUnit(item),
                  ()=>_removeWholeItem(item),
                  ()=>_editUnits(item),
                  ()=>_onItemTap(item),
                )).toList(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Button(
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical:5),
                        child: Row(
                          children: [
                            Icon(Icons.delete,color:Colors.white),
                            sep,
                            Column(
                              children: [
                                P('Eliminar',color:Colors.white,size:13),
                                P('pedido',color:Colors.white,size:13),
                              ],
                            ),
                          ],
                        ),
                      ),
                      _deleteOrder,
                      color: Colors.red,
                    ),
                    P('Saldo: '+_getBalance(),bold:true,color:Colors.black),
                  ],
                ),
                sep,
                Button(P('Datos generales'),_datosGenerales),
              ],
            ),
            sep,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                BottomButton(Icons.description,'Boleta',_boleta),
                BottomButton(Icons.description,'Factura',_factura),
                BottomButton(Icons.description,'Precuenta',_precuenta),
                BottomButton(Icons.assignment,'Otros',_otros),
              ],
            ),
            sep,
    			],
    		),
    	),
    );
  }
}

class ItemCard extends StatelessWidget {
  final Map item;
  final VoidCallback addUnit;
  final VoidCallback removeUnit;
  final VoidCallback removeWholeItem;
  final VoidCallback editUnits;
  final VoidCallback onItemTap;
  const ItemCard(this.item,this.addUnit,this.removeUnit,this.removeWholeItem,this.editUnits,this.onItemTap,{super.key});
  @override
  Widget build(BuildContext context){
    String subtitle = '';
    if(item['igv']!=null)subtitle += 'IGV ${item['igv'].toStringAsFixed(2)}%';
    if(item['observacion']!=null){
      subtitle += (item['igv']==null?'':' | ') + item['observacion']!;
    }
    if(item['descuento']!=null)subtitle+=' | -${item['descuento']}% desc.';
    if(item['nuevoPrecio']!=null)subtitle+=' | (precio modificado)';
    double precioFinal = item['precioUnit'];
    if(item['descuento']!=null)precioFinal = precioFinal * (1-(item['descuento']/100));
    if(item['nuevoPrecio']!=null)precioFinal = item['nuevoPrecio'];
    subtitle += ' | S/${precioFinal.toStringAsFixed(2)}';
    
    return Dismissible(
      key: Key(item['id'].toString()),
      onDismissed: (direction)=>removeWholeItem(),
      background: Container(
        color: Colors.red,
        padding: const EdgeInsets.symmetric(horizontal:16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(Icons.delete_forever,color:Colors.white,size:33),
            Icon(Icons.delete_forever,color:Colors.white,size:33),
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.only(bottom:16),
        child: Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: onItemTap,
                child: Column(
                  children: [
                    P(item['nombre'],color:Colors.black,bold:true,overflow:TextOverflow.clip,),
                    P(subtitle,color:Colors.black,size:12,overflow:TextOverflow.clip,),
                  ],
                ),
              ),
            ),
            sep,
            ItemButtons(item['cantidad'],addUnit,removeUnit,editUnits),
          ],
        ),
      ),
    );
  }
}

class ItemButtons extends StatelessWidget {
  final int units;
  final VoidCallback addUnit;
  final VoidCallback removeUnit;
  final VoidCallback editUnits;
  const ItemButtons(this.units,this.addUnit,this.removeUnit,this.editUnits,{super.key});
  @override
  Widget build(BuildContext context)=>Div(
    borderColor: Colors.grey,
    padding: const EdgeInsets.all(6),
    borderRadius: 9,
    child: Row(
      children: [
        InkWell(
          onTap: removeUnit,
          child: Icon(units==1?Icons.close:Icons.remove,color:Colors.red,size:33),
        ),
        sep,
        InkWell(
          onTap: editUnits,
          child: P(units.toString(),bold:true,size:18,color:Colors.black),
        ),
        sep,
        InkWell(
          onTap: addUnit,
          child: Icon(Icons.add,color:Colors.green,size:33),
        ),
      ],
    ),
  );
}