import 'package:blog/constant.dart';
import 'package:blog/models/api_response.dart';
import 'package:blog/models/user.dart';
import 'package:blog/screens/login.dart';
import 'package:blog/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'home.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  GlobalKey<FormState> formkey = GlobalKey<FormState>();
  bool loading = false;
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController passwordConfirmController = TextEditingController();

  void _registerUser() async {
    ApiResponse response = await register(
        emailController.text, passwordController.text, nameController.text);
    if (response.error == null) {
      _saveAndRedirectoHome(response.data as User);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('${response.error}'),
      ));
    }
  }

  void _saveAndRedirectoHome(User user) async {
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
        title: Text('Register'),
        centerTitle: true,
      ),
      body: Form(
          key: formkey,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 32),
            children: [
              TextFormField(
                controller: nameController,
                validator: (val) => val!.isEmpty ? 'Invalid name' : null,
                decoration: KinputDecoration('Name'),
              ),
              SizedBox(
                height: 20,
              ),
              TextFormField(
                keyboardType: TextInputType.emailAddress,
                controller: emailController,
                validator: (val) =>
                    val!.isEmpty ? 'Invalid email address' : null,
                decoration: KinputDecoration('Email'),
              ),
              SizedBox(
                height: 20,
              ),
              TextFormField(
                controller: passwordController,
                obscureText: true,
                validator: (val) =>
                    val!.length < 6 ? 'Required at least 6 characters' : null,
                decoration: KinputDecoration('Password'),
              ),
              SizedBox(
                height: 20,
              ),
              TextFormField(
                controller: passwordConfirmController,
                obscureText: true,
                validator: (val) => val != passwordController.text
                    ? 'Password Comfirm does not match'
                    : null,
                decoration: KinputDecoration('Confirm Password'),
              ),
              SizedBox(
                height: 20,
              ),
              loading
                  ? Center(
                      child: CircularProgressIndicator(),
                    )
                  : KTextButton('Register', () {
                      if (formkey.currentState!.validate()) {
                        setState(() {
                          loading = !loading;
                          _registerUser();
                        });
                      }
                    }),
              SizedBox(
                height: 20,
              ),
              loginRegisterHint('Already have an Account? ', 'Login', () {
                Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => Login()),
                    (route) => false);
              })
            ],
          )),
    );
  }
}
