import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
import 'package:todo_app/constants/colors.dart';
import 'package:todo_app/constants/text_styles.dart';
import 'package:todo_app/providers/theme_provider.dart';
import 'package:todo_app/providers/todo_service_provider.dart';
import 'package:todo_app/screens/todo_screen.dart';
import 'package:todo_app/services/auth_service.dart';

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
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ChangeNotifierProvider(create: (context) => TodoServiceProvider()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Future<void>? _initializationFuture;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _initializeApp(TodoServiceProvider todoProvider) async {
    final authService = AuthService();
    
    // Initialize storage based on current auth state
    final currentUser = authService.currentUser;
    if (currentUser != null) {
      await todoProvider.switchToCloud(currentUser.uid);
    } else {
      await todoProvider.initializeLocal();
    }
  }

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
      home: Consumer<TodoServiceProvider>(
        builder: (context, todoProvider, child) {
          // Only create the future once
          _initializationFuture ??= _initializeApp(todoProvider);
          
          return FutureBuilder<void>(
            future: _initializationFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }
              
              if (snapshot.hasError) {
                return Scaffold(
                  body: Center(child: Text('Error: ${snapshot.error}')),
                );
              }
              
              return const TodoScreen(title: 'TODO');
            },
          );
        },
      ),
    );
  }
}
