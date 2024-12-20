import 'package:flutter/material.dart';

class AddTimetablePopup extends StatefulWidget {
  final Function(String, String, String, TimeOfDay, TimeOfDay, Color) onAddEntry;

  const AddTimetablePopup({super.key, required this.onAddEntry});

  @override
  _AddTimetablePopupState createState() => _AddTimetablePopupState();
}

class _AddTimetablePopupState extends State<AddTimetablePopup> {
  String className = '';
  String classroom = '';
  String dayOfWeek = '월';
  TimeOfDay? startTime;
  TimeOfDay? endTime;
  Color selectedColor = Colors.pink[300]!; // 기본 색상

  // 사용자 정의 파스텔톤 색상 목록
  final List<Color> availableColors = [
    Colors.pink[300]!,     // 분홍
    Colors.orange[300]!,   // 주황
    Colors.lightGreen[300]!,// 연두
    Colors.lightBlue[300]!,// 하늘
    Colors.purple[300]!,   // 보라
  ];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('시간표 추가'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              onChanged: (value) => className = value,
              decoration: InputDecoration(labelText: '수업명'),
            ),
            TextField(
              onChanged: (value) => classroom = value,
              decoration: InputDecoration(labelText: '교실'),
            ),
            DropdownButtonFormField<String>(
              value: dayOfWeek,
              items: ['월', '화', '수', '목', '금'].map((String day) {
                return DropdownMenuItem<String>(
                  value: day,
                  child: Text(day),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  dayOfWeek = value!;
                });
              },
              decoration: InputDecoration(labelText: '요일'),
            ),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () async {
                      startTime = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      setState(() {});
                    },
                    child: Text(
                      startTime == null ? '시작 시간 선택' : '시작: ${startTime!.format(context)}',
                    ),
                  ),
                ),
                Expanded(
                  child: TextButton(
                    onPressed: () async {
                      endTime = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      setState(() {});
                    },
                    child: Text(
                      endTime == null ? '종료 시간 선택' : '종료: ${endTime!.format(context)}',
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Text('색상 선택:', style: TextStyle(fontWeight: FontWeight.bold)),
            Wrap(
              alignment: WrapAlignment.start, // 왼쪽 정렬
              spacing: 10, // 색상 원 사이의 가로 간격
              runSpacing: 10, // 줄 간격
              children: availableColors.map((color) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedColor = color;
                    });
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: selectedColor == color ? Colors.black : Colors.transparent,
                        width: 2,
                      ),
                    ),
                  ),
                );
              }).toList(),
            )

          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text('닫기'),
        ),
        TextButton(
          onPressed: () {
            if (className.isNotEmpty &&
                classroom.isNotEmpty &&
                startTime != null &&
                endTime != null) {
              widget.onAddEntry(
                className,
                classroom,
                dayOfWeek,
                startTime!,
                endTime!,
                selectedColor,
              );
              Navigator.pop(context);
            }
          },
          child: Text('추가'),
        ),
      ],
    );
  }
}
