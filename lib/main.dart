import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:todo_app_ver1/screens/sign_up_screen.dart';
import 'package:todo_app_ver1/screens/task_edit_screen.dart';
import 'package:todo_app_ver1/screens/tasks_screen.dart';

import 'firebase_options.dart';
import 'models/task.dart';
import 'screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      //home: const TasksScreen()
      //home: TaskEditScreen(
      //    task: Task(id: 1, title: "title", description: "description")),
      home: LoginScreen(),
      //home: SignUpScreen(),
    );
  }
}
