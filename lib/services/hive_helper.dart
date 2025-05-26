import 'package:hive/hive.dart';

Box setts = Hive.box('settings');
Box cart = Hive.box<Map>('cart');
Box products = Hive.box<Map>('products');
Box clients = Hive.box<Map>('clients');
Box turnos = Hive.box<Map>('turnos');
Box registroDeVentas = Hive.box<Map>('Registro de ventas');
Box pedidosBorrados = Hive.box<Map>('Pedidos borrados');
Box cierresDeTurno = Hive.box<Map>('Cierres de turno');
Box grupoDeUsuarios = Hive.box<Map>('Grupo de usuarios');
Box usuarios = Hive.box<Map>('Usuarios');
Box metodosDePago = Hive.box<Map>('Metodos de pago');
Box grupos = Hive.box<Map>('Grupos');
Box observaciones = Hive.box<Map>('Observaciones');
Box subgrupos = Hive.box<Map>('Subgrupos');
Box areas = Hive.box<Map>('Areas');
Box egresos = Hive.box<Map>('Egresos');

//Usuario logueado
Map? getUser()=>setts.get('user');
Future setUser(Map? user)async{
	if(user==null){await setts.delete('user');}
	else{await setts.put('user',user);}
}

//Turnos
// {id: String (millisecondsSinceEpoch),precioDeCompra: double,precioDeVenta: double,fondoInicialSoles: double,fondoInicialDolares: double,usuarioID: int}
Map? getTurnoActual()=>setts.get('turnoActual');
Future setTurnoActual(Map newTurn)async=>await setts.put('turnoActual',newTurn);
Future cerrarTurnoActual()async{
	Map currentTurn = getTurnoActual()!;
	currentTurn['id'] = currentTurn['id'].toString();
	await addTurno(currentTurn);
	await setts.delete('turnoActual');
}

//Turnos
// {id: String (millisecondsSinceEpoch), precioDeCompra: double, precioDeVenta: double, fondoInicialSoles: double, fondoInicialDolares: double, usuario: int (user ID)}
Map? getTurno(String id)=>turnos.get(id);
List<Map> getAllTurnos(){
	List<Map> list = [];
	turnos.keys.toList().forEach((id)=>list.add(getTurno(id)!));
	return list;
}
Future addTurno(Map newOne)async=>await turnos.put(newOne['id'].toString(),newOne);
Future setTurno(Map newOne)async=>await turnos.put(newOne['id'].toString(),newOne);
Future deleteTurno(String id)async=>await turnos.delete(id);
Future deleteAllTurnos()async=>await turnos.clear();

// Cart
// E.g. the same as product but with the 'cantidad' field as an integer
Map? getCartItem(int itemID)=>cart.get(itemID);
List<Map> getCart(){
	List<Map> list = [];
	cart.keys.toList().forEach((id){
		list.add(getCartItem(id)!);
	});
	return list;
}
Future<int> addCartItem(Map newOne)async{
	int id = await cart.add(newOne);
	Map map = {...newOne,'id':id,'cantidad':1};
	await cart.put(id,map);
	return id;
}
Future setCartItem(Map newOne)async=>await cart.put(newOne['id'],newOne);
Future deleteCartItem(int id)async=>await cart.delete(id);
Future deleteAllCartItem()async=>await cart.clear();

/* Products
id: int,
nombre: String,
nombreCorto: String,
precioUnit: double,
precioDelivery: double,
precioVentanilla: double,
observaciones: List<String>,
codigoDeBarras: String,
grupo: String (the name of the group),
subgrupo: String (the name of the sub-group),
combo: bool,
flexible: bool,
cantidad: int,
*/
Map? getProduct(int productID)=>products.get(productID);
List<Map> getProducts(){
	List<Map> list = [];
	products.keys.toList().forEach((prodID){
		list.add(getProduct(prodID)!);
	});
	return list;
}
Future<int> addProduct(Map newOne)async{
	int id = await products.add(newOne);
	Map map = {...newOne,'id':id};
	await products.put(id,map);
	return id;
}
Future setProduct(Map newOne)async=>await products.put(newOne['id'],newOne);
Future deleteProduct(int id)async=>await products.delete(id);
Future deleteAllProducts()async=>await products.clear();

