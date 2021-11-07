
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:e_shop/Authentication/authenication.dart';
class ForgotPass extends StatefulWidget {
  @override
  _ForgotPassState createState() => _ForgotPassState();
}

class _ForgotPassState extends State<ForgotPass> {
  final _formKey = GlobalKey<FormState>();
  String email;
  final emailController = TextEditingController();

  resetPassword() async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.amber,
        content: Text('Password Reset Email has been sent !',
          style: TextStyle(fontSize: 18.0),
        ),
      ),
      );
      Route route = MaterialPageRoute(builder: (c) => AuthenticScreen());
      Navigator.pushReplacement(context, route);
    } catch(error){
       if(error.code =="user-not-found"){
         print('No user found for that email !');
         ScaffoldMessenger.of(context).showSnackBar(SnackBar(
           backgroundColor: Colors.amber,
           content: Text('No user found for that email !',
             style: TextStyle(fontSize: 18.0,color: Colors.amber),
           ),
         ),
         );
       }
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(' Reset Password'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            //image
          ),
          Container(
            margin: EdgeInsets.only(top: 20.0),
            child: Text(
              ' Reset link will be send to your email ID !',
              style: TextStyle(fontSize: 20.0),
            ),
          ),
          Expanded(
              child: Form(
                key: _formKey,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                      vertical: 10.0, horizontal: 30.0),
                  child: ListView(
                    children: [
                      Container(
                        margin: EdgeInsets.symmetric(vertical: 10.0),
                        child: TextFormField(
                          autofocus: false,
                          decoration: InputDecoration(
                            labelText: 'Email',
                            labelStyle: TextStyle(
                              color: Colors.black26,
                              fontSize: 15.0,
                            ),
                          ),
                          controller: emailController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter Email !';
                            } else if (!value.contains('@')) {
                              return 'Please check valid Email!';
                            }
                            return null;
                          },
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.symmetric(vertical: 20.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                    setState(() {
                                      email = emailController.text;
                                    });
                                  resetPassword();
                              },
                              child: Text(
                                'Send email',
                                style: TextStyle(fontSize: 18.0),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Route route = MaterialPageRoute(builder: (c) => AuthenticScreen());
                                Navigator.pushReplacement(context, route);
                                },
                              child: Text(
                                'Login ',
                                style: TextStyle(fontSize: 13.0),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Do not have account ?'),
                            TextButton(
                              onPressed: () {},
                              child: Text('Signup'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ))
        ],
      ),
    );
  }
}
