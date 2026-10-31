import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/app_settings.dart';
import '../features/demo/demo_mode.dart';
import 'router.dart';
import 'theme.dart';
class ClinicFlowApp extends ConsumerWidget {
 const ClinicFlowApp({super.key});
 @override Widget build(BuildContext context, WidgetRef ref) {
  final s=ref.watch(appSettingsProvider);
  return MaterialApp.router(title:'ClinicFlow',debugShowCheckedModeBanner:false,theme:clinicTheme(Brightness.light),darkTheme:clinicTheme(Brightness.dark),themeMode:s.themeMode,locale:s.localeCode==null?null:Locale(s.localeCode!),supportedLocales:const[Locale('en'),Locale('ar')],localizationsDelegates:GlobalMaterialLocalizations.delegates,routerConfig:ref.watch(routerProvider),builder:(context,child){
   final media=MediaQuery.of(context);
   return MediaQuery(data:media.copyWith(textScaler:media.textScaler.clamp(minScaleFactor:s.textScale,maxScaleFactor:s.textScale)),child:Column(children:[const DemoBanner(),Expanded(child:child??const SizedBox.shrink())]));
  });
 }
}
