import 'package:flutter/material.dart';
import 'te_nums.dart';
import 'te.dart';
import 'te_producto.dart';

class ProductsTable extends StatelessWidget {
  final List products;
  const ProductsTable(this.products, {super.key});
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 12),
        const Row(
          children: [
            SizedBox(width: 40, child: Temuns('Cant', bold: true, size: 12)),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Teprod('Producto', bold: true, size: 12),
              ),
            ),
            SizedBox(
              width: 80,
              child: Temuns('Precio unit.', bold: true, size: 12),
            ),
            SizedBox(
              width: 63,
              child: Temuns('Subtotal', bold: true, size: 12),
            ),
          ],
        ),
        ...products.map<Widget>(
          (prod) => Row(
            children: [
              SizedBox(
                width: 40,
                child: Temuns(
                  double.parse(prod['cantidad'].toString()).toStringAsFixed(2),
                  size: 12,
                ),
              ),
              // Expanded(child: Teprod(prod['nombre'], size: 12)),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Teprod(prod['nombre'], size: 12),
                ),
              ),
              SizedBox(
                width: 80,
                child: Temuns(
                  double.parse(
                    prod['precioUnit'].toString(),
                  ).toStringAsFixed(2),
                  size: 12,
                ),
              ),
              SizedBox(
                width: 63,
                child: Temuns(
                  (prod['cantidad'] * prod['precioUnit']).toStringAsFixed(2),
                  size: 12,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}
