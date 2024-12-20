import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:exam_app/models/user.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DatabaseService {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  // Save user info
  Future<void> saveUserInfoInFirebase(
      {required String name,
      required String email,
      required String phone}) async {
    String uid = _auth.currentUser!.uid;
    String username = email.split('@')[0];

    UserProfile user = UserProfile(
      uid: uid,
      name: name,
      email: email,
      username: username,
      phone: phone,
    );
    final userMap = user.toMap();
    await _db.collection("Users").doc(uid).set(userMap);
  }

  // Get user info
  Future<UserProfile?> getUserFromFirebase(String uid) async {
    try {
      DocumentSnapshot userDoc = await _db.collection("Users").doc(uid).get();

      return UserProfile.fromDocument(userDoc);
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<String?> createClass({required String className}) async {
    try {
      String uid = _auth.currentUser!.uid;
      String email = _auth.currentUser!.email ?? '';

      DocumentReference classDoc = await _db.collection("Classes").add({
        'className': className,
        'createdBy': uid,
        'createdAt': FieldValue.serverTimestamp(),
      });
      await _db
          .collection("Classes")
          .doc(classDoc.id)
          .collection("Members")
          .doc(uid)
          .set({
        'email': email,
        'role': 'teacher',
      });

      String classCode = classDoc.id;
      print('Class created with ID: $classCode');

      return classCode;
    } catch (e) {
      print('Error creating class: $e');
      return null;
    }
  }

  // Thêm thành viên
  Future<void> addMemberToClass(
      {required String classId, required String email}) async {
    try {
      QuerySnapshot userSnapshot =
          await _db.collection("Users").where('email', isEqualTo: email).get();
      if (userSnapshot.docs.isNotEmpty) {
        String userId = userSnapshot.docs.first.id;
        DocumentSnapshot memberDoc = await _db
            .collection("Classes")
            .doc(classId)
            .collection("Members")
            .doc(userId)
            .get();

        if (memberDoc.exists) {
          print('Người dùng đã là thành viên của lớp này');
        } else {
          await _db
              .collection("Classes")
              .doc(classId)
              .collection("Members")
              .doc(userId)
              .set({
            'email': email,
            'role': 'member',
          });
          print('Đã thêm thành viên vào lớp');
        }
      } else {
        print('Email không tồn tại trong hệ thống');
      }
    } catch (e) {
      print("Lỗi khi thêm thành viên: $e");
    }
  }

  // Tham gia lớp
  Future<void> joinClassWithCode({required String classCode}) async {
    try {
      String uid = _auth.currentUser!.uid;
      String email = _auth.currentUser!.email ?? '';
      DocumentSnapshot classDoc =
          await _db.collection("Classes").doc(classCode).get();

      if (classDoc.exists) {
        DocumentSnapshot memberDoc = await _db
            .collection("Classes")
            .doc(classCode)
            .collection("Members")
            .doc(uid)
            .get();

        if (memberDoc.exists) {
          print('Người dùng đã là thành viên của lớp này');
        } else {
          await _db
              .collection("Classes")
              .doc(classCode)
              .collection("Members")
              .doc(uid)
              .set({
            'email': email,
            'role': "member",
          });
          print("Tham gia lớp thành công");
        }
      } else {
        print("Mã lớp không hợp lệ");
      }
    } catch (e) {
      print('Lỗi khi tham gia lớp: $e');
    }
  }

  // Lấy danh sách lớp mà người dùng đã tham gia
  Future<List<Map<String, dynamic>>> getJoinedClasses() async {
    try {
      String uid = _auth.currentUser!.uid;
      QuerySnapshot classSnapshot = await _db.collection("Classes").get();
      List<Map<String, dynamic>> joinedClasses = [];
      for (var classDoc in classSnapshot.docs) {
        DocumentSnapshot memberDoc = await _db
            .collection("Classes")
            .doc(classDoc.id)
            .collection("Members")
            .doc(uid)
            .get();

        if (memberDoc.exists) {
          joinedClasses.add({
            'classId': classDoc.id,
            'className': classDoc['className'],
            'createdBy': classDoc['createdBy'],
            'createdAt': classDoc['createdAt'],
          });
        }
      }
      if (joinedClasses.isEmpty) {
        print('Không có lớp nào mà người dùng đã tham gia.');
      }

      return joinedClasses;
    } catch (e) {
      print('Lỗi khi lấy danh sách lớp: $e');
      return [];
    }
  }

  // Hiển thị thành viên torng lớp
  Future<List<Map<String, dynamic>>> getClassMembers(String classId) async {
    try {
      // Lấy collection members của lớp
      QuerySnapshot memberSnapshot = await _db
          .collection("Classes")
          .doc(classId)
          .collection("Members")
          .get();

      List<Map<String, dynamic>> members = [];
      for (var doc in memberSnapshot.docs) {
        members.add({
          'userId': doc.id,
          'email': doc.get('email'),
          'role': doc.get('role'),
        });
      }
      return members;
    } catch (e) {
      print('Lỗi khi lấy danh sách thành viên: $e');
      return [];
    }
  }

  // Create a new exam in a class
  Future<String?> createExam({
    required String classId,
    required String examTitle,
    required String description,
    required DateTime startTime,
    required DateTime endTime,
    required int duration, // in minutes
  }) async {
    try {
      String uid = _auth.currentUser!.uid;

      // Check if user is a teacher
      DocumentSnapshot memberDoc = await _db
          .collection("Classes")
          .doc(classId)
          .collection("Members")
          .doc(uid)
          .get();

      if (!memberDoc.exists || memberDoc.get('role') != 'teacher') {
        throw 'Only teachers can create exams';
      }

      DocumentReference examDoc =
          await _db.collection("Classes").doc(classId).collection("Exams").add({
        'title': examTitle,
        'description': description,
        'createdBy': uid,
        'createdAt': FieldValue.serverTimestamp(),
        'startTime': startTime,
        'endTime': endTime,
        'duration': duration,
        'isPublished': false,
      });

      return examDoc.id;
    } catch (e) {
      print('Error creating exam: $e');
      return null;
    }
  }

  // Add a question to an exam
  Future<String?> addQuestionToExam({
    required String classId,
    required String examId,
    required String questionText,
    required List<String> options,
    required List<int> correctOptionIndices,
  }) async {
    try {
      String uid = _auth.currentUser!.uid;

      // Verify teacher permission
      DocumentSnapshot memberDoc = await _db
          .collection("Classes")
          .doc(classId)
          .collection("Members")
          .doc(uid)
          .get();

      if (!memberDoc.exists || memberDoc.get('role') != 'teacher') {
        throw 'Only teachers can add questions';
      }

      DocumentReference questionDoc = await _db
          .collection("Classes")
          .doc(classId)
          .collection("Exams")
          .doc(examId)
          .collection("Questions")
          .add({
        'questionText': questionText,
        'options': options,
        'correctOptionIndices': correctOptionIndices,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return questionDoc.id;
    } catch (e) {
      print('Error adding question: $e');
      return null;
    }
  }

  // Get all exams in a class
  Future<List<Map<String, dynamic>>> getClassExams(String classId) async {
    try {
      QuerySnapshot examSnapshot = await _db
          .collection("Classes")
          .doc(classId)
          .collection("Exams")
          .orderBy('createdAt', descending: true)
          .get();

      return examSnapshot.docs
          .map((doc) => {
                'examId': doc.id,
                ...doc.data() as Map<String, dynamic>,
              })
          .toList();
    } catch (e) {
      print('Error getting exams: $e');
      return [];
    }
  }

  // Get all questions in an exam
  Future<List<Map<String, dynamic>>> getExamQuestions(
      String classId, String examId) async {
    try {
      QuerySnapshot questionSnapshot = await _db
          .collection("Classes")
          .doc(classId)
          .collection("Exams")
          .doc(examId)
          .collection("Questions")
          .orderBy('createdAt')
          .get();

      return questionSnapshot.docs
          .map((doc) => {
                'questionId': doc.id,
                ...doc.data() as Map<String, dynamic>,
              })
          .toList();
    } catch (e) {
      print('Error getting questions: $e');
      return [];
    }
  }

  // Publish exam (make it available to students)
  Future<void> publishExam(String classId, String examId) async {
    try {
      String uid = _auth.currentUser!.uid;

      // Verify teacher permission
      DocumentSnapshot memberDoc = await _db
          .collection("Classes")
          .doc(classId)
          .collection("Members")
          .doc(uid)
          .get();

      if (!memberDoc.exists || memberDoc.get('role') != 'teacher') {
        throw 'Only teachers can publish exams';
      }

      await _db
          .collection("Classes")
          .doc(classId)
          .collection("Exams")
          .doc(examId)
          .update({'isPublished': true});
    } catch (e) {
      print('Error publishing exam: $e');
    }
  }

  // Bắt đầu làm bài thi
  Future<void> startExam(String classId, String examId) async {
    try {
      String uid = _auth.currentUser!.uid;

      await _db
          .collection("Classes")
          .doc(classId)
          .collection("Exams")
          .doc(examId)
          .collection("Submissions")
          .doc(uid)
          .set({
        'startTime': FieldValue.serverTimestamp(),
        'status': 'in_progress',
      });
    } catch (e) {
      print('Error starting exam: $e');
      rethrow;
    }
  }

  Future<double> submitExam({
  required String classId,
  required String examId,
  // Thay đổi kiểu dữ liệu của answers để nhận list các đáp án
  required Map<String, List<int>> answers,
  required DateTime startTime,
  required DateTime endTime,
}) async {
  try {
    String uid = _auth.currentUser!.uid;

    // Lấy danh sách câu hỏi và đáp án đúng
    QuerySnapshot questionSnapshot = await _db
        .collection("Classes")
        .doc(classId)
        .collection("Exams")
        .doc(examId)
        .collection("Questions")
        .get();

    double totalPoints = 0;
    int totalQuestions = questionSnapshot.docs.length;

    // Tính điểm
    for (var doc in questionSnapshot.docs) {
      String questionId = doc.id;
      List<int> correctOptionIndices = List<int>.from(doc.get('correctOptionIndices'));
      List<int>? userAnswers = answers[questionId];

      // Nếu không có câu trả lời cho câu hỏi này, bỏ qua
      if (userAnswers == null || userAnswers.isEmpty) continue;

      // Kiểm tra đáp án
      if (correctOptionIndices.length == 1) {
        // Câu hỏi một đáp án
        if (userAnswers.length == 1 && correctOptionIndices.contains(userAnswers[0])) {
          totalPoints += 1;
        }
      } else {
        // Câu hỏi nhiều đáp án
        // Chỉ cho điểm khi chọn đúng và đủ tất cả các đáp án
        if (userAnswers.length == correctOptionIndices.length &&
            userAnswers.every((answer) => correctOptionIndices.contains(answer)) &&
            correctOptionIndices.every((correct) => userAnswers.contains(correct))) {
          totalPoints += 1;
        }
      }
    }

    double score = (totalPoints / totalQuestions) * 10;

    // Lưu kết quả
    await _db
        .collection("Classes")
        .doc(classId)
        .collection("Exams")
        .doc(examId)
        .collection("Submissions")
        .doc(uid)
        .update({
      'endTime': FieldValue.serverTimestamp(),
      'answers': answers,
      'score': score,
      'status': 'completed',
      'timeSpent': endTime.difference(startTime).inMinutes,
    });

    return score;
  } catch (e) {
    print('Error submitting exam: $e');
    rethrow;
  }
}

  // Kiểm tra trạng thái làm bài
  Future<Map<String, dynamic>?> checkExamStatus(
      String classId, String examId) async {
    try {
      String uid = _auth.currentUser!.uid;

      DocumentSnapshot submissionDoc = await _db
          .collection("Classes")
          .doc(classId)
          .collection("Exams")
          .doc(examId)
          .collection("Submissions")
          .doc(uid)
          .get();

      if (submissionDoc.exists) {
        return {
          'status': submissionDoc.get('status'),
          'score': submissionDoc.get('score'),
        };
      }

      return null;
    } catch (e) {
      print('Error checking exam status: $e');
      return null;
    }
  }
  // Lấy điểm của tất cả học sinh trong một bài thi
  Future<List<Map<String, dynamic>>> getExamScores(String classId, String examId) async {
    try {
      // Lấy danh sách học sinh trong lớp
      QuerySnapshot memberSnapshot = await _db
          .collection("Classes")
          .doc(classId)
          .collection("Members")
          .where('role', isEqualTo: 'member')
          .get();

      List<Map<String, dynamic>> scores = [];
      
      // Lấy thông tin bài nộp của từng học sinh
      for (var memberDoc in memberSnapshot.docs) {
        String studentId = memberDoc.id;
        String studentEmail = memberDoc.get('email');

        DocumentSnapshot submissionDoc = await _db
          .collection("Classes")
          .doc(classId)
          .collection("Exams")
          .doc(examId)
          .collection("Submissions")
          .doc(studentId)
          .get();

        Map<String, dynamic> scoreInfo = {
          'studentId': studentId,
          'email': studentEmail,
          'status': 'not_started',
          'score': null,
          'timeSpent': null,
          'submittedAt': null,
        };

        if (submissionDoc.exists) {
          scoreInfo.update('status', (_) => submissionDoc.get('status'));
          if (submissionDoc.get('status') == 'completed') {
            scoreInfo.update('score', (_) => submissionDoc.get('score'));
            scoreInfo.update('timeSpent', (_) => submissionDoc.get('timeSpent'));
            scoreInfo.update('submittedAt', (_) => submissionDoc.get('endTime'));
          }
        }

        scores.add(scoreInfo);
      }

      return scores;
    } catch (e) {
      print('Error getting exam scores: $e');
      return [];
    }
  }

  // Update user profile information
  Future<void> updateUserProfile({
    required String uid,
    required String name,
    required String phone,
  }) async {
    try {
      await _db.collection("Users").doc(uid).update({
        'name': name,
        'phone': phone,
      });
    } catch (e) {
      print('Error updating profile: $e');
      rethrow;
    }
  }

  // Change user password
  Future<void> changePassword(String newPassword) async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        await user.updatePassword(newPassword);
      } else {
        throw 'No user logged in';
      }
    } catch (e) {
      print('Error changing password: $e');
      rethrow;
    }
  }

  // Delete user account
  Future<void> deleteUserAccount() async {
    try {
      String uid = _auth.currentUser!.uid;
      
      // Delete user data from Firestore
      await _db.collection("Users").doc(uid).delete();
      
      // Delete user authentication account
      await _auth.currentUser!.delete();
    } catch (e) {
      print('Error deleting account: $e');
      rethrow;
    }
  }
  // Add these methods to DatabaseService class

// Delete exam
Future<void> deleteExam(String classId, String examId) async {
  try {
    String uid = _auth.currentUser!.uid;
    
    // Verify teacher permission
    DocumentSnapshot memberDoc = await _db
        .collection("Classes")
        .doc(classId)
        .collection("Members")
        .doc(uid)
        .get();

    if (!memberDoc.exists || memberDoc.get('role') != 'teacher') {
      throw 'Only teachers can delete exams';
    }

    // Delete all questions in the exam
    QuerySnapshot questionsSnapshot = await _db
        .collection("Classes")
        .doc(classId)
        .collection("Exams")
        .doc(examId)
        .collection("Questions")
        .get();

    for (var doc in questionsSnapshot.docs) {
      await doc.reference.delete();
    }

    // Delete exam document
    await _db
        .collection("Classes")
        .doc(classId)
        .collection("Exams")
        .doc(examId)
        .delete();
  } catch (e) {
    print('Error deleting exam: $e');
    rethrow;
  }
}

// Update exam details
Future<void> updateExam({
  required String classId,
  required String examId,
  required String examTitle,
  required String description,
  required DateTime startTime,
  required DateTime endTime,
  required int duration,
}) async {
  try {
    String uid = _auth.currentUser!.uid;
    
    // Verify teacher permission
    DocumentSnapshot memberDoc = await _db
        .collection("Classes")
        .doc(classId)
        .collection("Members")
        .doc(uid)
        .get();

    if (!memberDoc.exists || memberDoc.get('role') != 'teacher') {
      throw 'Only teachers can update exams';
    }

    await _db
        .collection("Classes")
        .doc(classId)
        .collection("Exams")
        .doc(examId)
        .update({
      'title': examTitle,
      'description': description,
      'startTime': startTime,
      'endTime': endTime,
      'duration': duration,
    });
  } catch (e) {
    print('Error updating exam: $e');
    rethrow;
  }
}

// Delete question from exam
Future<void> deleteQuestion(String classId, String examId, String questionId) async {
  try {
    String uid = _auth.currentUser!.uid;
    
    // Verify teacher permission
    DocumentSnapshot memberDoc = await _db
        .collection("Classes")
        .doc(classId)
        .collection("Members")
        .doc(uid)
        .get();

    if (!memberDoc.exists || memberDoc.get('role') != 'teacher') {
      throw 'Only teachers can delete questions';
    }

    await _db
        .collection("Classes")
        .doc(classId)
        .collection("Exams")
        .doc(examId)
        .collection("Questions")
        .doc(questionId)
        .delete();
  } catch (e) {
    print('Error deleting question: $e');
    rethrow;
  }
}

// Update question
Future<void> updateQuestion({
  required String classId,
  required String examId,
  required String questionId,
  required String questionText,
  required List<String> options,
  required List<int> correctOptionIndices,
}) async {
  try {
    String uid = _auth.currentUser!.uid;
    
    // Verify teacher permission
    DocumentSnapshot memberDoc = await _db
        .collection("Classes")
        .doc(classId)
        .collection("Members")
        .doc(uid)
        .get();

    if (!memberDoc.exists || memberDoc.get('role') != 'teacher') {
      throw 'Only teachers can update questions';
    }

    await _db
        .collection("Classes")
        .doc(classId)
        .collection("Exams")
        .doc(examId)
        .collection("Questions")
        .doc(questionId)
        .update({
      'questionText': questionText,
      'options': options,
      'correctOptionIndices': correctOptionIndices,
    });
  } catch (e) {
    print('Error updating question: $e');
    rethrow;
  }
}

// Remove member from class
Future<void> removeMemberFromClass(String classId, String userId) async {
  try {
    String currentUid = _auth.currentUser!.uid;
    
    // Verify teacher permission
    DocumentSnapshot teacherDoc = await _db
        .collection("Classes")
        .doc(classId)
        .collection("Members")
        .doc(currentUid)
        .get();

    if (!teacherDoc.exists || teacherDoc.get('role') != 'teacher') {
      throw 'Only teachers can remove members';
    }

    await _db
        .collection("Classes")
        .doc(classId)
        .collection("Members")
        .doc(userId)
        .delete();
  } catch (e) {
    print('Error removing member: $e');
    rethrow;
  }
}

// Update class details
Future<void> updateClass({
  required String classId,
  required String className,
}) async {
  try {
    String uid = _auth.currentUser!.uid;
    
    // Verify teacher permission
    DocumentSnapshot memberDoc = await _db
        .collection("Classes")
        .doc(classId)
        .collection("Members")
        .doc(uid)
        .get();

    if (!memberDoc.exists || memberDoc.get('role') != 'teacher') {
      throw 'Only teachers can update class details';
    }

    await _db.collection("Classes").doc(classId).update({
      'className': className,
    });
  } catch (e) {
    print('Error updating class: $e');
    rethrow;
  }
}

// Delete class
Future<void> deleteClass(String classId) async {
  try {
    String uid = _auth.currentUser!.uid;
    
    // Verify teacher permission
    DocumentSnapshot memberDoc = await _db
        .collection("Classes")
        .doc(classId)
        .collection("Members")
        .doc(uid)
        .get();

    if (!memberDoc.exists || memberDoc.get('role') != 'teacher') {
      throw 'Only teachers can delete classes';
    }

    // Delete all members
    QuerySnapshot membersSnapshot = await _db
        .collection("Classes")
        .doc(classId)
        .collection("Members")
        .get();
    for (var doc in membersSnapshot.docs) {
      await doc.reference.delete();
    }

    // Delete all exams and their questions
    QuerySnapshot examsSnapshot = await _db
        .collection("Classes")
        .doc(classId)
        .collection("Exams")
        .get();
    for (var examDoc in examsSnapshot.docs) {
      // Delete questions for each exam
      QuerySnapshot questionsSnapshot = await examDoc.reference
          .collection("Questions")
          .get();
      for (var questionDoc in questionsSnapshot.docs) {
        await questionDoc.reference.delete();
      }
      await examDoc.reference.delete();
    }

    // Finally delete the class
    await _db.collection("Classes").doc(classId).delete();
  } catch (e) {
    print('Error deleting class: $e');
    rethrow;
  }
}
}
  

