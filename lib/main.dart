import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:task_time_tracker/screens/home.dart';
import 'package:task_time_tracker/widgets/colors.dart';
import 'screens/auth.dart';
import 'firebase_options.dart';
import 'package:permission_handler/permission_handler.dart';

import 'screens/notification_helper_stub.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationHelper.initialize(); // Initialize notifications
  initializeDateFormatting();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    runApp(MyApp());
  } catch (e) {
    if (kDebugMode) {
      print('Firebase initialization failed with error: $e');
    }
  }
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _requestNotificationPermissions(), // Request permissions during app initialization
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }
        return MaterialApp(
          title: 'Task Time Tracker',
          debugShowCheckedModeBanner: false,
          theme: ThemeData.dark().copyWith(
            scaffoldBackgroundColor: secondaryColor,
            colorScheme: ColorScheme.fromSwatch().copyWith(
              primary: primaryColor,
              secondary: secondaryColor,
              background: background,
            ),
            textTheme: GoogleFonts.workSansTextTheme(Theme.of(context).textTheme),
          ),
          initialRoute: '/',
          routes: {
            '/': (context) => _auth.currentUser != null ? const HomePage() : const AuthPage(),
            '/login': (context) => const AuthPage(), // Make sure this matches your login page
            '/home': (context) => const HomePage(),
          },
        );
      },
    );
  }

  Future<void> _requestNotificationPermissions() async {
    if (!kIsWeb) {
      PermissionStatus status = await Permission.notification.request();
      if (status != PermissionStatus.granted) {
        // Handle the case where the user did not grant the permission
        print("Notification permission not granted");
      }
    }
  }
}
