import 'package:boqiy_qahramonlar/core/utils.dart';
import 'package:boqiy_qahramonlar/pages/footer_widget.dart';
import 'package:boqiy_qahramonlar/provider/history_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/app_colors.dart';
import '../core/breakpoints.dart';
import 'desctop_appbar_widget.dart';

class PersonsPage extends ConsumerStatefulWidget {
  const PersonsPage({super.key});

  @override
  ConsumerState<PersonsPage> createState() => _PersonsPageState();
}

class _PersonsPageState extends ConsumerState<PersonsPage> {
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    bool isMobile = width < Breakpoints.mobile;
    final palette = context.palette;

    final historyState = ref.watch(historyProvider);

    int getCrossAxisCount() {
      if (width > Breakpoints.tablet) return 3;
      if (width > Breakpoints.mobile) return 2;
      return 1;
    }

    return Scaffold(
      backgroundColor: palette.background,
      appBar: AppBar(
        title: const DesctopAppbarWidget(),
        scrolledUnderElevation: 0.0,
        surfaceTintColor: Colors.transparent,
        backgroundColor: palette.appbarBg,
        toolbarHeight: 90.h,
        automaticallyImplyLeading: false,
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
                        "Tarixiy Shaxslar",
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
                    "Barcha Tarixiy Shaxslar",
                    style: GoogleFonts.notoSansHebrew(
                      fontSize: isMobile ? 28.sp : 42.sp,
                      fontWeight: FontWeight.w700,
                      color: palette.textPrimary,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (historyState.isLoading)
            const SliverFillRemaining(child: Center(child: CircularProgressIndicator()))
          else if (historyState.error != null)
            SliverFillRemaining(child: Center(child: Text(historyState.error!)))
          else ...[
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: isMobile ? 20 : 70.w, vertical: isMobile ? 30 : 60.h),
              sliver: SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: getCrossAxisCount(),
                  mainAxisSpacing: isMobile ? 20 : 40.h,
                  crossAxisSpacing: isMobile ? 20 : 30.w,
                  childAspectRatio: isMobile ? 1.0 : 0.75,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final hero = historyState.histories[index];
                    return GestureDetector(
                      onTap: () => context.go('/historys/${hero.id}'),
                      child: Container(
                        decoration: BoxDecoration(
                          color: palette.cardBg,
                          borderRadius: BorderRadius.circular(12.r),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.06),
                              blurRadius: 15,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 24.w, vertical: isMobile ? 16 : 30.h),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              hero.title ?? "",
                              textAlign: TextAlign.center,
                              style: GoogleFonts.cinzel(
                                fontSize: isMobile ? 18 : 22.sp,
                                fontWeight: FontWeight.bold,
                                color: palette.heading,
                              ),
                            ),
                            SizedBox(height: 16.h),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
                              decoration: BoxDecoration(
                                border: Border.all(color: AppColors.brown, width: 1.2),
                                borderRadius: BorderRadius.circular(4.r),
                              ),
                              child: Text(
                                "${hero.liveDate}",
                                style: GoogleFonts.roboto(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.brown,
                                ),
                              ),
                            ),
                            SizedBox(height: 24.h),
                            Expanded(
                              child: Text(
                                QuillUtils.parseDeltaToPlainText(hero.content),
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 5,
                                style: GoogleFonts.crimsonText(
                                  fontSize: isMobile ? 14 : 16.sp,
                                  color: palette.textSecondary,
                                  height: 1.5,
                                ),
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Davomi",
                                  style: GoogleFonts.roboto(
                                    fontSize: 15.sp,
                                    color: AppColors.brown,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(width: 8.w),
                                Icon(Icons.arrow_forward_outlined, size: 18.sp, color: AppColors.brown),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  childCount: historyState.histories.length,
                ),
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
