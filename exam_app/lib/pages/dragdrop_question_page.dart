import 'package:flutter/material.dart';

class DragDropQuestionPage extends StatefulWidget {
  @override
  _DragDropQuestionPageState createState() => _DragDropQuestionPageState();
}

class _DragDropQuestionPageState extends State<DragDropQuestionPage> {
  // Danh sách các đáp án đúng
  final List<String> correctAnswers = ["Tin học", "22", "Tân Xuân", "Hóc Môn"];

  // Danh sách các từ để kéo thả
  List<String> answers = ["Tin học", "22", "Tân Xuân", "Hóc Môn"];

  List<String?> selectedAnswers = [null, null, null, null];

  int score = 0;

  void _checkAnswers() {
    score = 0;
    for (int i = 0; i < correctAnswers.length; i++) {
      if (selectedAnswers[i] == correctAnswers[i]) {
        score++;
      } else {
        score--; 
      }
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(score >= 0 ? 'Kết quả' : 'Sai'),
        content: Text(score >= 0
            ? 'Điểm của bạn: $score / ${correctAnswers.length}'
            : 'Điểm của bạn: $score. Một số đáp án không đúng. Hãy thử lại!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Trang Câu Hỏi Kéo Thả'),
        backgroundColor: Color(0xFF5268B6),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Đoạn văn với các chỗ trống
            RichText(
              text: TextSpan(
                style: TextStyle(fontSize: 18, color: Colors.black),
                children: [
                  TextSpan(text: 'Cơ sở Hóc Môn là cơ sở mới nhất của Trường Đại học Ngoại ngữ - '),
                  _buildTextSpan(0),
                  TextSpan(text: ' TP. Hồ Chí Minh (HUFLIT), tọa lạc tại Quốc lộ '),
                  _buildTextSpan(1),
                  TextSpan(text: ', xã '),
                  _buildTextSpan(2),
                  TextSpan(text: ', huyện '),
                  _buildTextSpan(3),
                  TextSpan(text: ', TP. Hồ Chí Minh.'),
                ],
              ),
            ),
            SizedBox(height: 20),
            Wrap(
              spacing: 10,
              children: answers.map((answer) {
                return Draggable<String>(
                  data: answer,
                  child: Chip(label: Text(answer)),
                  feedback: Material(
                    child: Chip(label: Text(answer)),
                    elevation: 8.0,
                  ),
                  childWhenDragging: Chip(
                    label: Text(answer),
                    backgroundColor: Colors.grey[300],
                  ),
                );
              }).toList(),
            ),
            SizedBox(height: 20),
            OutlinedButton(
              onPressed: _checkAnswers,
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.black, 
                side: BorderSide(color: Colors.black), 
              ),
              child: Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }

  TextSpan _buildTextSpan(int index) {
    return TextSpan(
      children: [
        WidgetSpan(
          child: DragTarget<String>(
            builder: (context, candidateData, rejectedData) {
              return Container(
                width: 80,
                height: 25,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.blue),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Center(
                  child: Text(selectedAnswers[index] ?? '......'),
                ),
              );
            },
            onAccept: (data) {
              setState(() {
                selectedAnswers[index] = data;
                answers.remove(data);
              });
            },
          ),
        ),
      ],
    );
  }
}
