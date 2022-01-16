import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
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

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (context) => ThemeController(),
        builder: (context, _) {
          return MaterialApp(
            themeMode: Provider.of<ThemeController>(context).themeMode,
            darkTheme: ThemeData(
              brightness: Brightness.dark,
            ),
            debugShowCheckedModeBanner: false,
            home: const LoginScreen(),
          );
        });
  }
}

class ThemeController extends ChangeNotifier {
  ThemeMode themeMode = ThemeMode.light;

  bool isDarkMode() => themeMode == ThemeMode.dark;

  void changeTheme(bool toDark) {
    themeMode = toDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }
}
