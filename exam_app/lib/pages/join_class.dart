import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:exam_app/services/database/database_provider.dart';

class JoinClassScreen extends StatelessWidget {
  final TextEditingController _classCodeController = TextEditingController();

  JoinClassScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final databaseProvider =
        Provider.of<DatabaseProvider>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tham Gia Lớp",
            style: TextStyle(
              color: Color(0xFF133E87),
              fontWeight: FontWeight.bold,
              fontSize: 24,
            )),
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _classCodeController,
              decoration: InputDecoration(
                labelText: 'Tên Lớp',
                labelStyle: const TextStyle(color: Colors.black), 
                filled: true, 
                fillColor: Colors.white,
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.black, width: 2.0),
                  borderRadius: BorderRadius.circular(10), 
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.black, width: 3.0),
                  borderRadius: BorderRadius.circular(10), 
                ),
              ),            
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                String classCode = _classCodeController.text.trim();

                if (classCode.isNotEmpty) {
                  try {
                    await databaseProvider.joinClassWithCode(classCode);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Tham gia lớp thành công')),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Lỗi: ${e.toString()}')),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Vui lòng nhập mã lớp')),
                  );
                }
              },
               style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white, 
                elevation: 0, 
                side: const BorderSide(color: Colors.black, width: 2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Tham Gia Lớp',
                style: TextStyle(color: Colors.black),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
