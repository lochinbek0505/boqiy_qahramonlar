import 'package:boqiy_qahramonlar/provider/battle_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../battle/battle_theme.dart';
import '../battle/screens/battle_screen.dart';
import '../models/battle_model.dart';

/// Jangni animatsion xaritada ko'rsatish sahifasi.
/// Manzil: `/battles/:key?t=2.5&fs=1` — ixtiyoriy vaqt nuqtasi va to'liq ekran.
class ReadBattlePage extends ConsumerStatefulWidget {
  final String battleKey;
  final double? initialProgress;
  final bool initialFullscreen;

  const ReadBattlePage({
    super.key,
    required this.battleKey,
    this.initialProgress,
    this.initialFullscreen = false,
  });

  @override
  ConsumerState<ReadBattlePage> createState() => _ReadBattlePageState();
}

class _ReadBattlePageState extends ConsumerState<ReadBattlePage> {
  BattleModel? _battle;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  @override
  void didUpdateWidget(ReadBattlePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.battleKey != widget.battleKey) _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _loading = true);
    final notifier = ref.read(battleProvider.notifier);
    final battle = await notifier.findBattle(widget.battleKey);
    if (!mounted) return;
    setState(() {
      _battle = battle;
      _loading = false;
    });
    if (battle != null) notifier.increaseBattleView(battle);
  }

  @override
  Widget build(BuildContext context) {
    final battle = _battle;
    return Theme(
      data: battleTheme,
      child: _loading
          ? const Scaffold(body: Center(child: CircularProgressIndicator()))
          : battle == null
              ? Scaffold(
                  appBar: AppBar(
                    leading: IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => context.go('/battles'),
                    ),
                  ),
                  body: const Center(child: Text("Jang topilmadi")),
                )
              : BattleScreen(
                  key: ValueKey(battle.key),
                  battle: battle.battle,
                  initialProgress: widget.initialProgress,
                  initialFullscreen: widget.initialFullscreen,
                ),
    );
  }
}
