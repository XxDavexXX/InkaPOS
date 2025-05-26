import 'package:flutter/material.dart';
import '../services/helper.dart';
import '../services/db.dart';
import '../widgets/p.dart';
import '../widgets/default_background.dart';
import 'login.dart';

class Home extends StatefulWidget {
  const Home({super.key});
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_)async{
      await Future.delayed(const Duration(milliseconds:550));
      back(context);
      goTo(context,const Login());
    });
  }

  @override
  Widget build(BuildContext ctx) {
    return Scaffold(
      body: DefaultBackground(
        child: Column(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset('assets/banner.png',width:width(ctx)*0.9),
                  sep,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(color:Colors.white,height:2,width:24),sep,
                      P('CONTROLA FÁCIL',color:Colors.white,size:24),sep,
                      Container(color:Colors.white,height:2,width:24),
                    ],
                  ),
                  sep,
                  CircularProgressIndicator(color:prim(ctx)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  P('By TriNetSoft',bold:true,color:Colors.white,size:15),
                  P('@Copyright 2020 TriNetSoft S.A.C. Todos los derechos reservados',color:Colors.white,size:15),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}