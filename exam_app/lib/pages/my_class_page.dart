import 'package:exam_app/pages/class_detail.dart';
import 'package:exam_app/services/database/database_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class JoinedClassesPage extends StatefulWidget {
  @override
  _JoinedClassesPageState createState() => _JoinedClassesPageState();
}

class _JoinedClassesPageState extends State<JoinedClassesPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DatabaseProvider>().fetchJoinedClasses();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Danh sách lớp đã tham gia'),
      ),
      body: Consumer<DatabaseProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Lỗi: ${provider.error}'),
                  ElevatedButton(
                    onPressed: () => provider.fetchJoinedClasses(),
                    child: Text('Thử lại'),
                  ),
                ],
              ),
            );
          }

          if (provider.joinedClasses.isEmpty) {
            return Center(child: Text('Bạn chưa tham gia lớp nào'));
          }

          return ListView.builder(
            itemCount: provider.joinedClasses.length,
            itemBuilder: (context, index) {
              final classInfo = provider.joinedClasses[index];
              return Card(
                margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: ListTile(
                  title: Text(classInfo['className']),
                  subtitle: Text('Mã lớp: ${classInfo['classId']}'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ClassDetailPage(
                          classInfo: classInfo,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
