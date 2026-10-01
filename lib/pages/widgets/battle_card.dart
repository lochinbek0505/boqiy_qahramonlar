import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../battle/map/battle_map.dart';
import '../../battle/models.dart';
import '../../battle/widgets/force_bar.dart';
import '../../core/app_colors.dart';
import '../../core/breakpoints.dart';
import '../../models/battle_model.dart';

/// Jang kartasi: jang oxiridagi holat xaritasi, nomi, sanasi, taktikasi
/// va ikki tomon kuchlari nisbati.
class BattleCard extends StatelessWidget {
  // Har build'da yangi animatsiya obyekti UnitsPainter.shouldRepaint ni true
  // qilib, yuzlab figurani qayta chizdirardi — jang bo'yicha bitta obyekt.
  static final _finalFrame = Expando<Animation<double>>();

  final BattleModel item;
  final bool isMobile;

  const BattleCard({super.key, required this.item, required this.isMobile});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final battle = item.battle;

    final progress = _finalFrame[battle] ??= AlwaysStoppedAnimation(battle.phases.length - 0.01);

    return RepaintBoundary(
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () => context.go('/battles/${item.key}'),
          child: Container(
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: palette.cardBg,
              borderRadius: BorderRadius.circular(12.r),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 15, offset: const Offset(0, 8)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IgnorePointer(
                  child: BattleMap(battle: battle, progress: progress, interactive: false),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 24.w, vertical: isMobile ? 16 : 24.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (battle.commander.isNotEmpty) ...[
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.brown, width: 1.2),
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                          child: Text(
                            battle.commander,
                            style: GoogleFonts.roboto(
                              fontSize: isMobile ? 11 : 12.sp,
                              fontWeight: FontWeight.w700,
                              color: AppColors.brown,
                            ),
                          ),
                        ),
                        SizedBox(height: isMobile ? 12 : 16.h),
                      ],
                      Text(
                        battle.name,
                        style: GoogleFonts.cinzel(
                          fontSize: isMobile ? 18 : 22.sp,
                          fontWeight: FontWeight.bold,
                          color: palette.heading,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        battle.date,
                        style: GoogleFonts.inter(
                          fontSize: isMobile ? 12 : 13.sp,
                          color: palette.textMuted,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: isMobile ? 10 : 14.h),
                      Text(
                        battle.tactic,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.crimsonText(
                          fontSize: isMobile ? 15 : 17.sp,
                          color: palette.textSecondary,
                          height: 1.4,
                        ),
                      ),
                      SizedBox(height: isMobile ? 14 : 18.h),
                      ForceBar(
                        battle: battle,
                        a: battle.soldiersAt(Side.a, 0),
                        b: battle.soldiersAt(Side.b, 0),
                        compact: true,
                      ),
                      SizedBox(height: isMobile ? 14 : 20.h),
                      Row(
                        children: [
                          Icon(Icons.play_circle_outline, size: isMobile ? 18 : 20.sp, color: AppColors.brown),
                          SizedBox(width: 8.w),
                          Text(
                            "Jangni ko'rish",
                            style: GoogleFonts.roboto(
                              fontSize: isMobile ? 14 : 15.sp,
                              color: AppColors.brown,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Kartalarni ekran kengligiga qarab 1/2/3 ustunda joylashtiradi. Grid emas,
/// Wrap ishlatiladi — kartaning balandligi xarita nisbatiga bog'liq.
class BattleCardsWrap extends StatelessWidget {
  final List<BattleModel> battles;
  final bool isMobile;

  const BattleCardsWrap({super.key, required this.battles, required this.isMobile});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final columns = width > Breakpoints.tablet ? 3 : (width > Breakpoints.mobile ? 2 : 1);
    final spacing = isMobile ? 20.0 : 30.w;

    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = (constraints.maxWidth - spacing * (columns - 1)) / columns;
        return Wrap(
          spacing: spacing,
          runSpacing: isMobile ? 20 : 40.h,
          children: [
            for (final b in battles)
              SizedBox(
                width: cardWidth,
                child: BattleCard(item: b, isMobile: isMobile),
              ),
          ],
        );
      },
    );
  }
}
