import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/app_settings.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});
  String t(BuildContext c, String en, String ar) => Localizations.localeOf(c).languageCode == 'ar' ? ar : en;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(appSettingsProvider); final c = ref.read(appSettingsProvider.notifier); final theme = Theme.of(context);
    return Scaffold(appBar: AppBar(title: Text(t(context, 'Settings', 'الإعدادات'))), body: ListView(padding: const EdgeInsets.all(16), children: [
      Text(t(context, 'Appearance', 'المظهر'), style: theme.textTheme.titleMedium),
      Card(child: Column(children: [
        ListTile(leading: const Icon(Icons.palette_outlined), title: Text(t(context, 'Theme', 'السمة')), subtitle: Text(switch (s.themeMode) { ThemeMode.system => t(context,'Follow device','حسب الجهاز'), ThemeMode.light => t(context,'Light','فاتح'), ThemeMode.dark => t(context,'Dark','داكن') })),
        Padding(padding: const EdgeInsets.all(12), child: SegmentedButton<ThemeMode>(segments: [
          ButtonSegment(value: ThemeMode.system, icon: const Icon(Icons.settings_suggest), label: Text(t(context,'System','النظام'))),
          ButtonSegment(value: ThemeMode.light, icon: const Icon(Icons.light_mode_outlined), label: Text(t(context,'Light','فاتح'))),
          ButtonSegment(value: ThemeMode.dark, icon: const Icon(Icons.dark_mode_outlined), label: Text(t(context,'Dark','داكن'))),
        ], selected: {s.themeMode}, onSelectionChanged: (v) => c.setThemeMode(v.first))),
      ])),
      const SizedBox(height: 20), Text(t(context,'Language & region','اللغة والمنطقة'), style: theme.textTheme.titleMedium),
      Card(child: Padding(padding: const EdgeInsets.all(16), child: DropdownButtonFormField<String>(
        initialValue: s.localeCode ?? 'system', isExpanded: true, decoration: InputDecoration(labelText: t(context,'App language','لغة التطبيق'), prefixIcon: const Icon(Icons.language), border: const OutlineInputBorder()),
        items: [DropdownMenuItem(value:'system',child:Text(t(context,'Device language','لغة الجهاز'))), const DropdownMenuItem(value:'en',child:Text('English')), const DropdownMenuItem(value:'ar',child:Text('العربية'))],
        onChanged: (v) => c.setLocale(v == 'system' ? null : v),
      ))),
      const SizedBox(height: 20), Text(t(context,'Accessibility','إمكانية الوصول'), style: theme.textTheme.titleMedium),
      Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(children: [
        Row(children: [const Icon(Icons.format_size), const SizedBox(width:12), Expanded(child: Text(t(context,'Text size','حجم النص'))), Text('${(s.textScale*100).round()}%')]),
        Slider(min:.85,max:1.3,divisions:9,value:s.textScale,label:'${(s.textScale*100).round()}%',onChanged:c.setTextScale),
        Text(t(context,'Adjust text size throughout the app.','اضبط حجم النص في جميع أنحاء التطبيق.')),
      ]))),
      const SizedBox(height: 20), Card(child: ListTile(leading: const Icon(Icons.restart_alt), title: Text(t(context,'Reset settings','إعادة ضبط الإعدادات')), subtitle: Text(t(context,'Restore default display preferences.','استعادة تفضيلات العرض الافتراضية.')), onTap: () async {
        final yes = await showDialog<bool>(context:context,builder:(d)=>AlertDialog(title:Text(t(context,'Reset settings?','إعادة ضبط الإعدادات؟')),content:Text(t(context,'Your display preferences will return to their defaults.','ستعود تفضيلات العرض إلى إعداداتها الافتراضية.')),actions:[TextButton(onPressed:()=>Navigator.pop(d,false),child:Text(t(context,'Cancel','إلغاء'))),FilledButton(onPressed:()=>Navigator.pop(d,true),child:Text(t(context,'Reset','إعادة ضبط')))]));
        if (yes == true) await c.reset();
      })),
      const SizedBox(height:12), Text(t(context,'Preferences are saved on this device. Notification controls will be added when clinic notifications are enabled.','يتم حفظ التفضيلات على هذا الجهاز. ستضاف إعدادات الإشعارات عند تفعيل إشعارات العيادة.'), style: theme.textTheme.bodySmall),
    ]));
  }
}
