import 'package:boqiy_qahramonlar/pages/widgets/more_button.dart';
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
import 'desctop_appbar_widget.dart';

class PersonsPage extends ConsumerStatefulWidget {
  const PersonsPage({super.key});

  @override
  ConsumerState<PersonsPage> createState() => _ArticlesPageState();
}

class _ArticlesPageState extends ConsumerState<PersonsPage> {
  int _selectedCategoryIndex = 0;

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    bool isMobile = width < 600;

    final articleState = ref.watch(articleProvider);
    final categoryState = ref.watch(categoryProvider);

    int getCrossAxisCount() {
      if (width > 1000) return 3;
      if (width > 650) return 2;
      return 1;
    }

    double getAspectRatio() {
      if (width > 1000) return 5 / 7;
      if (width > 650) return 4 / 6.5;
      return 0.85;
    }

    // Kategoriyalarni yig'ish
    List<String> tabCategories = ["Barchasi"];

    if (categoryState.categories != null) {
      for (var cat in categoryState.categories!) {
        if (cat.name != null && !tabCategories.contains(cat.name)) {
          tabCategories.add(cat.name!);
        }
      }
    }

    // Kategoriya bo'yicha maqolalarni lokal filterlash
    final filteredArticles = _selectedCategoryIndex == 0
        ? articleState.articles
        : articleState.articles.where((article) {
      if (article.categoriesList == null) return false;
      return article.categoriesList!.any(
            (c) => c.name == tabCategories[_selectedCategoryIndex],
      );
    }).toList();



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

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: DesctopAppbarWidget(),
        scrolledUnderElevation: 0.0,
        surfaceTintColor: Colors.transparent,
        backgroundColor: AppColors.appbar,
        toolbarHeight: 90.h,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // Barcha elementlar chapga tekislanadi
          children: [
            SizedBox(height: isMobile ? 24.h : 40.h),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: isMobile ? 20.w : 70.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Breadcrumb (Navigatsiya yo'li)
                  Row(
                    children: [
                      InkWell(
                        onTap: () {
                          context.go('/'); // Bosh sahifaga qaytish yo'li
                        },
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
                        child: Icon(
                            Icons.chevron_right,
                            size: isMobile ? 16.sp : 18.sp,
                            color: Colors.grey.shade400
                        ),
                      ),
                      Text(
                        "Tarixiy Shaxslar",
                        style: GoogleFonts.inter(
                          fontSize: isMobile ? 12.sp : 14.sp,
                          color: AppColors.brown, // Aktiv sahifa rangi
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: isMobile ? 10.h : 16.h),

                  // 2. Asosiy Sarlavha
                  Text(
                    "Barcha Tarixiy Shaxslar",
                    style: GoogleFonts.notoSansHebrew(
                      fontSize: isMobile ? 28.sp : 42.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                      letterSpacing: -0.5,
                    ),
                  ),

                ],
              ),
            ),


        Column(
          children: [
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
                      context.go('/historys/${hero['id']}');
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
          ],
        )
          ],
        ),
      ),
    );
  }
}