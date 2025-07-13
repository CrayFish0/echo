import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'providers/diary_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase with error handling for duplicate app
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    if (e.toString().contains('duplicate-app')) {
      // Firebase is already initialized, which is fine
      print('Firebase already initialized');
    } else {
      // Re-throw other errors
      rethrow;
    }
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => DiaryProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Smart Diary',
            themeMode: themeProvider.themeMode,

            // Dark Theme (Default)
            darkTheme: ThemeData(
              useMaterial3: true,
              brightness: Brightness.dark,
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF007AFF), // Apple Blue
                brightness: Brightness.dark,
              ).copyWith(
                surface: const Color.fromARGB(
                    255, 17, 17, 17), // Pitch black background for dark mode
                onSurface: Colors.white,
                surfaceVariant: const Color(0xFF2C2C2E),
                onSurfaceVariant: const Color(0xFF8E8E93),
              ),

              // Card Theme
              cardTheme: CardTheme(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                color: const Color(0xFF2C2C2E),
              ),

              // AppBar Theme
              appBarTheme: const AppBarTheme(
                elevation: 0,
                backgroundColor: Colors.black, // Match pitch black background
                foregroundColor: Colors.white,
                scrolledUnderElevation: 0,
                titleTextStyle: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),

              // Elevated Button Theme
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: const Color(0xFF007AFF),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(0, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              // Text Button Theme
              textButtonTheme: TextButtonThemeData(
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF007AFF),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              // Input Decoration Theme
              inputDecorationTheme: InputDecorationTheme(
                filled: true,
                fillColor: const Color(0xFF3A3A3C),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFF007AFF),
                    width: 2,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                hintStyle: const TextStyle(
                  color: Color(0xFF8E8E93),
                ),
                labelStyle: const TextStyle(
                  color: Color(0xFF8E8E93),
                ),
              ),

              // FloatingActionButton Theme
              floatingActionButtonTheme: const FloatingActionButtonThemeData(
                elevation: 0,
                backgroundColor: Color(0xFF007AFF),
                foregroundColor: Colors.white,
              ),

              // List Tile Theme
              listTileTheme: const ListTileThemeData(
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              ),
            ),

            // Light Theme
            theme: ThemeData(
              useMaterial3: true,
              brightness: Brightness.light,
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF007AFF),
                brightness: Brightness.light,
              ).copyWith(
                surface: Colors.white,
                onSurface: Colors.black,
                surfaceVariant: const Color(0xFFF2F2F7),
                onSurfaceVariant: const Color(0xFF8E8E93),
              ),

              // Card Theme
              cardTheme: CardTheme(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                color: Colors.white,
                shadowColor: Colors.black.withOpacity(0.1),
              ),

              // AppBar Theme
              appBarTheme: const AppBarTheme(
                elevation: 0,
                backgroundColor: Color(0xFFF2F2F7),
                foregroundColor: Colors.black,
                scrolledUnderElevation: 0,
                titleTextStyle: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),

              // Elevated Button Theme
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: const Color(0xFF007AFF),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(0, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              // Text Button Theme
              textButtonTheme: TextButtonThemeData(
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF007AFF),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              // Input Decoration Theme
              inputDecorationTheme: InputDecorationTheme(
                filled: true,
                fillColor: const Color(0xFFF2F2F7),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFF007AFF),
                    width: 2,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                hintStyle: const TextStyle(
                  color: Color(0xFF8E8E93),
                ),
                labelStyle: const TextStyle(
                  color: Color(0xFF8E8E93),
                ),
              ),

              // FloatingActionButton Theme
              floatingActionButtonTheme: const FloatingActionButtonThemeData(
                elevation: 0,
                backgroundColor: Color(0xFF007AFF),
                foregroundColor: Colors.white,
              ),

              // List Tile Theme
              listTileTheme: const ListTileThemeData(
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              ),
            ),

            home: const AuthWrapper(),
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        if (authProvider.isAuthenticated) {
          return const HomeScreen();
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}
