import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:todo_app_ver1/auth_service.dart';
import 'package:todo_app_ver1/models/user_model.dart';
import 'package:todo_app_ver1/screens/sign_up_screen.dart';
import 'package:todo_app_ver1/screens/tasks_screen.dart';

class LoginScreen extends StatefulWidget {
  LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailTextController = TextEditingController();
  final passwordTextController = TextEditingController();

  final _key = GlobalKey<FormState>();

  @override
  void dispose() {
    emailTextController.dispose();
    passwordTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var emailField = TextFormField(
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
          contentPadding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
          hintText: "Email",
          prefixIcon: const Icon(Icons.account_circle),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          )),
      controller: emailTextController,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: (email) {
        final regex = RegExp(r'\w+@\w+\.\w+');
        if (email!.isEmpty) {
          return 'We need an email address';
        } else if (!regex.hasMatch(email)) {
          return "That doesn't look like an email address";
        } else {
          return null;
        }
      },
    );

    var passwordField = TextFormField(
      keyboardType: TextInputType.visiblePassword,
      obscureText: true,
      enableSuggestions: false,
      autocorrect: false,
      decoration: InputDecoration(
          contentPadding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
          hintText: "Password",
          prefixIcon: const Icon(Icons.vpn_key),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          )),
      controller: passwordTextController,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      //onSaved: (text) {
      //  passwordTextController.text = text!;
      //},
      validator: (password) {
        if (password!.length < 6) {
          return "Password is too short";
        } else {
          return null;
        }
      },
    );

    var confirmButton = Material(
      elevation: 5,
      borderRadius: BorderRadius.circular(30),
      color: Colors.blueAccent,
      child: MaterialButton(
        minWidth: MediaQuery.of(context).size.width,
        onPressed: () async {
          if (_key.currentState!.validate()) {
            // Using Text Controller
            print('Text Controller ${emailTextController.text}');
            // Using on saved
            _key.currentState!.save();

            final AuthService authService = AuthService(
              firebaseAuth: FirebaseAuth.instance,
            );
            SignInResult res = await authService.signInWithEmail(
                emailTextController.text, passwordTextController.text);

            switch (res) {
              case SignInResult.invalidEmail:
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content:
                        Text('Your email address appears to be malformed.'),
                  ),
                );
                break;
              case SignInResult.userDisabled:
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('User with this email has been disabled.'),
                ));
                break;
              case SignInResult.userNotFound:
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text("User with this email doesn't exist."),
                ));
                break;
              case SignInResult.emailAlreadyInUse:
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('An undefined Error happened.'),
                ));
                break;
              case SignInResult.wrongPassword:
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('Your password is wrong.'),
                ));
                break;
              case SignInResult.success:
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(
                      'Successfully logged ${FirebaseAuth.instance.currentUser!.email}'),
                ));
                Navigator.push<void>(
                    context,
                    MaterialPageRoute<void>(
                        builder: (BuildContext context) => TasksScreen(
                            user: UserModel(
                                uid: FirebaseAuth.instance.currentUser!.uid,
                                email: FirebaseAuth.instance.currentUser!.email,
                                name: FirebaseAuth
                                    .instance.currentUser!.displayName))));
                break;
            }
          }
        },
        child: const Text(
          "Sign In",
          style: TextStyle(
              fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(36.0),
            child: Form(
              key: _key,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 200,
                    child: Image.asset(
                      "assets/logo_flutter.png",
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  emailField,
                  const SizedBox(height: 40),
                  passwordField,
                  const SizedBox(height: 40),
                  confirmButton,
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Don't have an account? "),
                      GestureDetector(
                        onTap: () {
                          Navigator.push<void>(
                              context,
                              MaterialPageRoute<void>(
                                  builder: (BuildContext context) =>
                                      const SignUpScreen()));
                        },
                        child: const Text(
                          "Sign up!",
                          style: TextStyle(color: Colors.blueAccent),
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
