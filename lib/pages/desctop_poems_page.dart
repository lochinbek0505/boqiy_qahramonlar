import 'package:boqiy_qahramonlar/pages/read_poem_page.dart';
import 'package:boqiy_qahramonlar/pages/widgets/more_button.dart';
import 'package:boqiy_qahramonlar/pages/widgets/page_title_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/app_colors.dart';

class DesctopPoemsPage extends StatelessWidget {
  const DesctopPoemsPage({super.key});

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    bool isMobile = width < 600;

    int getCrossAxisCount() {
      if (width > 1000) return 3;
      if (width > 650) return 2;
      return 1;
    }

    final List<Map<String, dynamic>> poems = [
      {
        'title': 'Balki sen Haqdirsan',
        'author': 'Muallif: Yengilmas',
        'content': 'Balki sen haqdirsan, achchiq haqiqat...',
      },
      {
        'title': 'Balki sen Haqdirsan',
        'author': 'Muallif: Yengilmas',
        'content': 'Balki sen haqdirsan, achchiq haqiqat...',
      },
      {
        'title': 'Balki sen Haqdirsan',
        'author': 'Muallif: Yengilmas',
        'content': 'Balki sen haqdirsan, achchiq haqiqat...',
      },
    ];

    return Column(
      children: [
        SizedBox(height: isMobile ? 30 : 60.h),
        PageTitleText(title: "She'rlar"),
        SizedBox(height: isMobile ? 30 : 60.h),

        Padding(
          padding: EdgeInsets.symmetric(horizontal: isMobile ? 20 : 80.w),
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: getCrossAxisCount(),
              mainAxisSpacing: isMobile ? 30 : 60.h,
              crossAxisSpacing: isMobile ? 20 : 80.w,
              childAspectRatio: isMobile ? 1.0 : 0.9,
            ),
            shrinkWrap: true,
            itemCount: poems.length,
            itemBuilder: (context, index) {
              final poem = poems[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (builder) => ReadPoemPage()),
                  );
                },
                child: Container(
                  color: Colors.transparent,
                  child: Stack(
                    children: [
                      Positioned(
                        top: 0,
                        left: 0,
                        child: Container(
                          width: isMobile ? 40 : 80.w,
                          height: isMobile ? 40 : 80.h,
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
                          width: isMobile ? 40 : 80.w,
                          height: isMobile ? 40 : 80.h,
                          decoration: BoxDecoration(
                            border: Border(
                              right: BorderSide(color: Colors.grey.shade400, width: 2.w),
                              bottom: BorderSide(color: Colors.grey.shade400, width: 2.w),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(isMobile ? 20 : 40.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "${poem['title']}",
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.copse(
                                fontSize: isMobile ? 20 : 24.sp,
                                fontWeight: FontWeight.bold,
                                color: AppColors.darkBlue,
                                height: 1.3,
                              ),
                            ),
                            SizedBox(height: 12.h),
                            Text(
                              "${poem['author']}",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.copse(
                                fontSize: 14.sp,
                                color: AppColors.brown,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: isMobile ? 15 : 30.h),
                            Expanded(
                              child: Text(
                                "${poem['content']}",
                                overflow: TextOverflow.fade,
                                style: GoogleFonts.crimsonPro(
                                  fontSize: isMobile ? 14 : 16.sp,
                                  color: Colors.black87,
                                  height: 1.6,
                                  fontStyle: FontStyle.italic,
                                ),
                                textAlign: TextAlign.left,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        SizedBox(height: isMobile ? 20 : 40.h),
        const MoreButton(),
        SizedBox(height: isMobile ? 30 : 60.h),
      ],
    );
  }
}