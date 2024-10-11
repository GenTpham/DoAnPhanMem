import 'package:flutter/material.dart';

class ChoiceQuestionPage extends StatefulWidget {
  @override
  _ChoiceQuestionPageState createState() => _ChoiceQuestionPageState();
}

class _ChoiceQuestionPageState extends State<ChoiceQuestionPage> {
  // Danh sách câu hỏi và các đáp án
  final List<Map<String, dynamic>> questions = [
    {
      'question': 'Huflit gồm những cơ sở nào?',
      'answers': [
        {'answer': 'Hóc Môn', 'isSelected': false},
        {'answer': 'Sư Vạn Hạnh', 'isSelected': false},
        {'answer': 'Thủ Đức', 'isSelected': false},
        {'answer': 'Ba Gia', 'isSelected': false},
        {'answer': 'Thất Sơn', 'isSelected': false},
        {'answer': 'Cao Thắng', 'isSelected': false},
        {'answer': 'Củ Chi', 'isSelected': false},
        {'answer': 'Trường Sơn', 'isSelected': false},
      ]
    }
  ];

  // Danh sách đáp án đúng
  final List<String> correctAnswers = [
    'Hóc Môn',
    'Sư Vạn Hạnh',
    'Ba Gia',
    'Thất Sơn',
    'Cao Thắng',
    'Trường Sơn',
  ];

  int score = 0;
  bool isSubmitted = false;

  void _onAnswerSelected(int questionIndex, int answerIndex, bool isSelected) {
    setState(() {
      questions[questionIndex]['answers'][answerIndex]['isSelected'] = isSelected;
    });
  }

  void _submitAnswers() {
    int tempScore = 0;

    questions.forEach((question) {
      (question['answers'] as List<Map<String, dynamic>>).forEach((answer) {
        // Nếu đáp án được chọn và đúng thì cộng điểm
        if (answer['isSelected'] == true && correctAnswers.contains(answer['answer'])) {
          tempScore++;
        }
        // Nếu đáp án được chọn và sai thì trừ điểm
        else if (answer['isSelected'] == true && !correctAnswers.contains(answer['answer'])) {
          tempScore--;
        }
      });
    });

    setState(() {
      score = tempScore;
      isSubmitted = true;
    });

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Kết quả'),
          content: Text('Bạn đã trả lời đúng $score/${correctAnswers.length} câu.'),
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
        title: Text('Choice Question Page'),
        backgroundColor: Color(0xFF5268B6),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ...questions.map((question) {
              int questionIndex = questions.indexOf(question);
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    question['question'],
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Column(
                    children: (question['answers'] as List<Map<String, dynamic>>).map((answer) {
                      int answerIndex = question['answers'].indexOf(answer);
                      return CheckboxListTile(
                        title: Text(answer['answer']),
                        value: answer['isSelected'],
                        onChanged: (bool? value) {
                          _onAnswerSelected(questionIndex, answerIndex, value ?? false);
                        },
                      );
                    }).toList(),
                  ),
                ],
              );
            }).toList(),
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
                'You scored: $score/${correctAnswers.length}',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue),
              ),
          ],
        ),
      ),
    );
  }
}
