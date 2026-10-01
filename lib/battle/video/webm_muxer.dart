import 'dart:typed_data';

/// Kodlangan bitta video kadr (VP8/VP9).
class EncodedFrame {
  const EncodedFrame(this.data, this.timestampMicros, {required this.key});
  final Uint8List data;
  final int timestampMicros;
  final bool key;
}

/// Oddiy WebM (Matroska) konteyner yozuvchisi: bitta video trek, har kalit kadrda yangi
/// klaster, boshida SeekHead va oxirida Cues (videoni istalgan joyidan qo'yish uchun).
///
/// Tashqi kutubxonasiz ishlaydi, natija Chrome, Firefox, VLC va YouTube'da ochiladi.
class WebmMuxer {
  WebmMuxer({required this.width, required this.height, required this.codec});

  final int width;
  final int height;

  /// 'V_VP9' yoki 'V_VP8'.
  final String codec;

  final _frames = <EncodedFrame>[];

  void add(EncodedFrame f) => _frames.add(f);
  int get frameCount => _frames.length;

  Uint8List finish({required double durationMs}) {
    // 1) Klasterlar (har bir kalit kadrdan boshlanadi, nisbiy vaqt 16 bitga sig'ishi kerak).
    final clusters = <(int timeMs, Uint8List bytes)>[];
    var current = BytesBuilder(copy: false);
    var clusterTime = -1;
    void flush() {
      if (clusterTime < 0) return;
      final payload = BytesBuilder(copy: false)
        ..add(_uintEl(0xE7, clusterTime))
        ..add(current.takeBytes());
      clusters.add((clusterTime, _el(_idCluster, payload.takeBytes())));
    }

    for (final f in _frames) {
      final t = (f.timestampMicros / 1000).round();
      if (clusterTime < 0 || f.key || t - clusterTime > 30000) {
        flush();
        current = BytesBuilder(copy: false);
        clusterTime = t;
      }
      final rel = t - clusterTime;
      final block = BytesBuilder()
        ..addByte(0x81) // trek raqami 1 (vint)
        ..addByte((rel >> 8) & 0xFF)
        ..addByte(rel & 0xFF)
        ..addByte(f.key ? 0x80 : 0x00)
        ..add(f.data);
      current.add(_el(0xA3, block.takeBytes()));
    }
    flush();

    // 2) Info va Tracks.
    final info = _el(0x1549A966, [
      ..._uintEl(0x2AD7B1, 1000000), // vaqt birligi — 1 ms
      ..._el(0x4489, _float64(durationMs)),
      ..._el(0x4D80, _ascii('war_startegy')),
      ..._el(0x5741, _ascii('war_startegy')),
    ]);
    final tracks = _el(0x1654AE6B, _el(0xAE, [
      ..._uintEl(0xD7, 1),
      ..._uintEl(0x73C5, 1),
      ..._uintEl(0x83, 1), // video
      ..._el(0x86, _ascii(codec)),
      ..._el(0xE0, [..._uintEl(0xB0, width), ..._uintEl(0xBA, height)]),
    ]));

    // 3) SeekHead — o'lchami qat'iy (pozitsiyalar 8 baytda), shuning uchun oldindan hisoblanadi.
    List<int> seek(int id, int pos) => _el(0x4DBB, [..._el(0x53AB, _idBytes(id)), ..._el(0x53AC, _uint8(pos))]);
    final seekHeadLen = _el(0x114D9B74, [...seek(0x1549A966, 0), ...seek(0x1654AE6B, 0), ...seek(0x1C53BB6B, 0)]).length;
    final infoPos = seekHeadLen;
    final tracksPos = infoPos + info.length;
    var pos = tracksPos + tracks.length;
    final cuePoints = <int>[];
    for (final (time, bytes) in clusters) {
      cuePoints.addAll(_el(0xBB, [
        ..._uintEl(0xB3, time),
        ..._el(0xB7, [..._uintEl(0xF7, 1), ..._uintEl(0xF1, pos)]),
      ]));
      pos += bytes.length;
    }
    final cuesPos = pos;
    final cues = _el(0x1C53BB6B, cuePoints);
    final seekHead = _el(0x114D9B74, [...seek(0x1549A966, infoPos), ...seek(0x1654AE6B, tracksPos), ...seek(0x1C53BB6B, cuesPos)]);

    final body = BytesBuilder()
      ..add(seekHead)
      ..add(info)
      ..add(tracks);
    for (final (_, bytes) in clusters) {
      body.add(bytes);
    }
    body.add(cues);
    final segment = body.takeBytes();

    final header = _el(0x1A45DFA3, [
      ..._uintEl(0x4286, 1),
      ..._uintEl(0x42F7, 1),
      ..._uintEl(0x42F2, 4),
      ..._uintEl(0x42F3, 8),
      ..._el(0x4282, _ascii('webm')),
      ..._uintEl(0x4287, 4),
      ..._uintEl(0x4285, 2),
    ]);
    return (BytesBuilder()
          ..add(header)
          ..add(_idBytes(0x18538067))
          ..add(_size(segment.length))
          ..add(segment))
        .takeBytes();
  }

  static const _idCluster = 0x1F43B675;

  static List<int> _idBytes(int id) {
    final out = <int>[];
    var v = id;
    while (v > 0) {
      out.insert(0, v & 0xFF);
      v >>= 8;
    }
    return out;
  }

  /// EBML o'lchami (vint): eng qisqa uzunlikda.
  static List<int> _size(int n) {
    // Webda bit siljitish 32 bit bilan cheklangan, shuning uchun ko'paytma bilan hisoblaymiz.
    var limit = 128;
    for (var len = 1; len <= 8; len++, limit *= 128) {
      final max = limit - 2;
      if (n <= max) {
        final out = List<int>.filled(len, 0);
        var v = n;
        for (var i = len - 1; i >= 0; i--) {
          out[i] = v % 256;
          v ~/= 256;
        }
        out[0] |= 0x80 >> (len - 1);
        return out;
      }
    }
    throw ArgumentError('Juda katta element: $n');
  }

  static Uint8List _el(int id, List<int> payload) => (BytesBuilder(copy: false)
        ..add(_idBytes(id))
        ..add(_size(payload.length))
        ..add(payload))
      .takeBytes();

  static List<int> _uint(int v) {
    if (v == 0) return [0];
    final out = <int>[];
    var x = v;
    while (x > 0) {
      out.insert(0, x % 256);
      x ~/= 256;
    }
    return out;
  }

  static List<int> _uint8(int v) {
    final out = List<int>.filled(8, 0);
    var x = v;
    for (var i = 7; i >= 0; i--) {
      out[i] = x % 256;
      x ~/= 256;
    }
    return out;
  }

  static List<int> _uintEl(int id, int v) => _el(id, _uint(v));

  static List<int> _float64(double v) {
    final b = ByteData(8)..setFloat64(0, v);
    return b.buffer.asUint8List();
  }

  static List<int> _ascii(String s) => s.codeUnits;
}
