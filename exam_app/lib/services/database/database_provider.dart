import 'package:exam_app/models/user.dart';
import 'package:exam_app/services/auth/auth_service.dart';
import 'package:exam_app/services/database/database_service.dart';
import 'package:flutter/material.dart';

class DatabaseProvider extends ChangeNotifier {
  // get db & auth service
  final _db = DatabaseService();
  final _auth = AuthService();

  Future<UserProfile?> userProfile(String uid) => _db.getUserFromFirebase(uid);

}
