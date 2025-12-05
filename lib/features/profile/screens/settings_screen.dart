import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../services/user_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final UserService _userService = UserService();
  User? _user;
  bool _isLoading = true;
  bool _notificationsEnabled = true;
  bool _locationEnabled = true;
  String _imageQuality = 'high';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    setState(() => _isLoading = true);

    try {
      final user = await _userService.getCurrentUser();
      final prefs = await SharedPreferences.getInstance();

      setState(() {
        _user = user;
        _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
        _locationEnabled = prefs.getBool('location_enabled') ?? true;
        _imageQuality = prefs.getString('image_quality') ?? 'high';
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveSetting(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value is bool) {
      await prefs.setBool(key, value);
    } else if (value is String) {
      await prefs.setString(key, value);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                _buildSection('Account', [
                  _buildAccountTile(),
                  _buildEditProfileTile(),
                  _buildChangePasswordTile(),
                ]),
                _buildSection('Preferences', [
                  _buildNotificationSwitch(),
                  _buildLocationSwitch(),
                  _buildImageQualityTile(),
                ]),
                _buildSection('About', [
                  _buildAboutTile('Version', '1.0.0'),
                  _buildAboutTile('Build', '100'),
                  _buildLinkTile(
                    'Privacy Policy',
                    'View our privacy policy',
                    () => _showComingSoon(context),
                  ),
                  _buildLinkTile(
                    'Terms of Service',
                    'View terms of service',
                    () => _showComingSoon(context),
                  ),
                ]),
                _buildSection('Danger Zone', [
                  _buildDeleteAccountTile(),
                ]),
                const SizedBox(height: 32),
              ],
            ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
        ),
        ...children,
      ],
    );
  }

  Widget _buildAccountTile() {
    if (_user == null) return const SizedBox.shrink();

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.blue,
        child: Text(
          _user!.fullName.isNotEmpty ? _user!.fullName[0].toUpperCase() : 'U',
          style: const TextStyle(color: Colors.white),
        ),
      ),
      title: Text(_user!.fullName),
      subtitle: Text(_user!.email),
    );
  }

  Widget _buildEditProfileTile() {
    return ListTile(
      leading: const Icon(Icons.edit),
      title: const Text('Edit Profile'),
      subtitle: const Text('Update your name and email'),
      trailing: const Icon(Icons.chevron_right),
      onTap: _showEditProfileDialog,
    );
  }

  Widget _buildChangePasswordTile() {
    return ListTile(
      leading: const Icon(Icons.lock),
      title: const Text('Change Password'),
      subtitle: const Text('Update your password'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => _showComingSoon(context),
    );
  }

  Widget _buildNotificationSwitch() {
    return SwitchListTile(
      secondary: const Icon(Icons.notifications),
      title: const Text('Notifications'),
      subtitle: const Text('Enable push notifications'),
      value: _notificationsEnabled,
      onChanged: (value) {
        setState(() => _notificationsEnabled = value);
        _saveSetting('notifications_enabled', value);
      },
    );
  }

  Widget _buildLocationSwitch() {
    return SwitchListTile(
      secondary: const Icon(Icons.location_on),
      title: const Text('Location'),
      subtitle: const Text('Add GPS data to uploads'),
      value: _locationEnabled,
      onChanged: (value) {
        setState(() => _locationEnabled = value);
        _saveSetting('location_enabled', value);
      },
    );
  }

  Widget _buildImageQualityTile() {
    return ListTile(
      leading: const Icon(Icons.image),
      title: const Text('Image Quality'),
      subtitle: Text('Current: ${_imageQuality == 'high' ? 'High' : _imageQuality == 'medium' ? 'Medium' : 'Low'}'),
      trailing: const Icon(Icons.chevron_right),
      onTap: _showImageQualityDialog,
    );
  }

  Widget _buildAboutTile(String title, String value) {
    return ListTile(
      leading: const Icon(Icons.info),
      title: Text(title),
      trailing: Text(
        value,
        style: TextStyle(color: Colors.grey[600]),
      ),
    );
  }

  Widget _buildLinkTile(String title, String subtitle, VoidCallback onTap) {
    return ListTile(
      leading: const Icon(Icons.open_in_new),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  Widget _buildDeleteAccountTile() {
    return ListTile(
      leading: const Icon(Icons.delete_forever, color: Colors.red),
      title: const Text('Delete Account', style: TextStyle(color: Colors.red)),
      subtitle: const Text('Permanently delete your account'),
      onTap: _showDeleteAccountDialog,
    );
  }

  void _showEditProfileDialog() {
    final nameController = TextEditingController(text: _user?.fullName);
    final emailController = TextEditingController(text: _user?.email);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Profile'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Full Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _updateProfile(
                nameController.text,
                emailController.text,
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _updateProfile(String name, String email) async {
    try {
      final updatedUser = await _userService.updateProfile(
        fullName: name.isNotEmpty ? name : null,
        email: email.isNotEmpty ? email : null,
      );

      setState(() => _user = updatedUser);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update profile: $e')),
        );
      }
    }
  }

  void _showImageQualityDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Image Quality'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('High'),
              subtitle: const Text('Best quality, larger file size'),
              value: 'high',
              groupValue: _imageQuality,
              onChanged: (value) {
                if (value != null) {
                  setState(() => _imageQuality = value);
                  _saveSetting('image_quality', value);
                  Navigator.pop(context);
                }
              },
            ),
            RadioListTile<String>(
              title: const Text('Medium'),
              subtitle: const Text('Balanced quality and size'),
              value: 'medium',
              groupValue: _imageQuality,
              onChanged: (value) {
                if (value != null) {
                  setState(() => _imageQuality = value);
                  _saveSetting('image_quality', value);
                  Navigator.pop(context);
                }
              },
            ),
            RadioListTile<String>(
              title: const Text('Low'),
              subtitle: const Text('Smaller file size, lower quality'),
              value: 'low',
              groupValue: _imageQuality,
              onChanged: (value) {
                if (value != null) {
                  setState(() => _imageQuality = value);
                  _saveSetting('image_quality', value);
                  Navigator.pop(context);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteAccountDialog() {
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
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showComingSoon(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Coming soon!')),
    );
  }
}
