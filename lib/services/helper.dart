import 'package:flutter/material.dart';

const sep=SizedBox(height:12,width:12);

Future<dynamic?> goTo(BuildContext ctx,Widget p)async=>await Navigator.push(ctx,MaterialPageRoute(builder:(x)=>p));
void back(BuildContext ctx,{dynamic? data})=>Navigator.pop(ctx,data);

void p(dynamic t)=>print(t is String?t:t.toString());

Color prim(BuildContext ctx)=>Theme.of(ctx).colorScheme.primary;
Color sec(BuildContext ctx)=>Theme.of(ctx).colorScheme.secondary;
Color surf(BuildContext ctx)=>Theme.of(ctx).colorScheme.surface;
Color onSurf(BuildContext ctx)=>Theme.of(ctx).colorScheme.onSurface;
double width(BuildContext ctx)=>MediaQuery.of(ctx).size.width;
double height(BuildContext ctx)=>MediaQuery.of(ctx).size.height;

String getDateString(int? millis, String template, {bool monthAsText=false}){
  if(millis==null)return '';
  String to2Chars(int x)=>'$x'.length==1?'0$x':'$x';
  DateTime d = DateTime.fromMillisecondsSinceEpoch(millis);
  String string = template;
  string = string.replaceAll('year',d.year.toString());
  if(monthAsText){
    string = string.replaceAll('month',['Enero','Febrero','Marzo','Abril','Mayo','Junio','Julio','Agosto','Septiembre','Octubre','Noviembre','Diciembre'][d.month-1]);
  } else {
    string = string.replaceAll('month',to2Chars(d.month));
  }
  string = string.replaceAll('day',to2Chars(d.day));
  string = string.replaceAll('hour',to2Chars(d.hour));
  string = string.replaceAll('minute',to2Chars(d.minute));
  string = string.replaceAll('second',to2Chars(d.second));
  return string;
}

Future<void> alert(BuildContext context,String message, {bool selectable=false,bool dismissible=true})async{
  await showDialog(
    context:context,
    barrierDismissible: dismissible,
    builder:(context){
      return SimpleDialog(
        backgroundColor: Colors.white,
        title: selectable?
        SelectableText(message,style:TextStyle(fontWeight:FontWeight.bold,fontSize:17,color:Colors.black),textAlign:TextAlign.center):
        Text(message,style:TextStyle(fontWeight:FontWeight.bold,fontSize:17,color:Colors.black),textAlign:TextAlign.center),
        children:[
          Row(
            mainAxisAlignment:MainAxisAlignment.center,
            children:[
              ElevatedButton(
                onPressed:()=>Navigator.pop(context),
                style:ButtonStyle(
                  backgroundColor:MaterialStateProperty.all(Theme.of(context).colorScheme.primary),
                ),
                child:Padding(
                  padding: const EdgeInsets.symmetric(horizontal:32),
                  child: Text('Ok',style:TextStyle(fontWeight:FontWeight.bold,color:Theme.of(context).colorScheme.onPrimary)),
                ),
              ),
            ],
          ),
        ],
      );
    }
  );
}

Future<bool?> confirm(BuildContext context, String question, {bool dismissible=true})async{
  bool? answer;
  await showDialog(
    context: context,
    barrierDismissible:dismissible,
    builder: (context){
      return AlertDialog(
        backgroundColor: Colors.white,
        title: Text(question,style:TextStyle(fontSize:17,color:Colors.black,fontWeight:FontWeight.bold)),
        actions: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                style:ButtonStyle(
                  backgroundColor:MaterialStateProperty.all(Theme.of(context).colorScheme.primary),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal:23),
                  child: Text('Si',style:TextStyle(fontSize:17,color:Theme.of(context).colorScheme.onPrimary)),
                ),
                onPressed: (){
                  answer = true;
                  Navigator.pop(context);
                },
              ),
              sep,
              ElevatedButton(
                style:ButtonStyle(
                  backgroundColor:MaterialStateProperty.all(Theme.of(context).colorScheme.primary),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal:23),
                  child: Text('No',style:TextStyle(fontSize:17,color:Theme.of(context).colorScheme.onPrimary)),
                ),
                onPressed: (){
                  answer = false;
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ],
      );
    },
  );
  return answer;
}

Future<String?> prompt(BuildContext context, {String text='', String initialValue='', Widget child=const SizedBox(), int maxCharacters=0, TextInputType type=TextInputType.text, bool obscureText=false, bool dismissible=true, TextCapitalization capitalization=TextCapitalization.sentences})async{
  bool okButtonPressed=false;
  final TextEditingController stringController = TextEditingController();
  await showDialog(
    context:context,
    barrierDismissible:dismissible,
    builder:(context)=>SimpleDialog(
      backgroundColor: Theme.of(context).colorScheme.surface,
      contentPadding:const EdgeInsets.all(10.0),
      title:text==''?null:Text(text,style:TextStyle(fontSize:17,color:Theme.of(context).colorScheme.onSurface)),
      children:<Widget>[
        TextField(
          style:TextStyle(color:Theme.of(context).colorScheme.onSurface),
          keyboardType:type,
          maxLines:type==TextInputType.multiline?null:1,
          textCapitalization:capitalization,
          maxLength:maxCharacters==0?null:maxCharacters,
          controller:stringController..text=initialValue,
          autofocus:true,
          obscureText:obscureText,
        ),
        sep,
        Row(
          mainAxisAlignment:MainAxisAlignment.spaceEvenly,
          children:<Widget>[
            ElevatedButton(
              style:ButtonStyle(
                backgroundColor:MaterialStateProperty.all(Theme.of(context).primaryColor),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal:12),
                child: Text('Ok',style:TextStyle(fontSize:16,color:Theme.of(context).colorScheme.onPrimary)),
              ),
              onPressed:(){
                okButtonPressed=true;
                Navigator.pop(context);
              },
            ),
            ElevatedButton(
              style:ButtonStyle(
                backgroundColor:MaterialStateProperty.all(Theme.of(context).primaryColor),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal:12),
                child: Text('Cancelar',style:TextStyle(fontSize:16,color:Theme.of(context).colorScheme.onPrimary)),
              ),
              onPressed:(){
                Navigator.pop(context);
              },
            ),
          ],
        ),
        child,
      ],
    ),
  );
  return okButtonPressed?stringController.text.trim():null;
}

