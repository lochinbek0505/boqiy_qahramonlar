import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import '../models.dart';

/// Landshaft rastr tasvirining o'lchami (16:10). Xaritada silliq kattalashtiriladi.
const terrainW = 640;
const terrainH = 400;

/// Har bir jang uchun relyef, dalalar va o'simliklarni protsedural tarzda
/// generatsiya qiladi va keshlaydi. Hisob UI qotib qolmasligi uchun bo'laklab bajariladi.
class TerrainImages {
  static final _cache = <String, Future<ui.Image>>{};
  static final _ready = <String, ui.Image>{};
  static Future<void> _queue = Future.value();

  static ui.Image? ready(Battle b) => _ready[b.id];

  static Future<ui.Image> load(Battle b) => _cache.putIfAbsent(b.id, () {
        final job = _queue.then((_) => _build(b));
        _queue = job.then((_) {}, onError: (_) {});
        return job;
      });

  static Future<ui.Image> _build(Battle b) async {
    final pixels = await generateTerrainPixels(b);
    final c = Completer<ui.Image>();
    ui.decodeImageFromPixels(pixels, terrainW, terrainH, ui.PixelFormat.rgba8888, c.complete);
    final img = await c.future;
    _ready[b.id] = img;
    return img;
  }
}

class _Palette {
  const _Palette(this.low, this.high, this.alt,
      {this.green, this.fields = const [], this.snowPatches = false, this.grain = 0.05});
  final int low, high, alt;
  final int? green;
  final List<int> fields;
  final bool snowPatches;
  final double grain;
}

const _palettes = <Biome, _Palette>{
  Biome.dry: _Palette(0xD8C08A, 0xB08F5E, 0xC9B27A, green: 0x8FA25E),
  Biome.arid: _Palette(0xDCC394, 0xA2804F, 0xCDB184, green: 0x6F9A4E),
  Biome.steppe: _Palette(0xC5C585, 0x9C9F63, 0xB5BD74, green: 0x78A057),
  Biome.frost: _Palette(0xDADBCF, 0xB3B5A6, 0xC8C9B7,
      fields: [0xD2D0BF, 0xC6C4AC, 0xDADBD3, 0xBDBDA5], snowPatches: true),
  Biome.summer: _Palette(0xA7BF7C, 0x7B9455, 0x98B26D,
      fields: [0xB9C77E, 0xD6C98A, 0x9DB86C, 0xC7B777, 0x8FAF63]),
  Biome.spring: _Palette(0xB1C888, 0x86A062, 0xA2BD7A,
      fields: [0xBFD08A, 0xD9D39A, 0xA4C27A, 0xCFC08B, 0x96B872]),
  Biome.snow: _Palette(0xF2F4F5, 0xC9D0D6, 0xE4E8EB, grain: 0.03),
};

// --- shovqin (noise) funksiyalari -------------------------------------------

double _hash(double x, double y, double seed) {
  final v = math.sin(x * 127.1 + y * 311.7 + seed * 74.7) * 43758.5453;
  return v - v.floorToDouble();
}

double _vnoise(double x, double y, double seed) {
  final xi = x.floorToDouble(), yi = y.floorToDouble();
  final xf = x - xi, yf = y - yi;
  final u = xf * xf * (3 - 2 * xf), v = yf * yf * (3 - 2 * yf);
  final a = _hash(xi, yi, seed), b = _hash(xi + 1, yi, seed);
  final c = _hash(xi, yi + 1, seed), d = _hash(xi + 1, yi + 1, seed);
  return (a + (b - a) * u) + ((c + (d - c) * u) - (a + (b - a) * u)) * v;
}

double _fbm(double x, double y, double seed, [int octaves = 4]) {
  var sum = 0.0, amp = 0.5, norm = 0.0, f = 1.0;
  for (var i = 0; i < octaves; i++) {
    sum += amp * _vnoise(x * f, y * f, seed + i * 17);
    norm += amp;
    amp *= 0.5;
    f *= 2.03;
  }
  return sum / norm;
}

