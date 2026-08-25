import 'package:boqiy_qahramonlar/pages/widgets/more_button.dart';
import 'package:boqiy_qahramonlar/pages/widgets/page_title_text.dart';
import 'package:boqiy_qahramonlar/provider/category_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/app_colors.dart';
import '../provider/article_provider.dart';

class DesctopArticlesPage extends ConsumerStatefulWidget {
  const DesctopArticlesPage({super.key});

  @override
  ConsumerState<DesctopArticlesPage> createState() =>
      _DesctopArticlesPageState();
}

class _DesctopArticlesPageState extends ConsumerState<DesctopArticlesPage> {
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
      return 0.9;
    }

    // Kategoriyalarni API'dan (categoryProvider'dan) yig'ish
    List<String> tabCategories = ["Barchasi"];

    // Eslatma: 'categories' degan joyni o'zingizning CategoryState ichidagi ro'yxat nomiga almashtiring
    // (Masalan: categoryState.dataListList yoki categoryState.categoryList bo'lishi mumkin)
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

    return Column(
      children: [
        SizedBox(height: isMobile ? 30.h : 60.h),
        PageTitleText(title: "Maqolalar"),
        SizedBox(height: isMobile ? 30.h : 50.h),

        // Agar maqolalar yoki kategoriyalar yuklanayotgan bo'lsa
        if (articleState.isLoading || categoryState.isLoading)
          const Center(child: CircularProgressIndicator())
        // Agar xatolik bo'lsa
        else if (articleState.error != null || categoryState.error != null)
          Center(
            child: Text(
              articleState.error ?? categoryState.error ?? "Xatolik yuz berdi!",
              style: const TextStyle(color: Colors.red),
            ),
          )
        // Ma'lumotlar muvaffaqiyatli kelgan bo'lsa
        else ...[
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
                        width: isMobile ? 100.w : 120.w,
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
          SizedBox(height: isMobile ? 30.h : 60.h),

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

                String categoryName = article.categoriesList?.isNotEmpty == true
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
                        // Banner rasmi
                        Container(
                          width: double.infinity,
                          height: isMobile ? 200.h : 240.h,
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
                        SizedBox(height: isMobile ? 15.h : 30.h),

                        // Kategoriya
                        Text(
                          categoryName,
                          style: TextStyle(
                            fontSize: isMobile ? 12.sp : 14.sp,
                            color: AppColors.brown,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: isMobile ? 8.h : 16.h),

                        // Sarlavha va strelka
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
                        SizedBox(height: isMobile ? 8.h : 16.h),

                        // Qisqacha matn (Description)
                        Text(
                          article.description ?? "",
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: isMobile ? 13.sp : 15.sp,
                            color: Colors.grey.shade600,
                            height: 1.4,
                          ),
                        ),
                        SizedBox(height: isMobile ? 8.h : 12.h),

                        // Hashteglar qismi (YANGI)
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
                              // Yoki AppColors.indigoBlue
                              fontWeight: FontWeight.w500,
                            ),
                          ),

                        const Spacer(),

                        // Pastki qism: Muallif va Statistikalar
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Muallif ma'lumotlari
                            Expanded(
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: isMobile ? 18.r : 22.r,
                                    // Ozgina kichraytirildi, sig'ishi oson bo'lishi uchun
                                    backgroundImage:
                                        article.author?.profileImageUrl != null
                                        ? NetworkImage(
                                            "https://api.boqiyqahramonlar.uz${article.author!.profileImageUrl!}",
                                          )
                                        : null,
                                    child:
                                        article.author?.profileImageUrl == null
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
                                          article.createAt?.substring(0, 10) ??
                                              "",
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

                            // Statistikalar: Ko'rishlar soni va O'qish vaqti (YANGI)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // View count
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
                                // Read time
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
          GestureDetector(
            onTap: () {
              context.go('/article');
            },
            child: MoreButton(),
          ),
          SizedBox(height: isMobile ? 30.h : 40.h),
        ],
      ],
    );
  }
}
