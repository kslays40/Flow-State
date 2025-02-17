import 'package:flow_state/screens/tasklist_screen.dart';
import 'package:flow_state/services/database_service.dart';
import 'package:flow_state/services/theme_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseService.init();
  await ThemeService.init(); // Initialize ThemeService for theme storage
  runApp(ProviderScope(child: MyApp()));
}

// Main App
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // Initially setting the theme mode based on the stored value.
  ThemeMode _themeMode = ThemeService.currentThemeMode;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Task Manager',
      themeMode: _themeMode, // Apply the current theme mode
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Quicksand',
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Quicksand',
        brightness: Brightness.dark,
      ),
      home: TaskListScreen(
        onThemeToggle: _toggleTheme, // Pass the theme toggle function
      ),
    );
  }

  // Toggle the theme and update Hive
  void _toggleTheme() async {
    await ThemeService.toggleTheme();
    setState(() {
      _themeMode = ThemeService.currentThemeMode; // Update the theme mode
    });
  }
}