import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'Login_1.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _signUp() async {
    try {
      // 입력된 데이터 출력 (디버깅용)
      print('Email: ${_emailController.text}');
      print('Password: ${_passwordController.text}');
      print('Name: ${_nameController.text}');

      // Firebase Authentication으로 사용자 생성
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      // Firestore에 사용자 정보 저장
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'email': _emailController.text,
        'name': _nameController.text,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // 회원가입 완료 알림창
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('회원가입 성공'),
          content: const Text('회원가입이 완료되었습니다.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // 알림창 닫기
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
              },
              child: const Text('확인'),
            ),
          ],
        ),
      );
    } catch (e) {
      // 오류 발생 시 알림창 표시
      String errorMessage;
      if (e is FirebaseAuthException && e.code == 'email-already-in-use') {
        errorMessage = '이미 사용 중인 이메일 주소입니다. 다른 이메일을 사용하세요.';
      } else {
        errorMessage = e.toString();
      }

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('오류'),
          content: Text(errorMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('확인'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('회원가입', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('이메일*', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                hintText: '예) abc@gmail.com',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            const Text('비밀번호*', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                hintText: '영문, 숫자 조합 8~16자',
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.visibility_off),
              ),
            ),
            const SizedBox(height: 16),
            const Text('이름*', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                hintText: '예) 홍길동',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 32),
            Center(
              child: ElevatedButton(
                onPressed: _signUp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple[100],
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                ),
                child: const Text(
                  '저장',
                  style: TextStyle(color: Colors.purple, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
