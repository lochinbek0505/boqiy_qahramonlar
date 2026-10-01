import 'dart:async';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';
import 'dart:typed_data';

import 'package:web/web.dart' as web;

import '../models.dart';
import 'video_renderer.dart';
import 'webm_muxer.dart';

/// Brauzer WebCodecs'ni qo'llab-quvvatlaydimi (Chrome, Edge, Opera, yangi Safari va Firefox).
bool get videoExportSupported => globalContext.has('VideoEncoder');

Future<VideoExportResult> exportBattleVideo(
  Battle battle,
  VideoSettings settings, {
  required void Function(double progress, String stage) onProgress,
  bool Function()? isCancelled,
  bool download = true,
}) async {
  final started = DateTime.now();
  final w = settings.width, h = settings.height, fps = settings.fps;
  onProgress(0, 'Xarita va ikonlar tayyorlanmoqda…');
  final renderer = BattleVideoRenderer(battle, settings);
  await renderer.prepare();

  onProgress(0, 'Video kodek tanlanmoqda…');
  // Kodek tanlash: VP9 (sifatli, kichik fayl), bo'lmasa VP8.
  final bitrate = (w * h * fps * 0.12).round();
  web.VideoEncoderConfig config(String codec) =>
      web.VideoEncoderConfig(codec: codec, width: w, height: h, bitrate: bitrate, framerate: fps);
  String? codec, matroskaCodec;
  for (final (c, m) in [('vp09.00.31.08', 'V_VP9'), ('vp8', 'V_VP8')]) {
    try {
      // Ba'zi brauzerlarda bu so'rov javobsiz qolishi mumkin — 3 soniyadan so'ng VP9 bilan urinib ko'ramiz.
      final support = await web.VideoEncoder.isConfigSupported(config(c))
          .toDart
          .then<bool?>((s) => s.supported)
          .timeout(const Duration(seconds: 3), onTimeout: () => null);
      if (support ?? true) {
        codec = c;
        matroskaCodec = m;
        break;
      }
    } catch (_) {}
  }
  if (codec == null) {
    throw UnsupportedError('Brauzeringiz video kodlashni qo\'llamaydi. Chrome yoki Edge\'ning yangi versiyasini ishlating.');
  }

  final muxer = WebmMuxer(width: w, height: h, codec: matroskaCodec!);
  String? encoderError;
  final encoder = web.VideoEncoder(web.VideoEncoderInit(
    output: ((web.EncodedVideoChunk chunk, JSAny? meta) {
      final buf = Uint8List(chunk.byteLength);
      chunk.copyTo(buf.toJS);
      muxer.add(EncodedFrame(buf, chunk.timestamp, key: chunk.type == 'key'));
    }).toJS,
    error: ((web.DOMException e) {
      encoderError = e.message;
    }).toJS,
  ));
  encoder.configure(config(codec));

  onProgress(0, 'Kadrlar chizish boshlandi ($codec)…');
  final total = settings.frameCountFor(battle);
  final frameUs = 1000000 ~/ fps;
  try {
    for (var i = 0; i < total; i++) {
      if (isCancelled?.call() ?? false) throw const VideoExportCancelled();
      if (encoderError != null) throw StateError('Kodlashda xato: $encoderError');
      final rgba = await renderer.renderFrame(i);
      final frame = web.VideoFrame(
        rgba.toJS,
        web.VideoFrameBufferInit(format: 'RGBA', codedWidth: w, codedHeight: h, timestamp: i * frameUs, duration: frameUs),
      );
      // Har 2 soniyada kalit kadr — videoni istalgan joyidan ko'rish uchun.
      encoder.encode(frame, web.VideoEncoderEncodeOptions(keyFrame: i % (fps * 2) == 0));
      frame.close();
      while (encoder.encodeQueueSize > 4) {
        await Future<void>.delayed(const Duration(milliseconds: 4));
      }
      if (i % 3 == 0) {
        onProgress(i / total, 'Kadrlar tayyorlanmoqda: $i / $total');
        await Future<void>.delayed(Duration.zero);
      }
    }
    onProgress(0.99, 'Video yakunlanmoqda…');
    await encoder.flush().toDart;
  } finally {
    if (encoder.state != 'closed') encoder.close();
  }

  final bytes = muxer.finish(durationMs: total * 1000 / fps);
  final fileName = 'jang_${battle.id}_${h}p.webm';
  if (!download) {
    return VideoExportResult(
        fileName: fileName, bytes: bytes.length, elapsed: DateTime.now().difference(started), data: bytes);
  }
  final blob = web.Blob(<JSAny>[bytes.toJS].toJS, web.BlobPropertyBag(type: 'video/webm'));
  final url = web.URL.createObjectURL(blob);
  final a = web.HTMLAnchorElement()
    ..href = url
    ..download = fileName;
  web.document.body!.append(a);
  a.click();
  a.remove();
  Future<void>.delayed(const Duration(seconds: 30), () => web.URL.revokeObjectURL(url));
  onProgress(1, 'Tayyor');
  return VideoExportResult(fileName: fileName, bytes: bytes.length, elapsed: DateTime.now().difference(started));
}
