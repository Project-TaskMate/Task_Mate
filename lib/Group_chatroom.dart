import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class GroupChatRoom extends StatefulWidget {
  final String chatRoomId;

  const GroupChatRoom({Key? key, required this.chatRoomId}) : super(key: key);

  @override
  _GroupChatRoomState createState() => _GroupChatRoomState();
}

class _GroupChatRoomState extends State<GroupChatRoom> {
  final TextEditingController messageController = TextEditingController();
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final String currentUserUid = FirebaseAuth.instance.currentUser!.uid;
  String chatRoomName = "채팅방 이름";
  String currentUserName = "";

  @override
  void initState() {
    super.initState();
    fetchChatRoomName();
    fetchCurrentUserName();
  }

  Future<void> fetchChatRoomName() async {
    var chatRoomSnapshot =
    await firestore.collection('chatrooms').doc(widget.chatRoomId).get();
    setState(() {
      chatRoomName = chatRoomSnapshot.data()?['name'] ?? "채팅방 이름";
    });
  }

  Future<void> fetchCurrentUserName() async {
    var userSnapshot =
    await firestore.collection('users').doc(currentUserUid).get();
    setState(() {
      currentUserName = userSnapshot.data()?['name'] ?? "사용자 이름";
    });
  }

  void sendMessage(String message) {
    if (message.trim().isEmpty) return;
    firestore
        .collection('chatrooms')
        .doc(widget.chatRoomId)
        .collection('messages')
        .add({
      'senderUid': currentUserUid,
      'senderName': currentUserName,
      'message': message,
      'createdAt': FieldValue.serverTimestamp(),
    });
    messageController.clear();
  }

  void updateChatRoomName(String newName) async {
    try {
      await firestore.collection('chatrooms').doc(widget.chatRoomId).update({
        'name': newName,
      });
      setState(() {
        chatRoomName = newName;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("채팅방 이름이 변경되었습니다.")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("채팅방 이름 변경 중 오류가 발생했습니다.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(chatRoomName),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  final TextEditingController nameController =
                  TextEditingController(text: chatRoomName);
                  return AlertDialog(
                    title: const Text("채팅방 이름 변경"),
                    content: TextField(
                      controller: nameController,
                      decoration:
                      const InputDecoration(hintText: "새 채팅방 이름을 입력하세요"),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text("취소"),
                      ),
                      TextButton(
                        onPressed: () {
                          updateChatRoomName(nameController.text.trim());
                          Navigator.pop(context);
                        },
                        child: const Text("확인"),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: firestore
                  .collection('chatrooms')
                  .doc(widget.chatRoomId)
                  .collection('messages')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                var messages = snapshot.data!.docs;
                return ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    var message = messages[index];
                    bool isCurrentUser = message['senderUid'] == currentUserUid;

                    return Align(
                      alignment: isCurrentUser
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                            vertical: 4.0, horizontal: 8.0),
                        padding: const EdgeInsets.all(12.0),
                        decoration: BoxDecoration(
                          color: isCurrentUser
                              ? Colors.blue[200]
                              : Colors.grey[300],
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (!isCurrentUser)
                              Text(
                                message['senderName'],
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                            Text(
                              message['message'],
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: messageController,
                    decoration:
                    const InputDecoration(hintText: "메시지를 입력하세요"),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () {
                    sendMessage(messageController.text);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
