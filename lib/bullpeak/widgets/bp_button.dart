import 'package:flutter/material.dart';

enum BPButtonKind { primary, secondary, tertiary, destructive }

class BPButton extends StatelessWidget {
  const BPButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.kind = BPButtonKind.primary,
  });

  final String label;
  final VoidCallback? onPressed;
  final BPButtonKind kind;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    ButtonStyle style;
    switch (kind) {
      case BPButtonKind.primary:
        style = ElevatedButton.styleFrom(
          backgroundColor: cs.primary,
          foregroundColor: cs.onPrimary,
        );
        return ElevatedButton(
            onPressed: onPressed, style: style, child: Text(label));
      case BPButtonKind.secondary:
        style = OutlinedButton.styleFrom(
          foregroundColor: cs.onSurface,
          side: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.7)),
        );
        return OutlinedButton(
            onPressed: onPressed, style: style, child: Text(label));
      case BPButtonKind.tertiary:
        style = TextButton.styleFrom(foregroundColor: cs.onSurface);
        return TextButton(
            onPressed: onPressed, style: style, child: Text(label));
      case BPButtonKind.destructive:
        style = TextButton.styleFrom(foregroundColor: cs.error);
        return TextButton(
            onPressed: onPressed, style: style, child: Text(label));
    }
  }
}
