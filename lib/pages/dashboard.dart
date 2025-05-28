import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/db.dart';
import '../services/helper.dart';
import '../services/hive_helper.dart';
import '../widgets/my_icon.dart';
import '../widgets/button.dart';
import '../widgets/svg.dart';
import '../widgets/dialog_title.dart';
import '../widgets/default_background.dart';
import '../widgets/p.dart';
import 'pedidos/crear_pedido.dart';
import 'reportes/reportes.dart';
import 'login.dart';
import 'abrir_turno.dart';
import 'maestros.dart';
import 'cierre_de_turno.dart';
import 'configuracion_de_caja.dart';
import 'configuracion_de_negocio.dart';
import 'imprimir/test_impresoras.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});
  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {

	void _download()async{
		int? index = await choose(
			context,
			['Descarga de datos', 'Enviar datos', 'Actualizar impresoras', 'Actualizar cajas'],
			text: 'Sincronización de datos',
		);
		if(index==null)return;
		if(index==0)_descargarDatos();
		if(index==1)_enviarDatos();
		if(index==2){
		loadThis(context, () async {
			await _fetchPrinters();
			await alert(context, 'Impresoras actualizadas');
		});
		}
		if(index==3){
		loadThis(context, () async {
			await _fetchCajas();
			await alert(context, 'Cajas actualizadas');
		});
		}
	}

	//TODO: Just mock data
	Future<void> _fetchProducts()async{
		await deleteAllProducts();
		List<Map> list = [
	    {'id':111,'nombre':'Agua sin gas','nombreCorto':'Agua sin gas','precioUnit':5.00,'precioDelivery':5.00,'precioVentanilla':5.00,'observaciones':['500 ml','750 ml','1 litro'],'codigoDeBarras':'1234','grupo':'Tickets','subgrupo':'Cervezas y complementos','combo':true,'flexible':false,'igv':10.0,'cantidad':1},
	    {'id':222,'nombre':'Agua con gas','nombreCorto':'Agua con gas','precioUnit':5.00,'precioDelivery':5.00,'precioVentanilla':5.00,'observaciones':['500 ml','750 ml','1 litro'],'codigoDeBarras':'1234','grupo':'Tickets','subgrupo':'Cervezas y complementos','combo':true,'flexible':false,'igv':10.0,'cantidad':1},
	    {'id':333,'nombre':'Coca cola zero','nombreCorto':'Coca cola zero','precioUnit':6.00,'precioDelivery':6.00,'precioVentanilla':6.00,'observaciones':['500 ml','750 ml','1 litro'],'codigoDeBarras':'1234','grupo':'Tickets','subgrupo':'Cervezas y complementos','combo':true,'flexible':false,'igv':10.0,'cantidad':1},
	    {'id':444,'nombre':'Inka Cola zero','nombreCorto':'Inka Cola zero','precioUnit':6.00,'precioDelivery':6.00,'precioVentanilla':6.00,'observaciones':['500 ml','750 ml','1 litro'],'codigoDeBarras':'1234','grupo':'Tickets','subgrupo':'Cervezas y complementos','combo':true,'flexible':false,'igv':10.0,'cantidad':1},
	    {'id':555,'nombre':'Hamburguesa','nombreCorto':'Hamburguesa','precioUnit':16.00,'precioDelivery':16.00,'precioVentanilla':16.00,'observaciones':['Bien cocido','Termino medio','Poco cocido'],'codigoDeBarras':'1234','grupo':'Tickets','subgrupo':'Cervezas y complementos','combo':true,'flexible':false,'igv':10.0,'cantidad':1},
	    {'id':666,'nombre':'Chaufa con sillao','nombreCorto':'Chaufa con sillao','precioUnit':36.0,'precioDelivery':36.0,'precioVentanilla':36.0,'codigoDeBarras':'1234','grupo':'Tickets','subgrupo':'Cervezas y complementos','combo':true,'flexible':false,'igv':10.0,'cantidad':1},
	    {'id':777,'nombre':'Helado lúcuma','nombreCorto':'Helado lúcuma','precioUnit':17.0,'precioDelivery':17.0,'precioVentanilla':17.0,'codigoDeBarras':'1234','grupo':'Tickets','subgrupo':'Cervezas y complementos','combo':true,'flexible':false,'igv':10.0,'cantidad':1},
	    {'id':888,'nombre':'Helado chocolate','nombreCorto':'Helado chocolate','precioUnit':16.0,'precioDelivery':16.0,'precioVentanilla':16.0,'codigoDeBarras':'1234','grupo':'Tickets','subgrupo':'Cervezas y complementos','combo':true,'flexible':false,'igv':10.0,'cantidad':1},
	    {'id':999,'nombre':'Helado Vainilla','nombreCorto':'Helado Vainilla','precioUnit':15.0,'precioDelivery':15.0,'precioVentanilla':15.0,'codigoDeBarras':'1234','grupo':'Tickets','subgrupo':'Cervezas y complementos','combo':true,'flexible':false,'igv':10.0,'cantidad':1},
	    {'id':100,'nombre':'Helado Fresa','nombreCorto':'Helado Fresa','precioUnit':15.0,'precioDelivery':15.0,'precioVentanilla':15.0,'codigoDeBarras':'1234','grupo':'Tickets','subgrupo':'Cervezas y complementos','combo':true,'flexible':false,'igv':10.0,'cantidad':1},
	  ];
  	for(int i=0; i < list.length; i++){await addProduct(list[i]);}
	}

	Future<void> _fetchPrinters() async {
		final box = Hive.box<Map>('Impresoras');
		await box.clear();
		await box.add({
			'codigo': '1',
			'nombre': 'IPCAJA',
			'nombreDeRed': '192.168.1.211',
			'nroDeSerie': 'B001',
			'nroDeActualizacion': '007',
			'isDocument': true,
			'active': true,
		});
		await box.add({
			'codigo': '2',
			'nombre': 'IPCAJA 2',
			'nombreDeRed': '192.168.1.216',
			'nroDeSerie': 'B002',
			'nroDeActualizacion': '009',
			'isDocument': true,
			'active': false,
		});
		await box.add({
			'codigo': '3',
			'nombre': 'IPCOCINA',
			'nombreDeRed': '192.168.1.250',
			'nroDeSerie': 'P001',
			'nroDeActualizacion': '011',
			'isDocument': false,
			'active': false,
		});
	}

	// Agrega esta función justo debajo de `_fetchPrinters()` en tu archivo Dashboard
	Future<void> _fetchCajas() async {
	final box = Hive.box<Map>('Cajas');
	await box.clear(); // Opcional: limpiar anteriores

	await box.add({
		'codigo': 'C001',
		'nombre': 'Caja Principal',
		'ubicacion': 'Mostrador A',
		'serieBoleta': 'B001',
		'serieFactura': 'F001',
		'activa': false,
	});
	await box.add({
		'codigo': 'C002',
		'nombre': 'Caja Secundaria',
		'ubicacion': 'Mostrador B',
		'serieBoleta': 'B002',
		'serieFactura': 'F002',
		'activa': false,
	});
	await box.add({
		'codigo': 'C003',
		'nombre': 'Caja Delivery',
		'ubicacion': 'Zona de envíos',
		'serieBoleta': 'B003',
		'serieFactura': 'F003',
		'activa': false,
	});
	await box.add({
		'codigo': 'C004',
		'nombre': 'Caja Auxiliar',
		'ubicacion': 'Almacén',
		'serieBoleta': 'B004',
		'serieFactura': 'F004',
		'activa': false,
	});

	await setCajaActual(box.values.firstWhere((e) => e['activa'] == true));
	}

	//TODO: Just mock data
	Future<void> _fetchClients()async{
		await deleteAllClients();
		List<Map> list = [
	    {'id':111,'nombre':'Manuel Gomez','documento':'DNI','nroDeDocumento':'64826459','direccion':'Address 123','correo':'manu23g@hotmail.com','telefono':'9993472446'},
	    {'id':222,'nombre':'Fernanda Sanchez','documento':'DNI','nroDeDocumento':'5657674','direccion':'San Borja 72','correo':'fernanda.s@gmail.com','telefono':'9992039447'},
	    {'id':333,'nombre':'Mauricio Aramburu','documento':'DNI','nroDeDocumento':'64826459','direccion':'La victoria 36','correo':'mauricio.@gmail.com','telefono':'999476548'},
	  ];
  	for(int i=0; i < list.length; i++){await addClient(list[i]);}
	}

	void _descargarDatos()async{
		if((await confirm(context,'¿Descargar datos?'))!=true)return;
		loadThis(context,()async{
			await _fetchProducts();
			await _fetchClients();
			await alert(context,'Descarga correcta');
		},errMsg:'Error descargando datos');
	}
	
	void _enviarDatos(){
		loadThis(context,()async{
			//TODO
			await Future.delayed(const Duration(milliseconds:720));
			await alert(context,'Envío correcto');
		},errMsg:'Error enviando datos');
	}

	void _settings()async{
		List<String> opts = [
			'Salir',
			'Test impresoras',
			'Acerca de',
			'Web administrativa',
			'Test base de datos',
			'Soporte',
		];
		int? opt = await choose(context,opts,text:'Menú');
		if(opt==null)return;
		switch(opts[opt!]){
			case 'Salir':
				await loadThis(context,()async=>await setUser(null));
				back(context);
				goTo(context,const Login());
				break;
			case 'Test impresoras':
				goTo(context,const TestImpresoras());
				break;
			case 'Acerca de':
				await dialog(
					context,
					background: Colors.white,
					children: [
						Image.asset('assets/logo white bg.png'),
						sep,
						P('Versión v1.0.0',bold:true,color:Colors.black,align:P.center,overflow:TextOverflow.clip,size:12),
						P('@Copyright 2020 TrinetSoft S.A.C.',color:Colors.black,align:P.center,overflow:TextOverflow.clip,size:12),
						P('TrinetPOS es una marca registrada por TrinetSoft S.A.C.',color:Colors.black,align:P.center,overflow:TextOverflow.clip,size:12),
						sep,
						P('Indecopi - Nro de partida registral:',color:Colors.black,align:P.center,overflow:TextOverflow.clip,size:12),
						P('00276 - 2008 - Asiento: 01',color:Colors.black,align:P.center,size:12),
						DialogTitle('Contacto'),
						Row(
							mainAxisAlignment: MainAxisAlignment.center,
							children: [
								Svg('wpp'),
								const SizedBox(width:5),
								P('+51 955 576 199',color:Colors.black),
							],
						),
						P('Área de soporte:',color:Colors.black,bold:true),
						Row(
							mainAxisAlignment: MainAxisAlignment.center,
							children: [
								Svg('wpp'),
								const SizedBox(width:5),
								P('+51 934 564 288',color:Colors.black),
							],
						),
						sep,
						Image.asset('assets/logo with panel.png'),
						Wrap(
							alignment: WrapAlignment.center,
							spacing: 5.5,
							runSpacing: 5.5,
							children: [
								Image.asset('assets/trinetrest.png', width: 72),
								Image.asset('assets/trinetspa.png', width: 72),
								Image.asset('assets/trinetpos.png', width: 72),
							],
						),
					],
				);
				break;
			case 'Web administrativa':
				String? link = await DB.getUserWebAdminLink();
				if(link==null)return;
				launchUrl(Uri.parse(link!));
				break;
			case 'Test base de datos':
				bool isDbOk = await DB.checkDbIsOk();
				alert(context,isDbOk?'Conexión correcta':'Hubo errores al testear la conexión a la base datos');
				break;
			case 'Soporte':
				launchUrl(Uri.parse('https://api.whatsapp.com/send/?phone=51934564288'));
				break;
		}
	}

	void _configuracion()async{
		int? opt = await choose(context,['Configuracion de negocio','Configuracion de caja']);
		if(opt==0)goTo(context,const ConfiguracionDeNegocio());
		if(opt==1)goTo(context,const ConfiguracionDeCaja());
	}

	void _aFacturar() async {
    if (getTurnoActual() == null) {
      Map? openingData = await goTo(context, const AbrirTurno());
      if (openingData == null) return;
      await setTurnoActual(openingData);
    }

    final turno = getTurnoActual();
    final user = getUser();

    if (turno?['usuarioID'] != user?['id']) {
      await alert(context, 'Solo el usuario que abrió el turno puede operar esta caja.\nTurno abierto por otro usuario.');
      return;
    }

    goTo(context, const CrearPedido());
  }


	void _testing()async{
		List<String> opts=[
			'Limpiar carrito',
			'Eliminar registros de venta',
      'Limpiar correlativos',
		];
		int? opt=await choose(context,opts);
		if(opt==null)return;
		switch(opts[opt!]){
			case 'Limpiar carrito':(()async{
				if((await confirm(context,'Limpiar carrito'))!=true)return;
				loadThis(context,()async{
					await deleteAllCartItem();
					await alert(context,'Done');
				});
			})();break;
			case 'Eliminar registros de venta':(()async{
				if((await confirm(context,'Eliminar registros de venta'))!=true)return;
				loadThis(context,()async{
					await deleteAllRegistrosDeVenta();
					await alert(context,'Done');
				});
			})();break;
      case 'Limpiar correlativos': (() async {
        if ((await confirm(context, '¿Deseas reiniciar todos los correlativos a cero?')) != true) return;
        await loadThis(context, () async {
          await resetCorrelativos();
          await alert(context, 'Correlativos reiniciados a cero');
        });
      })();break;
		}
	}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DefaultBackground(
      	child: Column(
      		children: [
      			sep,
						Image.asset('assets/banner.png',width:width(context)*0.9),
						Expanded(
							child: Column(
								mainAxisAlignment: MainAxisAlignment.center,
								crossAxisAlignment: CrossAxisAlignment.center,
								children: [
									MyButton(Icons.description,'A FACTURAR',_aFacturar),
									MyButton(Icons.search,'REPORTES',()=>goTo(context,const Reportes()),isGrey:true),
									MyButton(Icons.perm_data_setting,'CONFIGURACIÓN',_configuracion,isGrey:true),
									MyButton(Icons.edit_document,'MAESTROS',()=>goTo(context,const Maestros()),isGrey:true),
									MyButton(Icons.lock,'CERRAR TURNO',()=>goTo(context,const CierreDeTurno())),
									MyButton(Icons.lock,'TESTING',_testing,isGrey:true),
								],
							),
						),
						Padding(
							padding: const EdgeInsets.all(16),
							child: Row(
								mainAxisAlignment: MainAxisAlignment.spaceBetween,
								children: [
									MyIcon(Icons.download,_download),
									MyIcon(Icons.settings,_settings),
								],
							),
						),
      		],
      	),
      ),
    );
  }
}


class MyButton extends StatelessWidget {
	final IconData icon;
	final String text;
	final VoidCallback onTap;
	final bool isGrey;
  const MyButton(this.icon,this.text,this.onTap,{this.isGrey=false,super.key});
  @override
  Widget build(BuildContext context)=>Padding(
  	padding: const EdgeInsets.only(bottom:12),
  	child: Center(
  		child: SizedBox(
  			width: width(context)*0.85,
  			height: 55,
  			child: Button(
  				Row(
  					mainAxisAlignment: MainAxisAlignment.center,
  					children: [
  						Icon(icon,color:isGrey?Colors.white:Colors.black),sep,
  						P(text,color:isGrey?Colors.white:Colors.black,size:18,bold:true),
  					],
  				),
  				onTap,
  				color:isGrey?Colors.grey:null,
  			),
  		),
  	),
  );
}