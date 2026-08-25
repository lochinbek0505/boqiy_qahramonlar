import 'package:boqiy_qahramonlar/pages/read_persons_page.dart';
import 'package:boqiy_qahramonlar/pages/widgets/more_button.dart';
import 'package:boqiy_qahramonlar/pages/widgets/page_title_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/app_colors.dart';

class DesctopPersonsPage extends StatelessWidget {
  const DesctopPersonsPage({super.key});

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    bool isMobile = width < 600;

    // Kenglikka qarab ustunlar sonini belgilash
    int getCrossAxisCount() {
      if (width > 1000) return 3;
      if (width > 650) return 2;
      return 1;
    }

    final List<Map<String, dynamic>> heroes = [
      {
        'name': 'ALP ARSLON',
        'years': '1063-1072',
        'description': "(forscha: آلپ ارسلان)(20-yanvar 1029-yil — noyabr 1075-yil) — Saljuqiylarlarning ikkinchi sultoni...",
      },
      {
        'name': 'ALP ARSLON',
        'years': '1063-1072',
        'description': "(forscha: آلپ ارسلان)...",
      },
      {
        'name': 'ALP ARSLON',
        'years': '1063-1072',
        'description': "(forscha: آلپ ارسلان)...",
      },
    ];

    return Column(
      children: [
        SizedBox(height: isMobile ? 30 : 60.h),
        PageTitleText(title: "Shaxslar"),
        SizedBox(height: isMobile ? 30 : 60.h),

        Padding(
          padding: EdgeInsets.symmetric(horizontal: isMobile ? 20 : 70.w),
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: getCrossAxisCount(),
              mainAxisSpacing: isMobile ? 20 : 40.h,
              crossAxisSpacing: isMobile ? 20 : 30.w,
              childAspectRatio: isMobile ? 1.0 : 0.75, // Mos ravishda to'g'rilandi
            ),
            shrinkWrap: true,
            itemCount: heroes.length,
            itemBuilder: (context, index) {
              final hero = heroes[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (builder) => ReadPersonPage()));
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 16 : 24.w,
                      vertical: isMobile ? 16 : 30.h
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        hero['name'],
                        textAlign: TextAlign.center,
                        style: GoogleFonts.cinzel(
                          fontSize: isMobile ? 18 : 22.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkBlue,
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
                          hero['years'],
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
                          hero['description'],
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 5,
                          style: GoogleFonts.crimsonText(
                            fontSize: isMobile ? 14 : 16.sp,
                            color: Colors.grey.shade800,
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
        const MoreButton(),
        SizedBox(height: isMobile ? 40 : 80.h),
      ],
    );
  }
}