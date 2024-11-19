import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:exam_app/models/user.dart';
import 'package:exam_app/services/auth/auth_service.dart';
import 'package:exam_app/services/database/database_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class DatabaseProvider extends ChangeNotifier {
  final _db = DatabaseService();
  final _auth = AuthService();
  User? get currentUser => _auth.getCurrentUser();

  bool get isTeacher {
    if (currentUser == null || _classMembers.isEmpty) return false;
    return _classMembers.any((member) =>
        member['email'] == currentUser?.email && member['role'] == 'teacher');
  }

  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<UserProfile?> userProfile(String uid) => _db.getUserFromFirebase(uid);

  Future<String?> createClass(String className) async {
    try {
      String? classCode = await _db.createClass(className: className);
      await fetchJoinedClasses();
      return classCode;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  Future<void> addMemberToClass(String classId, String email) async {
    await _db.addMemberToClass(classId: classId, email: email);
    notifyListeners();
  }

  Future<void> joinClassWithCode(String classCode) async {
    await _db.joinClassWithCode(classCode: classCode);
    notifyListeners();
  }

  List<Map<String, dynamic>> _joinedClasses = [];
  List<Map<String, dynamic>> get joinedClasses => _joinedClasses;

  Future<void> fetchJoinedClasses() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _joinedClasses = await _db.getJoinedClasses();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  List<Map<String, dynamic>> _classMembers = [];
  List<Map<String, dynamic>> get classMembers => _classMembers;

  Future<void> fetchClassMembers(String classId) async {
    try {
      _isLoading = true;
      notifyListeners();

      _classMembers = await _db.getClassMembers(classId);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  List<Map<String, dynamic>> _classExams = [];
  List<Map<String, dynamic>> get classExams => _classExams;

  List<Map<String, dynamic>> _examQuestions = [];
  List<Map<String, dynamic>> get examQuestions => _examQuestions;

  Future<String?> createExam({
    required String classId,
    required String examTitle,
    required String description,
    required DateTime startTime,
    required DateTime endTime,
    required int duration,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      String? examId = await _db.createExam(
        classId: classId,
        examTitle: examTitle,
        description: description,
        startTime: startTime,
        endTime: endTime,
        duration: duration,
      );

      await fetchClassExams(classId);

      _isLoading = false;
      notifyListeners();

      return examId;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  Future<String?> addQuestionToExam({
    required String classId,
    required String examId,
    required String questionText,
    required List<String> options,
    required List<int> correctOptionIndices,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      String? questionId = await _db.addQuestionToExam(
        classId: classId,
        examId: examId,
        questionText: questionText,
        options: options,
        correctOptionIndices: correctOptionIndices,
      );

      await fetchExamQuestions(classId, examId);

      _isLoading = false;
      notifyListeners();

      return questionId;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  Future<void> fetchClassExams(String classId) async {
    try {
      _isLoading = true;
      notifyListeners();

      _classExams = await _db.getClassExams(classId);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> fetchExamQuestions(String classId, String examId) async {
    try {
      _isLoading = true;
      notifyListeners();

      _examQuestions = await _db.getExamQuestions(classId, examId);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> publishExam(String classId, String examId) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _db.publishExam(classId, examId);
      await fetchClassExams(classId);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> startExam(String classId, String examId) async {
    try {
      await _db.startExam(classId, examId);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<double> submitExam({
    required String classId,
    required String examId,
    required Map<String, int> answers,
    required DateTime startTime,
    required DateTime endTime,
  }) async {
    try {
      return await _db.submitExam(
        classId: classId,
        examId: examId,
        answers: answers,
        startTime: startTime,
        endTime: endTime,
      );
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      throw e;
    }
  }

  Future<Map<String, dynamic>?> checkExamStatus(
      String classId, String examId) async {
    try {
      return await _db.checkExamStatus(classId, examId);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }
  List<Map<String, dynamic>> _examScores = [];
  List<Map<String, dynamic>> get examScores => _examScores;

  Future<void> fetchExamScores(String classId, String examId) async {
    try {
      _isLoading = true;
      notifyListeners();

      _examScores = await _db.getExamScores(classId, examId);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }
  Future<void> updateProfile({
    required String uid,
    required String name,
    required String phone,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _db.updateUserProfile(
        uid: uid,
        name: name,
        phone: phone,
      );

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      throw e;
    }
  }

  Future<void> changePassword(String newPassword) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _db.changePassword(newPassword);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      throw e;
    }
  }

  Future<void> deleteAccount() async {
    try {
      _isLoading = true;
      notifyListeners();

      await _db.deleteUserAccount();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      throw e;
    }
  }
  
}
