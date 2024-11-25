import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math'; // Random 사용
import 'Home_table.dart'; // AddTimetablePopup 임포트
import 'Home_user.dart'; // 사용자 정보 변경 위젯 임포트
import 'Home_friend.dart'; // 친구 추가 팝업 위젯 임포트
import 'Group_1.dart';
import 'ToDoList.dart';
import 'Notice_1.dart';

class HomeScreen extends StatefulWidget {
  String userName;

  HomeScreen({super.key, required this.userName});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<Map<String, dynamic>> timetableEntries = [];
  Map<String, Color> subjectColors = {}; // 과목별 색상 저장
  int _currentIndex = 0;
  String searchText = '';

  Color _generateRandomColor() {
    Random random = Random();
    return Color.fromRGBO(
      random.nextInt(256),
      random.nextInt(256),
      random.nextInt(256),
      1,
    );
  }

  void _addTimetableEntry(String className, String classroom, String dayOfWeek,
      TimeOfDay startTime, TimeOfDay endTime) async {
    String uid = _auth.currentUser!.uid;
    var docRef = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('timetable')
        .add({
      'className': className,
      'classroom': classroom,
      'dayOfWeek': dayOfWeek,
      'startTime': '${startTime.hour}:${startTime.minute}',
      'endTime': '${endTime.hour}:${endTime.minute}',
    });

    // 과목별 색상 추가
    if (!subjectColors.containsKey(className)) {
      subjectColors[className] = _generateRandomColor();
    }

    // 로컬 데이터 업데이트
    setState(() {
      timetableEntries.add({
        'id': docRef.id,
        'className': className,
        'classroom': classroom,
        'dayOfWeek': dayOfWeek,
        'startTime': startTime,
        'endTime': endTime,
      });
    });
  }

  void _deleteTimetableEntry(String id) async {
    String uid = _auth.currentUser!.uid;

    // Firebase에서 삭제
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('timetable')
        .doc(id)
        .delete();

    // 로컬 데이터 업데이트
    setState(() {
      timetableEntries.removeWhere((entry) => entry['id'] == id);
    });
  }

  @override
  void initState() {
    super.initState();
    _loadTimetableFromFirebase();
  }

  Future<void> _loadTimetableFromFirebase() async {
    String uid = _auth.currentUser!.uid;
    var snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('timetable')
        .get();

    setState(() {
      timetableEntries = snapshot.docs.map((doc) {
        var data = doc.data();

        // 과목별 색상 추가
        String className = data['className'];
        if (!subjectColors.containsKey(className)) {
          subjectColors[className] = _generateRandomColor();
        }

        return {
          'id': doc.id,
          'className': className,
          'classroom': data['classroom'],
          'dayOfWeek': data['dayOfWeek'],
          'startTime': TimeOfDay(
            hour: int.parse(data['startTime'].split(':')[0]),
            minute: int.parse(data['startTime'].split(':')[1]),
          ),
          'endTime': TimeOfDay(
            hour: int.parse(data['endTime'].split(':')[0]),
            minute: int.parse(data['endTime'].split(':')[1]),
          ),
        };
      }).toList();
    });
  }

