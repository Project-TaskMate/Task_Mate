import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'Login_2.dart';
import 'Notice_1.dart'; // NoticePage를 import 함

class LoginPage extends StatelessWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TextEditingController _emailController = TextEditingController();
    final TextEditingController _passwordController = TextEditingController();
    final FirebaseAuth _auth = FirebaseAuth.instance;

    Future<void> _signIn() async {
      try {
        // Firebase Authentication을 통한 로그인 시도
        await _auth.signInWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );

        // 로그인 성공 시 NoticePage로 이동
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const NoticePage()),
        );
      } catch (e) {
        // 로그인 실패 시 오류 메시지 표시
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('오류'),
            content: Text('로그인에 실패했습니다. 이메일과 비밀번호를 확인하세요.'),
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

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'TaskMate',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Column(
                children: [
                  TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'ID',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _signIn, // 로그인 버튼 클릭 시 _signIn 함수 호출
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 100,
                        vertical: 15,
                      ),
                    ),
                    child: const Text('Sign in'),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        onPressed: () {
                          // 비밀번호 찾기 기능 추가 가능
                        },
                        child: const Text(
                          '비밀번호를 잊으셨나요?',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                      const SizedBox(width: 10),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SignUpPage(),
                            ),
                          );
                        },
                        child: const Text(
                          '회원가입을 하시겠어요?',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
