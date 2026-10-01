import 'dart:convert';
import 'dart:ui' as ui;

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Qo'shin turi, texnika, taktik belgi yoki joy — `assets/units/catalog.json` dagi bitta yozuv.
class UnitKind {
  const UnitKind({
    required this.id,
    required this.nameEn,
    required this.nameUz,
    required this.category,
    required this.era,
    required this.icon,
    required this.source,
  });

  factory UnitKind.fromJson(Map<String, dynamic> j) => UnitKind(
        id: j['id'] as String,
        nameEn: j['name_en'] as String,
        nameUz: j['name_uz'] as String,
        category: j['category'] as String,
        era: j['era'] as String,
        icon: j['icon'] as String,
        source: j['source'] as String,
      );

  final String id;
  final String nameEn;
  final String nameUz;
  final String category;

  /// historical, modern yoki both
  final String era;

  /// SVG fayl yo'li (assets ichida).
  final String icon;
  final String source;
}

const categoryNames = <String, String>{
  'infantry': 'Piyoda qo\'shin',
  'cavalry': 'Otliq qo\'shin',
  'siege': 'Maxsus kuchlar va qamal texnikasi',
  'command': 'Qo\'mondonlik',
  'ground': 'Quruqlikdagi qo\'shinlar',
  'vehicles': 'Texnika',
  'artillery': 'Artilleriya va raketalar',
  'air_defense': 'Havo hujumidan mudofaa',
  'air': 'Havo kuchlari',
  'naval': 'Dengiz kuchlari',
  'support': 'Ta\'minot va yordam',
  'tactical': 'Taktik belgilar',
  'terrain': 'Relyef va joy',
};

const eraNames = <String, String>{
  'historical': 'Tarixiy qo\'shinlar',
  'modern': 'Zamonaviy qo\'shinlar',
  'both': 'Taktik belgilar, relyef va joy',
};

/// Katalog va ikonlar keshi. [load] ilova ishga tushganda bir marta chaqiriladi.
class UnitCatalog {
  static final _kinds = <String, UnitKind>{};
  static List<UnitKind> _all = const [];

  static List<UnitKind> get all => _all;
  static UnitKind? byId(String id) => _kinds[id];
  static String iconPath(String id) => 'assets/icons/units/$id.svg';
  static bool get isLoaded => _all.isNotEmpty;

  static Future<void> load([AssetBundle? bundle]) async {
    if (isLoaded) return;
    final raw = await (bundle ?? rootBundle).loadString('assets/units/catalog.json');
    _all = [for (final e in jsonDecode(raw) as List) UnitKind.fromJson(e as Map<String, dynamic>)];
    for (final k in _all) {
      _kinds[k.id] = k;
    }
  }

  // --- Kanvasda chizish uchun rastrlangan ikonlar -------------------------------

  static final _images = <String, ui.Image>{};
  static final _loading = <String>{};

  /// Yangi ikon tayyor bo'lganda oshadi — rassomlar (painter) qayta chiziladi.
  static final version = ValueNotifier<int>(0);

  /// Kanvas uchun oq-qora (keyin bo'yaladigan) ikon, hali tayyor bo'lmasa null.
  static ui.Image? image(String id) {
    final img = _images[id];
    if (img == null) _rasterize(id);
    return img;
  }

  static Future<void> _rasterize(String id) async {
    if (!_loading.add(id)) return;
    try {
      final info = await vg.loadPicture(SvgAssetLoader(iconPath(id)), null);
      const px = 96;
      final rec = ui.PictureRecorder();
      final canvas = Canvas(rec);
      canvas.scale(px / info.size.width, px / info.size.height);
      canvas.drawPicture(info.picture);
      final img = await rec.endRecording().toImage(px, px);
      info.picture.dispose();
      _images[id] = img;
      version.value++;
    } catch (e) {
      debugPrint('Ikon yuklanmadi: $id ($e)');
    }
  }
}

/// Katalogdagi SVG ikonni berilgan rangda ko'rsatadi.
class KindIcon extends StatelessWidget {
  const KindIcon(this.id, {super.key, this.size = 22, this.color = const Color(0xFF2B2118)});
  final String id;
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) => SvgPicture.asset(
        UnitCatalog.iconPath(id),
        width: size,
        height: size,
        colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
      );
}

/// Rangli doira ichida oq ikon — xaritadagi bo'linma belgisi bilan bir xil ko'rinish.
class KindBadge extends StatelessWidget {
  const KindBadge(this.id, this.color, {super.key, this.size = 30});
  final String id;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        padding: EdgeInsets.all(size * 0.17),
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFFFFFBF2), width: 1.5),
          boxShadow: const [BoxShadow(color: Color(0x33000000), blurRadius: 3, offset: Offset(0, 1))],
        ),
        child: KindIcon(id, size: size * 0.66, color: const Color(0xFFFFFFFF)),
      );
}
