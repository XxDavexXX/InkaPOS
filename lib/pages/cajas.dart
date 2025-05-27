import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../../services/helper.dart';
import '../../services/hive_helper.dart';
import '../../widgets/default_background.dart';
import '../../widgets/dialog_title.dart';
import '../../widgets/simple_white_box.dart';
import '../../widgets/my_icon.dart';
import '../../widgets/p.dart';

class Cajas extends StatefulWidget {
  const Cajas({super.key});
  @override
  State<Cajas> createState() => _CajasState();
}

class _CajasState extends State<Cajas> {
  List<Map> _cajas = [];

  void _cargarCajas() {
    setState(() {
      _cajas = getAllCajas();
    });
  }

  Future<void> _activarCaja(Map caja) async {
    final box = Hive.box<Map>('Cajas');
    for (var key in box.keys) {
      Map? actual = box.get(key);
      if (actual != null) {
        await box.put(key, {...actual, 'activa': false});
      }
    }

    final cajaKey = box.keys.firstWhere(
      (key) => box.get(key)?['codigo'] == caja['codigo'],
      orElse: () => null,
    );

    if (cajaKey != null) {
      await box.put(cajaKey, {...caja, 'activa': true});
      await setCajaActual({...caja, 'activa': true});
      _cargarCajas();
    }
  }

  @override
  void initState() {
    super.initState();
    _cargarCajas();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        leading: Center(
          child: Padding(
            padding: const EdgeInsets.only(left: 10),
            child: MyIcon(Icons.menu, () {}),
          ),
        ),
        actions: [
          MyIcon(Icons.arrow_back, () => Navigator.pop(context)), sep,
        ],
      ),
      body: DefaultBackground(
        addPadding: true,
        child: Column(
          children: [
            SimpleWhiteBox(
              children: [
                const DialogTitle('Cajas registradas'),
                sep,
                ..._cajas.map((caja) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: InkWell(
                    onTap: () => _activarCaja(caja),
                    child: Container(
                      decoration: BoxDecoration(
                        color: caja['activa'] == true ? Colors.green[100] : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: caja['activa'] == true ? Colors.green : Colors.grey,
                          width: 2,
                        ),
                      ),
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          P('Nombre: ${caja['nombre']}', bold: true, color: Colors.black),
                          P('Ubicación: ${caja['ubicacion']}', color: Colors.black),
                          P('Serie boleta: ${caja['serieBoleta']}', color: Colors.black),
                          P('Serie factura: ${caja['serieFactura']}', color: Colors.black),
                          P(
                            caja['activa'] == true ? '✔ Activa' : 'No activa',
                            bold: true,
                            color: caja['activa'] == true ? Colors.green[900]! : Colors.grey[700]!,
                          ),
                        ],
                      ),
                    ),
                  ),
                )),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
