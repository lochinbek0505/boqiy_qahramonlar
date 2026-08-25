import 'package:boqiy_qahramonlar/pages/read_article_page.dart';
import 'package:boqiy_qahramonlar/pages/widgets/more_button.dart';
import 'package:boqiy_qahramonlar/pages/widgets/page_title_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/app_colors.dart';

class DesctopArticlesPage extends StatefulWidget {
  const DesctopArticlesPage({super.key});

  @override
  State<DesctopArticlesPage> createState() => _DesctopArticlesPageState();
}

class _DesctopArticlesPageState extends State<DesctopArticlesPage> {
  final List<String> _articleName = [
    "Tarix",
    "Siyosat",
    "O'zlik",
    "Erkin",
    "O'zlik",
    "Haqlik",
    "Yo'qlik",
  ];
  final List<Map<String, String>> _articles = [
    {
      'image': 'assets/images/article1.png',
      'category': 'Tarix',
      'title': 'Millat tarixi',
      'description':
      'How do you create compelling presentations that wow your colleagues and impress your managers?',
      'authorImage': 'assets/images/author1.png',
      'authorName': 'Turon Beka',
      'date': '20 Jan 2022',
    },
    {
      'image': 'assets/images/article1.png',
      'category': 'Tarix',
      'title': 'Millat tarixi',
      'description':
      'How do you create compelling presentations that wow your colleagues and impress your managers?',
      'authorImage': 'assets/images/author1.png',
      'authorName': 'Turon Beka',
      'date': '20 Jan 2022',
    },
    {
      'image': 'assets/images/article1.png',
      'category': 'Tarix',
      'title': 'Millat tarixi',
      'description':
      'How do you create compelling presentations that wow your colleagues and impress your managers?',
      'authorImage': 'assets/images/author1.png',
      'authorName': 'Turon Beka',
      'date': '20 Jan 2022',
    },
    {
      'image': 'assets/images/article1.png',
      'category': 'Tarix',
      'title': 'Millat tarixi',
      'description':
      'How do you create compelling presentations that wow your colleagues and impress your managers?',
      'authorImage': 'assets/images/author1.png',
      'authorName': 'Turon Beka',
      'date': '20 Jan 2022',
    },
    {
      'image': 'assets/images/article1.png',
      'category': 'Tarix',
      'title': 'Millat tarixi',
      'description':
      'How do you create compelling presentations that wow your colleagues and impress your managers?',
      'authorImage': 'assets/images/author1.png',
      'authorName': 'Turon Beka',
      'date': '20 Jan 2022',
    },
    {
      'image': 'assets/images/article2.png',
      'category': 'Tarix',
      'title': 'Millat tarixi',
      'description':
      'How do you create compelling presentations that wow your colleagues and impress your managers?',
      'authorImage': 'assets/images/author2.png',
      'authorName': 'Turon Beka',
      'date': '20 Jan 2022',
    },
  ];

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    bool isMobile = width < 600;

    // Ekran o'lchamiga qarab ustunlar sonini belgilash
    int getCrossAxisCount() {
      if (width > 1000) return 3;
      if (width > 650) return 2;
      return 1;
    }

    // Kartalarning bo'yi-eniga nisbatini ekran o'lchamiga moslash
    double getAspectRatio() {
      if (width > 1000) return 5 / 7;
      if (width > 650) return 4 / 6.5;
      return 0.9; // Mobil uchun chiroyli nisbat
    }

    return Column(
      children: [
        SizedBox(height: isMobile ? 30.h : 60.h),
        PageTitleText(title: "Maqolalar"),
        SizedBox(height: isMobile ? 30.h : 50.h),

        // Kategoriyalar qismi: mobilda ekranga sig'masa gorizontal skroll bo'lishi uchun SingleChildScrollView qo'shildi
        Padding(
          padding: EdgeInsets.symmetric(horizontal: isMobile ? 20.w : 70.w),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(_articleName.length, (index) {
                bool isActive = index == 0;
                return Padding(
                  padding: EdgeInsets.only(right: 16.w),
                  child: Container(
                    width: isMobile ? 100.w : 120.w,
                    height: isMobile ? 45.h : 40.h, // balandlikni .w dan .h ga to'g'irladik
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
                        _articleName[index],
                        style: GoogleFonts.notoSansHebrew(
                          fontWeight: FontWeight.w500,
                          color: isActive ? AppColors.brown : AppColors.black,
                          fontSize: isMobile ? 16.sp : 19.sp,
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
              mainAxisSpacing: isMobile ? 20.h : 30.h, // Vertikal masofa
              crossAxisSpacing: isMobile ? 20.w : 60.w, // Gorizontal masofa
              childAspectRatio: getAspectRatio(), // Elementning eniga bo'yi nisbati dinamiklashdi
            ),
            shrinkWrap: true,
            itemCount: _articles.length,
            itemBuilder: (context, index) {
              final article = _articles[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (b) => const ReadArticlePage()));
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
                      // Rasm joyi
                      Container(
                        width: double.infinity,
                        height: isMobile ? 200.h : 240.h, // rasm bo'yini .h qildik (.w qotib qolardi)
                        decoration: BoxDecoration(
                          color: Colors.blueGrey.shade100,
                          borderRadius: BorderRadius.circular(8.r),
                          // image: DecorationImage(image: AssetImage("${article['image']}"), fit: BoxFit.cover),
                        ),
                      ),
                      SizedBox(height: isMobile ? 15.h : 30.h),

                      // Kategoriya nomi
                      Text(
                        "${article['category']}",
                        style: TextStyle(
                          fontSize: isMobile ? 12.sp : 14.sp,
                          color: AppColors.brown,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: isMobile ? 8.h : 16.h),

                      // Sarlavha (Uzun bo'lib ketsa ikonkani itarib yubormasligi uchun Expanded qo'shildi)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              "${article['title']}",
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
                      SizedBox(height: isMobile ? 8.h : 16.h),

                      // Tavsif
                      Text(
                        "${article['description']}",
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: isMobile ? 13.sp : 15.sp,
                          color: Colors.grey.shade600,
                          height: 1.4,
                        ),
                      ),

                      const Spacer(), // Muallif ma'lumotlarini eng pastga taqash uchun

                      // Muallif ma'lumotlari
                      Row(
                        children: [
                          CircleAvatar(
                            radius: isMobile ? 20.r : 25.r,
                            backgroundImage: AssetImage(
                              "${article['authorImage']}",
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "${article['authorName']}",
                                style: TextStyle(
                                  fontSize: isMobile ? 12.sp : 13.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                "${article['date']}",
                                style: TextStyle(
                                  fontSize: isMobile ? 11.sp : 13.sp,
                                  color: Colors.grey.shade600,
                                ),
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
        const MoreButton(),
        SizedBox(height: isMobile ? 30.h : 40.h),
      ],
    );
  }
}