Future<int?> choose(BuildContext context,List<String> options,{String? text, Widget? child, Color? color, Color? bg, bool dismissible=true})async{
  int? selectedIndex;
  List<Widget> dialogOptions=[];
  for(int c=0;c<options.length;c++){
    dialogOptions.add(
      SimpleDialogOption(
        child:Text(options[c],style:TextStyle(fontSize:16,fontWeight:FontWeight.bold)),
        onPressed:(){
          selectedIndex=c;
          Navigator.pop(context);
        },
      ),
    );
  }
  if(child!=null)dialogOptions.add(child);
  await showDialog(
    context:context,
    barrierDismissible:dismissible,
    builder:(context)=>SimpleDialog(
      backgroundColor: Colors.white,
      children: [
        if(text!=null)Column(
          children: [
            Column(
              children: [
                sep,
                Text(text,style:TextStyle(fontSize:19,color:prim(context),fontWeight:FontWeight.bold),textAlign:TextAlign.center),
                sep,Container(width:width(context)*0.66,height:1,color:Colors.grey),sep,
              ],
            ),
          ],
        ),
        ...dialogOptions
      ],
    ),
  );
  return selectedIndex;
}

Future<List<int>?> select(BuildContext context,List<String> options,{String? text, Color? color, Color? bg, bool dismissible=true})async{
  return await showDialog(
    barrierDismissible: dismissible,
    context: context,
    builder: (BuildContext context){
      List<int> selectedIndexes = [];
      return StatefulBuilder(
        builder:(context,setState)=>Dialog(
          backgroundColor: bg??surf(context),
          child: Column(
            children: [
              sep,
              if(text!=null)Column(
                children: [
                  sep,
                  Text(text,style:TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: color??onSurf(context),
                  )),
                ],
              ),
              sep,
              Expanded(
                child: ListView(
                  children: options.asMap().entries.toList().map<Widget>((MapEntry<int,String> item){
                    final int index = item.key;
                    final String option = item.value;
                    final bool checked = selectedIndexes.contains(index);
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal:10),
                      child: Card(
                        color: bg??surf(context),
                        child: ListTile(
                          title: Text(
                            option,
                            style: TextStyle(
                              color: color??onSurf(context),
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.start,
                          ),
                          trailing: Icon(
                            checked?Icons.check_box:Icons.check_box_outline_blank,
                            color: prim(context),
                            size: 28,
                          ),
                          onTap: ()=>setState((){
                            if(checked){
                              selectedIndexes.remove(index);
                            } else {
                              selectedIndexes.add(index);
                            }
                          }),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              sep,
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: (){
                    selectedIndexes.sort((a,b) => a.compareTo(b));
                    back(context,data:selectedIndexes);
                  },
                  child: Text(
                    'Select',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign:TextAlign.center,
                  ),
                ),
              ),
              sep,
            ],
          ),
        ),
      );
    }
  );
}

Future<dynamic?> dialog(BuildContext context,{
  Color? background,
  double borderRadius = 23.0,
  double padding = 16.0,
  List<Widget> children = const <Widget>[],
  bool dismissible = true,
  double? width,
  double? height,
  Color? shadowColor,
  Color? barrierColor,
  Alignment alignment = Alignment.center,
})async{
  return await showDialog(
    barrierColor: barrierColor,
    barrierDismissible: dismissible,
    context:context,
    builder:(context)=>SimpleDialog(
      shadowColor: shadowColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(borderRadius)),
      backgroundColor: background??Theme.of(context).colorScheme.surface,
      children: [SizedBox(
        width: width,
        height: height,
        child: Column(children:children),
      )],
      contentPadding: EdgeInsets.all(padding),
      alignment: alignment,
    ),
  );
}

void showSnackBar(BuildContext context,String title,String subtitle,{int? seconds, Icon? icon, Color? color, Color? background})async{
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    duration: Duration(seconds:seconds??2),
    backgroundColor: Colors.transparent,
    behavior: SnackBarBehavior.floating,
    elevation: 0,
    content: Container(
      padding: const EdgeInsets.all(8),
      height: 72,
      decoration: BoxDecoration(
        color: background??Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
      child: Row(
        children: [
          const SizedBox(width: 12),
          icon??Icon(Icons.warning,color:Colors.amber,size:30),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 16, color: color??Colors.black, fontWeight: FontWeight.bold),
                ),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 15, color: color??Colors.black),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  ));
}

Future<void> loadThis(BuildContext context,Function cb,{String errMsg='Ocurrió un error'})async{
  doLoad(context);
  try{await cb();}
  catch(e){await alert(context,errMsg);}
  finally{Navigator.pop(context);}
}

void doLoad(BuildContext context,{Color? color}){
  showDialog(
    context: context,
    builder: (context){
      return PopScope(
        canPop: false,
        child: AbsorbPointer(
          absorbing: true,
          child: Center(
            child: Material(
              type:MaterialType.transparency,
              child:CircularProgressIndicator(color:color??prim(context)),
            ),
          ),
        ),
      );
    }
  );
}