import 'package:flutter/material.dart';
import 'WeeklySchedule.dart'; // 주간 일정 위젯을 import

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: CalendarScreen(),
    );
  }
}

class CalendarScreen extends StatefulWidget {
  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _currentDate = DateTime(2024, 10); // 초기 날짜를 2024년 10월로 설정

  // 달을 한 달 앞 또는 뒤로 이동
  void _changeMonth(int increment) {
    setState(() {
      _currentDate = DateTime(_currentDate.year, _currentDate.month + increment);
    });
  }

  void _openWeeklySchedule(DateTime selectedDate) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WeeklySchedule(initialDate: selectedDate),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${_currentDate.year}.${_currentDate.month.toString().padLeft(2, '0')}',
          style: TextStyle(fontSize: 24, color: Colors.black),
        ),
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [
          // 요일 표시
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: ['SUN', 'MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT']
                  .map(
                    (day) => Text(
                  day,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: day == 'SUN' ? Colors.red : Colors.purple,
                  ),
                ),
              )
                  .toList(),
            ),
          ),
          // 달력 그리드
          Expanded(
            child: Stack(
              children: [
                GridView.builder(
                  padding: EdgeInsets.only(bottom: 100), // 화살표와 겹치지 않도록 여백 추가
                  itemCount: _daysInMonth(_currentDate) +
                      _firstWeekdayOffset(_currentDate),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 7,
                    childAspectRatio: 0.8,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                  ),
                  itemBuilder: (context, index) {
                    final day = index >= _firstWeekdayOffset(_currentDate)
                        ? index - _firstWeekdayOffset(_currentDate) + 1
                        : null;
                    return GestureDetector(
                      onTap: day != null
                          ? () => _openWeeklySchedule(
                          DateTime(_currentDate.year, _currentDate.month, day))
                          : null,
                      child: Container(
                        decoration: BoxDecoration(
                          color: day != null ? Colors.white : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: day != null
                              ? [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              spreadRadius: 1,
                              blurRadius: 5,
                              offset: Offset(0, 3),
                            ),
                          ]
                              : [],
                        ),
                        child: Center(
                          child: day != null
                              ? Text(
                            '$day',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.purple,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                              : null,
                        ),
                      ),
                    );
                  },
                ),
                // 화살표를 중앙에 더 가깝게 배치
                Positioned(
                  bottom: 150, // 화살표를 중앙에 더 가깝게 위치
                  left: 16,
                  right: 16,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        iconSize: 48, // 화살표 크기 증가
                        icon: Icon(Icons.arrow_left, color: Colors.grey),
                        onPressed: () {
                          _changeMonth(-1);
                        },
                      ),
                      IconButton(
                        iconSize: 48, // 화살표 크기 증가
                        icon: Icon(Icons.arrow_right, color: Colors.grey),
                        onPressed: () {
                          _changeMonth(1);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  int _daysInMonth(DateTime date) {
    final firstDayOfNextMonth = (date.month < 12)
        ? DateTime(date.year, date.month + 1, 1)
        : DateTime(date.year + 1, 1, 1);
    return firstDayOfNextMonth.subtract(Duration(days: 1)).day;
  }

  int _firstWeekdayOffset(DateTime date) {
    return DateTime(date.year, date.month, 1).weekday % 7;
  }
}


