import 'package:flutter/material.dart';
import 'dart:typed_data';
import '../services/helper.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:image/image.dart' as image;
import '../widgets/p.dart';
import '../services/hive_helper.dart';
import '../services/db.dart';
import '../widgets/default_background.dart';
import '../widgets/simple_white_box.dart';
import '../widgets/dialog_title.dart';
import '../widgets/simple_line.dart';
import '../widgets/my_icon.dart';
import '../widgets/button.dart';
import '../widgets/input.dart';
import '../widgets/div.dart';
import '../widgets/p.dart';

class Imprimir extends StatefulWidget {
  final Uint8List bytes;
  const Imprimir(this.bytes,{super.key});
  @override
  State<Imprimir> createState() => _ImprimirState();
}

class _ImprimirState extends State<Imprimir> {

  List<BluetoothInfo> _devices = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_)async{
      await _askBluetoothPermission();
      await _loadBluetoothDevices();
    });
  }

  Future<void> _loadBluetoothDevices()async{
    List<BluetoothInfo> list = await PrintBluetoothThermal.pairedBluetooths;
    setState(()=>_devices=list);
  }

  Future<void> _askBluetoothPermission()async{
    PermissionStatus bluetoothPer = await Permission.bluetooth.request();
    print('bluetooth permission: ${bluetoothPer==PermissionStatus.granted?'Granted':'Not granted'}');
    PermissionStatus bluetoothConnectPer = await Permission.bluetoothConnect.request();
    print('bluetoothConnect permission: ${bluetoothConnectPer==PermissionStatus.granted?'Granted':'Not granted'}');
    PermissionStatus bluetoothScanPer = await Permission.bluetoothScan.request();
    print('bluetoothScan permission: ${bluetoothScanPer==PermissionStatus.granted?'Granted':'Not granted'}');
  }

  void _onDeviceTap(BluetoothInfo device)async{
    doLoad(context);
    try {
      await PrintBluetoothThermal.disconnect;
      bool connectionDone = await PrintBluetoothThermal.connect(macPrinterAddress: device.macAdress);
      if(connectionDone){
        CapabilityProfile profile = await CapabilityProfile.load();
        Generator generator = Generator(PaperSize.mm58, profile);
        List<int> bytes = [];
        Uint8List compressedBytes = Uint8List.fromList(image.encodePng(
          image.copyResize(image.decodeImage(widget.bytes)!,width:400),
          level: 9,
        ));
        bytes += generator.image(image.decodeImage(compressedBytes)!);
        await PrintBluetoothThermal.writeBytes(bytes);
        await alert(context,'Imprimiendo');
        back(context);back(context);
      } else {
        await alert(context,'Error a conectar con el dispositivo');
        back(context);
      }
    } catch (e) {
      await alert(context,'Ocurrió un error');
      back(context);
    }
  }

  @override
  Widget build(BuildContext context)=>Scaffold(
    backgroundColor: surf(context),
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
              DialogTitle('Selecciona impresora'),
              sep,
              if(_devices.isEmpty)const P('No hay dispositivos',color:Colors.white,align:TextAlign.center),
              ..._devices.map<Widget>((BluetoothInfo device)=>Card(
                elevation: 5.5,
                color: const Color.fromRGBO(36,36,36,1),
                child: ListTile(
                  leading: Icon(Icons.print),
                  onTap: ()=>_onDeviceTap(device),
                  title: P(device.name,color:Colors.white,bold:true),
                  subtitle: P(device.macAdress??'No address',color:Colors.white),
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