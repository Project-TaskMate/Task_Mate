import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NoticePage extends StatefulWidget {
  const NoticePage({super.key});

  @override
  _NoticePageState createState() => _NoticePageState();
}

class _NoticePageState extends State<NoticePage> {
  Map<String, List<Map<String, dynamic>>> timetableNotifications = {}; // 시간표 알림 저장
  Map<String, int> timetableClassCounts = {}; // 요일별 수업 개수 저장
  List<Map<String, String>> todolistNotifications = []; // ToDoList 알림 저장
  Set<String> deletedNotificationIds = {}; // 삭제된 알림 ID 저장

  @override
  void initState() {
    super.initState();
    _loadNotifications(); // Firebase에서 알림 데이터를 로드
  }

  Future<void> _loadNotifications() async {
    final firestore = FirebaseFirestore.instance;
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      print("[ERROR] 사용자가 로그인되지 않았습니다.");
      return;
    }

    final userId = user.uid;

    // 삭제된 알림 ID 로드
    final deletedSnapshot = await firestore
        .collection('users')
        .doc(userId)
        .collection('deletedNotifications')
        .get();

    Set<String> deletedIds = deletedSnapshot.docs
        .map((doc) => doc.id)
        .toSet(); // 삭제된 알림 ID 저장

    // 시간표 알림 로드
    final timetableSnapshot = await firestore
        .collection('users')
        .doc(userId)
        .collection('timetable')
        .get();

    Map<String, int> timetableClassCountsTemp = {};
    Map<String, List<Map<String, dynamic>>> timetableNotificationsTemp = {};

    for (var doc in timetableSnapshot.docs) {
      if (deletedIds.contains(doc.id)) continue; // 삭제된 항목 필터링

      final data = doc.data();
      print("[INFO] Firebase 시간표 데이터: $data");

      final dayOfWeek = data['dayOfWeek'].toString();
      final className = data['className'].toString();
      final startTime = data['startTime'].toString();
      final docId = doc.id;

      // 요일별 수업 개수 증가
      timetableClassCountsTemp[dayOfWeek] =
          (timetableClassCountsTemp[dayOfWeek] ?? 0) + 1;

      // 요일별 알림 저장
      if (!timetableNotificationsTemp.containsKey(dayOfWeek)) {
        timetableNotificationsTemp[dayOfWeek] = [];
      }

      timetableNotificationsTemp[dayOfWeek]!.add({
        'id': docId,
        'className': className,
        'startTime': startTime,
      });
    }

    // ToDoList 알림 로드
    final todolistSnapshot = await firestore
        .collection('users')
        .doc(userId)
        .collection('todolist')
        .get();

    List<Map<String, String>> todolistNotificationsTemp = [];

    for (var doc in todolistSnapshot.docs) {
      if (deletedIds.contains(doc.id)) continue; // 삭제된 항목 필터링

      final data = doc.data();
      print("[INFO] Firebase ToDoList 데이터: $data");

      // 날짜 형식 변환 (yyyy-MM-dd -> MM/dd)
      final rawDate = data['date'] as Timestamp?; // Firebase의 Timestamp로 가져오기
      final date = rawDate != null
          ? "${rawDate.toDate().month}/${rawDate.toDate().day}"
          : "날짜 없음";

      todolistNotificationsTemp.add({
        'id': doc.id, // 삭제를 위해 문서 ID 추가
        'date': date,
        'title': data['title'] ?? "제목 없음",
        'time': data['time'] ?? "시간 없음",
      });
    }

    // 상태 업데이트
    setState(() {
      deletedNotificationIds = deletedIds;
      timetableClassCounts = timetableClassCountsTemp;
      timetableNotifications = timetableNotificationsTemp;
      todolistNotifications = todolistNotificationsTemp;
    });

    print("[INFO] 시간표 데이터 로드 완료: $timetableNotifications");
    print("[INFO] ToDoList 데이터 로드 완료: $todolistNotifications");
  }

  Future<void> _markAsDeleted(String id) async {
    final firestore = FirebaseFirestore.instance;
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      print("[ERROR] 사용자가 로그인되지 않았습니다.");
      return;
    }

    final userId = user.uid;

    // Firebase에 삭제된 항목 기록
    await firestore
        .collection('users')
        .doc(userId)
        .collection('deletedNotifications')
        .doc(id)
        .set({});
  }

  void _removeTimetableItem(String id, String dayOfWeek) {
    _markAsDeleted(id); // Firebase에 삭제 기록
    setState(() {
      timetableNotifications[dayOfWeek]?.removeWhere((cls) => cls['id'] == id);

      // 해당 요일에 수업이 없다면 요일 데이터 삭제
      if (timetableNotifications[dayOfWeek]?.isEmpty ?? true) {
        timetableNotifications.remove(dayOfWeek);
        timetableClassCounts.remove(dayOfWeek);
      }
    });

    print("[INFO] 시간표 목록에서 항목 삭제 완료: $id");
  }

  void _removeTodoItem(String id) {
    _markAsDeleted(id); // Firebase에 삭제 기록
    setState(() {
      todolistNotifications.removeWhere((item) => item['id'] == id);
    });

    print("[INFO] ToDoList 목록에서 항목 삭제 완료: $id");
  }

  String _formatTime(String time) {
    final parts = time.split(':');
    int hour = int.parse(parts[0]);
    String minute = parts[1].padLeft(2, '0'); // 분 앞에 0 채우기
    String period = hour >= 12 ? 'PM' : 'AM';
    hour = hour % 12 == 0 ? 12 : hour % 12;
    return "$hour:$minute $period";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 시간표 알림
          if (timetableNotifications.isNotEmpty)
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
                ...timetableNotifications.keys.map((dayOfWeek) {
                  final classes = timetableNotifications[dayOfWeek] ?? [];
                  final classCount = timetableClassCounts[dayOfWeek] ?? 0;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "$dayOfWeek요일: 수업 $classCount개가 있어요!",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...classes.map((cls) {
                        return Dismissible(
                          key: Key(cls['id']!), // 고유 키 설정
                          background: Container(
                            color: Colors.red,
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            child: const Icon(Icons.delete, color: Colors.white),
                          ),
                          direction: DismissDirection.endToStart,
                          onDismissed: (direction) {
                            _removeTimetableItem(cls['id']!, dayOfWeek);
                          },
                          child: ListTile(
                            title: Text(cls['className']!),
                            subtitle:
                            Text("$dayOfWeek - ${_formatTime(cls['startTime'])}"),
                          ),
                        );
                      }).toList(),
                      const Divider(
                        color: Colors.black38,
                        thickness: 1,
                        height: 24,
                      ),
                    ],
                  );
                }).toList(),
              ],
            ),
          // ToDoList 알림
          if (todolistNotifications.isNotEmpty)
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
                ...todolistNotifications.map((todo) {
                  return Dismissible(
                    key: Key(todo['id']!), // 고유 키 설정
                    background: Container(
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    direction: DismissDirection.endToStart,
                    onDismissed: (direction) {
                      _removeTodoItem(todo['id']!);
                    },
                    child: ListTile(
                      title: Text("${todo['date']} ${todo['title']}"),
                      subtitle: Text(todo['time']!),
                    ),
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
