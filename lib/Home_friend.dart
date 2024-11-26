import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddFriendPopup extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  AddFriendPopup({super.key});

  Future<void> _addFriend(String email, BuildContext parentContext) async {
    if (email.isEmpty) {
      ScaffoldMessenger.of(parentContext).showSnackBar(
        SnackBar(content: Text("이메일을 입력하세요.")),
      );
      return;
    }

    try {
      // Firestore에서 해당 이메일의 사용자 찾기
      var userSnapshot = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .get();

      if (userSnapshot.docs.isEmpty) {
        ScaffoldMessenger.of(parentContext).showSnackBar(
          SnackBar(content: Text("해당 이메일의 사용자를 찾을 수 없습니다.")),
        );
        return;
      }

      String friendUid = userSnapshot.docs.first.id;
      String friendName = userSnapshot.docs.first.data()['name'];
      String currentUid = _auth.currentUser!.uid;

      if (friendUid == currentUid) {
        ScaffoldMessenger.of(parentContext).showSnackBar(
          SnackBar(content: Text("자신을 친구로 추가할 수 없습니다.")),
        );
        return;
      }

      var existingFriend = await _firestore
          .collection('users')
          .doc(currentUid)
          .collection('friends')
          .where('uid', isEqualTo: friendUid)
          .get();

      if (existingFriend.docs.isNotEmpty) {
        ScaffoldMessenger.of(parentContext).showSnackBar(
          SnackBar(content: Text("이미 친구로 추가된 사용자입니다.")),
        );
        return;
      }

      // 현재 사용자 정보 가져오기
      var currentUserSnapshot = await _firestore.collection('users').doc(currentUid).get();
      String currentUserName = currentUserSnapshot.data()!['name'];
      String currentUserEmail = currentUserSnapshot.data()!['email'];

      // 현재 사용자 -> 친구
      await _firestore
          .collection('users')
          .doc(currentUid)
          .collection('friends')
          .add({
        'uid': friendUid,
        'email': email,
        'name': friendName, // 친구의 이름 저장
        'addedAt': FieldValue.serverTimestamp(),
      });

      // 친구 -> 현재 사용자
      await _firestore
          .collection('users')
          .doc(friendUid)
          .collection('friends')
          .add({
        'uid': currentUid,
        'email': currentUserEmail,
        'name': currentUserName, // 현재 사용자의 이름 저장
        'addedAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(parentContext).showSnackBar(
        SnackBar(content: Text("친구가 추가되었습니다!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(parentContext).showSnackBar(
        SnackBar(content: Text("친구 추가 중 오류가 발생했습니다.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    String email = '';
    return AlertDialog(
      title: Text("친구 추가"),
      content: TextField(
        onChanged: (value) {
          email = value;
        },
        decoration: InputDecoration(
          hintText: "친구의 이메일을 입력하세요",
          border: OutlineInputBorder(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text("취소"),
        ),
        ElevatedButton(
          onPressed: () async {
            await _addFriend(email, context);
            Navigator.pop(context);
          },
          child: Text("추가"),
        ),
      ],
    );
  }
}
