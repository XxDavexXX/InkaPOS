import 'package:flutter/material.dart';
import '../services/helper.dart';
import '../services/db.dart';
import '../services/hive_helper.dart';
import '../widgets/button.dart';
import '../widgets/div.dart';
import '../widgets/p.dart';
import '../widgets/default_background.dart';
import 'dashboard.dart';

class Login extends StatefulWidget {
  const Login({super.key});
  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {

	late final TextEditingController _user;
	late final TextEditingController _password;
	String _deviceID = '<desconocido>';
	bool _obscure = true;

	void _login()async{
		String user = _user.text.trim();
		String password = _password.text.trim();
		if(user==''){alert(context,'Ingresa un usuario');return;}
		if(password==''){alert(context,'Ingresa una contraseña');return;}
		List<Map> users = getAllUsuarios().where((Map u)=>u['activo']==true).toList();
		for(int i=0;i<users.length;i++){
			if(users[i]['usuario']==user && users[i]['contraseña']==password){
				await setUser(users[i]);
				back(context);
				goTo(context,const Dashboard());
				return;
			}
		}
		await alert(context,'Datos no válidos');
	}

  @override
  void initState() {
    super.initState();
    _user = TextEditingController();
		_password = TextEditingController();
		WidgetsBinding.instance.addPostFrameCallback((_)async{
      doLoad(context);
      try{
      	String deviceID = await DB.getDeviceID();
      	setState(()=>_deviceID=deviceID);
      	back(context);
      	//Handle if already logged in
      	Map? loggedInUser = getUser();
      	if(loggedInUser!=null){
      		_user.text=loggedInUser['usuario'];
					_password.text=loggedInUser['contraseña'];
      		_login();
      	}
      } catch(e,tr) {
      	await alert(context,'Ocurrió un error');p('Error: $e\nTrace: $tr');
      	back(context);
      }
    });
  }

  @override
  void dispose() {
    _user.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DefaultBackground(
      	child: Column(
      		children: [
      			sep,sep,
						Image.asset('assets/banner.png',width:width(context)*0.9),
      			Expanded(
      				child: Center(
      					child: Div(
      						borderRadius: 23,
      						width: width(context)*0.80,
      						height: 330,
      						background: const Color.fromRGBO(81,81,81,1),
      						child: Column(
      							children: [
      								Container(
      									width: width(context),
      									height: 47,
      									decoration: const BoxDecoration(
      										color: Colors.grey,
												  borderRadius:BorderRadius.only(
												    topRight:Radius.circular(23),
												    topLeft:Radius.circular(23),
												  ),
												),
      									child: const Center(
      										child: P('INICIAR SESIÓN',color:Colors.white,align:TextAlign.center,size:24,bold:true),
      									),
      								),
      								sep,
      								SizedBox(
      									width: width(context)*0.72,
      									child: Input(
	      									_user,
	      									hint: 'Usuario',
	      									type: TextInputType.emailAddress,
	      									borderColor: Colors.white,
													borderWidth: 1,
													borderRadius: 0,
	      								),
      								),
      								sep,
      								SizedBox(
      									width: width(context)*0.72,
      									child: Input(
	      									_password,
	      									hint: 'Contraseña',
	      									type: TextInputType.visiblePassword,
	      									obscure: _obscure,
	      									borderColor: Colors.white,
													borderWidth: 1,
													borderRadius: 0,
	      									trailing: IconButton(
	      										icon: Icon(_obscure?Icons.visibility:Icons.visibility_off),
	      										onPressed: ()=>setState(()=>_obscure=!_obscure),
	      									),
	      								),
      								),
      								sep,sep,
      								Button(
      									const P('INGRESAR',color:Colors.white,bold:true,size:19),
      									_login,
      								),
      							],
      						),
      					),
      				),
      			),
      			P('$_deviceID | 1.2',color:Colors.white),
      		],
      	),
      ),
    );
  }
}


// Special Input for only this page
class Input extends StatelessWidget {
  final TextEditingController controller;
  final TextInputType type;
  final String? hint;
  final Color? hintColor;
  final String? label;
  final Color? labelColor;
  final Color background;
  final Color color;
  final Color borderColor;
  final double borderWidth;
  final double borderRadius;
  final Widget? leading;
  final Widget? trailing;
  final bool shadow;
  final bool bold;
  final bool? obscure;
  final EdgeInsetsGeometry? padding;
  final double? size;
  final int? maxCharacters;
  final TextCapitalization capitalization;
  final void Function(String)? onSubmitted;
  final void Function(String)? onChanged;
  const Input(this.controller,{
    this.type=TextInputType.text,
    this.hint,
    this.hintColor,
    this.label,
    this.labelColor,
    this.background=const Color.fromRGBO(79,80,82,1),
    this.padding,
    this.color=Colors.white,
    this.borderColor=Colors.transparent,
    this.borderWidth=2,
    this.borderRadius=16,
    this.leading,
    this.trailing,
    this.shadow=false,
    this.size,
    this.maxCharacters,
    this.obscure,
    this.bold=false,
    this.capitalization=TextCapitalization.none,
    this.onSubmitted,
    this.onChanged,
    super.key,
  });
  @override
  Widget build(BuildContext ctx) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: shadow?[
          const BoxShadow(
            color: Colors.grey,
            blurRadius: 7,
            spreadRadius: 1,
            offset: Offset(2,2),
          ),
        ]:null,
      ),
      child: TextField(
        style: TextStyle(
          color:color,
          fontSize:size??16,
          fontWeight:bold?FontWeight.bold:null,
        ),
        textCapitalization: capitalization,
        controller: controller,
        keyboardType: type,
        maxLines:type==TextInputType.multiline?null:1,
        maxLength:maxCharacters,
        obscureText:obscure??type==TextInputType.visiblePassword,
        onSubmitted:onSubmitted,
        onChanged:onChanged,
        decoration: InputDecoration(
          contentPadding: padding??const EdgeInsets.symmetric(horizontal:12,vertical:0),
          prefixIcon: leading,
          suffixIcon: trailing,
          hintText: hint,
          labelText: label,
          hintStyle: TextStyle(color:hintColor,fontSize:size??15),
          labelStyle: TextStyle(color:labelColor,fontSize:size??15),
          filled: true,
          fillColor: background??Colors.transparent,
          border: UnderlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            borderSide: BorderSide(color:borderColor,width:borderWidth),
          ),
          enabledBorder: UnderlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            borderSide: BorderSide(color:borderColor,width:borderWidth),
          ),
          focusedBorder: UnderlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            borderSide: BorderSide(color:borderColor,width:borderWidth),
          ),
        ),
      ),
    );
  }
}