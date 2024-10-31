import 'package:cloud_firestore/cloud_firestore.dart';

class QuestionModel {
  final String questionId;
  final String questionText; // Nội dung câu hỏi
  final List<String> options; // Các lựa chọn đáp án
  final int correctAnswerIndex; // Vị trí đáp án đúng trong danh sách options

  QuestionModel({
    required this.questionId,
    required this.questionText,
    required this.options,
    required this.correctAnswerIndex,
  });

  // firebase -> app
  factory QuestionModel.fromDocument(DocumentSnapshot doc) {
    return QuestionModel(
      questionId: doc['questionId'],
      questionText: doc['questionText'],
      options: List<String>.from(doc['options']),
      correctAnswerIndex: doc['correctAnswerIndex'],
    );
  }

  // app -> firebase
  Map<String, dynamic> toMap() {
    return {
      'questionId': questionId,
      'questionText': questionText,
      'options': options,
      'correctAnswerIndex': correctAnswerIndex,
    };
  }

  // Kiểm tra xem đáp án người dùng chọn có đúng không
  bool isCorrect(int userAnswerIndex) {
    return userAnswerIndex == correctAnswerIndex;
  }
}
