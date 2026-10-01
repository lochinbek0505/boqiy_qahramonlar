/// Qo'shin turlari va ularning xatti-harakati.
///
/// Har bir [UnitType] o'z xususiyatlarini o'zi saqlaydi: saf shakli ([Formation]),
/// xaritadagi figurasi ([Glyph]), quroli ([Weapon]) va otish masofasi, qayerda
/// harakatlanishi ([Domain]) hamda katalogdagi SVG ikoni. Shuning uchun yangi tur
/// qo'shish — shu yerga bitta qator yozish demakdir; chizish kodi o'zi moslashadi.
library;

/// Saf shakli — figuralar qanday joylashadi.
enum Formation {
  block, // zich to'g'ri to'rtburchak (oddiy piyoda)
  phalanx, // chuqur, juda zich blok (nayzador, falanga)
  line, // uzun 2–3 qatorli chiziq (kamonchi, mushketyor)
  wedge, // pona — uchi dushmanga (og'ir otliq, tanklar)
  swarm, // tarqoq to'da (otliq kamonchi, dronlar)
  battery, // qurollar qatori (to'p, katapulta, gaubitsa)
  column, // yurish kolonnasi (ta'minot, BTR)
  vee, // «V» shakl (samolyotlar, vertolyotlar, kemalar)
  cluster, // zamonaviy piyoda — kichik guruhlar, bir-biridan uzoqroq
  fortLine, // qo'zg'almas bunkerlar qatori
  single, // bitta belgi (qo'mondon)
}

/// Xaritadagi bitta figura qanday chiziladi.
enum Glyph {
  footman,
  spearman,
  pikeman,
  swordsman,
  archer,
  crossbowman,
  musketeer,
  lightHorse,
  heavyHorse,
  horseArcher,
  camel,
  elephant,
  catapult,
  cannon,
  commander,
  rifleman,
  apc,
  tank,
  howitzer,
  rocketLauncher,
  antiTankGun,
  aaGun,
  plane,
  fighter,
  helicopter,
  drone,
  bunker,
  truck,
  ship,
}

/// Qurol turi — jang effekti shunga qarab chiziladi.
enum Weapon {
  none,
  melee, // qilich, nayza: uchqunlar va chang
  arrows, // kamon o'qlari yomg'iri
  bolts, // arbalet: tekis va tez o'qlar
  musket, // miltiq zalpi: chaqnash va oq tutun
  stones, // katapulta toshlari
  cannonball, // to'p o'qi
  rifle, // miltiq trasserlari
  machineGun, // pulemyot: tez, zich trasserlar
  tankGun, // tank to'pi
  shells, // gaubitsa: baland yoy va katta portlash
  rockets, // reaktiv snaryadlar zalpi
  bombs, // aviabombalar
  strafe, // qiruvchining pulemyot zarbasi
  flak, // zenit: havodagi portlashlar
  missile, // boshqariladigan raketa (dron, PTUR)
}

enum Domain { ground, air, sea, fixed }

enum UnitType {
  // --- Tarixiy piyoda -------------------------------------------------------
  infantry('Piyoda', 'Zich saflar — har bir nuqta bir guruh askar', Formation.block, Glyph.footman, Weapon.melee,
      icon: 'infantry', modernIcon: 'rifleman', modernGlyph: Glyph.rifleman, modernWeapon: Weapon.rifle, range: 14),
  spearman('Nayzador', 'Chuqur saf, nayzalar oldinga qaratilgan — otliqqa qarshi devor', Formation.phalanx,
      Glyph.spearman, Weapon.melee,
      icon: 'spearman'),
  pikeman('Uzun nayzali askar (falanga)', 'Juda zich va chuqur blok, uzun nayzalar bir necha qator oldinga chiqadi',
      Formation.phalanx, Glyph.pikeman, Weapon.melee,
      icon: 'pikeman'),
  swordsman('Qilichboz', 'Qalqon va qilichli zich saf, yaqin jangda kuchli', Formation.block, Glyph.swordsman,
      Weapon.melee,
      icon: 'swordsman'),
  heavyInfantry('Og\'ir zirhli piyoda', 'Katta qalqonlar bilan yopilgan sekin, lekin mustahkam saf', Formation.block,
      Glyph.swordsman, Weapon.melee,
      icon: 'heavy_infantry', spacing: 1.15),
  archer('Kamonchi', 'Siyrak chiziq, baland yoy bo\'ylab o\'q yomg\'iri yog\'diradi', Formation.line, Glyph.archer,
      Weapon.arrows,
      icon: 'archer', range: 24),
  crossbowman('Arbaletchi', 'Chiziq; o\'qlari tekis va kuchli, lekin sekin qayta o\'qlanadi', Formation.line,
      Glyph.crossbowman, Weapon.bolts,
      icon: 'crossbowman', range: 18),
  musketeer('Miltiqchi (chiziqli piyoda)', '2–3 qatorli chiziq, zalp bilan otadi, atrofni oq tutun qoplaydi',
      Formation.line, Glyph.musketeer, Weapon.musket,
      icon: 'musketeer', range: 11),

