import 'package:flutter/material.dart';
import 'class_page.dart';
class GoToClassPage extends StatefulWidget {
  @override
  _GoToClassPageState createState() => _GoToClassPageState();
}

class _GoToClassPageState extends State<GoToClassPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, String>> _classes = [
    {'code': 'CL01', 'name': 'DoAnPhanMem'},
    {'code': 'CL02', 'name': 'MayHoc'},
    {'code': 'CL03', 'name': 'THiGiacMayTinh'},
  ];

  List<Map<String, String>> _filteredClasses = [];

  @override
  void initState() {
    super.initState();
    _filteredClasses = _classes;
  }

  void _filterClasses(String query) {
    final results = _classes.where((classData) {
      final classCode = classData['code']!.toLowerCase();
      final className = classData['name']!.toLowerCase();
      final searchLower = query.toLowerCase();

      return classCode.contains(searchLower) || className.contains(searchLower);
    }).toList();

    setState(() {
      _filteredClasses = results;
    });
  }

  void _showConfirmationDialog(String className, String classCode) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Xác nhận'),
          content: Text('Bạn có muốn vào lớp $className không?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Đóng hộp thoại
              },
              child: Text('Hủy'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Đóng hộp thoại

                // Điều hướng sang ClassPage
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ClassPage(
                      className: className,
                      classCode: classCode,
                    ),
                  ),
                );
              },
              child: Text('Xác nhận'),
            ),
          ],
        );
      },
    );
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF5268B6),
        title: const Text(
          "CLASS",
          style: TextStyle(
            color: Color.fromARGB(255, 255, 255, 255),
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search for class code or class name',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black, width: 2.0),
                ),
              ),
              onChanged: (value) {
                _filterClasses(value);
              },
            ),
            SizedBox(height: 20),
            Expanded(
              child: _filteredClasses.isNotEmpty
                  ? ListView.builder(
                      itemCount: _filteredClasses.length,
                      itemBuilder: (context, index) {
                        final classData = _filteredClasses[index];
                        return ListTile(
                          title: Text(classData['name']!),
                          subtitle: Text('Class Code: ${classData['code']}'),
                          onTap: () {
                            _showConfirmationDialog(classData['name']!, classData['code']!);
                          },
                        );
                      },
                    )
                  : Center(child: Text('No classes found')),
            ),
          ],
        ),
      ),
    );
  }
}

