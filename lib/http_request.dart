import 'dart:developer';
import 'package:http/http.dart' as http;

class HttpService {
  static Future<String?> get(String baseurl) async {
    try{
      http.Response response =  await http.get(Uri.parse(baseurl));
      if(response.statusCode == 200){
        print('Status 200');
        return response.body;
      }
      else {
        print('Status not 200');
      }
    } catch(e){
      log('HttpService $e');
    }
    return '';
  }
}