  bool _isWithinTimeRange(String day, int hour, Map<String, dynamic> entry) {
    if (entry['dayOfWeek'] != day) return false;
    int startHour = entry['startTime'].hour;
    int endHour = entry['endTime'].hour;
    return hour >= startHour && hour < endHour;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          _currentIndex == 0
              ? '홈'
              : _currentIndex == 1
              ? 'To Do List'
              : _currentIndex == 2
              ? 'Group'
              : '알람',
          style: TextStyle(color: Colors.black),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.person, color: Colors.grey),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => EditNamePopup(
                  currentName: widget.userName,
                  onNameUpdated: (newName) {
                    setState(() {
                      widget.userName = newName;
                    });
                  },
                ),
              );
            },
          ),
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        selectedItemColor: Color(0xFF792CA7),
        unselectedItemColor: Color(0xFF999999),
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: 'To Do List'),
          BottomNavigationBarItem(icon: Icon(Icons.group), label: 'Group'),
          BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'Notice'),
        ],
      ),
    );
  }

  Widget _buildBody() {
    switch (_currentIndex) {
      case 0:
        return _buildHomeTab();
      case 1:
        return CalendarScreen();
      case 2:
        return GroupPage();
      case 3:
        return NoticePage();
      default:
        return _buildHomeTab();
    }
  }

  Widget _buildHomeTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '안녕하세요, ${widget.userName}님!',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            '2024년 2학기 시간표',
            style: TextStyle(color: Colors.red, fontSize: 16),
          ),
          SizedBox(height: 16),
          Expanded(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: Icon(Icons.add, color: Colors.purple),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AddTimetablePopup(
                            onAddEntry: (className, classroom, dayOfWeek, startTime, endTime) {
                              _addTimetableEntry(className, classroom, dayOfWeek, startTime, endTime);
                            },
                          ),
                        );
                      },
                    ),
                  ],
                ),
                Table(
                  border: TableBorder.all(color: Colors.grey),
                  columnWidths: const {
                    0: FixedColumnWidth(40),
                  },
                  children: [
                    TableRow(
                      children: [
                        Container(),
                        Center(child: Text('월', style: TextStyle(fontWeight: FontWeight.bold))),
                        Center(child: Text('화', style: TextStyle(fontWeight: FontWeight.bold))),
                        Center(child: Text('수', style: TextStyle(fontWeight: FontWeight.bold))),
                        Center(child: Text('목', style: TextStyle(fontWeight: FontWeight.bold))),
                        Center(child: Text('금', style: TextStyle(fontWeight: FontWeight.bold))),
                      ],
                    ),
                    for (var hour in [9, 10, 11, 12, 13, 14, 15, 16, 17, 18])
                      TableRow(
                        children: [
                          Center(
                            child: Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text(hour.toString(),
                                  style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ),
                          for (var i = 0; i < 5; i++)
                            Builder(
                              builder: (context) {
                                var day = ['월', '화', '수', '목', '금'][i];
                                var entry = timetableEntries.firstWhere(
                                      (entry) => _isWithinTimeRange(day, hour, entry),
                                  orElse: () => {},
                                );

                                if (entry.isNotEmpty) {
                                  return GestureDetector(
                                    onTap: () {
                                      _showDeleteDialog(entry);
                                    },
                                    child: Container(
                                      height: 45.0,
                                      color: subjectColors[entry['className']]!.withOpacity(0.2),
                                      child: Center(
                                        child: entry['startTime'].hour == hour
                                            ? Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              entry['className'],
                                              style: TextStyle(
                                                  color: subjectColors[entry['className']],
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            Text(
                                              entry['classroom'],
                                              style: TextStyle(
                                                  color: subjectColors[entry['className']]),
                                            ),
                                          ],
                                        )
                                            : null,
                                      ),
                                    ),
                                  );
                                } else {
                                  return Container(
                                    height: 45.0,
                                    child: Center(child: Text("")),
                                  );
                                }
                              },
                            ),
                        ],
                      ),
                  ],
                ),
                SizedBox(height: 16),
                TextField(
                  onChanged: (value) {
                    setState(() {
                      searchText = value;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: '검색어를 입력하세요',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.search),
                    suffixIcon: IconButton(
                      icon: Icon(Icons.person_add),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AddFriendPopup(),
                        );
                      },
                      tooltip: '친구 추가',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(Map<String, dynamic> entry) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('삭제 확인'),
        content: Text('정말로 "${entry['className']}" 과목을 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('취소'),
          ),
          TextButton(
            onPressed: () {
              _deleteTimetableEntry(entry['id']);
              Navigator.pop(context);
            },
            child: Text('삭제'),
          ),
        ],
      ),
    );
  }
}
