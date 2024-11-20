import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:exam_app/services/database/database_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class TakeExamPage extends StatefulWidget {
  final String classId;
  final String examId;
  final Map<String, dynamic> examInfo;

  const TakeExamPage({
    super.key,
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
  List<Map<String, dynamic>> randomizedQuestions = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (examStarted && isAfterExamEnd) {
        submitExam();
      }
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

  void startTimer() {
    examTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (remainingTime > 0) {
          remainingTime--;

          // Cảnh báo khi còn 5 phút
          if (remainingTime == 300) {
            _showTimeWarning('⚠️ Còn 5 phút');
          }
          // Cảnh báo khi còn 1 phút
          else if (remainingTime == 60) {
            _showTimeWarning('⚠️ Còn 1 phút cuối!');
          }
          // Cảnh báo khi còn 30 giây
          else if (remainingTime == 30) {
            _showTimeWarning('⚠️ Còn 30 giây!', isUrgent: true);
          }
        } else {
          timer.cancel();
          _showTimeUpDialog();
        }
      });
    });
  }

  String formatTime(int seconds) {
    int hours = seconds ~/ 3600;
    int minutes = (seconds % 3600) ~/ 60;
    int remainingSeconds = seconds % 60;

    String hoursStr = hours > 0 ? '${hours.toString().padLeft(2, '0')}:' : '';
    return '$hoursStr${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  void _showTimeWarning(String message, {bool isUrgent = false}) {
    if (!mounted) return; // Kiểm tra widget còn mounted không

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: isUrgent ? 16 : 14,
          ),
        ),
        backgroundColor: isUrgent ? Colors.red : Colors.orange,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  void _showTimeUpDialog() {
    if (!mounted) return; // Kiểm tra widget còn mounted không

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: const [
            Icon(Icons.timer_off, color: Colors.red),
            SizedBox(width: 8),
            Text('Hết giờ!'),
          ],
        ),
        content: const Text(
            'Đã hết thời gian làm bài. Hệ thống sẽ tự động nộp bài của bạn.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              submitExam();
            },
            child: const Text('Đồng ý'),
          ),
        ],
      ),
    );
  }

  void randomizeQuestions(List<Map<String, dynamic>> questions) {
    randomizedQuestions = List.from(questions);

    final random = Random();
    for (int i = randomizedQuestions.length - 1; i > 0; i--) {
      final j = random.nextInt(i + 1);
      final temp = randomizedQuestions[i];
      randomizedQuestions[i] = randomizedQuestions[j];
      randomizedQuestions[j] = temp;
    }

    for (var question in randomizedQuestions) {
      final options = List<String>.from(question['options']);
      final originalOptions = List<String>.from(options);
      final randomizedOptions = <String>[];
      final optionMapping = <int, int>{};

      while (options.isNotEmpty) {
        final index = random.nextInt(options.length);
        final option = options.removeAt(index);
        randomizedOptions.add(option);
        optionMapping[randomizedOptions.length - 1] =
            originalOptions.indexOf(option);
      }

      question['options'] = randomizedOptions;
      question['optionMapping'] = optionMapping;
    }
  }

  void startExam() async {
    if (!isWithinExamPeriod) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Không trong thời gian làm bài'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      await context.read<DatabaseProvider>().startExam(
            widget.classId,
            widget.examId,
          );

      final questions = context.read<DatabaseProvider>().examQuestions;
      randomizeQuestions(questions);

      setState(() {
        examStarted = true;
        startTime = DateTime.now();
        remainingTime = widget.examInfo['duration'] * 60;
        answers = {};
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

  Map<String, List<int>> convertAnswersToOriginalOrder(
      Map<String, List<int>> currentAnswers) {
    final convertedAnswers = <String, List<int>>{};

    for (var question in randomizedQuestions) {
      final questionId = question['questionId'];
      if (currentAnswers.containsKey(questionId)) {
        final originalIndices = currentAnswers[questionId]!
            .map((index) => question['optionMapping'][index] as int)
            .toList();
        convertedAnswers[questionId] = originalIndices;
      }
    }

    return convertedAnswers;
  }

  void submitExam() async {
    if (!examStarted || startTime == null) return;

    setState(() {
      isLoading = true;
    });

    try {
      final originalAnswers = convertAnswersToOriginalOrder(answers);

      final score = await context.read<DatabaseProvider>().submitExam(
            classId: widget.classId,
            examId: widget.examId,
            answers: originalAnswers,
            startTime: startTime!,
            endTime: DateTime.now(),
          );
      examTimer?.cancel();

      if (!mounted) return; // Kiểm tra widget còn mounted không

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
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi nộp bài: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  bool get isWithinExamPeriod {
    final now = DateTime.now();
    final startDateTime = (widget.examInfo['startTime'] as Timestamp).toDate();
    final endDateTime = (widget.examInfo['endTime'] as Timestamp).toDate();
    return now.isAfter(startDateTime) && now.isBefore(endDateTime);
  }

  bool get isBeforeExamStart {
    final now = DateTime.now();
    final startDateTime = (widget.examInfo['startTime'] as Timestamp).toDate();
    return now.isBefore(startDateTime);
  }

  bool get isAfterExamEnd {
    final now = DateTime.now();
    final endDateTime = (widget.examInfo['endTime'] as Timestamp).toDate();
    return now.isAfter(endDateTime);
  }

  String get examTimeStatus {
    if (isBeforeExamStart) {
      final startDateTime =
          (widget.examInfo['startTime'] as Timestamp).toDate();
      return 'Bài thi sẽ bắt đầu vào ${DateFormat('dd/MM/yyyy HH:mm').format(startDateTime)}';
    } else if (isAfterExamEnd) {
      return 'Bài thi đã kết thúc';
    }
    return '';
  }

  String formatDateTime(Timestamp timestamp) {
    return DateFormat('dd/MM/yyyy HH:mm').format(timestamp.toDate());
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
              content: const Text(
                  'Bạn có chắc muốn thoát? Mọi câu trả lời sẽ bị mất.'),
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
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                margin: const EdgeInsets.only(right: 16),
                decoration: BoxDecoration(
                  color: remainingTime <= 300
                      ? Colors.red.withOpacity(0.1)
                      : Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: remainingTime <= 300 ? Colors.red : Colors.blue,
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.timer,
                      size: 20,
                      color: remainingTime <= 300 ? Colors.red : Colors.blue,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      formatTime(remainingTime),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: remainingTime <= 300 ? Colors.red : Colors.blue,
                      ),
                    ),
                  ],
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
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                      Text(
                          'Thời gian làm bài: ${widget.examInfo['duration']} phút'),
                      Text(
                          'Thời gian bắt đầu: ${formatDateTime(widget.examInfo['startTime'])}'),
                      Text(
                          'Thời gian kết thúc: ${formatDateTime(widget.examInfo['endTime'])}'),
                      if (examTimeStatus.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isBeforeExamStart
                                ? Colors.orange.withOpacity(0.1)
                                : Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isBeforeExamStart
                                  ? Colors.orange
                                  : Colors.red,
                            ),
                          ),
                          child: Text(
                            examTimeStatus,
                            style: TextStyle(
                              color: isBeforeExamStart
                                  ? Colors.orange[800]
                                  : Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 24),
                      Center(
                        child: ElevatedButton(
                          onPressed: isWithinExamPeriod ? startExam : null,
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
                          child: Text(
                            'Bắt đầu làm bài',
                            style: TextStyle(
                              color: isWithinExamPeriod
                                  ? Colors.white
                                  : Colors.grey,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ...randomizedQuestions.asMap().entries.map((entry) {
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
                      onPressed: answers.length == randomizedQuestions.length
                          ? submitExam
                          : null,
                      child: const Text('Nộp bài'),
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
