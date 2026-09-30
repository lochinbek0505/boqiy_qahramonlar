import 'package:boqiy_qahramonlar/pages/widgets/more_button.dart';
import 'package:boqiy_qahramonlar/pages/widgets/page_title_text.dart';
import 'package:boqiy_qahramonlar/provider/history_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/app_colors.dart';
import '../../core/breakpoints.dart';
import '../../core/utils.dart';

class DesctopPersonsPage extends ConsumerWidget {
  const DesctopPersonsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    double width = MediaQuery.of(context).size.width;
    bool isMobile = width < Breakpoints.mobile;
    final palette = context.palette;

    final historyState = ref.watch(historyProvider);

    // Kenglikka qarab ustunlar sonini belgilash
    int getCrossAxisCount() {
      if (width > Breakpoints.tablet) return 3;
      if (width > Breakpoints.mobile) return 2;
      return 1;
    }

    return Column(
      children: [
        SizedBox(height: isMobile ? 30 : 60.h),
        PageTitleText(title: "Shaxslar"),
        SizedBox(height: isMobile ? 30 : 60.h),

        if (historyState.isLoading)
          const Center(child: CircularProgressIndicator())
        else if (historyState.error != null)
          Center(child: Text(historyState.error!))
        else
          Padding(
            padding: EdgeInsets.symmetric(horizontal: isMobile ? 20 : 70.w),
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: getCrossAxisCount(),
                mainAxisSpacing: isMobile ? 20 : 40.h,
                crossAxisSpacing: isMobile ? 20 : 30.w,
                childAspectRatio: isMobile ? 1.0 : 0.75,
              ),
              shrinkWrap: true,
              itemCount: historyState.histories.length > 6 ? 6 : historyState.histories.length,
              itemBuilder: (context, index) {
                final hero = historyState.histories[index];
                return GestureDetector(
                  onTap: () {
                    context.go('/historys/${hero.id}');
                  },
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
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 16 : 24.w,
                      vertical: isMobile ? 16 : 30.h,
                    ),
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
                          padding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 6.h,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: AppColors.brown,
                              width: 1.2,
                            ),
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
                            Icon(
                              Icons.arrow_forward_outlined,
                              size: 18.sp,
                              color: AppColors.brown,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        SizedBox(height: isMobile ? 30 : 50.h),
        GestureDetector(
          onTap: () {
            context.go('/historys');
          },
          child: MoreButton(),
        ),
        SizedBox(height: isMobile ? 40 : 80.h),
      ],
    );
  }
}

