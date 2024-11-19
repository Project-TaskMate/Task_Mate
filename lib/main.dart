import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'Login_1.dart';
import 'Login_2.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Firebase 초기화
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TaskMate App',
      theme: ThemeData(
        primarySwatch: Colors.purple,
      ),
      home: const LoginPage(), // LoginPage를 초기 화면으로 설정
    );
  }
}
