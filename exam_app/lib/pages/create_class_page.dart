import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; 

class CreateClassPage extends StatefulWidget {
  @override
  _CreateClassPageState createState() => _CreateClassPageState();
}

class _CreateClassPageState extends State<CreateClassPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _maLopController = TextEditingController();
  final TextEditingController _tenLopController = TextEditingController();
  DateTime _ngayTao = DateTime.now(); 

  Future<void> _chonNgay(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _ngayTao,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _ngayTao)
      setState(() {
        _ngayTao = picked;
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF5268B6),
      appBar: AppBar(
        title: const Text(
            "CREATE CLASS",
            style: TextStyle(
              color: Color(0xFF5268B6),
              fontWeight: FontWeight.bold,
              fontSize: 24,
            )
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextFormField(
                controller: _maLopController,
                decoration: InputDecoration(
                  hintText: 'Class Code', 
                  filled: true, 
                  fillColor: Colors.white, 
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black, width: 2.0), 
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter Class Code';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _tenLopController,
                decoration: InputDecoration(
                  hintText: 'Class Name',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black), 
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black, width: 2.0),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter Class Name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Text(
                    'Day: ${DateFormat('yyyy-MM-dd').format(_ngayTao)}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 19, 
                    ),
                  ),
                  Spacer(),
                  IconButton(
                    icon: Icon(Icons.calendar_today, color: Colors.white),
                    onPressed: () => _chonNgay(context),
                  ),
                ],
              ),
              SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                ),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    String maLop = _maLopController.text;
                    String tenLop = _tenLopController.text;
                    String ngayTao = DateFormat('yyyy-MM-dd').format(_ngayTao);

                    print('Class Code: $maLop');
                    print('Class Name: $tenLop');
                    print('Day: $ngayTao');
                  }
                },
                child: Text(
                  'Create Class',
                  style: TextStyle(
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
