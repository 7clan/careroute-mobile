import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/errors/app_exception.dart';
import '../../providers/appointments_providers.dart';
import '../../providers/favorites_providers.dart';
import '../../providers/infrastructure_providers.dart';
import '../../providers/session_providers.dart';
import '../../providers/theme_mode_provider.dart';

/// Account overview: profile card, quick stats, appearance, diagnostics
/// (the honest "API condition simulator" of the mock backend) and sign-out.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider).value;
    final user = session?.user;
    final favoritesCount = ref.watch(favoritesProvider).value?.length ?? 0;
    final upcomingCount = ref.watch(upcomingAppointmentsProvider).length;

    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: theme.colorScheme.primaryContainer,
                      child: Text(
                        _initials(user?.name ?? '?'),
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user?.name ?? 'Signed out',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            user?.email ?? '—',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          if (user != null) ...[
                            const SizedBox(height: 2),
                            Text(
                              'Member since '
                              '${DateFormat('MMMM yyyy').format(user.memberSince)}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    icon: Icons.favorite_outline,
                    value: '$favoritesCount',
                    label: 'Saved',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    icon: Icons.event_available,
                    value: '$upcomingCount',
                    label: 'Upcoming',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _AppearanceCard(),
            const SizedBox(height: 12),
            _DiagnosticsCard(),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Demo account',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'demo@careroute.app · Demo1234!\n'
                      'Data is served by an in-app mock backend — see the '
                      'Profile diagnostics below.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: theme.colorScheme.error,
              ),
              onPressed: () => _signOut(context, ref),
              icon: const Icon(Icons.logout),
              label: const Text('Sign out'),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                'CareRoute · portfolio build',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) return parts.first.characters.first.toUpperCase();
    return (parts.first.characters.first + parts.last.characters.first)
        .toUpperCase();
  }

  Future<void> _signOut(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign out?'),
        content: const Text(
          'You will need to sign in again to browse '
          'providers and manage appointments.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Stay'),
          ),
          FilledButton.tonal(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sign out'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await ref.read(sessionProvider.notifier).logout();
    } on AppException {
      // logout() already clears local state on failure.
    }
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          children: [
            Icon(icon, color: theme.colorScheme.primary),
            const SizedBox(height: 8),
            Text(value, style: theme.textTheme.titleLarge),
            Text(
              label,
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AppearanceCard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final mode = ref.watch(themeModeProvider);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.dark_mode_outlined,
                  size: 18,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Appearance',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SegmentedButton<ThemeMode>(
              segments: const [
                ButtonSegment(
                  value: ThemeMode.system,
                  icon: Icon(Icons.brightness_auto_outlined),
                  label: Text('Auto'),
                ),
                ButtonSegment(
                  value: ThemeMode.light,
                  icon: Icon(Icons.light_mode_outlined),
                  label: Text('Light'),
                ),
                ButtonSegment(
                  value: ThemeMode.dark,
                  icon: Icon(Icons.dark_mode_outlined),
                  label: Text('Dark'),
                ),
              ],
              selected: {mode},
              onSelectionChanged: (selection) =>
                  ref.read(themeModeProvider.notifier).setMode(selection.first),
            ),
          ],
        ),
      ),
    );
  }
}

/// Honest diagnostics: these switches only affect the *bundled mock
/// backend* so a reviewer can experience the app's failure states live.
class _DiagnosticsCard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final conditions = ref.watch(backendConditionsProvider);
    final controller = ref.read(backendConditionsProvider.notifier);
    final latencyMs = conditions.latency.inMilliseconds;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.network_check,
                  size: 18,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'API condition simulator',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Applies to the in-app mock backend — experience the app '
              'offline / timeout / server-error states.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Simulate offline'),
              subtitle: const Text('Requests fail with no connection'),
              value: conditions.offline,
              onChanged: controller.setOffline,
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Simulate timeout'),
              subtitle: const Text('Requests hang past the Dio timeouts'),
              value: conditions.timeoutAfter != null,
              onChanged: controller.setSimulatedTimeout,
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Force server error (500)'),
              value: conditions.forceStatus != null,
              onChanged: controller.setForceServerError,
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Malformed response'),
              subtitle: const Text('200 with broken JSON'),
              value: conditions.malformedResponse,
              onChanged: controller.setMalformed,
            ),
            const SizedBox(height: 4),
            Text(
              'Latency: ${latencyMs >= 1000 ? '${(latencyMs / 1000).toStringAsFixed(1)} s' : '$latencyMs ms'}',
              style: theme.textTheme.bodySmall,
            ),
            Slider(
              value: latencyMs.clamp(0, 2000).toDouble(),
              min: 0,
              max: 2000,
              divisions: 8,
              label: latencyMs >= 1000
                  ? '${(latencyMs / 1000).toStringAsFixed(1)} s'
                  : '$latencyMs ms',
              onChanged: (value) =>
                  controller.setLatency(Duration(milliseconds: value.round())),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: controller.reset,
                icon: const Icon(Icons.restart_alt, size: 18),
                label: const Text('Reset conditions'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
