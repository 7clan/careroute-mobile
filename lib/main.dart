import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'presentation/providers/infrastructure_providers.dart';

/// Riverpod 3 retries failing async providers automatically (exponential
/// backoff). We disable that on purpose:
///
/// * our repositories already classify errors ([AppException]); retrying a
///   401/422 (auth/validation) request is wrong,
/// * the UI owns retry semantics — every error state ships a retry button
///   and load-more failures keep the list visible with a footer retry.
///
/// See docs/STATE_MANAGEMENT.md ("Error handling & retry policy").
Duration? appRetryPolicy(int retryCount, Object error) => null;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Local key/value storage must exist before the widget tree builds
  // (favorites & preferences read it synchronously on first frame).
  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      retry: appRetryPolicy,
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      child: const CareRouteApp(),
    ),
  );
}
