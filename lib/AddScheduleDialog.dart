import 'package:flutter/material.dart';

class AddScheduleDialog extends StatefulWidget {
  final DateTime selectedDate;
  final Function(String, String, String) onScheduleAdded;

  AddScheduleDialog({required this.selectedDate, required this.onScheduleAdded});

  @override
  _AddScheduleDialogState createState() => _AddScheduleDialogState();
}

class _AddScheduleDialogState extends State<AddScheduleDialog> {
  final _titleController = TextEditingController();
  final _detailsController = TextEditingController();
  late TextEditingController _timeController;
  String _time = "09:00 AM";

  @override
  void initState() {
    super.initState();
    _timeController = TextEditingController(text: _time);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _detailsController.dispose();
    _timeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "일정 등록하기",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.purple),
                ),
                IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: "제목"),
            ),
            TextField(
              controller: _detailsController,
              decoration: InputDecoration(labelText: "상세일정"),
            ),
            TextField(
              controller: _timeController,
              decoration: InputDecoration(labelText: "시간"),
              onTap: () async {
                TimeOfDay? pickedTime = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay(hour: 9, minute: 0),
                );
                if (pickedTime != null) {
                  setState(() {
                    _time = pickedTime.format(context);
                    _timeController.text = _time; // _timeController에 선택된 시간 설정
                  });
                }
              },
              readOnly: true,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.purple.shade100),
              onPressed: () {
                widget.onScheduleAdded(_titleController.text, _detailsController.text, _time);
                Navigator.of(context).pop();
              },
              child: Text("OK", style: TextStyle(color: Colors.purple)),
            ),
          ],
        ),
      ),
    );
  }
}