/// Qirrali (ridged) shovqin: tog' tizmalari va ular orasidagi jarliklarga o'xshash naqsh.
double _ridged(double x, double y, double seed, [int octaves = 5]) {
  var sum = 0.0, amp = 0.5, norm = 0.0, f = 1.0, weight = 1.0;
  for (var i = 0; i < octaves; i++) {
    var n = 1 - (_vnoise(x * f, y * f, seed + i * 23) * 2 - 1).abs();
    n = n * n * weight;
    weight = (n * 1.8).clamp(0.0, 1.0);
    sum += n * amp;
    norm += amp;
    amp *= 0.5;
    f *= 2.1;
  }
  return sum / norm;
}

double _segDist(double px, double py, double ax, double ay, double bx, double by) {
  final dx = bx - ax, dy = by - ay;
  final len2 = dx * dx + dy * dy;
  var t = len2 == 0 ? 0.0 : ((px - ax) * dx + (py - ay) * dy) / len2;
  t = t.clamp(0.0, 1.0);
  final qx = ax + dx * t - px, qy = ay + dy * t - py;
  return math.sqrt(qx * qx + qy * qy);
}

/// Y o'qi ekranda 0.625 marta qisqaroq (16:10), shuning uchun masofalar shu nisbatda o'lchanadi.
const _aspect = 0.625;

double _polyDist(double x, double y, List<({double x, double y})> pts) {
  var best = double.infinity;
  for (var i = 0; i < pts.length - 1; i++) {
    final d = _segDist(x, y, pts[i].x, pts[i].y, pts[i + 1].x, pts[i + 1].y);
    if (d < best) best = d;
  }
  return best;
}

/// Siniq chiziqqa proyeksiya: masofa, chiziq bo'ylab uzunlik va chiziqqa tik (ishorali) siljish.
({double d, double along, double across}) _polyProj(double x, double y, List<({double x, double y})> pts) {
  var best = double.infinity, along = 0.0, across = 0.0, acc = 0.0;
  for (var i = 0; i < pts.length - 1; i++) {
    final ax = pts[i].x, ay = pts[i].y, dx = pts[i + 1].x - ax, dy = pts[i + 1].y - ay;
    final len = math.sqrt(dx * dx + dy * dy);
    if (len == 0) continue;
    final t = (((x - ax) * dx + (y - ay) * dy) / (len * len)).clamp(0.0, 1.0);
    final qx = ax + dx * t - x, qy = ay + dy * t - y;
    final d = math.sqrt(qx * qx + qy * qy);
    if (d < best) {
      best = d;
      along = acc + t * len;
      across = ((x - ax) * dy - (y - ay) * dx) / len;
    }
    acc += len;
  }
  return (d: best, along: along, across: across);
}

int _mix(int a, int b, double t) {
  t = t.clamp(0.0, 1.0);
  final ar = (a >> 16) & 0xff, ag = (a >> 8) & 0xff, ab = a & 0xff;
  final br = (b >> 16) & 0xff, bg = (b >> 8) & 0xff, bb = b & 0xff;
  return ((ar + (br - ar) * t).round() << 16) | ((ag + (bg - ag) * t).round() << 8) | (ab + (bb - ab) * t).round();
}

double _smooth(double e0, double e1, double x) {
  final t = ((x - e0) / (e1 - e0)).clamp(0.0, 1.0);
  return t * t * (3 - 2 * t);
}

