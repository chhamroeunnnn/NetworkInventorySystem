import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:projectteam/Screen/department_page.dart';
import 'package:projectteam/Screen/user_page.dart';
import 'package:projectteam/login-page/Login.dart';
import 'package:projectteam/Screen/device_admin_page.dart';
import 'package:projectteam/Screen/network_inventory_page.dart';
import '../Screen/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginPage(),
        '/inventory': (context) => const NetworkInventoryPage(),
        '/add-device': (context) => const AddDevicePage(),
        '/departments': (context) => const DepartmentsPage(),
        '/users': (context) => const UsersPage(),
      },
    );
  }
}
