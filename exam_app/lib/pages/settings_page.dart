import 'package:exam_app/components/my_settings_tile.dart';
import 'package:exam_app/services/auth/auth_service.dart';
import 'package:exam_app/services/database/database_provider.dart';
import 'package:exam_app/themes/theme_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  // auth service
  final _auth = AuthService();

  void logout() {
    _auth.logout();
  }

  // Settings state
  double _fontSize = 14;
  String _selectedLanguage = 'English';
  bool _notificationsEnabled = true;
  bool _emailNotificationsEnabled = true;

  final List<String> _languages = [
    'English',
    'Vietnamese',
    'Spanish',
    'French',
    'German'
  ];

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final provider = Provider.of<DatabaseProvider>(context, listen: false);
    final userProfile = await provider.userProfile(provider.currentUser!.uid);
    if (userProfile != null) {
      setState(() {
        _nameController.text = userProfile.name;
        _phoneController.text = userProfile.phone;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Profile Dialog
  void _showProfileDialog(BuildContext context, DatabaseProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Profile Info'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: const Icon(Icons.person),
              title: Text(_nameController.text),
              subtitle: const Text('Name'),
            ),
            ListTile(
              leading: const Icon(Icons.email),
              title: Text(provider.currentUser?.email ?? ''),
              subtitle: const Text('Email'),
            ),
            ListTile(
              leading: const Icon(Icons.phone),
              title: Text(_phoneController.text),
              subtitle: const Text('Phone'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  // Edit Profile Dialog
  void _showEditProfileDialog(BuildContext context, DatabaseProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Profile'),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Phone'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your phone number';
                  }
                  return null;
                },
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
              if (_formKey.currentState!.validate()) {
                try {
                  await provider.updateProfile(
                    uid: provider.currentUser!.uid,
                    name: _nameController.text,
                    phone: _phoneController.text,
                  );
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Profile updated successfully')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: ${e.toString()}')),
                  );
                }
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  // Change Password Dialog
  void _showChangePasswordDialog(
      BuildContext context, DatabaseProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Password'),
        content: Form(
          key: _formKey,
          child: TextFormField(
            controller: _passwordController,
            decoration: const InputDecoration(labelText: 'New Password'),
            obscureText: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter new password';
              }
              if (value.length < 6) {
                return 'Password must be at least 6 characters';
              }
              return null;
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                try {
                  await provider.changePassword(_passwordController.text);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Password changed successfully')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: ${e.toString()}')),
                  );
                }
              }
            },
            child: const Text('Change'),
          ),
        ],
      ),
    );
  }

  // Delete Account Dialog
  void _showDeleteAccountDialog(
      BuildContext context, DatabaseProvider provider) {
    showDialog(
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
                await provider.deleteAccount();
                Navigator.pop(context);
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/login',
                  (route) => false,
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: ${e.toString()}')),
                );
              }
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  // Font Size Dialog
  void _showFontSizeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Font Size'),
        content: StatefulBuilder(
          builder: (context, setState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Sample Text', style: TextStyle(fontSize: _fontSize)),
              Slider(
                value: _fontSize,
                min: 12,
                max: 24,
                divisions: 12,
                label: _fontSize.round().toString(),
                onChanged: (value) {
                  setState(() {
                    _fontSize = value;
                  });
                },
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
            onPressed: () {
              // TODO: Save font size preference
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  // Language Dialog
  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Language'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _languages.length,
            itemBuilder: (context, index) {
              final language = _languages[index];
              return RadioListTile<String>(
                title: Text(language),
                value: language,
                groupValue: _selectedLanguage,
                onChanged: (value) {
                  setState(() {
                    _selectedLanguage = value!;
                  });
                  // TODO: Implement language change
                  Navigator.pop(context);
                },
              );
            },
          ),
        ),
      ),
    );
  }

  // Notifications Dialog
  void _showNotificationsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Notification Settings'),
        content: StatefulBuilder(
          builder: (context, setState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SwitchListTile(
                title: const Text('Push Notifications'),
                value: _notificationsEnabled,
                onChanged: (value) {
                  setState(() {
                    _notificationsEnabled = value;
                  });
                },
              ),
              SwitchListTile(
                title: const Text('Email Notifications'),
                value: _emailNotificationsEnabled,
                onChanged: (value) {
                  setState(() {
                    _emailNotificationsEnabled = value;
                  });
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  // About Dialog
  Future<void> _showAboutDialog(BuildContext context) async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (context) => AboutDialog(
            applicationName: 'Exam App',
            applicationVersion: packageInfo.version,
            applicationIcon: const FlutterLogo(size: 50),
            children: [
              const Text('An online examination platform'),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () async {
                  try {
                    final Uri url =
                        Uri.parse('https://your-privacy-policy-url.com');
                    if (!await launchUrl(
                      url,
                      mode: LaunchMode.externalApplication,
                    )) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Could not open Privacy Policy'),
                          ),
                        );
                      }
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error: ${e.toString()}'),
                        ),
                      );
                    }
                  }
                },
                child: const Text('Privacy Policy'),
              ),
              TextButton(
                onPressed: () async {
                  try {
                    final Uri url = Uri.parse('https://your-terms-url.com');
                    if (!await launchUrl(
                      url,
                      mode: LaunchMode.externalApplication,
                    )) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Could not open Terms of Service'),
                          ),
                        );
                      }
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error: ${e.toString()}'),
                        ),
                      );
                    }
                  }
                },
                child: const Text('Terms of Service'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading app info: ${e.toString()}'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text("S E T T I N G S"),
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: Consumer<DatabaseProvider>(
        builder: (context, provider, child) {
          return ListView(
            children: [
              const SizedBox(height: 20),

              // Account Section
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  'Account',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              MySettingsTile(
                tile: "View Profile",
                action: IconButton(
                  icon: const Icon(Icons.person),
                  onPressed: () => _showProfileDialog(context, provider),
                ),
              ),
              MySettingsTile(
                tile: "Edit Profile",
                action: IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _showEditProfileDialog(context, provider),
                ),
              ),
              MySettingsTile(
                tile: "Change Password",
                action: IconButton(
                  icon: const Icon(Icons.lock),
                  onPressed: () => _showChangePasswordDialog(context, provider),
                ),
              ),

              // Appearance Section
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  'Appearance',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              MySettingsTile(
                tile: "Dark Mode",
                action: CupertinoSwitch(
                  onChanged: (value) =>
                      Provider.of<ThemeProvider>(context, listen: false)
                          .toggleTheme(),
                  value: Provider.of<ThemeProvider>(context, listen: false)
                      .isDarkMode,
                ),
              ),
              MySettingsTile(
                tile: "Font Size",
                action: IconButton(
                  icon: const Icon(Icons.text_fields),
                  onPressed: () => _showFontSizeDialog(context),
                ),
              ),
              MySettingsTile(
                tile: "Language",
                action: IconButton(
                  icon: const Icon(Icons.language),
                  onPressed: () => _showLanguageDialog(context),
                ),
              ),

              // Notifications Section
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  'Notifications',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              MySettingsTile(
                tile: "Notification Settings",
                action: IconButton(
                  icon: const Icon(Icons.notifications),
                  onPressed: () => _showNotificationsDialog(context),
                ),
              ),

              // Other Section
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  'Other',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              MySettingsTile(
                tile: "About",
                action: IconButton(
                  icon: const Icon(Icons.info),
                  onPressed: () => _showAboutDialog(context),
                ),
              ),
              MySettingsTile(
                tile: "Help & Support",
                action: IconButton(
                  icon: const Icon(Icons.help),
                  onPressed: () async {
                    const url = 'https://your-support-url.com';
                    if (await canLaunch(url)) {
                      await launch(url);
                    }
                  },
                ),
              ),
              MySettingsTile(
                tile: "Rate App",
                action: IconButton(
                  icon: const Icon(Icons.star),
                  onPressed: () async {
                    // TODO: Replace with actual app store URLs
                    const url = 'https://play.google.com/store/apps/your-app';
                    if (await canLaunch(url)) {
                      await launch(url);
                    }
                  },
                ),
              ),
              MySettingsTile(
                tile: "Delete Account",
                action: IconButton(
                  icon: const Icon(Icons.delete_forever, color: Colors.red),
                  onPressed: () => _showDeleteAccountDialog(context, provider),
                ),
              ),

              // Sign Out Button
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ElevatedButton(
                  onPressed: () async {
                    try {
                      logout;
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        '/login',
                        (route) => false,
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: ${e.toString()}')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Sign Out',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          );
        },
      ),
    );
  }
}
