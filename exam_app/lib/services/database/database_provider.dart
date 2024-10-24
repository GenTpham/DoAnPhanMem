import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:exam_app/models/user.dart';
import 'package:exam_app/services/auth/auth_service.dart';
import 'package:exam_app/services/database/database_service.dart';
import 'package:flutter/material.dart';

class DatabaseProvider extends ChangeNotifier {
  final _db = DatabaseService();
  final _auth = AuthService();
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
}
