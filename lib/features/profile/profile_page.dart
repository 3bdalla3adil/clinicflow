import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(padding: const EdgeInsets.all(20), children: [
        const CircleAvatar(radius: 36, child: Icon(Icons.person)),
        const SizedBox(height: 20),
        TextFormField(initialValue: 'Demo Patient', decoration: const InputDecoration(labelText: 'Name')),
        const SizedBox(height: 16),
        TextFormField(initialValue: 'patient@example.com', decoration: const InputDecoration(labelText: 'Email')),
        const SizedBox(height: 24),
        FilledButton(onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile changes are saved through the secure repository.'))), child: const Text('Save changes')),
        TextButton(onPressed: () => context.go('/login'), child: const Text('Sign out')),
      ]),
    );
  }
}