import 'package:flutter/material.dart';
import 'home_table.dart';
import 'Notice_1.dart';

class HomeScreen extends StatefulWidget {
  final String userName;

  const HomeScreen({super.key, required this.userName});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> timetableEntries = [];
  int _currentIndex = 0;

  void _addTimetableEntry(String className, String classroom, String dayOfWeek, TimeOfDay startTime, TimeOfDay endTime) {
    setState(() {
      timetableEntries.add({
        'className': className,
        'classroom': classroom,
        'dayOfWeek': dayOfWeek,
        'startTime': startTime,
        'endTime': endTime,
      });
    });
  }

  bool _isWithinTimeRange(String day, int hour, Map<String, dynamic> entry) {
    if (entry['dayOfWeek'] != day) return false;
    int startHour = entry['startTime'].hour;
    int endHour = entry['endTime'].hour;
    return hour >= startHour && hour < endHour;
  }

  bool _isStartTime(String day, int hour, Map<String, dynamic> entry) {
    return entry['dayOfWeek'] == day && entry['startTime'].hour == hour;
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
              : 'Notice',
          style: TextStyle(color: Colors.black),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.person, color: Colors.grey),
            onPressed: () {
              // 사용자 정보 수정 화면으로 이동
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

  // 각 탭에 따른 내용을 표시
  Widget _buildBody() {
    switch (_currentIndex) {
      case 0:
        return _buildHomeTab();
      case 1:
        return Center(child: Text('To Do List 화면입니다.'));
      case 2:
        return Center(child: Text('Group 화면입니다.'));
      case 3:
        return NoticePage(); // Notice 화면으로 변경
      default:
        return _buildHomeTab();
    }
  }

  // 홈 탭에서 시간표를 표시하는 위젯
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
                              child: Text(hour.toString(), style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ),
                          for (var i = 0; i < 5; i++)
                            Builder(
                              builder: (context) {
                                var day = ['월', '화', '수', '목', '금'][i];
                                var entry = timetableEntries.firstWhere(
                                      (entry) => _isStartTime(day, hour, entry),
                                  orElse: () => {},
                                );

                                if (entry.isNotEmpty) {
                                  return Container(
                                    height: 50.0,
                                    color: Colors.purple.withOpacity(0.2),
                                    child: Center(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            entry['className'],
                                            style: TextStyle(color: Colors.purple, fontWeight: FontWeight.bold),
                                          ),
                                          Text(
                                            entry['classroom'],
                                            style: TextStyle(color: Colors.purple),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                } else if (timetableEntries.any((entry) => _isWithinTimeRange(day, hour, entry))) {
                                  return Container(
                                    height: 50.0,
                                    color: Colors.purple.withOpacity(0.2),
                                  );
                                } else {
                                  return Container(
                                    height: 50.0,
                                    child: Center(child: Text("")),
                                  );
                                }
                              },
                            ),
                        ],
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
