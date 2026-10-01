import 'package:boqiy_qahramonlar/pages/footer_widget.dart';
import 'package:boqiy_qahramonlar/pages/widgets/battle_card.dart';
import 'package:boqiy_qahramonlar/provider/battle_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/app_colors.dart';
import '../core/breakpoints.dart';
import 'desctop_appbar_widget.dart';

class BattlesPage extends ConsumerWidget {
  const BattlesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    double width = MediaQuery.of(context).size.width;
    bool isMobile = width < Breakpoints.mobile;
    final palette = context.palette;

    final battleState = ref.watch(battleProvider);

    return Scaffold(
      backgroundColor: palette.background,
      endDrawer: width < Breakpoints.tablet ? const MobileMenuDrawer() : null,
      appBar: AppBar(
        title: const DesctopAppbarWidget(),
        scrolledUnderElevation: 0.0,
        surfaceTintColor: Colors.transparent,
        backgroundColor: palette.appbarBg,
        toolbarHeight: 90.h,
        automaticallyImplyLeading: false,
        // Drawer'ni appbar ichidagi o'z menyu tugmasi ochadi — AppBar'ning
        // avtomatik qo'shadigan ikkinchi tugmasini o'chirish uchun.
        actions: const [SizedBox.shrink()],
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: isMobile ? 20.w : 70.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: isMobile ? 24.h : 40.h),
                  // Breadcrumb
                  Row(
                    children: [
                      InkWell(
                        onTap: () => context.go('/'),
                        borderRadius: BorderRadius.circular(4.r),
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 4.h, horizontal: 2.w),
                          child: Text(
                            "Bosh sahifa",
                            style: GoogleFonts.inter(
                              fontSize: isMobile ? 12.sp : 14.sp,
                              color: palette.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.w),
                        child: Icon(Icons.chevron_right, size: isMobile ? 16.sp : 18.sp, color: palette.textMuted),
                      ),
                      Text(
                        "Janglar",
                        style: GoogleFonts.inter(
                          fontSize: 12.sp,
                          color: AppColors.brown,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: isMobile ? 10.h : 16.h),
                  Text(
                    "Buyuk Janglar",
                    style: GoogleFonts.notoSansHebrew(
                      fontSize: isMobile ? 28.sp : 42.sp,
                      fontWeight: FontWeight.w700,
                      color: palette.textPrimary,
                      letterSpacing: -0.5,
                    ),
                  ),
                  SizedBox(height: isMobile ? 8.h : 12.h),
                  Text(
                    "Tarixiy janglar relyefli xaritada bosqichma-bosqich: har bir qo'shin turi o'z shaklida, "
                    "askarlar soni esa bo'linma kattaligida ko'rinadi.",
                    style: GoogleFonts.inter(
                      fontSize: isMobile ? 13.sp : 16.sp,
                      color: palette.textSecondary,
                      height: 1.5,
                    ),
                  ),
                  SizedBox(height: isMobile ? 8.h : 12.h),
                  TextButton.icon(
                    onPressed: () => context.go('/battles/types'),
                    icon: const Icon(Icons.menu_book, color: AppColors.brown),
                    label: Text(
                      "Qo'shin turlari lug'ati",
                      style: GoogleFonts.inter(color: AppColors.brown, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (battleState.isLoading)
            const SliverFillRemaining(child: Center(child: CircularProgressIndicator()))
          else if (battleState.error != null)
            SliverFillRemaining(child: Center(child: Text(battleState.error!)))
          else ...[
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: isMobile ? 20 : 70.w, vertical: isMobile ? 30 : 60.h),
              sliver: SliverToBoxAdapter(
                child: battleState.battles.isEmpty
                    ? Center(
                        child: Text(
                          "Hozircha janglar qo'shilmagan",
                          style: GoogleFonts.inter(color: palette.textSecondary),
                        ),
                      )
                    : BattleCardsWrap(battles: battleState.battles, isMobile: isMobile),
              ),
            ),
            SliverToBoxAdapter(
              child: Column(
                children: [
                  SizedBox(height: isMobile ? 30 : 50.h),
                  const FooterWidget(),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
