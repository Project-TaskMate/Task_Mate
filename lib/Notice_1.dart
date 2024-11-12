import 'package:flutter/material.dart';

class NoticePage extends StatefulWidget {
  const NoticePage({super.key});

  @override
  _NoticePageState createState() => _NoticePageState();
}

class _NoticePageState extends State<NoticePage> {
  int _currentIndex = 3; // Notice 탭이 초기 활성화 상태
  int? _selectedIndex; // 현재 선택된 알림 항목의 인덱스를 저장

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            // 뒤로 가기 버튼 클릭 시 동작
            Navigator.pop(context);
          },
        ),
        title: Text(
          '알림',
          style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.w400),
        ),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 7, // 처음과 끝의 구분선 + 알림 항목 3개 + 중간 구분선 3개 = 총 7개
        itemBuilder: (context, index) {
          if (index == 0 || index == 6) {
            // 첫 번째와 마지막 구분선
            return Divider(
              color: Colors.grey[300],
              thickness: 1,
              height: 24,
            );
          } else if (index % 2 == 0) {
            // 각 항목 사이에 구분선 추가
            return Divider(
              color: Colors.grey[300],
              thickness: 1,
              height: 24,
            );
          } else {
            // 알림 항목 생성
            int itemIndex = (index - 1) ~/ 2;
            if (itemIndex == 0) {
              return _buildNotificationItem(context, itemIndex, "오늘은 수업 1개가 있어요", "17:00 고급모바일프로그래밍", "10 min");
            } else if (itemIndex == 1) {
              return _buildNotificationItem(context, itemIndex, "todo 알림", "todo mate로부터 온 알림입니다.", "15 min");
            } else {
              return _buildNotificationItem(context, itemIndex, "카카오톡", "고급모바일프로그래밍 프로젝트를 시작해보자!", "23 min");
            }
          }
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed, // 항상 모든 레이블 표시
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: 'To Do List'),
          BottomNavigationBarItem(icon: Icon(Icons.group), label: 'Group'),
          BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'Notice'),
        ],
        currentIndex: _currentIndex, // 현재 활성화된 탭 인덱스
        selectedItemColor: Color(0xFF792CA7),
        unselectedItemColor: Color(0xFF999999),
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          print("탭 $index 클릭됨");
        },
      ),
    );
  }

  Widget _buildNotificationItem(BuildContext context, int index, String title, String subtitle, String time) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = index; // 클릭 시 선택된 항목 인덱스를 업데이트
        });
      },
      child: Container(
        color: _selectedIndex == index ? Colors.grey[300] : Colors.transparent, // 선택된 항목만 배경색 변경
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            Text(
              time,
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
