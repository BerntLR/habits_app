import 'package:flutter/material.dart';

class BPSwipeActions extends StatelessWidget {
  const BPSwipeActions({
    super.key,
    required this.child,
    required this.onDelete,
    required this.onEdit,
    this.dismissKey,
  });

  final Widget child;
  final Future<void> Function() onDelete;
  final Future<void> Function() onEdit;
  final Key? dismissKey;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Dismissible(
      key: dismissKey ?? key ?? UniqueKey(),
      dismissThresholds: const {
        DismissDirection.startToEnd: 0.20,
        DismissDirection.endToStart: 0.35,
      },
      confirmDismiss: (dir) async {
        if (dir == DismissDirection.endToStart) {
          await onDelete();
          return false;
        }
        if (dir == DismissDirection.startToEnd) {
          await onEdit();
          return false;
        }
        return false;
      },
      background: Container(
        color: cs.primary.withValues(alpha: 0.12),
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 16),
        child: Icon(Icons.edit_outlined, color: cs.onSurface),
      ),
      secondaryBackground: Container(
        color: cs.error,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        child: Icon(Icons.delete_outline, color: cs.onError),
      ),
      child: child,
    );
  }
}
