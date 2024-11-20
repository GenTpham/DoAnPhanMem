import 'dart:async';

import 'package:exam_app/services/database/database_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TakeExamPage extends StatefulWidget {
  final String classId;
  final String examId;
  final Map<String, dynamic> examInfo;

  const TakeExamPage({super.key, 
    required this.classId,
    required this.examId,
    required this.examInfo,
  });

  @override
  _TakeExamPageState createState() => _TakeExamPageState();
}

class _TakeExamPageState extends State<TakeExamPage> {
  Map<String, List<int>> answers = {};
  bool isLoading = false;
  bool examStarted = false;
  DateTime? startTime;
  Timer? examTimer;
  int remainingTime = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DatabaseProvider>().fetchExamQuestions(
            widget.classId,
            widget.examId,
          );
    });
  }

  @override
  void dispose() {
    examTimer?.cancel();
    super.dispose();
  }

  void startExam() async {
    setState(() {
      isLoading = true;
    });

    try {
      await context.read<DatabaseProvider>().startExam(
            widget.classId,
            widget.examId,
          );

      setState(() {
        examStarted = true;
        startTime = DateTime.now();
        remainingTime = widget.examInfo['duration'] * 60; // Convert to seconds
        answers = {}; // Khởi tạo answers
      });

      startTimer();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không thể bắt đầu bài thi: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void startTimer() {
    examTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (remainingTime > 0) {
          remainingTime--;
        } else {
          submitExam();
          timer.cancel();
        }
      });
    });
  }

  String formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  void submitExam() async {
    if (!examStarted || startTime == null) return;

    setState(() {
      isLoading = true;
    });

    try {
      final score = await context.read<DatabaseProvider>().submitExam(
            classId: widget.classId,
            examId: widget.examId,
            answers: answers.map((questionId, options) => MapEntry(questionId,
                options.first)), // Chỉ lưu index của đáp án đầu tiên
            startTime: startTime!,
            endTime: DateTime.now(),
          );

      examTimer?.cancel();

      // Hiển thị dialog kết quả
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text('Kết quả bài thi'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Điểm số của bạn: ${score.toStringAsFixed(2)}/10'),
              const SizedBox(height: 16),
              const Text('Bạn đã hoàn thành bài thi!'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text('Đóng'),
            ),
          ],
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi nộp bài: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (examStarted) {
          final shouldPop = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Thoát bài thi?'),
              content:
                  const Text('Bạn có chắc muốn thoát? Mọi câu trả lời sẽ bị mất.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Không'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Có'),
                ),
              ],
            ),
          );
          return shouldPop ?? false;
        }
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.examInfo['title']),
          actions: [
            if (examStarted)
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Text(
                    'Thời gian: ${formatTime(remainingTime)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
        body: Consumer<DatabaseProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading || isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!examStarted) {
              return Center(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), 
                  decoration: BoxDecoration(
                    color: Colors.white, 
                    borderRadius: BorderRadius.circular(16), 
                    border: Border.all(
                      color: Colors.grey, 
                      width: 1.5, 
                    ),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start, 
                    children: [
                      Text(
                        'Thông tin bài thi',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 16),
                      Text('Tiêu đề: ${widget.examInfo['title']}'),
                      Text('Mô tả: ${widget.examInfo['description']}'),
                      Text('Thời gian: ${widget.examInfo['duration']} phút'),
                      const SizedBox(height: 24),
                      Center(
                        child: ElevatedButton(
                          onPressed: startExam,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF3572EF),
                            side: const BorderSide(
                              color: Colors.black,
                              width: 1.5,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: const Text(
                            'Bắt đầu làm bài',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }


            final questions = provider.examQuestions;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ...questions.asMap().entries.map((entry) {
                    final index = entry.key;
                    final question = entry.value;
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Câu ${index + 1}: ${question['questionText']}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ...List<Widget>.generate(
                              question['options'].length,
                              (optionIndex) => CheckboxListTile(
                                title: Text(question['options'][optionIndex]),
                                value: answers[question['questionId']]
                                        ?.contains(optionIndex) ??
                                    false,
                                onChanged: (value) {
                                  setState(() {
                                    if (value == true) {
                                      answers
                                          .putIfAbsent(
                                              question['questionId'], () => [])
                                          .add(optionIndex);
                                    } else {
                                      answers[question['questionId']]
                                          ?.remove(optionIndex);
                                    }
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 16),
                  Center(
                        child: ElevatedButton(
                          onPressed: startExam,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF3572EF),
                            side: const BorderSide(
                              color: Colors.black,
                              width: 1.5,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: const Text(
                            'Nộp bài',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
