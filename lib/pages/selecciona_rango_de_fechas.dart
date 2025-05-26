import 'package:flutter/material.dart';
import '../services/helper.dart';
import '../services/db.dart';
import '../services/hive_helper.dart';
import '../widgets/default_background.dart';
import '../widgets/simple_white_box.dart';
import '../widgets/dialog_title.dart';
import '../widgets/simple_line.dart';
import '../widgets/my_icon.dart';
import '../widgets/button.dart';
import '../widgets/input.dart';
import '../widgets/div.dart';
import '../widgets/p.dart';

class SeleccionaRangoDeFechas extends StatefulWidget {
  final DateTime firstDate;
  final DateTime lastDate;
  final DateTime? initialDateFrom;
  final DateTime? initialDateTo;
  final String? text;
  const SeleccionaRangoDeFechas({
    required this.firstDate,
    required this.lastDate,
    this.initialDateFrom,
    this.initialDateTo,
    this.text,
    super.key,
  });
  @override
  State<SeleccionaRangoDeFechas> createState() => _SeleccionaRangoDeFechasState();
}

class _SeleccionaRangoDeFechasState extends State<SeleccionaRangoDeFechas> {
  DateTime? _dateFrom;
  DateTime? _dateTo;

  @override
  void initState() {
    super.initState();
    _dateFrom = widget.initialDateFrom;
    _dateTo = widget.initialDateTo;
  }
  
  void _pickFrom()async{
    DateTime? x = await _selectDate();
    if(x==null)return;
    if(_dateTo!=null&&x.isAfter(_dateTo!)){alert(context,'Fecha no válida');return;}
    setState(()=>_dateFrom=x);
  }

  void _pickTo()async{
    DateTime? x = await _selectDate();
    if(x==null)return;
    if(_dateFrom!=null&&x.isBefore(_dateFrom!)){alert(context,'Fecha no válida');return;}
    setState(()=>_dateTo=x);
  }

  Future<DateTime?> _selectDate()async{
    final DateTime now = DateTime.now();
    return await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: widget.firstDate,
      lastDate: widget.lastDate,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:Theme.of(context).colorScheme.surface,
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
                DialogTitle('Selecciona rango de fechas'),
                if(widget.text!=null)Padding(
                  padding: const EdgeInsets.only(bottom:16),
                  child: P(widget.text!,align:P.center,color:Colors.black),
                ),
                DatePickerBox(label:'Desde:',date:_dateFrom,onTap:_pickFrom),
                sep,
                DatePickerBox(label:'Hasta:',date:_dateTo,onTap:_pickTo),
                sep,sep,
                Center(
                  child: SizedBox(
                    width: width(context)*0.72,
                    child: Button(P('Escoger rango',color:Colors.white),(){
                      back(context,data:(_dateFrom!=null&&_dateTo!=null)?<DateTime>[_dateFrom!,_dateTo!]:null);
                    }),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class DatePickerBox extends StatelessWidget {
  final String label;
  final DateTime? date;
  final VoidCallback onTap;
  const DatePickerBox({
    required this.label,
    required this.date,
    required this.onTap,
    super.key,
  });
  @override
  Widget build(BuildContext context)=>Column(
    mainAxisAlignment: MainAxisAlignment.start,
    children: [
      P(label,bold:true,color:Colors.black),
      const SizedBox(height:7),
      InkWell(
        onTap: onTap,
        child: Div(
          width: width(context)*0.72,
          height: 47,
          background: const Color.fromRGBO(236,236,236,1),
          padding: const EdgeInsets.symmetric(horizontal:14,vertical:5),
          borderRadius: 16,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              P(date==null?'Mes día, año':getDateString(date!.millisecondsSinceEpoch,'month day, year',monthAsText:true),color:Colors.black),
              sep,
              Icon(Icons.calendar_month,color:prim(context),size:32),
            ],
          ),
        ),
      ),
    ],
  );
}