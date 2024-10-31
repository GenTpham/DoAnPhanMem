import 'package:cloud_firestore/cloud_firestore.dart';

class ExamModel {
  final String examId;
  final String title;
  final String description;
  final int duration;
  final DateTime startTime;
  final DateTime endTime;
  final List<String> questionIds;

  ExamModel({
    required this.examId,
    required this.title,
    required this.description,
    required this.duration,
    required this.startTime,
    required this.endTime,
    required this.questionIds,
  });
  // firebase -> app
  factory ExamModel.fromDocument(DocumentSnapshot doc) {
    return ExamModel(
      examId: doc['examId'],
      title: doc['title'],
      description: doc['description'],
      duration: doc['duration'],
      startTime: (doc['startTime'] as Timestamp).toDate(),
      endTime: (doc['endTime'] as Timestamp).toDate(),
      questionIds: List<String>.from(doc['questionIds']),
    );
  }

  // app -> firebase
  Map<String, dynamic> toMap() {
    return {
      'examId': examId,
      'title': title,
      'description': description,
      'duration': duration,
      'startTime': Timestamp.fromDate(startTime),
      'endTime': Timestamp.fromDate(endTime),
      'questionIds': questionIds,
    };
  }
}