Future<Uint8List> generateTerrainPixels(Battle b) async {
  final pal = _palettes[b.biome]!;
  final seed = b.id.codeUnits.fold<int>(7, (h, c) => (h * 31 + c) % 9973).toDouble();

  List<({double x, double y})> conv(List<ui.Offset> pts) =>
      [for (final o in pts) (x: o.dx, y: o.dy * _aspect)];

  final hills = b.terrain.where((t) => t.kind == TerrainKind.hill).toList();
  final ridges = [
    for (final t in b.terrain.where((t) => t.kind == TerrainKind.mountains)) conv(t.points),
  ];
  final rivers = [
    for (final t in b.terrain.where((t) => t.kind == TerrainKind.river)) (conv(t.points), t.size * 0.2),
  ];
  final forests = b.terrain.where((t) => t.kind == TerrainKind.forest).toList();

  // Hisob UI'ni qotirmasligi uchun har ~6 ms da brauzerga kadr chizishga
  // imkon beriladi (oldin har 20 qatorda — bu bir bo'lakda 30-50 ms edi).
  final budget = Stopwatch()..start();
  Future<void> yieldIfBusy() async {
    if (budget.elapsedMilliseconds < 6) return;
    await Future<void>.delayed(Duration.zero);
    budget.reset();
  }

  final elev = Float32List(terrainW * terrainH);
  final green = Float32List(terrainW * terrainH);

  // 1-bosqich: balandlik xaritasi.
  for (var py = 0; py < terrainH; py++) {
    await yieldIfBusy();
    for (var px = 0; px < terrainW; px++) {
      final x = (px + 0.5) / terrainW * 100;
      final y = (py + 0.5) / terrainH * 100 * _aspect;
      var e = _fbm(x * 0.045, y * 0.045, seed) * 0.45 + _fbm(x * 0.2, y * 0.2, seed + 5, 3) * 0.08;
      // Shakllar ideal ellips/chiziq bo'lmasligi uchun koordinatalar shovqin bilan buriladi.
      final wx = x + (_fbm(x * 0.09, y * 0.09, seed + 51, 3) - 0.5) * 7;
      final wy = y + (_fbm(x * 0.09, y * 0.09, seed + 53, 3) - 0.5) * 7;
      for (final h in hills) {
        final dx = (wx - h.points[0].dx) / (h.size * 1.2);
        final dy = (wy - h.points[0].dy * _aspect) / (h.size * 0.75);
        final r2 = dx * dx + dy * dy;
        if (r2 > 9) continue;
        // Yumaloq, yumshoq tepalik; sirti biroz notekis.
        final body = math.exp(-r2 * 1.4);
        e += body * (0.78 + 0.18 * _fbm(x * 0.22, y * 0.22, seed + 57, 3));
        // Yonbag'irlarda cho'qqidan pastga radial ketuvchi yuvilma jarliklar (cho'qqi va etakda yo'q).
        final rr = math.sqrt(r2), ang = math.atan2(dy, dx), rad = 2.2 + rr * 0.8;
        final gully = _ridged(math.cos(ang) * rad + h.size, math.sin(ang) * rad, seed + 59, 3);
        e -= gully * 0.16 * _smooth(0.2, 0.55, rr) * body;
      }
      for (final r in ridges) {
        final pr = _polyProj(wx, wy, r);
        if (pr.d > 18) continue;
        final mask = math.exp(-(pr.d / 6.5) * (pr.d / 6.5));
        // Real tog' tizmasi yuqoridan: bosh qirra va undan ikki tomonga tik ketuvchi tarmoqlar
        // (yon qirralar), ular orasida jarliklar. Shovqin qirra bo'ylab tez, ko'ndalangiga sekin o'zgaradi.
        final across = pr.across + (_fbm(x * 0.2, y * 0.2, seed + 61, 2) - 0.5) * 3;
        final spurs = _ridged(pr.along * 0.22, across * 0.07, seed + 9, 4);
        final crest = math.exp(-(pr.d / 2.6) * (pr.d / 2.6));
        final peaks = 0.75 + 0.5 * _fbm(pr.along * 0.12, 0, seed + 67, 2);
        e += mask * (0.55 + 0.7 * spurs) * peaks + crest * 0.45 * peaks;
      }
      var g = 0.0;
      for (final (pts, halfW) in rivers) {
        final d = math.max(0.0, _polyDist(x, y, pts) - halfW);
        g = math.max(g, math.exp(-(d / 3.2) * (d / 3.2)));
        e -= math.exp(-(d / 2.5) * (d / 2.5)) * 0.12; // daryo vodiysi
      }
      for (final f in forests) {
        final dx = (x - f.points[0].dx) / (f.size * 1.5);
        final dy = (y - f.points[0].dy * _aspect) / (f.size * 1.0);
        g = math.max(g, math.exp(-(dx * dx + dy * dy) * 1.2) * 0.8);
      }
      final i = py * terrainW + px;
      elev[i] = e;
      green[i] = g;
    }
  }

  // 2-bosqich: rang + relyef soyasi (yorug'lik shimoli-g'arbdan).
  final out = Uint8List(terrainW * terrainH * 4);
  const pixel = 100 / terrainW;
  const relief = 5.0; // relyefni bo'rttirish koeffitsienti (yumshoq qiyaliklar uchun)
  final icy = b.biome == Biome.frost || b.biome == Biome.snow;
  final snowLine = switch (b.biome) {
    Biome.snow => 0.95,
    Biome.frost => 1.15,
    Biome.arid || Biome.dry => 1.6,
    _ => 1.45,
  };
  double at(int px, int py) => elev[py.clamp(0, terrainH - 1) * terrainW + px.clamp(0, terrainW - 1)];
  for (var py = 0; py < terrainH; py++) {
    await yieldIfBusy();
    for (var px = 0; px < terrainW; px++) {
      final i = py * terrainW + px;
      final x = (px + 0.5) / terrainW * 100;
      final y = (py + 0.5) / terrainH * 100 * _aspect;
      final e = elev[i];

      final gx = (at(px + 1, py) - at(px - 1, py)) / (2 * pixel);
      final gy = (at(px, py + 1) - at(px, py - 1)) / (2 * pixel);
      final slope = math.sqrt(gx * gx + gy * gy);
      // Yorug'lik shimoli-g'arbdan: shu tomonga qaragan yonbag'ir yorug', qarama-qarshisi soyada.
      // Tik joylarda bo'rttirish kamayadi — tepaliklar aniq ko'rinadi, tog'lar qop-qora bo'lib ketmaydi.
      final facing = (gx + gy) * math.sqrt1_2;
      final lit = facing * relief / (1 + slope * 4);
      // Egrilik: botiqlar (jarlik, vodiy) biroz to'qroq — tabiiy "ambient occlusion".
      final around = (at(px - 6, py) + at(px + 6, py) + at(px, py - 6) + at(px, py + 6)) / 4;
      final curv = ((around - e) * 3).clamp(-0.08, 0.12);
      // Tekis joy = 0; musbat — quyoshga qaragan, manfiy — soyadagi yonbag'ir.
      final light = (lit - curv).clamp(-0.55, 0.5);
      // Shimolga qaragan (soyali, namroq) yonbag'ir: shimolga qarab balandlik pasayadi.
      final north = (gy > 0 ? gy * 2 : 0.0).clamp(0.0, 1.0);

      var c = _mix(pal.low, pal.high, math.min(e, 1.0) * 1.1);
      c = _mix(c, pal.alt, _smooth(0.42, 0.68, _fbm(x * 0.11, y * 0.11, seed + 3)) * 0.7);

      if (pal.fields.isNotEmpty && e < 0.95) {
        final wx = x + (_fbm(x * 0.08, y * 0.08, seed + 11) - 0.5) * 8;
        final wy = y + (_fbm(x * 0.08, y * 0.08, seed + 13) - 0.5) * 8;
        const cw = 3.4, ch = 2.3;
        final cx = (wx / cw).floorToDouble(), cy = (wy / ch).floorToDouble();
        final pick = pal.fields[(_hash(cx, cy, seed) * pal.fields.length).floor() % pal.fields.length];
        // Tik yonbag'irlarda dala yo'q.
        c = _mix(c, pick, 0.55 * (1 - _smooth(0.2, 0.45, slope)));
        final fx = wx / cw - cx, fy = wy / ch - cy;
        if (fx < 0.07 || fy < 0.09) c = _mix(c, 0x5F7040, 0.22); // dala chegaralari (ariq, butazor)
      }

      if (pal.green != null) c = _mix(c, pal.green!, green[i] * 0.75);
      if (pal.snowPatches) {
        c = _mix(c, 0xEEF1F2, _smooth(0.46, 0.7, _fbm(x * 0.22, y * 0.22, seed + 21)) * 0.45);
      }
      if (b.biome == Biome.snow) {
        c = _mix(c, 0xDCE3E8, _fbm(x * 0.5, y * 0.08, seed + 23, 3) * 0.35); // shamol izlari
      }

      // Tepalik va past tog' yonbag'irlari: o't-butazor, soyali tomonda namroq va to'qroq.
      final upland = _smooth(0.6, 1.0, e) * (1 - _smooth(1.5, 1.9, e));
      if (!icy) c = _mix(c, b.biome == Biome.arid || b.biome == Biome.dry ? 0x9A8F62 : 0x6A8048, upland * (0.08 + north * 0.4));

      // Qoya: balandlikda va tik joylarda ochiladi; qatlamlar (strata) shovqin bilan.
      final strata = _fbm(x * 0.9 + e * 6, y * 0.25, seed + 61, 3);
      final rock = _mix(0x9A8F7E, 0x655C50, strata);
      final rockMask = (_smooth(1.45, 1.9, e) * 0.75 + _smooth(0.28, 0.7, slope) * 0.8).clamp(0.0, 0.92);
      c = _mix(c, rock, rockMask);
      // Ochilgan tuproq/shag'al — o'rtacha qiyalikda.
      c = _mix(c, 0x8A7456, (_smooth(0.12, 0.35, slope) * 0.22) * (1 - rockMask));

      // Qor: yuqorida; soyali yonbag'irda pastroqqacha tushadi, juda tik qoyada ushlanmaydi.
      final snowN = (_fbm(x * 0.4, y * 0.4, seed + 71, 3) - 0.5) * 0.3;
      final snow = _smooth(snowLine, snowLine + 0.35, e + north * 0.18 + snowN) * (1 - _smooth(0.9, 1.5, slope) * 0.6);
      c = _mix(c, 0xE9EDF0, snow * 0.88);

      // Mayda butalar/toshlar — tasodifiy to'q nuqtalar (tekis yerda kam, tepaliklarda ko'proq).
      final speck = _hash(px * 1.7, py * 2.3, seed + 81);
      final shrubs = (0.012 + upland * 0.05 + green[i] * 0.04) * (1 - snow) * (1 - rockMask);
      if (speck < shrubs) c = _mix(c, icy ? 0x5F6B5A : 0x4A5A30, 0.55);

      final texture = (_fbm(x * 1.1, y * 1.1, seed + 41, 2) - 0.5) * 0.14;
      final grain = (_hash(px.toDouble(), py.toDouble(), seed + 31) - 0.5) * pal.grain * 255 + texture * 255;
      // Yoritilgan tomon iliq oqish rangga, soya — sovuq ko'kish-to'q rangga aralashtiriladi
      // (oddiy ko'paytirish yorug' tuproqda oqarib "kuyib" ketadi va tepalik ko'rinmay qoladi).
      c = light >= 0 ? _mix(c, 0xFFF8E6, light * 0.8) : _mix(c, 0x2E3442, -light * 0.9);
      final o = i * 4;
      out[o] = (((c >> 16) & 0xff) + grain).round().clamp(0, 255);
      out[o + 1] = (((c >> 8) & 0xff) + grain).round().clamp(0, 255);
      out[o + 2] = ((c & 0xff) + grain).round().clamp(0, 255);
      out[o + 3] = 255;
    }
  }
  return out;
}
