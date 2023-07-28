import 'package:blog/constant.dart';
import 'package:blog/models/api_response.dart';
import 'package:blog/models/user.dart';
import 'package:blog/screens/register.dart';
import 'package:blog/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'home.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final GlobalKey<FormState> formkey = GlobalKey<FormState>(); //...form key....
  //text controller.....
  TextEditingController txtEmail = TextEditingController();
  TextEditingController txtPassword = TextEditingController();

  bool loading = false; //loader icon.......

  void _loginUser() async {
    ApiResponse response = await login(
        txtEmail.text, txtPassword.text); //The textControllers.text...
    if (response.error == null) {
      _saveAndRedirectToHome(response.data as User);
    } else {
      setState(() {
        loading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('${response.error}'),
      ));
    } 
  }

  void _saveAndRedirectToHome(User user) async {
    //Shared Preferences to store data.....
    SharedPreferences pref = await SharedPreferences.getInstance();
    await pref.setString('token', user.token ?? '');
    await pref.setInt('userId', user.id ?? 0);
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => Home()), (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
        centerTitle: true,
      ),
      body: Form(
          key: formkey,
          child: ListView(
            padding: EdgeInsets.all(32),
            children: [
              TextFormField(
                keyboardType: TextInputType.emailAddress,
                controller: txtEmail,
                validator: (val) =>
                    val!.isEmpty ? 'Invalid email address' : null,
                decoration: KinputDecoration('Email'),
              ),
              SizedBox(
                height: 10,
              ),
              TextFormField(
                  controller: txtPassword,
                  obscureText: true,
                  validator: (val) =>
                      val!.length<6 ? 'Required at least 6 characters' : null,
                  decoration: KinputDecoration('Password')),
              SizedBox(
                height: 10,
              ),
              loading
                  ? Center(
                      child: CircularProgressIndicator(),
                    )
                  : KTextButton('Login', () {
                      if (formkey.currentState!.validate()) {
                        setState(() {
                          loading = true;
                          _loginUser();
                        });
                      }
                    }),
              SizedBox(
                height: 10,
              ),
              loginRegisterHint('Dont have an Account? ', 'Register', () {
                Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => Register()),
                    (route) => false);
              })
            ],
          )),
    );
  }
}
