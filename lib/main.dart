import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase is optional in local demo mode. When Firebase configuration is
  // available, initialize the default app explicitly before any repository
  // accesses FirebaseAuth/Firestore.
  try {
    await Firebase.initializeApp();
  } on FirebaseException catch (e) {
    debugPrint('Firebase initialization skipped: ${e.code}: ${e.message}');
  }

  runApp(const ProviderScope(child: ClinicFlowApp()));
}
