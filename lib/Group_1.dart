import 'package:flutter/material.dart';

class GroupPage extends StatelessWidget {
  const GroupPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 상단 빈 공간 제거 또는 최소화
          Container(
            height: kToolbarHeight * 0.1, // AppBar 높이의 1.5배
            color: Colors.white,
          ),
          const Padding(
            padding: EdgeInsets.only(left: 16.0, bottom: 8.0), // 위쪽 여백 제거
            child: Text(
              '대화 목록',
              style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ListView(
              children: const [
                ChatItem(
                  groupName: '고모프 TaskMate',
                  message: '좋아요 6시반 부터 시작합시당^^',
                  time: '10 min',
                ),
                ChatItem(
                  groupName: '김○○, 박○○, 최○○',
                  message: '알겠습니다.',
                  time: '20 min',
                ),
                ChatItem(
                  groupName: '이○○, 강○○',
                  message: '다음주에 봐요',
                  time: '30 min',
                ),
                ChatItem(
                  groupName: '캡스톤',
                  message: '다음주에 만나요!!',
                  time: '35 min',
                ),
                ChatItem(
                  groupName: '웹프웤',
                  message: '과제 이번주 금요일까지 제출입니다',
                  time: '40 min',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ChatItem extends StatelessWidget {
  final String groupName;
  final String message;
  final String time;

  const ChatItem({
    Key? key,
    required this.groupName,
    required this.message,
    required this.time,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
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
