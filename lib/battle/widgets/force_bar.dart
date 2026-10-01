import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models.dart';

/// Ikki tomon kuchlarining nisbati: bitta bo'lingan chiziq va raqamlar.
class ForceBar extends StatelessWidget {
  const ForceBar({super.key, required this.battle, required this.a, required this.b, this.compact = false});

  final Battle battle;
  final int a, b;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final total = math.max(1, a + b);
    final style = TextStyle(fontSize: compact ? 12 : 13.5, fontWeight: FontWeight.w700);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text('${battle.sideA}  ${formatCount(a)}',
                  overflow: TextOverflow.ellipsis, style: style.copyWith(color: battle.colorA)),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text('${formatCount(b)}  ${battle.sideB}',
                  textAlign: TextAlign.right,
                  overflow: TextOverflow.ellipsis,
                  style: style.copyWith(color: battle.colorB)),
            ),
          ],
        ),
        const SizedBox(height: 5),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: SizedBox(
            height: compact ? 8 : 12,
            child: Row(
              children: [
                Expanded(flex: (a * 1000 ~/ total).clamp(1, 1000), child: Container(color: battle.colorA)),
                Container(width: 2, color: Colors.white),
                Expanded(flex: (b * 1000 ~/ total).clamp(1, 1000), child: Container(color: battle.colorB)),
              ],
            ),
          ),
        ),
        if (!compact) ...[
          const SizedBox(height: 4),
          Text(
            a == b
                ? 'Kuchlar teng'
                : '${a > b ? battle.sideA : battle.sideB} ~${(a > b ? a / math.max(1, b) : b / math.max(1, a)).toStringAsFixed(1)} barobar ko\'p',
            style: const TextStyle(fontSize: 12, color: Colors.black54),
          ),
        ],
      ],
    );
  }
}
