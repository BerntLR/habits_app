import 'package:flutter/material.dart';
import 'bp_button.dart';
import 'bp_card.dart';
import '../tokens.dart';

class BPEmptyState extends StatelessWidget {
  const BPEmptyState({
    super.key,
    required this.title,
    required this.message,
    required this.icon,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String message;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(BPSpacing.l),
        child: BPCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 44, color: cs.onSurfaceVariant),
              const SizedBox(height: BPSpacing.m),
              Text(title,
                  style: Theme.of(context).textTheme.titleLarge,
                  textAlign: TextAlign.center),
              const SizedBox(height: BPSpacing.s),
              Text(message,
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center),
              if (actionLabel != null && onAction != null) ...[
                const SizedBox(height: BPSpacing.l),
                BPButton(
                    label: actionLabel!,
                    kind: BPButtonKind.primary,
                    onPressed: onAction),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
