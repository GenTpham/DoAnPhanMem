import 'package:exam_app/models/user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:exam_app/services/database/database_provider.dart';
import 'package:exam_app/services/auth/auth_service.dart';
import 'package:exam_app/components/my_button.dart';

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
  late final DatabaseProvider databaseProvider =
      Provider.of<DatabaseProvider>(context, listen: false);
  UserProfile? user;
  String currentUserId = AuthService().getCurrentUid();
  bool _isLoading = true;
  
  // Controllers for edit profile
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _passwordController;
  late TextEditingController _confirmPasswordController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _phoneController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
    loadUser();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> loadUser() async {
    user = await databaseProvider.userProfile(widget.uid);
    if (user != null) {
      _nameController.text = user!.name;
      _phoneController.text = user!.phone;
    }
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _showEditProfileDialog() async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Profile'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Phone'),
                keyboardType: TextInputType.phone,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              try {
                await databaseProvider.updateProfile(
                  uid: widget.uid,
                  name: _nameController.text,
                  phone: _phoneController.text,
                );
                Navigator.pop(context);
                loadUser(); // Reload user data
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Profile updated successfully')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error updating profile: $e')),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _showChangePasswordDialog() async {
    _passwordController.clear();
    _confirmPasswordController.clear();
    
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Password'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'New Password'),
                obscureText: true,
              ),
              TextField(
                controller: _confirmPasswordController,
                decoration: const InputDecoration(labelText: 'Confirm Password'),
                obscureText: true,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (_passwordController.text != _confirmPasswordController.text) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Passwords do not match')),
                );
                return;
              }
              try {
                await databaseProvider.changePassword(_passwordController.text);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Password changed successfully')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error changing password: $e')),
                );
              }
            },
            child: const Text('Change'),
          ),
        ],
      ),
    );
  }

  Future<void> _showDeleteAccountDialog() async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'Are you sure you want to delete your account? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              try {
                await databaseProvider.deleteAccount();
                Navigator.pop(context);
                // Navigate to login page
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/login',
                  (route) => false,
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error deleting account: $e')),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF5268B6),
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
                  color: Colors.white,
                ),
                const SizedBox(height: 20),
                Text(
                  _isLoading ? '' : '${user!.name}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  _isLoading ? '' : user!.phone,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
                MyButton(
                  text: "Edit Profile",
                  onTap: _showEditProfileDialog,
                ),
                const SizedBox(height: 20),
                MyButton(
                  text: "Change Password",
                  onTap: _showChangePasswordDialog,
                ),
                const SizedBox(height: 20),
                MyButton(
                  text: "Delete Account",
                  onTap: _showDeleteAccountDialog,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}