import 'package:flutter/material.dart';

class AddTimetablePopup extends StatefulWidget {
  final Function(String, String, String, TimeOfDay, TimeOfDay) onAddEntry;

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

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('시간표 추가'),
      content: Column(
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
        ],
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
            if (className.isNotEmpty && classroom.isNotEmpty && startTime != null && endTime != null) {
              widget.onAddEntry(className, classroom, dayOfWeek, startTime!, endTime!);
              Navigator.pop(context);
            }
          },
          child: Text('추가'),
        ),
      ],
    );
  }
}