// Clientes
// E.g. {'id':111,'nombre':'Manuel Gomez','documento':'DNI','nroDeDocumento':'64826459','direccion':'Address 123','correo':'manu23g@hotmail.com','telefono':'9993472446'},
Map? getClient(int id)=>clients.get(id);
List<Map> getAllClients(){
	List<Map> list = [];
	clients.keys.toList().forEach((id)=>list.add(getClient(id)!));
	return list;
}
Future<int> addClient(Map newOne)async{
	int id = await clients.add(newOne);
	Map map = {...newOne,'id':id};
	await clients.put(id,map);
	return id;
}
Future updateClient(Map newOne)async=>await clients.put(newOne['id'],newOne);
Future deleteClient(int id)async=>await clients.delete(id);
Future deleteAllClients()async=>await clients.clear();

//Usuarios
// E.g. {'usuario':nombre,'contraseña':contrasena,'grupo':grupo as Map,'activo':activo as bool}
Map? getUsuario(int id)=>usuarios.get(id);
List<Map> getAllUsuarios(){
	List<Map> list = [];
	usuarios.keys.toList().forEach((id)=>list.add(getUsuario(id)!));
	return list;
}
Future<int> addUsuario(Map newOne)async{
	int id = await usuarios.add(newOne);
	Map map = {...newOne,'id':id};
	await usuarios.put(id,map);
	return id;
}
Future setUsuario(Map newOne)async=>await usuarios.put(newOne['id'],newOne);
Future deleteUsuario(int id)async=>await usuarios.delete(id);
Future deleteAllUsuarios()async=>await usuarios.clear();

//Métodos de pago
// E.g.: {abreviatura:'S/','nombre':'Efectivo soles','tipo':'efectivo','divisa':'soles'},
// tipo puede ser 3 valores: electrónico, efectivo y tarjeta
Map? getMetodoDePago(int id)=>metodosDePago.get(id);
List<Map> getAllMetodosDePago(){
	List<Map> list = [];
	metodosDePago.keys.toList().forEach((id)=>list.add(getMetodoDePago(id)!));
	return list;
}
Future<int> addMetodoDePago(Map newOne)async{
	int id = await metodosDePago.add(newOne);
	Map map = {...newOne,'id':id};
	await metodosDePago.put(id,map);
	return id;
}
Future setMetodoDePago(Map newOne)async=>await metodosDePago.put(newOne['id'],newOne);
Future deleteMetodoDePago(int id)async=>await metodosDePago.delete(id);
Future deleteAllMetodosDePagos()async=>await metodosDePago.clear();

//Grupo de usuarios
//E.g.: {'id':'111','nombre':'ADMINISTRADOR','activo':true}
Map? getGrupoDeUsuarios(int id)=>grupoDeUsuarios.get(id);
List<Map> getAllGruposDeUsuarios(){
	List<Map> list = [];
	grupoDeUsuarios.keys.toList().forEach((id)=>list.add(getGrupoDeUsuarios(id)!));
	return list;
}
Future<int> addGrupoDeUsuarios(Map newOne)async{
	int id = await grupoDeUsuarios.add(newOne);
	Map map = {...newOne,'id':id};
	await grupoDeUsuarios.put(id,map);
	return id;
}
Future setGrupoDeUsuarios(Map newOne)async=>await grupoDeUsuarios.put(newOne['id'],newOne);
Future deleteGrupoDeUsuarios(int id)async=>await grupoDeUsuarios.delete(id);
Future deleteAllGruposDeUsuarios()async=>await grupoDeUsuarios.clear();

//Registro de ventas
//TODO: Add here in a comment the final structure of a register
Map? getRegistroDeVenta(int id)=>registroDeVentas.get(id);
List<Map> getAllRegistrosDeVenta(){
	List<Map> list = [];
	registroDeVentas.keys.toList().forEach((id)=>list.add(getRegistroDeVenta(id)!));
	return list;
}
Future<int> addRegistroDeVenta(Map newOne)async{
	int id = await registroDeVentas.add(newOne);
	Map map = {...newOne,'id':id};
	await registroDeVentas.put(id,map);
	return id;
}
Future setRegistroDeVenta(Map newOne)async=>await registroDeVentas.put(newOne['id'],newOne);
Future deleteRegistroDeVenta(int id)async=>await registroDeVentas.delete(id);
Future deleteAllRegistrosDeVenta()async=>await registroDeVentas.clear();

