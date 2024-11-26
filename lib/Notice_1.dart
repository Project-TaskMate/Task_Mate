import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NoticePage extends StatefulWidget {
  const NoticePage({super.key});

  @override
  _NoticePageState createState() => _NoticePageState();
}

class _NoticePageState extends State<NoticePage> {
  List<Map<String, dynamic>> todayTimetableNotifications = [];
  List<Map<String, String>> todayTodolistNotifications = [];

  @override
  void initState() {
    super.initState();
    _loadTodayNotifications();
  }

  Future<void> _loadTodayNotifications() async {
    final firestore = FirebaseFirestore.instance;
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      print("[ERROR] 사용자가 로그인되지 않았습니다.");
      return;
    }

    final userId = user.uid;
    final now = DateTime.now();

    // 오늘 날짜 범위 설정
    final startOfDay = Timestamp.fromDate(DateTime(now.year, now.month, now.day));
    final endOfDay = Timestamp.fromDate(DateTime(now.year, now.month, now.day, 23, 59, 59));

    List<Map<String, dynamic>> timetableTemp = [];
    List<Map<String, String>> todolistTemp = [];

    // 시간표 알림 로드
    final timetableSnapshot = await firestore
        .collection('users')
        .doc(userId)
        .collection('timetable')
        .get();

    for (var doc in timetableSnapshot.docs) {
      final data = doc.data();
      final dayOfWeek = _getDayOfWeek(now.weekday);

      if (data['dayOfWeek'] == dayOfWeek) {
        timetableTemp.add({
          'id': doc.id,
          'className': data['className'],
          'startTime': data['startTime'],
        });
      }
    }

    // ToDoList 알림 로드
    final todolistSnapshot = await firestore
        .collection('users')
        .doc(userId)
        .collection('todolist')
        .where('date', isGreaterThanOrEqualTo: startOfDay)
        .where('date', isLessThanOrEqualTo: endOfDay)
        .get();

    for (var doc in todolistSnapshot.docs) {
      final data = doc.data();

      todolistTemp.add({
        'id': doc.id,
        'title': data['title'] ?? "제목 없음",
        'time': data['time'] ?? "시간 없음",
      });
    }

    // 상태 업데이트
    setState(() {
      todayTimetableNotifications = timetableTemp;
      todayTodolistNotifications = todolistTemp;
    });

    print("[INFO] 오늘 날짜 시간표 데이터 로드 완료: $todayTimetableNotifications");
    print("[INFO] 오늘 날짜 ToDoList 데이터 로드 완료: $todayTodolistNotifications");
  }

  String _getDayOfWeek(int weekday) {
    const daysOfWeek = ['월', '화', '수', '목', '금', '토', '일'];
    return daysOfWeek[weekday - 1];
  }

  String _formatTime(String time) {
    final parts = time.split(':');
    int hour = int.parse(parts[0]);
    String minute = parts[1].padLeft(2, '0'); // 분 앞에 0 채우기
    String period = hour >= 12 ? 'PM' : 'AM';
    hour = hour % 12 == 0 ? 12 : hour % 12;
    return "$hour:$minute $period";
  }

  String _formatDate(DateTime date) {
    const daysOfWeek = ['일', '월', '화', '수', '목', '금', '토'];
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    final dayOfWeek = daysOfWeek[date.weekday % 7];
    return '$month/$day ($dayOfWeek)';
  }

  @override
  Widget build(BuildContext context) {
    final currentDate = DateTime.now();
    final formattedDate = _formatDate(currentDate);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          formattedDate,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 시간표 알림
          if (todayTimetableNotifications.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "시간표 알림",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "수업 ${todayTimetableNotifications.length}개가 있어요!",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                ...todayTimetableNotifications.map((cls) {
                  return ListTile(
                    title: Text(cls['className']),
                    subtitle: Text(_formatTime(cls['startTime'])),
                  );
                }).toList(),
                const Divider(
                  color: Colors.black38,
                  thickness: 1,
                  height: 24,
                ),
              ],
            ),
          // ToDoList 알림
          if (todayTodolistNotifications.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "ToDoList 알림",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 8),
                ...todayTodolistNotifications.map((todo) {
                  return ListTile(
                    title: Text(todo['title'] ?? "제목 없음"),
                    subtitle: Text(todo['time'] ?? "시간 없음"),
                  );
                }).toList(),
                const Divider(
                  color: Colors.grey,
                  thickness: 1,
                  height: 24,
                ),
              ],
            ),
        ],
      ),
    );
  }
}
