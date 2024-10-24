import 'package:exam_app/services/database/database_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ClassDetailPage extends StatefulWidget {
  final Map<String, dynamic> classInfo;

  ClassDetailPage({required this.classInfo});

  @override
  _ClassDetailPageState createState() => _ClassDetailPageState();
}

class _ClassDetailPageState extends State<ClassDetailPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context
          .read<DatabaseProvider>()
          .fetchClassMembers(widget.classInfo['classId']);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chi tiết lớp học'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thông tin lớp học
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Thông tin lớp học',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      SizedBox(height: 8),
                      Text('Tên lớp: ${widget.classInfo['className']}'),
                      Text('Mã lớp: ${widget.classInfo['classId']}'),
                      Text(
                          'Ngày tạo: ${widget.classInfo['createdAt']?.toDate().toString() ?? 'N/A'}'),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Danh sách thành viên',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              SizedBox(height: 8),
              Consumer<DatabaseProvider>(
                builder: (context, provider, child) {
                  if (provider.isLoading) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (provider.error != null) {
                    return Center(
                      child: Column(
                        children: [
                          Text('Lỗi: ${provider.error}'),
                          ElevatedButton(
                            onPressed: () => provider.fetchClassMembers(
                                widget.classInfo['classId']),
                            child: Text('Thử lại'),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: provider.classMembers.length,
                    itemBuilder: (context, index) {
                      final member = provider.classMembers[index];
                      return Card(
                        child: ListTile(
                          leading: CircleAvatar(
                            child: Icon(
                              member['role'] == 'teacher'
                                  ? Icons.school
                                  : Icons.person,
                            ),
                          ),
                          title: Text(member['email']),
                          subtitle: Text(
                            member['role'] == 'teacher' ? 'Giáo viên' : 'Học sinh',
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
