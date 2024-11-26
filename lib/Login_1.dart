import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'Login_2.dart';
import 'Notice_1.dart';
import 'Home.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TextEditingController _emailController = TextEditingController();
    final TextEditingController _passwordController = TextEditingController();
    final FirebaseAuth _auth = FirebaseAuth.instance;
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;

    Future<void> _resetPassword() async {
      showDialog(
        context: context,
        builder: (context) {
          final TextEditingController _emailResetController = TextEditingController();
          final TextEditingController _currentPasswordController = TextEditingController();
          final TextEditingController _newPasswordController = TextEditingController();
          final TextEditingController _confirmPasswordController = TextEditingController();

          return AlertDialog(
            title: const Text('새 암호 설정'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    '현재 비밀번호를 확인하고 새 암호를 설정하세요.',
                    style: TextStyle(fontSize: 12),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _emailResetController,
                    decoration: const InputDecoration(
                      labelText: '이메일*',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _currentPasswordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: '현재 비밀번호*',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _newPasswordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: '새 암호*',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _confirmPasswordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: '새 암호 확인*',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('돌아가기'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (_emailResetController.text.isEmpty ||
                      _currentPasswordController.text.isEmpty ||
                      _newPasswordController.text.isEmpty ||
                      _newPasswordController.text != _confirmPasswordController.text) {
                    // 필수 입력 값이 비어 있거나 새 비밀번호가 일치하지 않을 경우
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('오류'),
                        content: const Text('모든 필드를 올바르게 입력하세요.'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('확인'),
                          ),
                        ],
                      ),
                    );
                    return;
                  }

                  try {
                    // 현재 사용자 가져오기
                    User? currentUser = _auth.currentUser;
                    if (currentUser == null) {
                      throw FirebaseAuthException(
                        code: 'user-not-logged-in',
                        message: '현재 사용자가 로그인되어 있지 않습니다.',
                      );
                    }

                    // 이메일과 비밀번호를 사용해 재인증 시도
                    AuthCredential credential = EmailAuthProvider.credential(
                      email: _emailResetController.text,
                      password: _currentPasswordController.text,
                    );

                    await currentUser.reauthenticateWithCredential(credential);

                    // 비밀번호 업데이트
                    await currentUser.updatePassword(_newPasswordController.text);

                    // 성공 메시지와 함께 입력 필드 초기화
                    _emailResetController.clear();
                    _currentPasswordController.clear();
                    _newPasswordController.clear();
                    _confirmPasswordController.clear();

                    // 성공 메시지
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero,
                        ),
                        title: const Text('완료'),
                        content: const Text('비밀번호가 성공적으로 변경되었습니다.'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop(); // 성공 메시지 닫기
                            },
                            child: const Text('확인'),
                          ),
                        ],
                      ),
                    );
                  } catch (e) {
                    // 오류 메시지 항상 동일하게 처리
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('오류'),
                        content: const Text('잘못된 인증 정보입니다.'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('확인'),
                          ),
                        ],
                      ),
                    );
                  }
                },
                child: const Text('내 새 암호 저장'),
              ),
            ],
          );
        },
      );
    }








    Future<void> _signIn() async {
      try {
        UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );

        String uid = userCredential.user!.uid;
        DocumentSnapshot userDoc = await _firestore.collection('users').doc(uid).get();
        String userName = userDoc['name'];

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomeScreen(userName: userName),
          ),
        );
      } catch (e) {
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
                    onPressed: _signIn,
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
                        onPressed: _resetPassword,
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
