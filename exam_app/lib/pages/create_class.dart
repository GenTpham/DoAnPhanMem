import 'package:exam_app/services/database/database_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

class CreateClassScreen extends StatelessWidget {
  final TextEditingController _classNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  CreateClassScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final databaseProvider =
        Provider.of<DatabaseProvider>(context, listen: false);

    return Scaffold(
      backgroundColor: const Color(0xFF3572EF),
      appBar: AppBar(
        title: const Text("Tạo Lớp Học",
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
              controller: _classNameController,
              style: const TextStyle(color: Colors.black),
              decoration: InputDecoration(
                labelText: 'Tên Lớp',
                labelStyle: const TextStyle(color: Colors.black), 
                filled: true, 
                fillColor: Colors.white,
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.white, width: 2.0),
                  borderRadius: BorderRadius.circular(10), 
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.white, width: 3.0),
                  borderRadius: BorderRadius.circular(10), 
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                String className = _classNameController.text;
                if (className.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Vui lòng nhập tên lớp'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }
                
                try {
                  await databaseProvider.createClass(className);
                  // Xóa text trong controller
                  _classNameController.clear();
                  
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Tạo lớp "$className" thành công'),
                        backgroundColor: Colors.green,
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Có lỗi xảy ra: ${e.toString()}'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white, 
                elevation: 0, 
                side: const BorderSide(color: Colors.white, width: 2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10), 
                ),
              ),
              child: const Text(
                'Tạo Lớp',
                style: TextStyle(color: Colors.black),
               ),
            ),
          ],
        ),
      ),
    );
  }
}