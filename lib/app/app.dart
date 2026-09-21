import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'router.dart';
import 'theme.dart';

class ClinicFlowApp extends ConsumerWidget {
  const ClinicFlowApp({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) => MaterialApp.router(
    title: 'ClinicFlow', debugShowCheckedModeBanner: false,
    theme: clinicTheme(Brightness.light), darkTheme: clinicTheme(Brightness.dark),
    themeMode: ThemeMode.system, routerConfig: ref.watch(routerProvider),
  );
}
