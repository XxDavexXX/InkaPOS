import 'package:http/http.dart' as http;
import 'dart:convert';

Future<Map?> doHttp(String method, String url, {Map<String,String>? headers, Map<String,dynamic>? body}) async {
  http.Response res;
  Uri uri = Uri.parse(url);
  switch (method.toUpperCase()) {
    case 'GET': res = await http.get(uri, headers: headers);break;
    case 'POST': res = await http.post(uri, headers: headers, body: json.encode(body));break;
    case 'PUT': res = await http.put(uri, headers: headers, body: json.encode(body));break;
    case 'PATCH': res = await http.patch(uri, headers: headers, body: json.encode(body));break;
    case 'DELETE': res = await http.delete(uri, headers: headers);break;
    default: throw Exception('HTTP method not supported: $method');
  }
  if(res.statusCode >= 200 && res.statusCode < 300)return json.decode(res.body);
  throw Exception('Failed to perform $method request in "$url" with status code ${res.statusCode}.');
}

class DB {

  static Future<String> getDeviceID()async{
    return 'E13cab69';
  }
  static Future<bool> checkDbIsOk()async{
    //TODO: dashboard.dart. Convalida que haya conexión a la base de datos remota
    await Future.delayed(const Duration(milliseconds:720));
    return true;
  }
  static Future<String?> getUserWebAdminLink()async{
    //TODO: dashboard.dart. E.g.: https://almacenweb.trinetsoft.com/webkelys
    return 'trinetsoft.com';
  }
  static Future<Map<String,double>?> tipoDeCambioSunat()async{
    //TODO: abrir_turno.dart
    await Future.delayed(const Duration(milliseconds:550));
    return null;
  }
  
}