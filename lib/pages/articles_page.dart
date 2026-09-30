import 'package:boqiy_qahramonlar/pages/footer_widget.dart';
// import 'package:boqiy_qahramonlar/pages/widgets/page_title_text.dart'; // Buni olib tashladik
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/app_colors.dart';
import '../core/breakpoints.dart';
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
    bool isMobile = width < Breakpoints.mobile;
    final palette = context.palette;

    final articleState = ref.watch(articleProvider);
    final categoryState = ref.watch(categoryProvider);

    int getCrossAxisCount() {
      if (width > Breakpoints.tablet) return 3;
      if (width > Breakpoints.mobile) return 2;
      return 1;
    }

    double getAspectRatio() {
      if (width > Breakpoints.tablet) return 5 / 7;
      if (width > Breakpoints.mobile) return 4 / 6.5;
      return 0.85;
    }

    // Kategoriyalarni yig'ish
    List<String> tabCategories = ["Barchasi"];

    for (var cat in categoryState.categories) {
      if (cat.name != null && !tabCategories.contains(cat.name)) {
        tabCategories.add(cat.name!);
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
                  // 1. Breadcrumb
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
                              fontSize: 12.sp,
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
                        "Maqolalar",
                        style: GoogleFonts.inter(
                          fontSize: 12.sp,
                          color: AppColors.brown,
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
                      color: palette.textPrimary,
                      letterSpacing: -0.5,
                    ),
                  ),
                  SizedBox(height: isMobile ? 15.h : 30.h),
                ],
              ),
            ),
          ),
          if (articleState.isLoading || categoryState.isLoading)
            const SliverFillRemaining(child: Center(child: CircularProgressIndicator()))
          else if (articleState.error != null || categoryState.error != null)
            SliverFillRemaining(
              child: Center(
                child: Text(
                  articleState.error ?? categoryState.error ?? "Xatolik yuz berdi!",
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            )
          else ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: isMobile ? 20.w : 70.w),
                child: Column(
                  children: [
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
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
                                ref.read(articleProvider.notifier).fetchArticles(category: tabCategories[index]);
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
                                    color: isActive ? AppColors.brown : AppColors.indigoBlue,
                                    width: 1.8.w,
                                  ),
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                                child: Center(
                                  child: Text(
                                    tabCategories[index],
                                    style: GoogleFonts.notoSansHebrew(
                                      fontWeight: FontWeight.w500,
                                      color: isActive ? AppColors.brown : palette.textPrimary,
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
                    SizedBox(height: isMobile ? 30.h : 50.h),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: isMobile ? 20.w : 70.w),
              sliver: SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: getCrossAxisCount(),
                  mainAxisSpacing: isMobile ? 20.h : 30.h,
                  crossAxisSpacing: isMobile ? 20.w : 60.w,
                  childAspectRatio: getAspectRatio(),
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final article = filteredArticles[index];
                    String categoryName = article.categoriesList?.isNotEmpty == true ? article.categoriesList!.first.name ?? "" : "Maqola";
                    return GestureDetector(
                      onTap: () => context.go('/article/${article.id}'),
                      child: Container(
                        decoration: BoxDecoration(
                          color: palette.cardBg,
                          borderRadius: BorderRadius.circular(12.r),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
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
                                color: palette.placeholder,
                                borderRadius: BorderRadius.circular(8.r),
                                image: article.bannerUrl != null
                                    ? DecorationImage(
                                        image: NetworkImage(article.bannerUrl!),
                                        fit: BoxFit.cover,
                                      )
                                    : null,
                              ),
                              child: article.bannerUrl == null ? const Center(child: Icon(Icons.image, size: 50, color: Colors.grey)) : null,
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
                                Icon(Icons.arrow_outward, size: isMobile ? 18.sp : 16.sp),
                              ],
                            ),
                            SizedBox(height: isMobile ? 6.h : 12.h),
                            Text(
                              article.description ?? "",
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: isMobile ? 13.sp : 15.sp,
                                color: palette.textSecondary,
                                height: 1.4,
                              ),
                            ),
                            SizedBox(height: isMobile ? 6.h : 10.h),
                            if (article.hashTegsList != null && article.hashTegsList!.isNotEmpty)
                              Text(
                                article.hashTegsList!.map((e) => '${e.hashteg}').join('  '),
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
                                        backgroundImage: article.author?.profileImageUrl != null
                                            ? NetworkImage("https://api.boqiyqahramonlar.uz${article.author!.profileImageUrl!}")
                                            : null,
                                        child: article.author?.profileImageUrl == null ? const Icon(Icons.person) : null,
                                      ),
                                      SizedBox(width: 8.w),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
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
                                                color: palette.textSecondary,
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
                                        Icon(Icons.visibility_outlined, size: isMobile ? 14.sp : 16.sp, color: palette.textSecondary),
                                        SizedBox(width: 4.w),
                                        Text(
                                          "${article.viewCount ?? 0} ta",
                                          style: TextStyle(fontSize: isMobile ? 11.sp : 12.sp, color: palette.textSecondary),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 4.h),
                                    Row(
                                      children: [
                                        Icon(Icons.access_time, size: isMobile ? 14.sp : 16.sp, color: palette.textSecondary),
                                        SizedBox(width: 4.w),
                                        Text(
                                          "${article.readTime ?? 0} daq",
                                          style: TextStyle(fontSize: isMobile ? 11.sp : 12.sp, color: palette.textSecondary),
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
                  childCount: filteredArticles.length,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Column(
                children: [
                  SizedBox(height: isMobile ? 30.h : 40.h),
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