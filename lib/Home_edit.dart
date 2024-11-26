import 'package:flutter/material.dart';

class EditDeletePopup extends StatefulWidget {
  final Map<String, dynamic> entry;
  final Function(String, String, String, TimeOfDay, TimeOfDay, Color) onUpdate;
  final Function onDelete;

  const EditDeletePopup({
    super.key,
    required this.entry,
    required this.onUpdate,
    required this.onDelete,
  });

  @override
  _EditDeletePopupState createState() => _EditDeletePopupState();
}

class _EditDeletePopupState extends State<EditDeletePopup> {
  late String className;
  late String classroom;
  late String dayOfWeek;
  TimeOfDay? startTime;
  TimeOfDay? endTime;
  late Color selectedColor;

  final List<Color> availableColors = [
    Colors.pink[300]!,     // 분홍
    Colors.orange[300]!,   // 주황
    Colors.lightGreen[300]!,// 연두
    Colors.lightBlue[300]!,// 하늘
    Colors.purple[300]!,   // 보라
  ];

  @override
  void initState() {
    super.initState();
    className = widget.entry['className'];
    classroom = widget.entry['classroom'];
    dayOfWeek = widget.entry['dayOfWeek'];
    startTime = widget.entry['startTime'];
    endTime = widget.entry['endTime'];
    selectedColor = widget.entry['color']; // 기존 저장된 색상 로드
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('수정 / 삭제'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              onChanged: (value) => className = value,
              decoration: InputDecoration(
                labelText: '수업명',
                hintText: widget.entry['className'],
              ),
              controller: TextEditingController(text: className),
            ),
            TextField(
              onChanged: (value) => classroom = value,
              decoration: InputDecoration(
                labelText: '교실',
                hintText: widget.entry['classroom'],
              ),
              controller: TextEditingController(text: classroom),
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
                        initialTime: startTime ?? TimeOfDay.now(),
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
                        initialTime: endTime ?? TimeOfDay.now(),
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
          child: Text('취소'),
        ),
        TextButton(
          onPressed: () {
            if (className.isNotEmpty &&
                classroom.isNotEmpty &&
                startTime != null &&
                endTime != null) {
              widget.onUpdate(
                className,
                classroom,
                dayOfWeek,
                startTime!,
                endTime!,
                selectedColor, // 선택한 색상 전달
              );
              Navigator.pop(context);
            }
          },
          child: Text('수정'),
        ),
        TextButton(
          onPressed: () {
            widget.onDelete();
            Navigator.pop(context);
          },
          child: Text('삭제'),
        ),
      ],
    );
  }
}
