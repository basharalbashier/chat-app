import 'dart:io';

import 'package:chat/pages/list_users.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import '../client/user.dart';
import '../controllers/db_controller.dart';
import '../controllers/signup_controller.dart';
import '../main.dart';
// import 'package:google_sign_in/google_sign_in.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  var displayNameController = TextEditingController();
  var info = [];
  @override
  void initState() {
    _getIfReg();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var signinController = Get.put(LoginController());
    return Scaffold(
      body: Center(
        child: info.isEmpty
            ? const CircularProgressIndicator.adaptive()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        FloatingActionButton.extended(
                            onPressed: () async =>
                                await signinController.login(context),
                            label: const Text("Signup with Google"))
                      ],
                    ),
                  )
                ],
              ),
      ),
    );
  }

  // GoogleSignIn _googleSignIn = new GoogleSignIn();

  void _getIfReg() async {
    User data = await DBProvider.db.getMe();
    data.name.isEmpty ? setState(() => info = [0]) : _nextPage(data);
  }

  _nextPage(User user) async {
    Get.offAll(() => const ListUsers());
  }
}
