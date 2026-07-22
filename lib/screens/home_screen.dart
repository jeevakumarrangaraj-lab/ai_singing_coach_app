import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: cs.surface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: Text(
          'Tuno',
          style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        actions: [
          Tooltip(
            message: 'Notifications',
            child: Semantics(
              button: true,
              label: 'Notifications',
              child: IconButton(
                onPressed: () {},
                icon: const Icon(Icons.notifications_none_rounded),
              ),
            ),
          ),
          const SizedBox(width: 4),
          Tooltip(
            message: 'Settings',
            child: Semantics(
              button: true,
              label: 'Settings',
              child: IconButton(
                onPressed: () => context.push('/settings'),
                icon: const Icon(Icons.settings_rounded),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Greeting ──
                  Text(
                    'Hello, Singer 👋',
                    style: textTheme.headlineMedium?.copyWith(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: cs.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Ready to improve your voice today?',
                    style: textTheme.bodyMedium?.copyWith(
                      fontSize: 16,
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 28),

                  // ── Main Practice Card ──
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(22),
                      side: BorderSide(color: cs.outlineVariant, width: 1),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          // Mic circle
                          Container(
                            width: 105,
                            height: 105,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: cs.surfaceContainerHighest,
                              border: Border.all(
                                color: cs.outlineVariant,
                                width: 1.5,
                              ),
                            ),
                            child: Icon(
                              Icons.mic_rounded,
                              size: 55,
                              color: cs.primary,
                            ),
                          ),
                          const SizedBox(height: 18),
                          Text(
                            'Start Voice Practice',
                            style: textTheme.titleLarge?.copyWith(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: cs.onSurface,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Record your voice and receive instant feedback.',
                            textAlign: TextAlign.center,
                            style: textTheme.bodyMedium?.copyWith(
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Tooltip(
                            message: 'Start Practice',
                            child: Semantics(
                              button: true,
                              label: 'Start Practice',
                              child: SizedBox(
                                width: double.infinity,
                                height: 54,
                                child: FilledButton(
                                  onPressed: () => context.push('/practice'),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.fiber_manual_record_rounded,
                                        size: 22,
                                      ),
                                      const SizedBox(width: 8),
                                      const Text(
                                        'Start Practice',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // ── Progress Section ──
                  Text(
                    'Your Progress',
                    style: textTheme.titleLarge?.copyWith(
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                      color: cs.onSurface,
                    ),
                  ),
                  const SizedBox(height: 16),

                  LayoutBuilder(
                    builder: (context, constraints) {
                      final useColumns = constraints.maxWidth >= 360;
                      if (useColumns) {
                        return Row(
                          children: [
                            Expanded(
                              child: _ProgressCard(
                                title: 'Practice',
                                value: '0 min',
                                icon: Icons.timer_outlined,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: _ProgressCard(
                                title: 'Streak',
                                value: '0 days',
                                icon: Icons.local_fire_department_outlined,
                              ),
                            ),
                          ],
                        );
                      }
                      return Column(
                        children: [
                          _ProgressCard(
                            title: 'Practice',
                            value: '0 min',
                            icon: Icons.timer_outlined,
                          ),
                          const SizedBox(height: 14),
                          _ProgressCard(
                            title: 'Streak',
                            value: '0 days',
                            icon: Icons.local_fire_department_outlined,
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ProgressCard extends StatelessWidget {
  const _ProgressCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  final String title;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: BorderSide(color: cs.outlineVariant, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: cs.primary, size: 30),
            const SizedBox(height: 18),
            Text(
              value,
              style: textTheme.titleLarge?.copyWith(
                fontSize: 21,
                fontWeight: FontWeight.bold,
                color: cs.onSurface,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              title,
              style: textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}
