import 'package:flutter/material.dart';
import '../services/helper.dart';
import 'products_table_comanda_enviar.dart';
import 'my_row_data.dart';
import 'simple_line.dart';
import 'div.dart';
import 'te.dart';
import '../services/logic.dart';
import '../services/hive_helper.dart';
import 'p.dart';

class PrintableDocComanda extends StatelessWidget {
  final Map reg;
  const PrintableDocComanda(this.reg, {super.key});

  String _getTotal() {
    double total = 0;
    reg['productos'].forEach((Map prod) {
      total += (prod['cantidad'] * prod['precioUnit']);
    });
    return total.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) => Div(
        width: 320,
        background: Colors.white,
        padding: const EdgeInsets.only(top: 12, left: 16, right: 16, bottom: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Te(reg['esAnulacion'] == true ? 'ANULACIÓN COMANDA' : 'LOCAL', bold: true),
            sep,
            MyRowData('N° PEDIDO:', reg['numeroDePedido'].toString().padLeft(10, '0')),
            Row(
              children: [
                Te('CAJA:', bold: true),
                sep,
                Te(
                  getCajaActual()?['nombre'] ??
                      getCajaActual()?['codigo'] ??
                      'CAJA',
                ),
              ],
            ),
            MyRowData(
              'FECHA:',
              getDateString(reg['fecha'], 'day/month/year - hour:minute:second'),
            ),
            
            // MyRowData('VENDEDOR:', reg['vendedor']['nombre']),
            ProductsTableComanda(reg['productos']),
            const SimpleLine(height: 2, color: Colors.black),
            Align(
              alignment: Alignment.centerRight,
              child: RichText(
                text: TextSpan(
                  style: const TextStyle(color: Colors.black, fontSize: 14),
                  children: [
                    const TextSpan(
                      text: 'Correlativo: ',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(
                      text: reg['correlativoDeComanda'] ?? '0',
                      style: const TextStyle(fontWeight: FontWeight.normal),
                    ),
                  ],
                ),
              ),
            ),
            ColorFiltered(
              colorFilter: const ColorFilter.matrix(<double>[
                0.2126, 0.7152, 0.0722, 0, 0,
                0.2126, 0.7152, 0.0722, 0, 0,
                0.2126, 0.7152, 0.0722, 0, 0,
                0,      0,      0,      1, 0,
              ]),
              child: Image.asset(
                'assets/logo with panel.png',
                width: width(context) * 0.30,
              ),
            ),
          ],
        ),
      );
}
