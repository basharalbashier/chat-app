import 'package:chat/helpers/constant.dart';
import 'package:chat/modules/show_snackbar.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


httpPostRequest(Map<String, dynamic> body) async {
  try {
    var result = await http.post(Uri.parse("${url}user"),
        headers: {'Content-Type': 'application/json'}, body: jsonEncode(body));
    var user = jsonDecode(result.body);
    return user;
  } catch (e) {
    showSnackbar("Error: $e");
  }
}
