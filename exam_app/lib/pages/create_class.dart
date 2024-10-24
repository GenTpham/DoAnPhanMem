import 'package:exam_app/services/database/database_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

class CreateClassScreen extends StatelessWidget {
  final TextEditingController _classNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final databaseProvider =
        Provider.of<DatabaseProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text('Tạo Lớp Học'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _classNameController,
              decoration: InputDecoration(labelText: 'Tên Lớp'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                String className = _classNameController.text;
                databaseProvider.createClass(className);
              },
              child: Text('Tạo Lớp'),
            ),
          ],
        ),
      ),
    );
  }
}
