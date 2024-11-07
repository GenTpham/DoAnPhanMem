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
      throw e;
    }
  }

  // Nộp bài thi
  Future<double> submitExam({
    required String classId,
    required String examId,
    required Map<String, int> answers,
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

      int correctAnswers = 0;
      int totalQuestions = questionSnapshot.docs.length;

      // Tính điểm
      for (var doc in questionSnapshot.docs) {
        String questionId = doc.id;
        List<int> correctOptionIndices =
            List.from(doc.get('correctOptionIndices'));

        if (answers[questionId] != null &&
            correctOptionIndices.contains(answers[questionId]!)) {
          correctAnswers++;
        }
      }

      double score = (correctAnswers / totalQuestions) * 10;

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
      throw e;
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

  
}
