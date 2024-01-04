import 'package:chat/helpers/constant.dart';
import 'package:chat/modules/show_snackbar.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

Future<dynamic> httpGetRequest(String id) async {
  try {
    var response = await http.get(Uri.parse("${url}user/$id"),
        headers: {'Content-Type': 'application/json'});
    var result = jsonDecode(response.body);
    return result;
  } catch (e) {
    showSnackbar("Error: $e");
  }
}
