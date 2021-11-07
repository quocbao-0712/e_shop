
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
class LoginGoogle extends GetxController{
  var _googleSignIn = GoogleSignIn();
  var isSignedIn = false.obs;
  var googleAcc = Rx<GoogleSignInAccount>(null);

  void signInWithGoogle()
  async{
    try{
        googleAcc.value= await _googleSignIn.signIn();

    }catch(e){
      Get.snackbar('Error occured!', e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );

    }
  }
}
