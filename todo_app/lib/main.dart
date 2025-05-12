import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
import 'package:todo_app/constants/colors.dart';
import 'package:todo_app/constants/text_styles.dart';
import 'package:todo_app/providers/theme_provider.dart';
import 'package:todo_app/screens/auth_screen.dart';
import 'package:todo_app/screens/todo_screen.dart';
import 'package:todo_app/services/auth_service.dart';

// Your web app's Firebase configuration
// These values will be used for Firebase initialization on the web.
const FirebaseOptions firebaseOptions = FirebaseOptions(
  apiKey: "AIzaSyAnFrbkF9Yturi-ogSQaXOTFO2YBcZkSwc",
  authDomain: "todo-app-gellend.firebaseapp.com",
  projectId: "todo-app-gellend",
  storageBucket: "todo-app-gellend.firebasestorage.app",
  messagingSenderId: "346324548675",
  appId: "1:346324548675:web:376a0dd8183e8d2e6c68f6",
  measurementId: "G-N7Y0S2ZS6S"
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    await Firebase.initializeApp(options: firebaseOptions);
  } else {
    await Firebase.initializeApp();
  }
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  final AuthService _authService = AuthService();

  MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'Todo App',
      debugShowCheckedModeBanner: false,
      themeMode: themeProvider.themeMode,
      theme: ThemeData(
        fontFamily: fontFamilyJosefin,
        scaffoldBackgroundColor: lightVeryLightGray,
        brightness: Brightness.light,
        colorScheme: const ColorScheme.light(
          primary: primaryBrightBlue,
          secondary: primaryBrightBlue,
          surface: lightVeryLightGrayishBlue,
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onSurface: lightVeryDarkGrayishBlue,
          onError: Colors.white,
          error: Colors.redAccent,
          brightness: Brightness.light,
        ),
        textTheme: TextTheme(
          bodyLarge: bodyTextStyle,
          bodyMedium: bodyTextStyle.copyWith(fontSize: 16.0),
          titleMedium: bodyTextStyleBold.copyWith(fontSize: 20.0),
          titleLarge: bodyTextStyleBold.copyWith(fontSize: 22.0),
          headlineSmall: bodyTextStyleBold.copyWith(fontSize: 24.0),
        ),
      ),
      darkTheme: ThemeData(
        fontFamily: fontFamilyJosefin,
        scaffoldBackgroundColor: darkVeryDarkBlue,
        brightness: Brightness.dark,
        colorScheme: const ColorScheme.dark(
          primary: primaryBrightBlue,
          secondary: primaryBrightBlue,
          surface: darkVeryDarkDesaturatedBlue,
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onSurface: darkLightGrayishBlue,
          onError: Colors.black,
          error: Colors.red,
          brightness: Brightness.dark,
        ),
        textTheme: TextTheme(
          bodyLarge: bodyTextStyle.copyWith(color: darkLightGrayishBlue),
          bodyMedium: bodyTextStyle.copyWith(fontSize: 16.0, color: darkLightGrayishBlue),
          titleMedium: bodyTextStyleBold.copyWith(fontSize: 20.0, color: darkLightGrayishBlue),
          titleLarge: bodyTextStyleBold.copyWith(fontSize: 22.0, color: darkLightGrayishBlue),
          headlineSmall: bodyTextStyleBold.copyWith(fontSize: 24.0, color: darkLightGrayishBlue),
        ),
      ),
      home: StreamBuilder<User?>(
        stream: _authService.authStateChanges,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
          if (snapshot.hasData && snapshot.data != null) {
            return const TodoScreen(title: 'TODO');
          } else {
            return const AuthScreen();
          }
        },
      ),
    );
  }
}