  // --- Tarixiy otliq --------------------------------------------------------
  cavalry('Otliq', 'Pona shaklidagi otliqlar', Formation.wedge, Glyph.lightHorse, Weapon.melee,
      icon: 'light_cavalry', heavy: true),
  lightCavalry('Yengil otliq', 'Tez, siyrak pona; ta\'qib va razvedka uchun', Formation.wedge, Glyph.lightHorse,
      Weapon.melee,
      icon: 'light_cavalry', heavy: true, spacing: 1.9),
  heavyCavalry('Og\'ir otliq (ritsar)', 'Zirhli otlar, zarba paytida nayzalar pastga tushadi', Formation.wedge,
      Glyph.heavyHorse, Weapon.melee,
      icon: 'heavy_cavalry', heavy: true, spacing: 1.6),
  horseArcher('Otliq kamonchi', 'Tarqoq to\'da, doim aylanib turadi va uzoqdan o\'q uzadi', Formation.swarm,
      Glyph.horseArcher, Weapon.arrows,
      icon: 'horse_archer', heavy: true, range: 22),
  camelry('Tuyali askar', 'Tuyalar hidi otlarni cho\'chitadi; cho\'lda chidamli', Formation.wedge, Glyph.camel,
      Weapon.melee,
      icon: 'camel_rider', heavy: true, spacing: 2.0),

  // --- Maxsus va qamal ------------------------------------------------------
  elephant('Jang fillari', 'Ustida minorasi bor yirik fillar — dushman safini oyoq osti qiladi', Formation.line,
      Glyph.elephant, Weapon.melee,
      icon: 'war_elephant', heavy: true, spacing: 3.2),
  siegeEngine('Qamal mashinasi (katapulta, manjaniq)', 'Og\'ir toshlarni baland yoy bo\'ylab otadi',
      Formation.battery, Glyph.catapult, Weapon.stones,
      icon: 'trebuchet', range: 36, spacing: 3.0),
  artillery('To\'p (artilleriya)', 'To\'plar qatori: otilganda tutun, snaryad yoy bo\'ylab uchadi', Formation.battery,
      Glyph.cannon, Weapon.cannonball,
      icon: 'cannon', modernIcon: 'towed_artillery', modernGlyph: Glyph.howitzer, modernWeapon: Weapon.shells,
      range: 40, spacing: 2.3),

  // --- Qo'mondonlik ---------------------------------------------------------
  hq('Qo\'mondon shtabi', 'Chodir, bayroq va soqchilar', Formation.single, Glyph.commander, Weapon.none,
      icon: 'commander', modernIcon: 'headquarters'),

  // --- Zamonaviy quruqlik ---------------------------------------------------
  rifleman('Piyoda (miltiqli)', 'Kichik guruhlarga bo\'lingan siyrak saf, trasserlar bilan otadi', Formation.cluster,
      Glyph.rifleman, Weapon.rifle,
      icon: 'rifleman', range: 14),
  mechanized('Motoo\'qchilar (BTR bilan)', 'Zirhli transportyorlar kolonnasi, pulemyot bilan otadi',
      Formation.column, Glyph.apc, Weapon.machineGun,
      icon: 'apc', heavy: true, range: 16, spacing: 2.3),
  armor('Tank', 'Tanklar ponasi, izidan tutun qoladi, to\'pdan otadi', Formation.wedge, Glyph.tank, Weapon.tankGun,
      icon: 'light_tank', heavy: true, range: 20, spacing: 2.4),
  howitzer('Gaubitsa (dala artilleriyasi)', 'Uzoqdan baland yoy bo\'ylab otadi, katta portlashlar', Formation.battery,
      Glyph.howitzer, Weapon.shells,
      icon: 'towed_artillery', range: 50, spacing: 2.4),
  rocketArtillery('Reaktiv artilleriya (RSZO)', 'Bir zumda o\'nlab raketa uchiradi — maydon bo\'ylab portlashlar',
      Formation.battery, Glyph.rocketLauncher, Weapon.rockets,
      icon: 'mlrs', range: 55, spacing: 2.6),
  antiTank('Tankka qarshi qurol', 'Pistirmadan tanklarni urish uchun past, yashirin qurollar', Formation.battery,
      Glyph.antiTankGun, Weapon.tankGun,
      icon: 'anti_tank_team', range: 18, spacing: 2.2),
  airDefense('Havo hujumidan mudofaa (zenit)', 'Samolyotlarga qarata otadi — osmonda qora portlashlar',
      Formation.battery, Glyph.aaGun, Weapon.flak,
      icon: 'aa_gun', range: 32, spacing: 2.4),
  fortification('Istehkom (bunker, dot)', 'Qo\'zg\'almas beton nuqtalar qatori, pulemyotlardan otadi',
      Formation.fortLine, Glyph.bunker, Weapon.machineGun,
      icon: 'fortification', domain: Domain.fixed, range: 14, spacing: 3.0),
  supply('Ta\'minot kolonnasi', 'Yuk mashinalari: o\'q-dori, yoqilg\'i, oziq-ovqat', Formation.column, Glyph.truck,
      Weapon.none,
      icon: 'military_truck', heavy: true, spacing: 2.2),

