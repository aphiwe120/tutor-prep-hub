import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/dashboard_screen.dart';
import 'screens/login_screen.dart';

void main() async {
  // Ensure Flutter is ready before setting up cloud connections
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase (You will paste your actual keys here!)
  await Supabase.initialize(
    url: 'https://dbzewswvnumgpukcmeuu.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImRiemV3c3d2bnVtZ3B1a2NtZXV1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODAzMDQ4MjUsImV4cCI6MjA5NTg4MDgyNX0.sZg1fx_3CsG-voVFT1IjLih7CLLktNqqRC4JLo70YmA',
  );

  runApp(const TutorPrepApp());
}

class TutorPrepApp extends StatelessWidget {
  const TutorPrepApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tutor Prep Hub',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: Supabase.instance.client.auth.currentUser == null
          ? const LoginScreen()
          : const DashboardScreen(),
    );
  }
}