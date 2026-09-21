import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/providers.dart';
import '../../data/models/models.dart';
import '../../data/repositories/clinic_repository.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});
  @override ConsumerState<LoginPage> createState()=>_LoginPageState();
}
class _LoginPageState extends ConsumerState<LoginPage>{
  final email=TextEditingController(text:'patient@demo.clinicflow.app');
  final password=TextEditingController(text:'ClinicFlow@Patient2026');
  bool loading=false; String? error;
  Future<void> _signIn() async{
    FocusScope.of(context).unfocus(); setState(()=>loading=true);
      await ref.read(clinicRepositoryProvider).signIn(email.text,password.text);
        if (!mounted) return;                  // ← add this right after every await
            Navigator.of(context).pushReplacement(...);
      ref.invalidate(currentUserProvider); ref.invalidate(appointmentsProvider);
      if(!context.mounted)return; context.go('/dashboard');
    }catch(_){
      if(!context.mounted)return;
      setState(()=>error='Unable to sign in. Check your credentials and try again.');
    }finally{if(mounted)setState(()=>loading=false);}
  }
  void _useDemo(DemoCredential c)=>setState((){email.text=c.email;password.text=c.password;error=null;});
  @override void dispose(){email.dispose();password.dispose();super.dispose();}
  @override Widget build(BuildContext context){
    final demo=ref.watch(firebaseAvailableProvider)==false;
    return Scaffold(body:SafeArea(child:Center(child:SingleChildScrollView(
      padding:const EdgeInsets.all(24),child:ConstrainedBox(constraints:const BoxConstraints(maxWidth:520),child:Column(
        crossAxisAlignment:CrossAxisAlignment.stretch,children:[
          const Icon(Icons.local_hospital,size:64),const SizedBox(height:16),
          Text('ClinicFlow',style:Theme.of(context).textTheme.headlineLarge,textAlign:TextAlign.center),
          const SizedBox(height:8),Text(demo?'Demo environment — Firebase is not initialized.':'Secure clinic management',textAlign:TextAlign.center),
          const SizedBox(height:28),
          TextField(controller:email,keyboardType:TextInputType.emailAddress,decoration:const InputDecoration(labelText:'Email')),
          const SizedBox(height:16),TextField(controller:password,obscureText:true,decoration:const InputDecoration(labelText:'Password')),
          if(error!=null)Padding(padding:const EdgeInsets.only(top:12),child:Text(error!,style:TextStyle(color:Theme.of(context).colorScheme.error))),
          const SizedBox(height:20),FilledButton(onPressed:loading?null:_signIn,child:Text(loading?'Signing in…':'Sign in')),
          const SizedBox(height:24),Text('Demo accounts',style:Theme.of(context).textTheme.titleMedium),const SizedBox(height:8),
          for(final c in DemoClinicRepository.demoCredentials)
            ListTile(contentPadding:EdgeInsets.zero,leading:Icon(_roleIcon(c.role)),title:Text('${c.name} · ${c.role.name}'),subtitle:Text(c.email),trailing:TextButton(onPressed:loading?null:()=>_useDemo(c),child:const Text('Use'))),
          const SizedBox(height:8),const Text('Demo credentials are public by design and are never suitable for real patient data.',textAlign:TextAlign.center),
        ],
      )),
    ))));
  }
  IconData _roleIcon(UserRole role)=>switch(role){
    UserRole.admin=>Icons.admin_panel_settings,UserRole.reception=>Icons.desk,
    UserRole.doctor=>Icons.medical_services,UserRole.accountant=>Icons.account_balance,UserRole.patient=>Icons.person,
  };
}
