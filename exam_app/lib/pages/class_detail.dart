import 'package:exam_app/pages/take_exam_page.dart';
import 'package:exam_app/services/database/database_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ClassDetailPage extends StatefulWidget {
  final Map<String, dynamic> classInfo;

  const ClassDetailPage({super.key, required this.classInfo});

  @override
  _ClassDetailPageState createState() => _ClassDetailPageState();
}

class _ClassDetailPageState extends State<ClassDetailPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();
  final _memberFormKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  // Controllers for exam creation
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime _startTime = DateTime.now();
  DateTime _endTime = DateTime.now().add(const Duration(hours: 2));
  final _durationController = TextEditingController(text: '120');

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DatabaseProvider>()
        ..fetchClassMembers(widget.classInfo['classId'])
        ..fetchClassExams(widget.classInfo['classId']);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _durationController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _showCreateExamDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tạo bài thi mới'),
        content: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: 'Tên bài thi'),
                  validator: (value) => value?.isEmpty ?? true
                      ? 'Vui lòng nhập tên bài thi'
                      : null,
                ),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(labelText: 'Mô tả'),
                  maxLines: 2,
                ),
                ListTile(
                  title: const Text('Thời gian bắt đầu'),
                  subtitle: Text(_startTime.toString()),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final date = await showDateTimePicker(context, _startTime);
                    if (date != null) {
                      setState(() => _startTime = date);
                    }
                  },
                ),
                ListTile(
                  title: const Text('Thời gian kết thúc'),
                  subtitle: Text(_endTime.toString()),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final date = await showDateTimePicker(context, _endTime);
                    if (date != null) {
                      setState(() => _endTime = date);
                    }
                  },
                ),
                TextFormField(
                  controller: _durationController,
                  decoration: const InputDecoration(
                    labelText: 'Thời gian làm bài (phút)',
                    suffix: Text('phút'),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Vui lòng nhập thời gian';
                    }
                    if (int.tryParse(value!) == null) return 'Phải là số';
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_formKey.currentState?.validate() ?? false) {
                final provider = context.read<DatabaseProvider>();
                final examId = await provider.createExam(
                  classId: widget.classInfo['classId'],
                  examTitle: _titleController.text,
                  description: _descriptionController.text,
                  startTime: _startTime,
                  endTime: _endTime,
                  duration: int.parse(_durationController.text),
                );

                if (examId != null) {
                  Navigator.pop(context);
                  _titleController.clear();
                  _descriptionController.clear();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Đã tạo bài thi thành công')),
                  );
                }
              }
            },
            child: const Text('Tạo'),
          ),
        ],
      ),
    );
  }

  void _showAddMemberDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Thêm thành viên'),
        content: Form(
          key: _memberFormKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  hintText: 'Nhập email của thành viên',
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập email';
                  }
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                      .hasMatch(value)) {
                    return 'Email không hợp lệ';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _emailController.clear();
            },
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_memberFormKey.currentState?.validate() ?? false) {
                try {
                  await context.read<DatabaseProvider>().addMemberToClass(
                        widget.classInfo['classId'],
                        _emailController.text,
                      );

                  Navigator.pop(context);
                  _emailController.clear();

                  // Refresh member list
                  context
                      .read<DatabaseProvider>()
                      .fetchClassMembers(widget.classInfo['classId']);

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Đã thêm thành viên thành công')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content:
                            Text('Không thể thêm thành viên: ${e.toString()}')),
                  );
                }
              }
            },
            child: const Text('Thêm'),
          ),
        ],
      ),
    );
  }

  void _showAddQuestionDialog(BuildContext context, String examId) {
    final questionController = TextEditingController();
    final optionControllers = List.generate(4, (_) => TextEditingController());
    List<int> selectedCorrectOptions = [];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Thêm câu hỏi'),
          content: SingleChildScrollView(
            child: Form(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: questionController,
                    decoration: const InputDecoration(labelText: 'Câu hỏi'),
                    maxLines: 2,
                  ),
                  ...List.generate(4, (index) {
                    return Row(
                      children: [
                        Checkbox(
                          value: selectedCorrectOptions.contains(index),
                          onChanged: (bool? value) {
                            setState(() {
                              if (value == true) {
                                selectedCorrectOptions.add(index);
                              } else {
                                selectedCorrectOptions.remove(index);
                              }
                            });
                          },
                        ),
                        Expanded(
                          child: TextFormField(
                            controller: optionControllers[index],
                            decoration: InputDecoration(
                              labelText: 'Đáp án ${index + 1}',
                            ),
                          ),
                        ),
                      ],
                    );
                  }),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () async {
                final options = optionControllers
                    .map((controller) => controller.text)
                    .toList();

                await context.read<DatabaseProvider>().addQuestionToExam(
                      classId: widget.classInfo['classId'],
                      examId: examId,
                      questionText: questionController.text,
                      options: options,
                      correctOptionIndices: selectedCorrectOptions,
                    );

                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Đã thêm câu hỏi thành công')),
                );
              },
              child: const Text('Thêm'),
            ),
          ],
        ),
      ),
    );
  }

  void _showScoresDialog(
      BuildContext context, String examId, String examTitle) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Điểm bài thi: $examTitle'),
        content: SizedBox(
          width: double.maxFinite,
          child: Consumer<DatabaseProvider>(
            builder: (context, provider, child) {
              if (provider.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              return SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: SingleChildScrollView(
                  // Thêm scroll ngang
                  scrollDirection: Axis.horizontal,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DataTable(
                        columnSpacing: 20, // Giảm khoảng cách giữa các cột
                        columns: const [
                          DataColumn(label: Text('Email')),
                          DataColumn(label: Text('Điểm')),
                          DataColumn(label: Text('Thời gian')),
                          DataColumn(label: Text('Trạng thái')),
                        ],
                        rows: provider.examScores.map((score) {
                          String status = '';
                          switch (score['status']) {
                            case 'completed':
                              status = 'Đã nộp';
                              break;
                            case 'in_progress':
                              status = 'Đang làm';
                              break;
                            case 'not_started':
                              status = 'Chưa làm';
                              break;
                          }

                          return DataRow(cells: [
                            DataCell(Text(score['email'])),
                            DataCell(Text(
                                score['score']?.toStringAsFixed(1) ?? '-')),
                            DataCell(
                                Text(score['timeSpent']?.toString() ?? '-')),
                            DataCell(Text(status)),
                          ]);
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF3572EF),
      appBar: AppBar(
        title: const Text('Chi tiết lớp học',
        style: TextStyle(
              color: Color(0xFF133E87),
              fontWeight: FontWeight.bold,
              fontSize: 24,
        )),
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.black,
          indicatorColor: Colors.black, 
          tabs: const [
            Tab(text: 'Thành viên'),
            Tab(text: 'Bài thi'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildMembersTab(),
          _buildExamsTab(),
        ],
      ),
      floatingActionButton: Consumer<DatabaseProvider>(
        builder: (context, provider, child) {
          final currentUserRole = provider.classMembers.firstWhere(
            (member) => member['email'] == provider.currentUser?.email,
            orElse: () => {'role': 'member'},
          )['role'];

          if (currentUserRole == 'teacher') {
            return FloatingActionButton(
              onPressed: () => _tabController.index == 0
                  ? _showAddMemberDialog(context) // Handle member management
                  : _showCreateExamDialog(context),
              child: const Icon(Icons.add),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildMembersTab() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8), 
              side: const BorderSide(
                color: Colors.black,
                width: 1.5, 
              ),
            ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Thông tin lớp học',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text('Tên lớp: ${widget.classInfo['className']}'),
                    Text('Mã lớp: ${widget.classInfo['classId']}'),
                    Text(
                      'Ngày tạo: ${widget.classInfo['createdAt']?.toDate().toString() ?? 'N/A'}',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Consumer<DatabaseProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: provider.classMembers.length,
                  itemBuilder: (context, index) {
                    final member = provider.classMembers[index];
                    return Card(
                      shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8), 
                      side: const BorderSide(
                        color: Colors.black, 
                        width: 1.5, 
                      ),
                    ),
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
                          member['role'] == 'teacher'
                              ? 'Giáo viên'
                              : 'Học sinh',
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
    );
  }

  Widget _buildExamsTab() {
    return Consumer<DatabaseProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: provider.classExams.length,
          itemBuilder: (context, index) {
            final exam = provider.classExams[index];
            return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8), 
                  side: const BorderSide(
                  color: Colors.black, 
                  width: 1.5, 
                ),
              ),
              child: ExpansionTile(
                title: Text(exam['title']),
                subtitle: Text(exam['description'] ?? ''),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            'Thời gian bắt đầu: ${exam['startTime'].toDate()}'),
                        Text('Thời gian kết thúc: ${exam['endTime'].toDate()}'),
                        Text('Thời gian làm bài: ${exam['duration']} phút'),
                        const SizedBox(height: 8),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              if (provider.isTeacher) ...[
                                TextButton(
                                  onPressed: () => _showAddQuestionDialog(
                                      context, exam['examId']),
                                  child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Color.fromARGB(255, 0, 0, 0), 
                                      width: 2, 
                                    ),
                                    borderRadius: BorderRadius.circular(8), 
                                  ),
                                  child: const Text(
                                    'Thêm câu hỏi',
                                    style: TextStyle(
                                      color: Color(0xFF3572EF), 
                                      fontWeight: FontWeight.bold, 
                                    ),
                                  ),
                                ),
                                ),
                                const SizedBox(
                                    width: 8), // Thêm khoảng cách giữa các nút
                                TextButton(
                                  onPressed: () {
                                    provider.publishExam(
                                      widget.classInfo['classId'],
                                      exam['examId'],
                                    );
                                  },
                                  child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Color.fromARGB(255, 0, 0, 0), 
                                      width: 2, 
                                    ),
                                    borderRadius: BorderRadius.circular(8), 
                                  ),
                                  child: const Text(
                                    'Xuất bản',
                                    style: TextStyle(
                                      color: Color(0xFF3572EF), 
                                      fontWeight: FontWeight.bold, 
                                    ),
                                  ),
                                ),
                                ),
                                const SizedBox(width: 8),
                                TextButton(
                                  onPressed: () {
                                    provider.fetchExamScores(
                                      widget.classInfo['classId'],
                                      exam['examId'],
                                    );
                                    _showScoresDialog(
                                      context,
                                      exam['examId'],
                                      exam['title'],
                                    );
                                  },
                                  child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Color.fromARGB(255, 0, 0, 0), 
                                      width: 2, 
                                    ),
                                    borderRadius: BorderRadius.circular(8), 
                                  ),
                                  child: const Text(
                                    'Xem điểm',
                                    style: TextStyle(
                                      color: Color(0xFF3572EF), 
                                      fontWeight: FontWeight.bold, 
                                    ),
                                  ),
                                ),
                                ),
                                const SizedBox(width: 8),
                              ],
                              TextButton(
                                onPressed: () async {
                                  final provider =
                                      context.read<DatabaseProvider>();
                                  final examStatus =
                                      await provider.checkExamStatus(
                                    widget.classInfo['classId'],
                                    exam['examId'],
                                  );

                                  if (examStatus != null &&
                                      examStatus['status'] == 'completed') {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                            'Bạn đã hoàn thành bài thi này với điểm: ${examStatus['score']}'),
                                      ),
                                    );
                                    return;
                                  }

                                  if (!exam['isPublished'] &&
                                      !provider.isTeacher) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content:
                                            Text('Bài thi chưa được xuất bản'),
                                      ),
                                    );
                                    return;
                                  }

                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => TakeExamPage(
                                        classId: widget.classInfo['classId'],
                                        examId: exam['examId'],
                                        examInfo: exam,
                                      ),
                                    ),
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Color.fromARGB(255, 0, 0, 0), 
                                      width: 2, 
                                    ),
                                    borderRadius: BorderRadius.circular(8), 
                                  ),
                                  child: const Text(
                                    'Chi tiết',
                                    style: TextStyle(
                                      color: Color(0xFF3572EF), 
                                      fontWeight: FontWeight.bold, 
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

Future<DateTime?> showDateTimePicker(
    BuildContext context, DateTime initialDate) async {
  final date = await showDatePicker(
    context: context,
    initialDate: initialDate,
    firstDate: DateTime.now(),
    lastDate: DateTime.now().add(const Duration(days: 365)),
  );
  if (date == null) return null;

  final time = await showTimePicker(
    context: context,
    initialTime: TimeOfDay.fromDateTime(initialDate),
  );
  if (time == null) return null;

  return DateTime(
    date.year,
    date.month,
    date.day,
    time.hour,
    time.minute,
  );
}
