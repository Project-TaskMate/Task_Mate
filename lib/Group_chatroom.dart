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
    if (message
        .trim()
        .isEmpty) return;
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

  void addFriendToChatRoom(BuildContext context) async {
    var currentUserSnapshot =
    await firestore.collection('users').doc(currentUserUid).get();
    var currentUserName = currentUserSnapshot.data()?['name'] ?? "Unknown";
    var friendsSnapshot = await firestore
        .collection('users')
        .doc(currentUserUid)
        .collection('friends')
        .get();

    List<Map<String, dynamic>> friends = friendsSnapshot.docs
        .map((doc) =>
    {
      'uid': doc['uid'],
      'name': doc['name'],
      'email': doc['email'],
    })
        .toList();

    showDialog(
      context: context,
      builder: (context) {
        List<bool> selected = List.filled(friends.length, false);
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("친구 추가"),
              content: SingleChildScrollView(
                child: Column(
                  children: friends
                      .asMap()
                      .entries
                      .map((entry) {
                    int index = entry.key;
                    var friend = entry.value;
                    return CheckboxListTile(
                      title: Text(friend['name']),
                      value: selected[index],
                      onChanged: (value) {
                        setState(() {
                          selected[index] = value!;
                        });
                      },
                    );
                  }).toList(),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("취소"),
                ),
                TextButton(
                  onPressed: () async {
                    var selectedFriends = friends
                        .asMap()
                        .entries
                        .where((entry) => selected[entry.key])
                        .map((entry) => entry.value)
                        .toList();

                    // 채팅방 멤버 업데이트
                    var chatRoomRef =
                    firestore.collection('chatrooms').doc(widget.chatRoomId);
                    await chatRoomRef.update({
                      'members': FieldValue.arrayUnion(selectedFriends),
                    });

                    // 채팅 대화창에 알림 메시지 추가
                    for (var friend in selectedFriends) {
                      sendMessage("${friend['name']} 님을 채팅방에 초대했습니다.");
                    }

                    Navigator.pop(context);
                  },
                  child: const Text("확인"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(chatRoomName, style: const TextStyle(fontSize: 18.0)),
            FutureBuilder<DocumentSnapshot>(
              future: firestore.collection('chatrooms')
                  .doc(widget.chatRoomId)
                  .get(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Text(
                    "로딩 중...",
                    style: TextStyle(fontSize: 12.0, color: Colors.grey[600]),
                  );
                }

                var chatRoomData = snapshot.data!.data() as Map<String,
                    dynamic>;
                var members = chatRoomData['members'] as List<dynamic>;

                // 중복 제거 및 표시
                var uniqueNames = members.map((member) => member['name'])
                    .toSet()
                    .toList();

                return Text(
                  "${uniqueNames.length}명 | ${uniqueNames.join(', ')}",
                  style: const TextStyle(fontSize: 14.0, color: Colors.black),
                  overflow: TextOverflow.ellipsis,
                );
              },
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.group_add), // 친구 초대 아이콘
            onPressed: () {
              addFriendToChatRoom(context);
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout), // 나가기 아이콘
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Text("채팅방 나가기"),
                    content: Text("‘$chatRoomName’ 채팅방을 나가시겠습니까?"),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context); // 팝업 닫기
                        },
                        child: const Text("취소"),
                      ),
                      TextButton(
                        onPressed: () async {
                          Navigator.pop(context); // 팝업 닫기
                          await leaveChatRoom(context); // 나가기 함수 호출
                        },
                        child: const Text("확인"),
                      ),
                    ],
                  );
                },
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings), // 설정 아이콘
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
                      decoration: const InputDecoration(
                          hintText: "새 채팅방 이름을 입력하세요"),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text("취소"),
                      ),
                      TextButton(
                        onPressed: () async {
                          await firestore
                              .collection('chatrooms')
                              .doc(widget.chatRoomId)
                              .update({'name': nameController.text.trim()});
                          setState(() {
                            chatRoomName = nameController.text.trim();
                          });
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
                              ? Colors.purple[100]
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

  Future<void> leaveChatRoom(BuildContext context) async {
    try {
      // 채팅방에서 현재 유저 제거
      var chatRoomRef = firestore.collection('chatrooms').doc(widget.chatRoomId);
      var chatRoomSnapshot = await chatRoomRef.get();
      var chatRoomData = chatRoomSnapshot.data() as Map<String, dynamic>;
      var updatedMembers = (chatRoomData['members'] as List<dynamic>)
          .where((member) => member['uid'] != currentUserUid)
          .toList();

      // 업데이트된 멤버 리스트로 Firestore 업데이트
      await chatRoomRef.update({'members': updatedMembers});

      // 알림 메시지 추가
      sendMessage("$currentUserName 님이 채팅방에서 나갔습니다.");

      // 사용자 채팅방 목록에서 제거
      Navigator.pop(context); // 채팅방 화면 종료
    } catch (e) {
      print("Error leaving chatroom: $e");
    }
  }
}