import 'package:flutter/material.dart';

/// Lightweight looping skeleton used while lists load.
///
/// Purely decorative: wrapped in [ExcludeSemantics] and hidden from
/// screen readers (the surrounding container announces "loading").
class SkeletonTile extends StatefulWidget {
  const SkeletonTile({super.key, this.height = 92});

  final double height;

  @override
  State<SkeletonTile> createState() => _SkeletonTileState();
}

class _SkeletonTileState extends State<SkeletonTile>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ExcludeSemantics(
      child: FadeTransition(
        opacity: Tween(begin: 0.35, end: 0.75).animate(
          CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
        ),
        child: Container(
          height: widget.height,
          margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              const Padding(
                padding: EdgeInsets.all(14),
                child: CircleAvatar(radius: 30),
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 16,
                      width: 200,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      height: 12,
                      width: 130,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      height: 12,
                      width: 170,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A column of skeleton tiles that visually matches the provider list.
class DoctorListSkeleton extends StatelessWidget {
  const DoctorListSkeleton({super.key, this.count = 6});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Loading providers',
      child: ListView(
        physics: const NeverScrollableScrollPhysics(),
        children: [
          for (var i = 0; i < count; i++) SkeletonTile(key: ValueKey(i)),
        ],
      ),
    );
  }
}
