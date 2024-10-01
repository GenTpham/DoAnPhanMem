import 'package:exam_app/components/my_button.dart';
import 'package:exam_app/models/user.dart';
import 'package:exam_app/services/auth/auth_service.dart';
import 'package:exam_app/services/database/database_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatefulWidget {
  final String uid;
  const ProfilePage({
    super.key,
    required this.uid,
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // late final listeningProvider = Provider.of<DatabaseProvider>(context);
  late final databaseProvier =
      Provider.of<DatabaseProvider>(context, listen: false);
  UserProfile? user;
  String currentUserId = AuthService().getCurrentUid();
  bool _isLoading = true;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadUser();
  }

  Future<void> loadUser() async {
    user = await databaseProvier.userProfile(widget.uid);
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(_isLoading ? '' : user!.email),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.person,
                  size: 100,
                ),
                const SizedBox(
                  height: 20,
                ),
                Text(
                  _isLoading ? '' : '${user!.name}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Text(
                  _isLoading ? '' : user!.phone,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                MyButton(
                  text: "Edit Profile",
                  onTap: () {},
                ),
                const SizedBox(
                  height: 20,
                ),
                MyButton(
                  text: "Change Password",
                  onTap: () {},
                ),
                const SizedBox(
                  height: 20,
                ),
                MyButton(
                  text: "Grade",
                  onTap: () {},
                ),
                const SizedBox(
                  height: 20,
                ),
                MyButton(
                  text: "Delete Account",
                  onTap: () {},
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
