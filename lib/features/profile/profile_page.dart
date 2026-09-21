import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/providers.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});
  @override Widget build(BuildContext context, WidgetRef ref) {
    final user=ref.watch(currentUserProvider).valueOrNull;
    return Scaffold(appBar:AppBar(title:const Text('Profile')),body:ListView(padding:const EdgeInsets.all(20),children:[
      const CircleAvatar(radius:36,child:Icon(Icons.person)),const SizedBox(height:20),
      TextFormField(initialValue:user?.name??'',readOnly:true,decoration:const InputDecoration(labelText:'Name')),
      const SizedBox(height:16),TextFormField(initialValue:user?.email??'',readOnly:true,decoration:const InputDecoration(labelText:'Email')),
      const SizedBox(height:16),TextFormField(initialValue:user?.role.name??'',readOnly:true,decoration:const InputDecoration(labelText:'Role')),
      const SizedBox(height:24),FilledButton(onPressed:()async{await ref.read(clinicRepositoryProvider).signOut();
      ref.read(demoModeProvider.notifier).state = false;
      ref.invalidate(currentUserProvider);
      ref.invalidate(appointmentsProvider);
      if (!context.mounted) return;
      context.go('/login');},child:const Text('Sign out')),
    ]));
  }
}
