

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_shop/Admin/adminLogin.dart';
import 'package:e_shop/Authentication/forgot_pass.dart';
import 'package:e_shop/Widgets/customTextField.dart';
import 'package:e_shop/DialogBox/errorDialog.dart';
import 'package:e_shop/DialogBox/loadingDialog.dart';
import 'package:e_shop/Widgets/loadingWidget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Store/storehome.dart';
import 'package:e_shop/Config/config.dart';


class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}





class _LoginState extends State<Login>
{
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailTextEditingController = TextEditingController();
  final TextEditingController _passwordTextEditingController = TextEditingController();
  final GoogleSignIn googleSignIn = GoogleSignIn();
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  SharedPreferences preferences;
  bool inLoggedIn = false;
  bool isLoading = false;
  FirebaseUser currentUser;

  @override
  void initState() {
    super.initState();
    isSignedIn();
  }

  void isSignedIn() async{
    this.setState(() {
      inLoggedIn = true;
    });
    preferences = await SharedPreferences.getInstance();
    inLoggedIn = await googleSignIn.isSignedIn();
    if(inLoggedIn){
      Navigator.push(context, MaterialPageRoute(builder: (context) => StoreHome(currentUserId: preferences.getString("id"))));
    }
    //currentUserId: preferences.getString("id")
    this.setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    double _screenWidth = MediaQuery.of(context).size.width, _screenHeight = MediaQuery.of(context).size.height;

    return SingleChildScrollView(
      child: Container(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Container(
              child: Image.asset(
                "images/login.png",
                height: 240.0,
                width: 240.0,
              ),
            ),
            Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  "Login to your account",
                  style: TextStyle(color: Colors.white),
                ),
            ),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  CustomTextField(
                    controller: _emailTextEditingController,
                    data: Icons.email,
                    hintText: "Email",
                    isObsecure: false,
                  ),
                  CustomTextField(
                    controller: _passwordTextEditingController,
                    data: Icons.password,
                    hintText: "Password",
                    isObsecure: true,
                  ),
                ],
              ),
            ),
            RaisedButton(
              onPressed: (){
                _emailTextEditingController.text.isNotEmpty && _passwordTextEditingController.text.isNotEmpty
                    ? loginUser()
                    : showDialog(
                  context: context,
                  builder: (c){
                    return ErrorAlertDialog(message: "Please write email and password",);
                  }
                );
              },
              color: Colors.blue,
              child: Text(
                "Login", style: TextStyle(color: Colors.white),
              ),
            ),
            GestureDetector(
              onTap: controlSignIn,
              child: Center(
                child: Column(
                  children: <Widget>[
                    Container(
                      width: 150.0,
                      height: 37.0,
                      decoration: BoxDecoration(
                       image: DecorationImage(
                         image: AssetImage('images/google.png'),
                         fit: BoxFit.cover,
                       ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // ElevatedButton(
            //   child: Text('Sign Up with Google'),
            //   onPressed: (){},
            // ),
            TextButton(onPressed: (){
              Route route = MaterialPageRoute(builder: (c) => ForgotPass());
              Navigator.pushReplacement(context, route);
            },
                child: Text("Forget password", style: TextStyle(color: Colors.white,fontSize: 14.0,fontWeight: FontWeight.w700),),
            ),
            SizedBox(
              height: 50.0,
            ),
            Container(
              height: 4.0,
              width: _screenWidth * 0.8,
              color: Colors.pink,
            ),
            SizedBox(
              height: 10.0,
            ),
            FlatButton.icon(
                onPressed: ()=> Navigator.push(context, MaterialPageRoute(builder: (context) => AdminSignInPage())),
                icon: (Icon(Icons.nature_people,color: Colors.pink,)),
                label: Text("Admin Page", style: TextStyle(color: Colors.pink,fontWeight: FontWeight.bold),),
            ),
          ],
        ),
      ),
    );
  }

  FirebaseAuth _auth = FirebaseAuth.instance;
  void loginUser()async{
    showDialog(
        context: context,
        builder: (c){
          return LoadingAlertDialog(message: "Please wait...",);
        }
        );
    FirebaseUser firebaseUser;
    await _auth.signInWithEmailAndPassword(
      email: _emailTextEditingController.text.trim(),
      password:  _passwordTextEditingController.text.trim(),
    ).then((authUser){
      firebaseUser = authUser.user;
    }).catchError((error){
      Navigator.pop(context);
      showDialog(
          context: context,
          builder: (c){
            return ErrorAlertDialog(message: error.message.toString(),);
          }
          );
    });
    if(firebaseUser != null){
      readData(firebaseUser).then((s){
        Navigator.pop(context);
        Route route = MaterialPageRoute(builder: (c) => StoreHome());
        Navigator.pushReplacement(context, route);

      });
    }
  }
  Future  readData(FirebaseUser fUser) async{
     Firestore.instance.collection("users").document(fUser.uid).get().then((dataSnapshot) async {
       await EcommerceApp.sharedPreferences.setString("uid", dataSnapshot.data[EcommerceApp.userUID]);
       await EcommerceApp.sharedPreferences.setString(EcommerceApp.userEmail, dataSnapshot.data[EcommerceApp.userEmail]);
       await EcommerceApp.sharedPreferences.setString(EcommerceApp.userName, dataSnapshot.data[EcommerceApp.userName]);
       await EcommerceApp.sharedPreferences.setString(EcommerceApp.userAvatarUrl, dataSnapshot.data[EcommerceApp.userAvatarUrl]);
       List<String> cartList = dataSnapshot.data[EcommerceApp.userCartList].cart<String>();
       await EcommerceApp.sharedPreferences.setStringList(EcommerceApp.userCartList, ["garbageValue"]);

     });
  }
  Future<Null> controlSignIn() async{
    preferences = await SharedPreferences.getInstance();
  this.setState(() {
    isLoading = true;
  });
  GoogleSignInAccount googleUser = await googleSignIn.signIn();
  GoogleSignInAuthentication googleSignInAuthentication = await googleUser.authentication;
  final AuthCredential credential = GoogleAuthProvider.getCredential(idToken: googleSignInAuthentication.idToken, accessToken: googleSignInAuthentication.accessToken);
  FirebaseUser firebaseUser = (await firebaseAuth.signInWithCredential(credential)).user;
  //Success
  if(firebaseUser != null){
    //check if ready Signup
    final QuerySnapshot resultQuery = await Firestore.instance.collection("users").where("uid", isEqualTo: firebaseUser.uid).getDocuments();
    final List<DocumentSnapshot> documentSnapshort = resultQuery.documents;
    //Save Data to FireStore - if new user
    if(documentSnapshort.length == 0){
      Firestore.instance.collection("users").document(firebaseUser.uid).setData({
        "name" : firebaseUser.displayName,
        "url" : firebaseUser.photoUrl,
        "uid" : firebaseUser.uid,
        EcommerceApp.userCartList:["garbageValue"],
      });
      currentUser = firebaseUser;
      await preferences.setString("uid", currentUser.uid);
      await preferences.setString("name", currentUser.displayName);
      await preferences.setString("url", currentUser.photoUrl);
      await EcommerceApp.sharedPreferences.setStringList(EcommerceApp.userCartList, ["garbageValue"]);

    }else{
      //Write data to local
      currentUser = firebaseUser;
      await preferences.setString("uid", documentSnapshort[0]["uid"]);
      await preferences.setString("name", documentSnapshort[0]["name"]);
      await preferences.setString("url", documentSnapshort[0]["url"]);
      await EcommerceApp.sharedPreferences.setStringList(EcommerceApp.userCartList, documentSnapshort[0]["garbageValue"]);
    }

    Fluttertoast.showToast(msg: "Congratulations, Sign in Successful.");
    this.setState(() {
      isLoading = false;
    });
    Navigator.push(context, MaterialPageRoute(builder: (context) => StoreHome(currentUserId: firebaseUser.uid)));
  }
  //Note Success
  else{
    Fluttertoast.showToast(msg: "Try Again, Sign in Failed.");
    this.setState(() {
      isLoading = false;
    });
  }
  }
}
