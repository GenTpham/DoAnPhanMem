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
      appBar: AppBar(
        title: Text('Create Class'),
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
                decoration: InputDecoration(labelText: 'Class Code'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter Class Code';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _tenLopController,
                decoration: InputDecoration(labelText: 'Class Name'),
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
                  ),
                  Spacer(),
                  IconButton(
                    icon: Icon(Icons.calendar_today),
                    onPressed: () => _chonNgay(context),
                  ),
                ],
              ),
              SizedBox(height: 16),
              ElevatedButton(
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
                child: Text('Create Class'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
