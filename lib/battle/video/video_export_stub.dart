import '../models.dart';
import 'video_renderer.dart';

bool get videoExportSupported => false;

Future<VideoExportResult> exportBattleVideo(
  Battle battle,
  VideoSettings settings, {
  required void Function(double progress, String stage) onProgress,
  bool Function()? isCancelled,
  bool download = true,
}) =>
    throw UnsupportedError('Video eksport hozircha faqat web versiyada ishlaydi.');
