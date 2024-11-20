import 'package:exam_app/pages/class_detail.dart';
import 'package:exam_app/services/database/database_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class JoinedClassesPage extends StatefulWidget {
  const JoinedClassesPage({super.key});

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
        title: const Text("Danh sách lớp đã tham gia",
            style: TextStyle(
              color: Color(0xFF133E87),
              fontWeight: FontWeight.bold,
              fontSize: 24,
            )),
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: Consumer<DatabaseProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Lỗi: ${provider.error}'),
                  ElevatedButton(
                    onPressed: () => provider.fetchJoinedClasses(),
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            );
          }

          if (provider.joinedClasses.isEmpty) {
            return const Center(child: Text('Bạn chưa tham gia lớp nào'));
          }

          return ListView.builder(
            itemCount: provider.joinedClasses.length,
            itemBuilder: (context, index) {
              final classInfo = provider.joinedClasses[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8), 
                  side: const BorderSide(
                    color: Colors.black,
                    width: 1, 
                  ),
                ),
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
