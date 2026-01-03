import 'package:flutter/material.dart';
import '../tokens.dart';

class BPListTile extends StatelessWidget {
  const BPListTile({
    super.key,
    this.onTap,
    this.leading,
    required this.title,
    this.subtitle,
    this.trailing,
  });

  final VoidCallback? onTap;
  final IconData? leading;
  final String title;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      borderRadius: BPRadius.card,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: BPSpacing.l, vertical: BPSpacing.m),
        child: Row(
          children: [
            if (leading != null) ...[
              Icon(leading, color: cs.onSurfaceVariant),
              const SizedBox(width: BPSpacing.m),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleMedium),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(subtitle!,
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: cs.onSurfaceVariant)),
                  ],
                ],
              ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: BPSpacing.m),
              trailing!,
            ],
          ],
        ),
      ),
    );
  }
}
