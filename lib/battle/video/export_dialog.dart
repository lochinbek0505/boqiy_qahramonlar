import 'package:flutter/material.dart';

import '../map/units_painter.dart';
import '../models.dart';
import 'video_export.dart';
import 'video_renderer.dart';

/// Jangni video faylga eksport qilish oynasi.
Future<void> showVideoExportDialog(BuildContext context, Battle battle, ViewOptions options) =>
    showDialog<void>(context: context, barrierDismissible: false, builder: (_) => _ExportDialog(battle, options));

enum _Stage { settings, running, done, failed }

class _ExportDialog extends StatefulWidget {
  const _ExportDialog(this.battle, this.options);
  final Battle battle;
  final ViewOptions options;

  @override
  State<_ExportDialog> createState() => _ExportDialogState();
}

class _ExportDialogState extends State<_ExportDialog> {
  int _height = 720;
  double _secondsPerPhase = 8;
  bool _labels = true;
  _Stage _stage = _Stage.settings;
  double _progress = 0;
  String _status = '';
  bool _cancel = false;
  DateTime? _started;
  VideoExportResult? _result;
  String? _error;

  VideoSettings get _settings => VideoSettings(
        width: _height == 1080 ? 1920 : 1280,
        height: _height,
        secondsPerPhase: _secondsPerPhase,
        options: widget.options.copyWith(labels: _labels, counts: _labels, grid: false),
      );

  Future<void> _start() async {
    setState(() {
      _stage = _Stage.running;
      _started = DateTime.now();
      _cancel = false;
    });
    try {
      final r = await exportBattleVideo(
        widget.battle,
        _settings,
        isCancelled: () => _cancel,
        onProgress: (p, s) {
          if (mounted) {
            setState(() {
              _progress = p;
              _status = s;
            });
          }
        },
      );
      if (mounted) {
        setState(() {
          _stage = _Stage.done;
          _result = r;
        });
      }
    } on VideoExportCancelled {
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        setState(() {
          _stage = _Stage.failed;
          _error = e.toString();
        });
      }
    }
  }

  String get _eta {
    if (_started == null || _progress < 0.02) return '';
    final spent = DateTime.now().difference(_started!).inSeconds;
    final left = (spent / _progress * (1 - _progress)).round();
    return left > 60 ? '~${left ~/ 60} daq ${left % 60} s qoldi' : '~$left s qoldi';
  }

  @override
  Widget build(BuildContext context) {
    final dur = _settings.durationFor(widget.battle).round();
    return AlertDialog(
      icon: const Icon(Icons.movie_creation_outlined),
      title: const Text('Videoga eksport'),
      content: SizedBox(
        width: 460,
        child: switch (_stage) {
          _Stage.settings => Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!videoExportSupported)
                  const Padding(
                    padding: EdgeInsets.only(bottom: 12),
                    child: Text(
                      'Bu qurilma/brauzer video kodlashni qo\'llamaydi. Web versiyani Chrome yoki Edge\'da oching.',
                      style: TextStyle(color: Color(0xFF9E2A2B)),
                    ),
                  ),
                const Text('Sifat', style: TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),
                SegmentedButton<int>(
                  segments: const [
                    ButtonSegment(value: 720, label: Text('720p (tezroq)')),
                    ButtonSegment(value: 1080, label: Text('1080p (Full HD)')),
                  ],
                  selected: {_height},
                  showSelectedIcon: false,
                  onSelectionChanged: (s) => setState(() => _height = s.first),
                ),
                const SizedBox(height: 14),
                const Text('Har bir bosqich uzunligi', style: TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),
                SegmentedButton<double>(
                  segments: const [
                    ButtonSegment(value: 6, label: Text('6 s')),
                    ButtonSegment(value: 8, label: Text('8 s')),
                    ButtonSegment(value: 12, label: Text('12 s')),
                  ],
                  selected: {_secondsPerPhase},
                  showSelectedIcon: false,
                  onSelectionChanged: (s) => setState(() => _secondsPerPhase = s.first),
                ),
                const SizedBox(height: 8),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: _labels,
                  onChanged: (v) => setState(() => _labels = v),
                  title: const Text('Bo\'linma nomlari va askarlar soni'),
                ),
                Text(
                  'Video: sarlavha lavhasi → ${widget.battle.phases.length} ta bosqich → jang yakuni. '
                  'Davomiyligi ~${dur ~/ 60} daq ${dur % 60} s, format WebM (VP9). '
                  'Tayyorlash kompyuter tezligiga qarab bir necha daqiqa oladi — sahifani yopmang.',
                  style: const TextStyle(fontSize: 12.5, color: Colors.black54, height: 1.4),
                ),
              ],
            ),
          _Stage.running => Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(value: _progress, minHeight: 10),
                ),
                const SizedBox(height: 10),
                Text('${(_progress * 100).round()}%  ·  $_status'),
                if (_eta.isNotEmpty) Text(_eta, style: const TextStyle(color: Colors.black54)),
              ],
            ),
          _Stage.done => Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(children: [
                  Icon(Icons.check_circle, color: Color(0xFF27613E)),
                  SizedBox(width: 8),
                  Text('Video tayyor va yuklab olindi', style: TextStyle(fontWeight: FontWeight.w700)),
                ]),
                const SizedBox(height: 10),
                Text('Fayl: ${_result!.fileName}'),
                Text('Hajmi: ${(_result!.bytes / 1024 / 1024).toStringAsFixed(1)} MB'),
                Text('Tayyorlandi: ${_result!.elapsed.inSeconds} soniyada'),
                const SizedBox(height: 8),
                const Text(
                  'WebM faylini Chrome, VLC, Telegram va YouTube ochadi. MP4 kerak bo\'lsa, istalgan '
                  'konvertor (masalan, HandBrake) bilan o\'zgartirish mumkin.',
                  style: TextStyle(fontSize: 12.5, color: Colors.black54, height: 1.4),
                ),
              ],
            ),
          _Stage.failed => Text('Xato: $_error', style: const TextStyle(color: Color(0xFF9E2A2B))),
        },
      ),
      actions: switch (_stage) {
        _Stage.settings => [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Bekor qilish')),
            FilledButton.icon(
              onPressed: videoExportSupported ? _start : null,
              icon: const Icon(Icons.download),
              label: const Text('Videoni yaratish'),
            ),
          ],
        _Stage.running => [
            TextButton(onPressed: () => setState(() => _cancel = true), child: const Text('To\'xtatish')),
          ],
        _ => [FilledButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Yopish'))],
      },
    );
  }
}
