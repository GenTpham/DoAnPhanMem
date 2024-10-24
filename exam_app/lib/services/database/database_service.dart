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
}
