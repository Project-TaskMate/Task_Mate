import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'Home_table.dart'; // AddTimetablePopup 임포트
import 'Home_user.dart'; // 사용자 정보 변경 위젯 임포트
import 'Home_friend.dart'; // 친구 추가 팝업 위젯 임포트
import 'Group_1.dart';
import 'ToDoList.dart';
import 'Notice_1.dart';
import 'Home_edit.dart';


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


  bool _isWithinTimeRange(String day, int hour, Map<String, dynamic> entry) {
    if (entry['dayOfWeek'] != day) return false;
    int startHour = entry['startTime'].hour;
    int endHour = entry['endTime'].hour;
    return hour >= startHour && hour < endHour;
  }

  Color _getDarkerShade(Color color) {
    int red = (color.red * 0.7).toInt();
    int green = (color.green * 0.7).toInt();
    int blue = (color.blue * 0.7).toInt();
    return Color.fromARGB(color.alpha, red, green, blue);
  }

  void _addTimetableEntry(String className, String classroom, String dayOfWeek,
      TimeOfDay startTime, TimeOfDay endTime, Color color) async {
    String uid = _auth.currentUser!.uid;

    try {
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
        'color': color.value.toRadixString(16),
      });

      setState(() {
        timetableEntries.add({
          'id': docRef.id,
          'className': className,
          'classroom': classroom,
          'dayOfWeek': dayOfWeek,
          'startTime': startTime,
          'endTime': endTime,
          'color': color,
        });
        subjectColors[className] = color;
      });
    } catch (e) {
      print('Failed to add entry: $e');
    }
  }


  void _updateTimetableEntry(String id, String className, String classroom,
      String dayOfWeek, TimeOfDay startTime, TimeOfDay endTime, Color color) async {
    String uid = _auth.currentUser!.uid;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('timetable')
        .doc(id)
        .update({
      'className': className,
      'classroom': classroom,
      'dayOfWeek': dayOfWeek,
      'startTime': '${startTime.hour}:${startTime.minute}',
      'endTime': '${endTime.hour}:${endTime.minute}',
      'color': color.value.toRadixString(16), // 색상 저장
    });

    setState(() {
      var index = timetableEntries.indexWhere((entry) => entry['id'] == id);
      if (index != -1) {
        timetableEntries[index] = {
          'id': id,
          'className': className,
          'classroom': classroom,
          'dayOfWeek': dayOfWeek,
          'startTime': startTime,
          'endTime': endTime,
          'color': color,
        };
      }
    });
  }

  void _deleteTimetableEntry(String id) async {
    String uid = _auth.currentUser!.uid;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('timetable')
        .doc(id)
        .delete();

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

    try {
      // Firebase 데이터 가져오기
      var snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('timetable')
          .get();

      List<Map<String, dynamic>> loadedEntries = snapshot.docs.map((doc) {
        var data = doc.data();

        // 색상 파싱
        Color color = Color(int.parse(data['color'], radix: 16));

        // 시간 파싱
        TimeOfDay startTime = TimeOfDay(
          hour: int.parse(data['startTime'].split(':')[0]),
          minute: int.parse(data['startTime'].split(':')[1]),
        );

        TimeOfDay endTime = TimeOfDay(
          hour: int.parse(data['endTime'].split(':')[0]),
          minute: int.parse(data['endTime'].split(':')[1]),
        );

        return {
          'id': doc.id,
          'className': data['className'],
          'classroom': data['classroom'],
          'dayOfWeek': data['dayOfWeek'],
          'startTime': startTime,
          'endTime': endTime,
          'color': color,
        };
      }).toList();

      setState(() {
        timetableEntries = loadedEntries;

        // 과목별 색상 저장
        for (var entry in loadedEntries) {
          if (!subjectColors.containsKey(entry['className'])) {
            subjectColors[entry['className']] = entry['color'];
          }
        }
      });
    } catch (e) {
      // 에러 처리
      print('Failed to load timetable: $e');
    }
  }

  void _showEditDeleteDialog(Map<String, dynamic> entry) {
    showDialog(
      context: context,
      builder: (context) => EditDeletePopup(
        entry: entry,
        onUpdate: (className, classroom, dayOfWeek, startTime, endTime, color) {
          _updateTimetableEntry(
              entry['id'], className, classroom, dayOfWeek, startTime, endTime, color);
        },
        onDelete: () {
          _deleteTimetableEntry(entry['id']);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          _currentIndex == 0
              ? 'Home'
              : _currentIndex == 1
              ? 'To Do List'
              : _currentIndex == 2
              ? 'Group'
              : 'Notice',
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
                            onAddEntry: (className, classroom, dayOfWeek,
                                startTime, endTime, color) {
                              _addTimetableEntry(
                                  className, classroom, dayOfWeek, startTime, endTime, color);
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
                                      _showEditDeleteDialog(entry);
                                    },
                                    child: Container(
                                      height: 45.0,
                                      color: entry['color'].withOpacity(0.2),
                                      child: Center(
                                        child: entry['startTime'].hour == hour
                                            ? Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              entry['className'],
                                              style: TextStyle(
                                                color: _getDarkerShade(entry['color']),
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Text(
                                              entry['classroom'],
                                              style: TextStyle(
                                                color: _getDarkerShade(entry['color']),
                                              ),
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    IconButton(
                      icon: Icon(Icons.person_add),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AddFriendPopup(),
                        );
                      },
                      tooltip: '친구 추가',
                    ),
                    Text(
                      '친구를 추가하세요!',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[400],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
