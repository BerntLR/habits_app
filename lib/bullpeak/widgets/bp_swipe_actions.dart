import 'package:flutter/material.dart';

import '../tokens.dart';

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

  /// Karo standard: swipe right = edit (blue), swipe left = delete (red).
  static const Color editColor = Color(0xFF1E88E5);
  static const Color deleteColor = Color(0xFFD32F2F);

  @override
  Widget build(BuildContext context) {
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
      background: _background(
        color: editColor,
        icon: Icons.edit_outlined,
        alignment: Alignment.centerLeft,
      ),
      secondaryBackground: _background(
        color: deleteColor,
        icon: Icons.delete_outline,
        alignment: Alignment.centerRight,
      ),
      child: child,
    );
  }

  Widget _background({
    required Color color,
    required IconData icon,
    required Alignment alignment,
  }) {
    return Container(
      decoration: BoxDecoration(color: color, borderRadius: BPRadius.card),
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Icon(icon, color: Colors.white),
    );
  }
}
