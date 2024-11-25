import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'Group_chatroom.dart';

class GroupPage extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String currentUid = FirebaseAuth.instance.currentUser!.uid;

  GroupPage({Key? key}) : super(key: key);

  /// 현재 사용자 정보를 가져옵니다.
  Future<Map<String, String>> fetchCurrentUser() async {
    try {
      var userSnapshot =
      await _firestore.collection('users').doc(currentUid).get();
      return {
        'uid': currentUid,
        'name': userSnapshot.data()?['name'] ?? 'Unknown',
        'email': userSnapshot.data()?['email'] ?? 'Unknown',
      };
    } catch (e) {
      print("사용자 정보를 가져오는 중 오류 발생: $e");
      return {
        'uid': currentUid,
        'name': 'Unknown',
        'email': 'Unknown',
      };
    }
  }

  /// 친구 목록을 가져옵니다.
  Future<List<Map<String, dynamic>>> fetchFriends() async {
    try {
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
    } catch (e) {
      print("친구 목록을 가져오는 중 오류 발생: $e");
      return [];
    }
  }

  /// 새로운 채팅방을 생성합니다.
  void createChatRoom(BuildContext context, Map<String, String> currentUser,
      List<Map<String, dynamic>> selectedFriends) async {
    try {
      var chatRoomData = {
        'members': [
          currentUser,
          ...selectedFriends,
        ],
        'createdAt': FieldValue.serverTimestamp(),
      };

      var chatRoomRef =
      await _firestore.collection('chatrooms').add(chatRoomData);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => GroupChatRoom(chatRoomId: chatRoomRef.id),
        ),
      );
    } catch (e) {
      print("채팅방 생성 중 오류 발생: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("채팅방 생성 중 오류가 발생했습니다: $e")),
      );
    }
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
              style: TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
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
                    'email': currentUser['email'],
                  })
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      print("채팅방 목록 로드 오류: ${snapshot.error}");
                      return const Center(
                        child: Text('대화방 로드 중 오류가 발생했습니다.'),
                      );
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(child: Text('대화방이 없습니다.'));
                    }
                    var chatRooms = snapshot.data!.docs;
                    return ListView.builder(
                      itemCount: chatRooms.length,
                      itemBuilder: (context, index) {
                        var chatRoom = chatRooms[index].data();
                        return ChatItem(
                          groupName: chatRoom['members']
                              .map((member) => member['name'])
                              .join(', '),
                          message: '채팅 시작하기',
                          time: chatRoom['createdAt'] != null
                              ? (chatRoom['createdAt'] as Timestamp)
                              .toDate()
                              .toString()
                              : '시간 없음',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => GroupChatRoom(
                                  chatRoomId: chatRooms[index].id,
                                ),
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
                        children: friends.asMap().entries.map((entry) {
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
