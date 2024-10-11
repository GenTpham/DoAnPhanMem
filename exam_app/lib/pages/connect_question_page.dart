import 'package:flutter/material.dart';

class ConnectQuestionPage extends StatefulWidget {
  @override
  _ConnectQuestionPageState createState() => _ConnectQuestionPageState();
}

class _ConnectQuestionPageState extends State<ConnectQuestionPage> {
  // Danh sách các câu hỏi và đáp án
  final List<String> questions = ['IT', 'AI', 'DB'];
  final List<String> correctAnswers = ['Information Technology', 'Artificial Intelligence', 'Database'];
  
  // Tạo một bản đồ câu hỏi - đáp án đúng
  final Map<String, String> correctMappings = {
    'IT': 'Information Technology',
    'AI': 'Artificial Intelligence',
    'DB': 'Database',
  };

  // Lưu vị trí kết nối đúng
  Map<String, String> matchedAnswers = {};

  // Biến để lưu điểm số
  int score = 0;
  bool isSubmitted = false;

  // Hàm để kiểm tra câu trả lời
  void _submitAnswers() {
    int tempScore = 0;
    matchedAnswers.forEach((question, answer) {
      if (correctMappings[question] == answer) {
        tempScore++;
      }
    });

    setState(() {
      score = tempScore;
      isSubmitted = true;
    });

    // Hiển thị thông báo điểm số
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Kết quả'),
          content: Text('Bạn đã trả lời đúng $score/${questions.length} câu.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF5268B6),
        title: Text('Connect Question Page'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Match the terms:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: questions.map((question) {
                      return Draggable<String>(
                        data: question,
                        child: ListTile(title: Text(question)),
                        feedback: Material(
                          child: Container(
                            padding: EdgeInsets.all(8),
                            color: Colors.blue,
                            child: Text(
                              question,
                              style: TextStyle(color: Colors.white, fontSize: 18),
                            ),
                          ),
                        ),
                        childWhenDragging: ListTile(
                            title: Text(question, style: TextStyle(color: Colors.grey))),
                      );
                    }).toList(),
                  ),
                ),
                SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: correctAnswers.map((answer) {
                      return DragTarget<String>(
                        builder: (context, candidateData, rejectedData) {
                          return ListTile(
                            title: Text(matchedAnswers.containsValue(answer)
                                ? matchedAnswers.keys.firstWhere((key) => matchedAnswers[key] == answer)
                                : answer),
                            tileColor: matchedAnswers.containsValue(answer) ? Colors.green[100] : null,
                          );
                        },
                        onAccept: (receivedData) {
                          setState(() {
                            matchedAnswers[receivedData] = answer;
                          });
                        },
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            if (!isSubmitted)
               OutlinedButton(
                onPressed: _submitAnswers,
                style: OutlinedButton.styleFrom(
                foregroundColor: Colors.black, // Màu chữ
                side: BorderSide(color: Colors.black), // Màu viền
              ),
              child: Text('Submit'),
            ),
            if (isSubmitted)
              Text(
                'You scored: $score/${questions.length}',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue),
              ),
          ],
        ),
      ),
    );
  }
}
