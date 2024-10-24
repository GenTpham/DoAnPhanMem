import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:exam_app/services/database/database_provider.dart';

class JoinClassScreen extends StatelessWidget {
  final TextEditingController _classCodeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final databaseProvider =
        Provider.of<DatabaseProvider>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: Text('Tham Gia Lớp'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _classCodeController,
              decoration: InputDecoration(labelText: 'Mã Lớp'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                String classCode = _classCodeController.text.trim();

                if (classCode.isNotEmpty) {
                  try {
                    await databaseProvider.joinClassWithCode(classCode);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Tham gia lớp thành công')),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Lỗi: ${e.toString()}')),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Vui lòng nhập mã lớp')),
                  );
                }
              },
              child: Text('Tham Gia Lớp'),
            ),
          ],
        ),
      ),
    );
  }
}
