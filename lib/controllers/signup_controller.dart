import 'package:chat/controllers/db_controller.dart';
import 'package:chat/helpers/constant.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:test_client/test_client.dart';

class LoginController extends GetxController {
  final _googleSignIn = GoogleSignIn();
  var googleAccount = Rx<GoogleSignInAccount?>(null);

  login(context) async {
    try {
      googleAccount.value = await _googleSignIn.signIn();
      print(googleAccount.value);
      // if (googleAccount.value != null) await DBProvider.db.addMe();
    } catch (e) {
      if (kDebugMode) {
        print(e.toString() + ": sign in error");
      }
    }
  }
}
