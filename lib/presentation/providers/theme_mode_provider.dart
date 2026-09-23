import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/storage/key_value_store.dart';
import 'infrastructure_providers.dart';

/// App-level theme preference, persisted across launches.
final themeModeProvider = NotifierProvider<ThemeModeController, ThemeMode>(
  ThemeModeController.new,
);

class ThemeModeController extends Notifier<ThemeMode> {
  static const _storageKey = 'careroute.themeMode';

  @override
  ThemeMode build() {
    // Load asynchronously; until then the system default is a safe value.
    final store = ref.watch(keyValueStoreProvider);
    unawaited(_load(store));
    return ThemeMode.system;
  }

  Future<void> _load(KeyValueStore store) async {
    final raw = await store.read(_storageKey);
    final mode = switch (raw) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
    if (state != mode) state = mode;
  }

  Future<void> setMode(ThemeMode mode) async {
    state = mode;
    final store = ref.read(keyValueStoreProvider);
    await store.write(_storageKey, switch (mode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
    });
  }
}
