import 'package:flutter/material.dart';

class EditScheduleDialog extends StatefulWidget {
  final Map<String, dynamic> event;
  final Function(String, String) onEdit; // 수정 콜백
  final Function onDelete; // 삭제 콜백

  EditScheduleDialog({
    required this.event,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  _EditScheduleDialogState createState() => _EditScheduleDialogState();
}

class _EditScheduleDialogState extends State<EditScheduleDialog> {
  late TextEditingController _titleController;
  late String _time;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.event['title']);
    _time = widget.event['time'];
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _pickTime() async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: int.parse(_time.split(":")[0]),
        minute: int.parse(_time.split(":")[1].split(" ")[0]),
      ),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: Colors.purple,
            hintColor: Colors.purple.shade100,
            timePickerTheme: TimePickerThemeData(
              dialBackgroundColor: Colors.purple.shade50,
              hourMinuteTextColor: Colors.purple,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedTime != null) {
      setState(() {
        _time = pickedTime.format(context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("수정 또는 삭제", style: TextStyle(color: Colors.purple)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _titleController,
            decoration: InputDecoration(labelText: "제목", labelStyle: TextStyle(color: Colors.purple)),
          ),
          SizedBox(height: 16),
          GestureDetector(
            onTap: _pickTime,
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.purple),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _time,
                style: TextStyle(fontSize: 16, color: Colors.purple),
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            widget.onDelete(); // 삭제 콜백 실행
            Navigator.of(context).pop();
          },
          child: Text("삭제", style: TextStyle(color: Colors.red)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.purple.shade100),
          onPressed: () {
            widget.onEdit(_titleController.text, _time); // 수정 콜백 실행
            Navigator.of(context).pop();
          },
          child: Text("수정", style: TextStyle(color: Colors.purple)),
        ),
      ],
    );
  }
}
