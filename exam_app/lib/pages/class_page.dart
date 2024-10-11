import 'package:flutter/material.dart';
import 'connect_question_page.dart';
import 'choice_question_page.dart';
import 'dragdrop_question_page.dart';
class ClassPage extends StatelessWidget {
  final String className;
  final String classCode;

 // Danh sách các bài thi giả lập
  final List<Map<String, String>> exams = [
    {'title': 'Choice Question Exam', 'dueDate': '2024-10-20', 'status': 'Pending'},
    {'title': 'Connect Question Exam', 'dueDate': '2024-12-15', 'status': 'Pending'},
    {'title': 'Drag and drop Question Exam', 'dueDate': '2024-11-05', 'status': 'Pending'},
  ];

  ClassPage({required this.className, required this.classCode});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF5268B6),
        title: Text('$className ($classCode)'), // Hiển thị tên và mã lớp trên AppBar
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hiển thị danh sách các bài thi
            Text(
              'Exams:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            // Nếu có bài thi, hiển thị chúng
            exams.isNotEmpty
                ? Expanded( // Đảm bảo việc hiển thị danh sách bài thi
                    child: ListView.builder(
                      itemCount: exams.length,
                      itemBuilder: (context, index) {
                        final exam = exams[index];
                        return ListTile(
                          title: Text(exam['title']!),
                          subtitle: Text('Due Date: ${exam['dueDate']}'),
                          trailing: Text(
                            exam['status']!,
                            style: TextStyle(
                              color: exam['status'] == 'Pending' ? Colors.red : Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          onTap: () {
                            if (exam['title'] == 'Choice Question Exam') {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ChoiceQuestionPage(),
                                ),
                              );
                            }
                            if (exam['title'] == 'Connect Question Exam'){
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ConnectQuestionPage(),
                                )
                              );
                            }
                            if (exam['title'] == 'Drag and drop Question Exam'){
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DragDropQuestionPage(),
                                )
                              );
                            }
                          },
                        );
                      },
                    ),
                  )
                : Center(
                    child: Text(
                      'No exams available',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
