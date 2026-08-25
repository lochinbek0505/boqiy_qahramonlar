import 'package:boqiy_qahramonlar/pages/widgets/more_button.dart';
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

class ArticlesPage extends ConsumerStatefulWidget {
  const ArticlesPage({super.key});

  @override
  ConsumerState<ArticlesPage> createState() => _ArticlesPageState();
}

class _ArticlesPageState extends ConsumerState<ArticlesPage> {
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
                        "Maqolalar",
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
                    "Barcha Maqolalar",
                    style: GoogleFonts.notoSansHebrew(
                      fontSize: isMobile ? 28.sp : 42.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                      letterSpacing: -0.5,
                    ),
                  ),
                  SizedBox(height: isMobile ? 8.h : 12.h),

                ],
              ),
            ),

            SizedBox(height: isMobile ? 15.h : 30.h),

            if (articleState.isLoading || categoryState.isLoading)
              const Center(child: CircularProgressIndicator())
            else if (articleState.error != null || categoryState.error != null)
              Center(
                child: Text(
                  articleState.error ?? categoryState.error ?? "Xatolik yuz berdi!",
                  style: const TextStyle(color: Colors.red),
                ),
              )
            else ...[
                // Kategoriyalar qismi
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: isMobile ? 20.w : 70.w),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: List.generate(tabCategories.length, (index) {
                        bool isActive = index == _selectedCategoryIndex;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedCategoryIndex = index;
                            });

                            if (index == 0) {
                              ref.read(articleProvider.notifier).fetchArticles();
                            } else {
                              ref
                                  .read(articleProvider.notifier)
                                  .fetchArticles(category: tabCategories[index]);
                            }
                          },
                          child: Padding(
                            padding: EdgeInsets.only(right: 16.w),
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 20.w),
                              height: isMobile ? 45.h : 40.h,
                              decoration: BoxDecoration(
                                color: Colors.transparent,
                                border: Border.all(
                                  color: isActive
                                      ? AppColors.brown
                                      : AppColors.indigoBlue,
                                  width: 1.8.w,
                                ),
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: Center(
                                child: Text(
                                  tabCategories[index],
                                  style: GoogleFonts.notoSansHebrew(
                                    fontWeight: FontWeight.w500,
                                    color: isActive
                                        ? AppColors.brown
                                        : AppColors.black,
                                    fontSize: isMobile ? 16.sp : 19.sp,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ),
                SizedBox(height: isMobile ? 30.h : 50.h),

                // GRID QISMIGA UMAN TEGINILMADI!
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: isMobile ? 20.w : 70.w),
                  child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: getCrossAxisCount(),
                      mainAxisSpacing: isMobile ? 20.h : 30.h,
                      crossAxisSpacing: isMobile ? 20.w : 60.w,
                      childAspectRatio: getAspectRatio(),
                    ),
                    shrinkWrap: true,
                    itemCount: filteredArticles.length,
                    itemBuilder: (context, index) {
                      final article = filteredArticles[index];

                      String categoryName =
                      article.categoriesList?.isNotEmpty == true
                          ? article.categoriesList!.first.name ?? ""
                          : "Maqola";

                      return GestureDetector(
                        onTap: () {
                          context.go('/article/${article.id}');
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12.r),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 5,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          padding: EdgeInsets.all(isMobile ? 16.w : 24.w),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: double.infinity,
                                height: isMobile ? 160.h : 220.h,
                                decoration: BoxDecoration(
                                  color: Colors.blueGrey.shade100,
                                  borderRadius: BorderRadius.circular(8.r),
                                  image: article.bannerUrl != null
                                      ? DecorationImage(
                                    image: NetworkImage(article.bannerUrl!),
                                    fit: BoxFit.cover,
                                  )
                                      : null,
                                ),
                                child: article.bannerUrl == null
                                    ? const Center(
                                  child: Icon(
                                    Icons.image,
                                    size: 50,
                                    color: Colors.grey,
                                  ),
                                )
                                    : null,
                              ),
                              SizedBox(height: isMobile ? 12.h : 20.h),
                              Text(
                                categoryName,
                                style: TextStyle(
                                  fontSize: isMobile ? 12.sp : 14.sp,
                                  color: AppColors.brown,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(height: isMobile ? 6.h : 12.h),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      article.title ?? "",
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: isMobile ? 18.sp : 22.sp,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  Icon(
                                    Icons.arrow_outward,
                                    size: isMobile ? 18.sp : 16.sp,
                                  ),
                                ],
                              ),
                              SizedBox(height: isMobile ? 6.h : 12.h),
                              Text(
                                article.description ?? "",
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: isMobile ? 13.sp : 15.sp,
                                  color: Colors.grey.shade600,
                                  height: 1.4,
                                ),
                              ),
                              SizedBox(height: isMobile ? 6.h : 10.h),
                              if (article.hashTegsList != null &&
                                  article.hashTegsList!.isNotEmpty)
                                Text(
                                  article.hashTegsList!
                                      .map((e) => '${e.hashteg}')
                                      .join('  '),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: isMobile ? 12.sp : 13.sp,
                                    color: Colors.blueAccent,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              const Spacer(),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Row(
                                      children: [
                                        CircleAvatar(
                                          radius: isMobile ? 16.r : 20.r,
                                          backgroundImage:
                                          article.author?.profileImageUrl != null
                                              ? NetworkImage(
                                            "https://api.boqiyqahramonlar.uz${article.author!.profileImageUrl!}",
                                          )
                                              : null,
                                          child: article.author?.profileImageUrl == null
                                              ? const Icon(Icons.person)
                                              : null,
                                        ),
                                        SizedBox(width: 8.w),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                article.author?.name ?? "Noma'lum",
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  fontSize: isMobile ? 12.sp : 13.sp,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              Text(
                                                article.createAt?.substring(0, 10) ?? "",
                                                style: TextStyle(
                                                  fontSize: isMobile ? 11.sp : 12.sp,
                                                  color: Colors.grey.shade600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.visibility_outlined,
                                            size: isMobile ? 14.sp : 16.sp,
                                            color: Colors.grey.shade600,
                                          ),
                                          SizedBox(width: 4.w),
                                          Text(
                                            "${article.viewCount ?? 0} ta",
                                            style: TextStyle(
                                              fontSize: isMobile ? 11.sp : 12.sp,
                                              color: Colors.grey.shade600,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 4.h),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.access_time,
                                            size: isMobile ? 14.sp : 16.sp,
                                            color: Colors.grey.shade600,
                                          ),
                                          SizedBox(width: 4.w),
                                          Text(
                                            "${article.readTime ?? 0} daq",
                                            style: TextStyle(
                                              fontSize: isMobile ? 11.sp : 12.sp,
                                              color: Colors.grey.shade600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
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
                SizedBox(height: isMobile ? 30.h : 40.h),

              ],
          ],
        ),
      ),
    );
  }
}