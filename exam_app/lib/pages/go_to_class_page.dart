import 'package:flutter/material.dart';

class GoToClassPage extends StatefulWidget {
  @override
  _GoToClassPageState createState() => _GoToClassPageState();
}

class _GoToClassPageState extends State<GoToClassPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, String>> _classes = [
    {'code': 'CS101', 'name': 'Computer Science 101'},
    {'code': 'MATH202', 'name': 'Advanced Mathematics'},
    {'code': 'PHY303', 'name': 'Physics III'},
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

  void _showConfirmationDialog(String className) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm'),
          content: Text('You want go to class $className?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); 
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); 
               
                print('Successfully entered class: $className');
                
              },
              child: Text('Confirm'),
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
        title: Text("Class"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search for class code or class name',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
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
                            _showConfirmationDialog(classData['name']!);
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
