import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:test_client/test_client.dart';
// import 'package:google_sign_in/google_sign_in.dart';

import '../controllers/db_controller.dart';
import '../controllers/router_controller.dart';
import 'chat_screen.dart';

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
    // _getIfReg();
    super.initState();
  }
/**
 * info.isEmpty
            ? const CircularProgressIndicator.adaptive()
            : 
 */
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SizedBox(
                width: MediaQuery.of(context).size.width / 2,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextField(
                      onChanged: ((v) => setState(() => {})),
                      controller: displayNameController,
                      decoration: InputDecoration(
                          suffix: Visibility(
                              visible: displayNameController.text.length > 2,
                              child: IconButton(
                                  onPressed: () async => _nextPage(User(id:DateTime.now().second,name: displayNameController.text.trim())),
                                  
                                  //  await DBProvider.db
                                  //     .addMe(User(
                                  //         name: displayNameController.text)).then((v)=>_getIfReg()) ,
                                  icon: const Icon(Icons.send))),
                          hintText: 'Display name'),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Sign up with google"),
                          IconButton(
                              onPressed: () => _handleSignIn(),
                              icon: const Icon(Icons.g_mobiledata)),
                        ],
                      ),
                    )
                  ],
                )),
      ),
    );
  }

  // GoogleSignIn _googleSignIn = new GoogleSignIn();

  Future<void> _handleSignIn() async {
    try {
      // GoogleSignInAccount googleSignInAccount = await _googleSignIn.signIn();
      // GoogleSignInAuthentication googleSignInAuthentication =
      //     await googleSignInAccount.authentication;

      // var result = (await _auth.signInWithCredential(credential));
      // _user = result.user;
      // await _googleSignIn.signIn();
    } catch (error) {
      if (kDebugMode) {
        print(error);
      }
    }
  }

  void _getIfReg() async {
    // User data = await DBProvider.db.getMe();
    // data.name.isEmpty ? setState(() => info = [0]) : _nextPage(data);
  }

  _nextPage(User user) async {
    // Navigator.of(context).pushReplacement(FadePageRoute(
    //     builder: (context) => ChatScreen(
    //           user: user,
    //         )));
  }
}
