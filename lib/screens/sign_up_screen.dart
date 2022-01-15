import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:todo_app_ver1/screens/login_screen.dart';
import '../auth_service.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final nameTextController = TextEditingController();
  final emailTextController = TextEditingController();
  final passwordTextController = TextEditingController();
  final confirmPasswordTextController = TextEditingController();

  final _key = GlobalKey<FormState>();

  @override
  void dispose() {
    nameTextController.dispose();
    emailTextController.dispose();
    passwordTextController.dispose();
    confirmPasswordTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final nameField = TextFormField(
        autofocus: false,
        controller: nameTextController,
        keyboardType: TextInputType.name,
        validator: (name) {
          final RegExp regex = RegExp(r'^.{3,}$');
          if (name!.isEmpty) {
            return ("Name cannot be empty");
          }
          if (!regex.hasMatch(name)) {
            return ("Enter Valid name(Min. 3 Character)");
          }
          return null;
        },
        onSaved: (value) {
          nameTextController.text = value!;
        },
        textInputAction: TextInputAction.next,
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.account_circle),
          contentPadding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
          hintText: "Name",
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ));

    final emailField = TextFormField(
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
          contentPadding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
          hintText: "Email",
          prefixIcon: const Icon(Icons.mail),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          )),
      controller: emailTextController,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: (email) {
        final regex = RegExp(r'\w+@\w+\.\w+');
        if (email!.isEmpty) {
          return 'Please enter email address';
        } else if (!regex.hasMatch(email)) {
          return "That doesn't look like an email address";
        } else {
          return null;
        }
      },
    );

    final passwordField = TextFormField(
      keyboardType: TextInputType.visiblePassword,
      textInputAction: TextInputAction.next,
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
      autovalidateMode: AutovalidateMode.onUserInteraction,
      onSaved: (text) {
        passwordTextController.text = text!;
      },
      validator: (password) {
        if (password!.length < 6) {
          return "Password is too short";
        } else {
          return null;
        }
      },
    );

    final confirmPasswordField = TextFormField(
        controller: confirmPasswordTextController,
        obscureText: true,
        enableSuggestions: false,
        autocorrect: false,
        validator: (value) {
          if (value != passwordTextController.text) {
            return "Password doesn't match";
          }
          return null;
        },
        textInputAction: TextInputAction.done,
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.vpn_key),
          contentPadding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
          hintText: "Confirm Password",
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ));

    final confirmButton = Material(
      elevation: 5,
      borderRadius: BorderRadius.circular(30),
      color: Colors.blueAccent,
      child: MaterialButton(
        minWidth: MediaQuery.of(context).size.width,
        onPressed: () async {
          _key.currentState!.save();
          if (_key.currentState!.validate()) {
            final AuthService authService = AuthService(
              firebaseAuth: FirebaseAuth.instance,
            );
            bool res;
            res = await authService.signUpWithEmail(emailTextController.text,
                passwordTextController.text, nameTextController.text);
            if (res) {
              Navigator.push<void>(
                  context,
                  MaterialPageRoute<void>(
                      builder: (BuildContext context) => const LoginScreen()));
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text("Registration succeeded"),
              ));
            } else {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text("Registartion failed"),
              ));
            }
          }
        },
        child: const Text(
          "Sign Up",
          style: TextStyle(
              fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );

    return Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.blueAccent,
          leading: const BackButton(),
          actions: const []),
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
                  nameField,
                  const SizedBox(height: 40),
                  emailField,
                  const SizedBox(height: 40),
                  passwordField,
                  const SizedBox(height: 40),
                  confirmPasswordField,
                  const SizedBox(height: 40),
                  confirmButton,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
