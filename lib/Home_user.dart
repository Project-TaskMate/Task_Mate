import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EditNamePopup extends StatefulWidget {
  final String currentName;
  final Function(String) onNameUpdated;

  const EditNamePopup({Key? key, required this.currentName, required this.onNameUpdated})
      : super(key: key);

  @override
  _EditNamePopupState createState() => _EditNamePopupState();
}

class _EditNamePopupState extends State<EditNamePopup> {
  final TextEditingController _nameController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.currentName;
  }

  Future<void> _updateName() async {
    String newName = _nameController.text.trim();
    if (newName.isNotEmpty) {
      try {
        String uid = _auth.currentUser!.uid;
        await _firestore.collection('users').doc(uid).update({'name': newName});
        widget.onNameUpdated(newName);
        Navigator.pop(context);
      } catch (e) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('오류'),
            content: Text('이름 업데이트에 실패했습니다.'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: Text('확인')),
            ],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('이름 변경'),
      content: TextField(
        controller: _nameController,
        decoration: InputDecoration(
          labelText: '새 이름',
          border: OutlineInputBorder(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('취소'),
        ),
        ElevatedButton(
          onPressed: _updateName,
          child: Text('저장'),
        ),
      ],
    );
  }
}
