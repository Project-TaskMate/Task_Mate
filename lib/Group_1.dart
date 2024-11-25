import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'Group_chatroom.dart';

class GroupPage extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String currentUid = FirebaseAuth.instance.currentUser!.uid;

  GroupPage({Key? key}) : super(key: key);

  Future<Map<String, String>> fetchCurrentUser() async {
    var userSnapshot = await _firestore.collection('users').doc(currentUid).get();
    return {
      'uid': currentUid,
      'name': userSnapshot.data()?['name'] ?? 'Unknown',
      'email': userSnapshot.data()?['email'] ?? 'Unknown',
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 16.0, bottom: 8.0),
            child: Text(
              '대화 목록',
              style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: FutureBuilder<Map<String, String>>(
              future: fetchCurrentUser(),
              builder: (context, currentUserSnapshot) {
                if (!currentUserSnapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                var currentUser = currentUserSnapshot.data!;
                return StreamBuilder(
                  stream: _firestore
                      .collection('chatrooms')
                      .where('members', arrayContains: {
                    'uid': currentUser['uid'],
                    'name': currentUser['name'],
                    'email': currentUser['email']
                  })
                      .snapshots(),
                  builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(child: Text('대화방이 없습니다.'));
                    }

                    var chatRooms = snapshot.data!.docs;
                    return ListView.builder(
                      itemCount: chatRooms.length,
                      itemBuilder: (context, index) {
                        var chatRoom = chatRooms[index].data() as Map<String, dynamic>;

                        // `name` 또는 `createdAt`이 null인 경우 기본값 설정
                        String groupName = chatRoom['name'] ?? 'Unnamed Chatroom';
                        String createdAt = (chatRoom['createdAt'] as Timestamp?)
                            ?.toDate()
                            .toString() ??
                            'Unknown Time';

                        return ChatItem(
                          groupName: groupName,
                          message: '채팅 시작하기',
                          time: createdAt,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    GroupChatRoom(chatRoomId: chatRooms[index].id),
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          var currentUser = await fetchCurrentUser();
          var friends = await fetchFriends();
          showDialog(
            context: context,
            builder: (context) {
              List<bool> selected = List.filled(friends.length, false);
              return StatefulBuilder(
                builder: (context, setState) {
                  return AlertDialog(
                    title: const Text('친구 선택'),
                    content: SingleChildScrollView(
                      child: Column(
                        children: [
                          ...friends.asMap().entries.map((entry) {
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
                        ],
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          var selectedFriends = friends
                              .asMap()
                              .entries
                              .where((entry) => selected[entry.key])
                              .map((entry) => entry.value)
                              .toList();
                          createChatRoom(context, currentUser, selectedFriends);
                          Navigator.pop(context);
                        },
                        child: const Text('생성'),
                      ),
                    ],
                  );
                },
              );
            },
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<List<Map<String, dynamic>>> fetchFriends() async {
    var snapshot = await _firestore
        .collection('users')
        .doc(currentUid)
        .collection('friends')
        .get();

    return snapshot.docs.map((doc) {
      return {
        'uid': doc['uid'],
        'name': doc['name'],
        'email': doc['email'],
      };
    }).toList();
  }

  void createChatRoom(
      BuildContext context, Map<String, String> currentUser, List<Map<String, dynamic>> selectedFriends) async {
    var chatRoomData = {
      'members': [
        currentUser,
        ...selectedFriends
      ],
      'createdAt': FieldValue.serverTimestamp(),
    };

    var chatRoomRef = await _firestore.collection('chatrooms').add(chatRoomData);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GroupChatRoom(chatRoomId: chatRoomRef.id),
      ),
    );
  }
}

class ChatItem extends StatelessWidget {
  final String groupName;
  final String message;
  final String time;
  final VoidCallback onTap;

  const ChatItem({
    Key? key,
    required this.groupName,
    required this.message,
    required this.time,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        backgroundColor: Colors.grey[300],
        child: Icon(Icons.group, color: Colors.grey[600]),
      ),
      title: Text(
        groupName,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(message),
      trailing: Text(
        time,
        style: const TextStyle(color: Colors.grey, fontSize: 12),
      ),
    );
  }
}
