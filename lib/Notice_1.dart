import 'package:flutter/material.dart';

class NoticePage extends StatefulWidget {
  const NoticePage({super.key});

  @override
  _NoticePageState createState() => _NoticePageState();
}

class _NoticePageState extends State<NoticePage> {
  int? _selectedIndex; // 현재 선택된 알림 항목의 인덱스를 저장

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //app bar 삭제
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
