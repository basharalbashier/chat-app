import 'package:chat/controllers/db_controller.dart';
import 'package:chat/helpers/constant.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:test_client/test_client.dart';

import '../pages/list_users.dart';

class LoginController extends GetxController {
  final _googleSignIn = GoogleSignIn();
  var googleAccount = Rx<GoogleSignInAccount?>(null);
  var me = Rx<User?>(null);

  login(context) async {
    try {
      googleAccount.value = await _googleSignIn.signIn();
      var value = googleAccount.value;
      User user = User(
          id: 1,
          uid: value!.id,
          name: value.displayName!,
          email: value.email,
          photourl: value.photoUrl);
      await DBProvider.db.addMe(user);
      Get.offAll(() => ListUsers(user: user));
    } catch (e) {
      if (kDebugMode) {
        print(e.toString() + ": sign in error");
      }
    }
  }
}
