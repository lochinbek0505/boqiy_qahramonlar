import 'package:boqiy_qahramonlar/core/utils.dart';
import 'package:boqiy_qahramonlar/pages/footer_widget.dart';
import 'package:boqiy_qahramonlar/pages/widgets/more_button.dart';
import 'package:boqiy_qahramonlar/pages/widgets/most_read_card.dart';
import 'package:boqiy_qahramonlar/pages/widgets/page_title_text.dart';
// import 'package:boqiy_qahramonlar/pages/widgets/page_title_text.dart'; // Buni olib tashladik
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/app_colors.dart';
import '../provider/article_provider.dart';
import '../provider/category_provider.dart';
import '../provider/poems_provider.dart';
import 'desctop_appbar_widget.dart';

class PoemsPage extends ConsumerStatefulWidget {
  PoemsPage({super.key});

  @override
  ConsumerState<PoemsPage> createState() => _PoemsPageState();
}

class _PoemsPageState extends ConsumerState<PoemsPage> {
  int _selectedCategoryIndex = 0;

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    bool isMobile = width < 600;

    final poemState = ref.watch(poemsProvider);

    int getCrossAxisCount() {
      if (width > 1000) return 3;
      if (width > 650) return 2;
      return 1;
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const DesctopAppbarWidget(),
        scrolledUnderElevation: 0.0,
        surfaceTintColor: Colors.transparent,
        backgroundColor: AppColors.appbar,
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
                              color: Colors.grey.shade500,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.w),
                        child: Icon(Icons.chevron_right, size: isMobile ? 16.sp : 18.sp, color: Colors.grey.shade400),
                      ),
                      Text(
                        "She'rlar",
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
                    "Barcha She'rlar",
                    style: GoogleFonts.notoSansHebrew(
                      fontSize: isMobile ? 28.sp : 42.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                      letterSpacing: -0.5,
                    ),
                  ),
                  SizedBox(height: isMobile ? 30.h : 60.h),
                ],
              ),
            ),
          ),
          if (poemState.isLoading)
            const SliverFillRemaining(child: Center(child: CircularProgressIndicator()))
          else if (poemState.error != null)
            SliverFillRemaining(child: Center(child: Text(poemState.error!, style: const TextStyle(color: Colors.red))))
          else ...[
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: isMobile ? 20.w : 80.w),
              sliver: SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: getCrossAxisCount(),
                  mainAxisSpacing: isMobile ? 30.h : 60.h,
                  crossAxisSpacing: isMobile ? 20.w : 80.w,
                  childAspectRatio: isMobile ? 1.0 : 0.9,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final poem = poemState.poems[index];
                    return GestureDetector(
                      onTap: () => context.go('/poems/${poem.id}'),
                      child: Container(
                        color: Colors.transparent,
                        child: Stack(
                          children: [
                            Positioned(
                              top: 0,
                              left: 0,
                              child: Container(
                                width: isMobile ? 40.w : 80.w,
                                height: isMobile ? 40.h : 80.h,
                                decoration: BoxDecoration(
                                  border: Border(
                                    top: BorderSide(color: AppColors.brown, width: 2.w),
                                    left: BorderSide(color: AppColors.brown, width: 2.w),
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                width: isMobile ? 40.w : 80.w,
                                height: isMobile ? 40.h : 80.h,
                                decoration: BoxDecoration(
                                  border: Border(
                                    right: BorderSide(color: Colors.grey.shade400, width: 2.w),
                                    bottom: BorderSide(color: Colors.grey.shade400, width: 2.w),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(isMobile ? 20.w : 40.w),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    poem.title ?? "",
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.copse(
                                      fontSize: isMobile ? 20.sp : 24.sp,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.darkBlue,
                                      height: 1.3,
                                    ),
                                  ),
                                  SizedBox(height: 12.h),
                                  Text(
                                    "Muallif: ${poem.author?.name ?? "Noma'lum"}",
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.copse(
                                      fontSize: 14.sp,
                                      color: AppColors.brown,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  SizedBox(height: isMobile ? 15.h : 30.h),
                                  Expanded(
                                    child: Text(
                                      QuillUtils.parseDeltaToPlainText(poem.content),
                                      overflow: TextOverflow.fade,
                                      style: GoogleFonts.crimsonPro(
                                        fontSize: isMobile ? 14.sp : 16.sp,
                                        color: Colors.black87,
                                        height: 1.6,
                                        fontStyle: FontStyle.italic,
                                      ),
                                      textAlign: TextAlign.left,
                                    ),
                                  ),
                                  SizedBox(height: 12.h),
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: poem.hashTegsList != null && poem.hashTegsList!.isNotEmpty
                                            ? Text(
                                                poem.hashTegsList!.map((e) => '#${e.hashteg}').join(' '),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(fontSize: isMobile ? 11.sp : 13.sp, color: Colors.blueAccent, fontWeight: FontWeight.w500),
                                              )
                                            : const SizedBox(),
                                      ),
                                      Row(
                                        children: [
                                          Icon(Icons.visibility_outlined, size: isMobile ? 14.sp : 16.sp, color: Colors.grey.shade600),
                                          SizedBox(width: 4.w),
                                          Text("${poem.viewCount ?? 0}", style: TextStyle(fontSize: isMobile ? 11.sp : 13.sp, color: Colors.grey.shade600)),
                                          SizedBox(width: 12.w),
                                          Icon(Icons.access_time, size: isMobile ? 14.sp : 16.sp, color: Colors.grey.shade600),
                                          SizedBox(width: 4.w),
                                          Text("${poem.readTime ?? 0} daq", style: TextStyle(fontSize: isMobile ? 11.sp : 13.sp, color: Colors.grey.shade600)),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  childCount: poemState.poems.length,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Column(
                children: [
                  SizedBox(height: isMobile ? 20.h : 40.h),
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