  // --- Havo ------------------------------------------------------------------
  air('Bombardimonchi / shturmovik', 'Samolyotlar zvenosi nishon ustida aylanadi va bomba tashlaydi', Formation.vee,
      Glyph.plane, Weapon.bombs,
      icon: 'bomber', domain: Domain.air, range: 24, spacing: 3.0),
  fighter('Qiruvchi samolyot', 'Tez aylanib uchadi, pulemyotdan o\'q uzib o\'tadi', Formation.vee, Glyph.fighter,
      Weapon.strafe,
      icon: 'fighter_jet', domain: Domain.air, range: 26, spacing: 2.6),
  helicopter('Jangovar vertolyot', 'Past balandlikda muallaq turadi, raketalar uchiradi', Formation.vee,
      Glyph.helicopter, Weapon.rockets,
      icon: 'attack_helicopter', domain: Domain.air, range: 20, spacing: 3.2),
  drone('Dron (uchuvchisiz apparat)', 'Kichik to\'da, nishon ustida muallaq turib zarba beradi', Formation.swarm,
      Glyph.drone, Weapon.missile,
      icon: 'attack_drone', domain: Domain.air, range: 24, spacing: 2.4),

  // --- Dengiz ----------------------------------------------------------------
  naval('Harbiy kemalar', 'Kemalar guruhi to\'plardan qirg\'oqqa o\'q uzadi', Formation.vee, Glyph.ship,
      Weapon.shells,
      icon: 'destroyer', domain: Domain.sea, range: 45, spacing: 3.4);

  const UnitType(
    this.nameUz,
    this.hint,
    this.formation,
    this.glyph,
    this.weapon, {
    required this.icon,
    this.modernIcon,
    this.modernGlyph,
    this.modernWeapon,
    this.range = 0,
    this.spacing = 0,
    this.heavy = false,
    this.domain = Domain.ground,
  });

  /// O'zbekcha nomi.
  final String nameUz;

  /// Xaritada qanday ko'rinishi haqida qisqa izoh.
  final String hint;

  final Formation formation;
  final Glyph glyph;
  final Weapon weapon;

  /// Katalogdagi SVG ikon id'si (`assets/units/catalog.json`).
  final String icon;

  /// XX asr janglarida o'rniga ishlatiladigan ikon, figura va qurol (masalan, oddiy
  /// «infantry» 1914-yilda miltiqli piyodaga aylanadi).
  final String? modernIcon;
  final Glyph? modernGlyph;
  final Weapon? modernWeapon;

  /// Uzoqdan otish masofasi (xarita birliklarida, 0 — faqat yaqin jang).
  final double range;

  /// Figuralar orasidagi masofa (figura o'lchamiga nisbatan). 0 — saf turiga qarab.
  final double spacing;

  /// Harakatda chang/tutun ko'taradimi (otliq, texnika).
  final bool heavy;

  final Domain domain;

  bool get isAirborne => domain == Domain.air;
  bool get isStatic => domain == Domain.fixed;
  bool get isCommand => formation == Formation.single;

  /// Otliqmi (zarba — «charge» — holati uchun).
  bool get isMounted =>
      glyph == Glyph.lightHorse ||
      glyph == Glyph.heavyHorse ||
      glyph == Glyph.horseArcher ||
      glyph == Glyph.camel ||
      glyph == Glyph.elephant;

  bool get isVehicle => const {
        Glyph.apc,
        Glyph.tank,
        Glyph.truck,
        Glyph.howitzer,
        Glyph.rocketLauncher,
        Glyph.antiTankGun,
        Glyph.aaGun,
      }.contains(glyph);

  Glyph glyphFor({required bool modern}) => modern ? (modernGlyph ?? glyph) : glyph;
  Weapon weaponFor({required bool modern}) => modern ? (modernWeapon ?? weapon) : weapon;
  String iconFor({required bool modern}) => modern ? (modernIcon ?? icon) : icon;

  double get figureSpacing {
    if (spacing > 0) return spacing;
    return switch (formation) {
      Formation.block || Formation.phalanx => 1.25,
      Formation.line => 1.35,
      Formation.wedge => 1.7,
      Formation.swarm => 1.9,
      Formation.cluster => 1.5,
      Formation.battery => 2.3,
      Formation.column => 2.2,
      Formation.vee => 3.0,
      Formation.fortLine => 3.0,
      Formation.single => 1,
    };
  }
}

/// Bo'linmaning bosqichdagi holati — animatsiya shunga qarab o'zgaradi.
enum Stance {
  hold('Joyida turibdi'),
  advance('Oldinga siljimoqda'),
  charge('Zarba bermoqda (hujum)'),
  defend('Mudofaada'),
  retreat('Tartibli chekinmoqda'),
  rout('Tartibsiz qochmoqda'),
  surrender('Taslim bo\'lmoqda'),
  hidden('Yashirin (pistirmada)');

  const Stance(this.nameUz);
  final String nameUz;
}
