import 'package:flutter/material.dart';
// 올바른 import 방식으로 수정
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'config/routes.dart';
import 'providers/experiment_provider.dart';
import 'providers/workspace_provider.dart';
import 'screens/home/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => WorkspaceProvider()),
        ChangeNotifierProvider(create: (_) => ExperimentProvider()),
      ],
      child: MaterialApp(
        title: 'BDA Studio',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          scaffoldBackgroundColor: Colors.white,
          // Google Fonts 사용
          textTheme: GoogleFonts.robotoTextTheme(Theme.of(context).textTheme),
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.white,
            elevation: 0,
            iconTheme: IconThemeData(color: Colors.black),
            titleTextStyle: TextStyle(
              color: Colors.black,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.blue, width: 2),
            ),
            filled: true,
            fillColor: Colors.grey[200],
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.blue,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          outlinedButtonTheme: OutlinedButtonThemeData(
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.blue,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        initialRoute: AppRoutes.home,
        onGenerateRoute: AppRoutes.onGenerateRoute,
        home: const HomeScreen(),
      ),
    );
  }
}
