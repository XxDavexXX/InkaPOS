import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../services/helper.dart';
import '../services/hive_helper.dart';
import '../services/logic.dart';
import 'products_table.dart';
import 'my_row_data.dart';
import 'simple_line.dart';
import 'div.dart';
import 'te.dart';
import 'p.dart';

class PrintableDocBoleta extends StatelessWidget {
  final Map reg;
  const PrintableDocBoleta(this.reg, {super.key});

  String _getPrefijoDelID(Map registro) {
    switch (registro['tipo']) {
      case 'boleta':
        return 'TB-';
      case 'factura':
        return 'TF-';
      default:
        return '';
    }
  }

  String _getTotal() {
    double subtotal = 0;
    reg['productos'].forEach((prod) {
      subtotal = subtotal + (prod['cantidad'] * prod['precioUnit']);
    });
    return subtotal.toStringAsFixed(2);
  }

  String _precioNeto() {
    double precioNeto = 0.0;
    reg['productos'].forEach((prod) {
      double productTotal = prod['cantidad'] * prod['precioUnit'];
      double productRealPriceWithoutIGV =
          productTotal / (1.0 + (prod['igv'] / 100));
      precioNeto += productRealPriceWithoutIGV;
    });
    return precioNeto.toStringAsFixed(2);
  }

  String _descuentoDelIgv() {
    double total = double.parse(_getTotal());
    double netPrice = double.parse(_precioNeto());
    int igvDisccount =
        int.parse((total * 100).toStringAsFixed(2).split('.').first) -
        int.parse((netPrice * 100).toStringAsFixed(2).split('.').first);
    return (igvDisccount / 100).toString();
  }

  @override
  Widget build(BuildContext context) {
    return Div(
      width: 320,
      background: const Color.fromARGB(255, 255, 255, 255),
      padding: const EdgeInsets.only(top: 5, bottom: 60, left: 16, right: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          sep,
          //Image.asset(reg['datosDelNegocio']['logo'],width:width(context)*0.42),
          //sep,
          Te('TRINETCORP S.A.C.'),
          Te(reg['datosDelNegocio']['nombre']),
          Te(reg['datosDelNegocio']['direccion']),
          Te('RUC: ' + reg['datosDelNegocio']['ruc']),
          sep,
          Te('BOLETA DE VENTA ELECTRÓNICA', bold: true),
          // Te(reg['id']),
          Te(reg['numeroDeComprobante'] ?? '00000000'),

          // Row(
          //         children: [
          //           Te('N° Pedido:',bold:true),
          //           sep,
          //           Te(reg['numeroDePedido']),
          //         ],
          //       ),
          sep,
          Row(
            children: [
              Te('Fecha:', bold: true),
              sep,
              Te(
                getDateString(
                  reg['fecha'],
                  'day/month/year hour:minute:second',
                ),
              ),
            ],
          ),
          Row(
            children: [
              Te('Caja:', bold: true),
              sep,
              Te(
                getCajaActual()?['nombre'] ??
                    getCajaActual()?['codigo'] ??
                    'CAJA',
              ),
            ],
          ),
          Row(
            children: [
              Te('Cajero:', bold: true),
              sep,
              Te(getUser()?['nombres'] ?? 'Usuario'),
            ],
          ),

          SimpleLine(height: 3, color: Colors.black),
          MyRowData(
            'Cliente: ',
            reg['cliente']?['nombre']?.toString().trim().isNotEmpty == true
                ? reg['cliente']['nombre']
                : '',
          ),
          // Documento de identidad (DNI, RUC, etc.)
          MyRowData(
            '${reg['cliente']?['documento']?.toString().toUpperCase() ?? 'DNI'}: ',
            reg['cliente']?['nroDeDocumento']?.toString().trim().isNotEmpty ==
                    true
                ? reg['cliente']['nroDeDocumento']
                : '',
          ),
          SimpleLine(height: 3, color: Colors.black),
          ProductsTable(reg['productos']),
          SimpleLine(height: 3, color: Colors.black),
          Align(
            alignment: Alignment.centerRight,
            child: Te('SubTotal: ' + _getTotal(), bold: true),
          ),
          sep,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Te('P. Neto:', bold: true),
              Te('S/${_precioNeto()}', bold: true),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Te('I.G.V. ${reg['igv']}%:', bold: true),
              Te('S/${_descuentoDelIgv()}', bold: true),
            ],
          ),
          SimpleLine(height: 3, color: Colors.black),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Te('TOTAL:', size: 16, bold: true),
              Expanded(child: const SizedBox()),
              Te('S/ ${_getTotal()}', size: 16, bold: true),
            ],
          ),
          if (reg['vuelto'] != 0 && reg['vuelto'] != null)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Te('Vuelto:', size: 16, bold: true),
                Expanded(child: const SizedBox()),
                Te(
                  'S/${reg['vuelto'].toStringAsFixed(2)}',
                  size: 16,
                  bold: true,
                ),
              ],
            ),
          sep,
          SizedBox(
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Te(Logic.turnPriceToWords(double.parse(_getTotal()))),
                if (reg['tipo_exacto'] != null &&
                    reg['tipo_exacto'].toString().trim().isNotEmpty) ...[
                  Te(
                    '${reg['tipo_exacto']} ${reg['metodosDePago'][0]['divisa'] == 'PEN' ? 'S/' : '\$'}${reg['metodosDePago'][0]['monto'].toStringAsFixed(2)}',
                  ),
                ] else ...[
                  ...reg['metodosDePago'].map<Widget>(
                    (mp) => Te(
                      '${mp['tipo'].toUpperCase()} ${mp['divisa'] == 'PEN' ? 'S/' : '\$'}${mp['monto'].toStringAsFixed(2)}',
                    ),
                  ),
                ],
              ],
            ),
          ),
          SizedBox(
            width: 120,
            height: 120,
            child: QrImageView(
              data:
                  '${_getPrefijoDelID(reg)}${reg['id']}, ${reg['cliente']['nombre']}, ${getDateString(reg['fecha'], 'day/month/year - hour:minute')}',
            ),
          ),
          SimpleLine(height: 3, color: Colors.black),
          Te('Tipo de operación: ${reg['tipoDeOperacion']}'),
          Te('REPRESENTACIÓN IMPRESA DE BOLETA ELECTRÓNICA'),
          SimpleLine(height: 3, color: Colors.black),
          Te('Consulte su documento en:'),
          Te('www.comprobante.trinetsoft.com'),
          sep,
          Image.asset(
            'assets/logo for documents.png',
            width: width(context) * 0.36,
          ),
        ],
      ),
    );
  }
}
