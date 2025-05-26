import 'package:flutter/material.dart';
import 'te.dart';

class ProductsTable extends StatelessWidget {
	final List products;
  const ProductsTable(this.products,{super.key});
  @override
  Widget build(BuildContext context) {
  	return Column(
  		children: [
  			const SizedBox(height:12),
  			const Row(
  				children: [
  					SizedBox(width:55,child:Te('Cant',bold:true,size:12)),
  					Expanded(child:Te('Producto',bold:true,size:12)),
  					SizedBox(width:100,child:Te('Precio unit.',bold:true,size:12)),
  					SizedBox(width:63,child:Te('Subtotal',bold:true,size:12)),
  				],
  			),
  			...products.map<Widget>((prod)=>Row(
  				children: [
  					SizedBox(width:55,child:Te(prod['cantidad'],size:12)),
  					Expanded(child:Te(prod['nombre'],size:12)),
  					SizedBox(width:100,child:Te(prod['precioUnit'],size:12)),
  					SizedBox(width:63,child:Te(prod['cantidad']*prod['precioUnit'],size:12)),
  				],
  			)),
  			const SizedBox(height:12),
  		],
  	);
  }
}