// Pedidos borrados
// id: int, turno: int, fecha: int, motivo: String, productos: List<Map>, cliente: {'nombre': String}, vendedor: {'nombre': String}
Map? getPedidoBorrado(int id)=>pedidosBorrados.get(id);
List<Map> getAllPedidosBorrados(){
	List<Map> list = [];
	pedidosBorrados.keys.toList().forEach((id)=>list.add(getPedidoBorrado(id)!));
	return list;
}
Future<int> addPedidoBorrado(Map newOne)async{
	int id = await pedidosBorrados.add(newOne);
	Map map = {...newOne,'id':id};
	await pedidosBorrados.put(id,map);
	return id;
}
Future setPedidoBorrado(Map newOne)async=>await pedidosBorrados.put(newOne['id'],newOne);
Future deletePedidoBorrado(int id)async=>await pedidosBorrados.delete(id);
Future deleteAllPedidosBorrados()async=>await pedidosBorrados.clear();

// Grupos
Map? getGrupo(int id)=>grupos.get(id);
List<Map> getAllGrupos(){
  List<Map> list = [];
  grupos.keys.toList().forEach((id)=>list.add(getGrupo(id)!));
  return list;
}
Future<int> addGrupo(Map newOne)async{
  int id = await grupos.add(newOne);
  Map map = {'id':id,...newOne};
  await grupos.put(id,map);
  return id;
}
Future setGrupo(Map newOne)async=>await grupos.put(newOne['id'],newOne);
Future deleteGrupo(int id)async=>await grupos.delete(id);
Future deleteAllGrupos()async=>await grupos.clear();

// Observaciones
Map? getObservacion(int id)=>observaciones.get(id);
List<Map> getAllObservaciones(){
  List<Map> list = [];
  observaciones.keys.toList().forEach((id)=>list.add(getObservacion(id)!));
  return list;
}
Future<int> addObservacion(Map newOne)async{
  int id = await observaciones.add(newOne);
  Map map = {'id':id,...newOne};
  await observaciones.put(id,map);
  return id;
}
Future setObservacion(Map newOne)async=>await observaciones.put(newOne['id'],newOne);
Future deleteObservacion(int id)async=>await observaciones.delete(id);
Future deleteAllObservaciones()async=>await observaciones.clear();

// Subgrupos
Map? getSubgrupo(int id)=>subgrupos.get(id);
List<Map> getAllSubgrupos(){
  List<Map> list = [];
  subgrupos.keys.toList().forEach((id)=>list.add(getSubgrupo(id)!));
  return list;
}
Future<int> addSubgrupo(Map newOne)async{
  int id = await subgrupos.add(newOne);
  Map map = {'id':id,...newOne};
  await subgrupos.put(id,map);
  return id;
}
Future setSubgrupo(Map newOne)async=>await subgrupos.put(newOne['id'],newOne);
Future deleteSubgrupo(int id)async=>await subgrupos.delete(id);
Future deleteAllSubgrupos()async=>await subgrupos.clear();

// Áreas
Map? getArea(int id)=>areas.get(id);
List<Map> getAllAreas(){
  List<Map> list = [];
  areas.keys.toList().forEach((id)=>list.add(getArea(id)!));
  return list;
}
Future<int> addArea(Map newOne)async{
  int id = await areas.add(newOne);
  Map map = {'id':id,...newOne};
  await areas.put(id,map);
  return id;
}
Future setArea(Map newOne)async=>await areas.put(newOne['id'],newOne);
Future deleteArea(int id)async=>await areas.delete(id);
Future deleteAllAreas()async=>await areas.clear();

// Egresos
Map? getEgreso(int id)=>egresos.get(id);
List<Map> getAllEgresos(){
  List<Map> list = [];
  egresos.keys.toList().forEach((id)=>list.add(getEgreso(id)!));
  return list;
}
Future<int> addEgreso(Map newOne)async{
  int id = await egresos.add(newOne);
  Map map = {'id':id,...newOne};
  await egresos.put(id,map);
  return id;
}
Future setEgreso(Map newOne)async=>await egresos.put(newOne['id'],newOne);
Future deleteEgreso(int id)async=>await egresos.delete(id);
Future deleteAllEgresos()async=>await egresos.clear();