import 'package:flutter/material.dart';
import '../tokens.dart';

class BPCard extends StatelessWidget {
  const BPCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(BPSpacing.l),
    this.margin,
  });

  final Widget child;
  final EdgeInsets padding;
  final EdgeInsets? margin;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BPRadius.card,
        boxShadow: BPShadows.soft(cs.shadow),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.35)),
      ),
      child: Padding(padding: padding, child: child),
    );
  }
}
