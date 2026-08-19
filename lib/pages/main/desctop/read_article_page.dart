import 'package:boqiy_qahramonlar/pages/main/desctop/widgets/most_read_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/app_colors.dart';
import '../mobile/mobile_appbar_widget.dart';
import 'desctop_appbar_widget.dart';

class ReadArticlePage extends StatefulWidget {
  const ReadArticlePage({super.key});

  @override
  State<ReadArticlePage> createState() => _ReadArticlePageState();
}

class _ReadArticlePageState extends State<ReadArticlePage> {
  final List<String> dollarTushishSabablari = [
    "1. Xalqaro obligatsiyalar (yevrobondlar) chiqarilishi",
    "2. Asosiy savdo hamkorlari valyutalarining mustahkamlanishi",
    "3. Eksport tushumlarining ortishi",
    "4. Migrantlardan keladigan pul o'tkazmalari",
    "5. Markaziy bankning oltin-valyuta operatsiyalari",
    "6. Mavsumiy va psixologik omillar (soliq to'lovlari davri)",
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
      'date': '20 - yanvar, 2022  •  1 daq. o\'qish',
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
    var size = MediaQuery.of(context).size;
    var article = _articles[0];

    return Scaffold(
      appBar: size.width < 500
          ? AppBar(
              title: const MobileAppbarWidget(),
              backgroundColor: AppColors.appbar,
              automaticallyImplyLeading: false,
            )
          : AppBar(
              title: const DesctopAppbarWidget(),
              scrolledUnderElevation: 0.0,
              surfaceTintColor: Colors.transparent,
              backgroundColor: AppColors.appbar,
              toolbarHeight: 90.sp,
              automaticallyImplyLeading: false,
            ),
      backgroundColor: AppColors.background,
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. ASOSIY MAQOLA QISMI (Chap tomon)
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 30.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Breadcrumbs (Navigatsiya)
                    Text(
                      "Bosh sahifa  >  Maqolalar",
                      style: GoogleFonts.inter(
                        fontSize: 11.sp,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 24.h),

                    // Kategoriya
                    Text(
                      "TARIX",
                      style: GoogleFonts.inter(
                        fontSize: 13.sp,
                        color: AppColors.brown,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                      ),
                    ),
                    SizedBox(height: 16.h),

                    // Maqola sarlavhasi
                    Text(
                      "Dollar kursi nega tushmoqda? So‘mning mustahkamlanishiga sabab bo‘layotgan asosiy omillar",
                      style: GoogleFonts.inter(
                        fontSize: 30.sp, // Kattalashtirildi
                        color: AppColors.black,
                        fontWeight: FontWeight.w800,
                        height: 1.3,
                      ),
                    ),
                    SizedBox(height: 24.h),

                    // Lidi (Kirish matni)
                    Text(
                      "Valyuta birjasida AQSh dollari kursi 2023-yil avgustidan buyon eng quyi ko‘rsatkichni yangilab, 11 820,4 so‘mgacha pasaydi. Fevral oyidagi qisqa muddatli sakrashdan so‘ng boshlangan ushbu pasayish trendi shunchaki spekulyativ hodisa emas, balki bir qator fundamental makroiqtisodiy omillar natijasidir.",
                      style: GoogleFonts.inter(
                        fontSize: 17.sp,
                        color: Colors.grey.shade800,
                        height: 1.6, // O'qishga qulaylik uchun
                      ),
                    ),
                    SizedBox(height: 32.h),

                    // Muallif (Tepa qism)
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 24.r,
                          backgroundImage: AssetImage(
                            "${article['authorImage']}",
                          ),
                        ),
                        SizedBox(width: 14.w),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "${article['authorName']}",
                              style: GoogleFonts.inter(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w700,
                                color: AppColors.black,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              "${article['date']}",
                              style: GoogleFonts.inter(
                                fontSize: 13.sp,
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 40.h),

                    // Asosiy Rasm
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20.r),
                      // Rasm burchaklari yumaloqlandi
                      child: Image.asset(
                        "assets/images/Image.png",
                        width: double.infinity,
                        height: 500.h,
                        fit: BoxFit
                            .cover, // Rasm proporsiyasi buzilmasligi uchun
                      ),
                    ),
                    SizedBox(height: 40.h),

                    // Asosiy Matn (Body)
                    Text(
                      """Valyuta birjasida AQSh dollari kursi 2023-yil avgustidan buyon eng quyi ko‘rsatkichni yangilab, 11 820,4 so‘mgacha pasaydi. Fevral oyidagi qisqa muddatli sakrashdan so‘ng boshlangan ushbu pasayish trendi shunchaki spekulyativ hodisa emas, balki bir qator fundamental makroiqtisodiy omillar natijasidir.
      
1. Valyuta taklifining talabdan ancha tezroq o‘sishi

Markaziy bank tahlillariga ko‘ra, 2026-yilning birinchi yarmida xorijiy valyutaga bo‘lgan umumiy talab 20% ga oshib, \$32 milliardni tashkil etgan. Biroq, regulyator aralashuvisiz ichki bozordagi to‘g‘ridan-to‘g‘ri valyuta taklifi birdaniga 31% ga o‘sib, \$27,8 milliardga yetdi. Natijada ichki bozordagi valyuta defitsiti \$1,3 milliardga (24% ga) qisqarib, milliy valyutaning mustahkamlanishiga to‘g‘ridan-to‘g‘ri zamin yaratdi.""",
                      style: GoogleFonts.inter(
                        fontSize: 17.sp,
                        color: Colors.black87,
                        height:
                            1.8, // Paragraflar o'qilishi oson bo'lishi uchun qator orasi ochildi
                      ),
                    ),
                    SizedBox(height: 60.h),

                    // "Muallifdan yana" sarlavhasi
                    Divider(color: Colors.grey.shade300, thickness: 1),
                    SizedBox(height: 40.h),
                    Text(
                      "Muallifning boshqa maqolalari",
                      style: GoogleFonts.inter(
                        fontSize: 26.sp,
                        color: AppColors.black,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 40.h),

                    // GridView qismi
                    GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        mainAxisSpacing: 30.h,
                        crossAxisSpacing: 24.w,
                        childAspectRatio: 0.72,
                      ),
                      shrinkWrap: true,
                      itemCount: _articles.length,
                      itemBuilder: (context, index) {
                        final gridArticle = _articles[index];
                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16.r),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(16.r),
                                ),
                                child: Container(
                                  width: double.infinity,
                                  height: 250.h,
                                  decoration: BoxDecoration(
                                    color: Colors.blueGrey.shade50,
                                    // image: DecorationImage(
                                    //   image: AssetImage("${gridArticle['image']}"),
                                    //   fit: BoxFit.cover,
                                    // )
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: EdgeInsets.all(20.w),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "${gridArticle['category']}",
                                        style: GoogleFonts.inter(
                                          fontSize: 12.sp,
                                          color: AppColors.brown,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 1.1,
                                        ),
                                      ),
                                      SizedBox(height: 10.h),
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              "${gridArticle['title']}",
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: GoogleFonts.inter(
                                                fontSize: 18.sp,
                                                fontWeight: FontWeight.w800,
                                                color: AppColors.black,
                                                height: 1.2,
                                              ),
                                            ),
                                          ),
                                          Icon(
                                            Icons.arrow_outward,
                                            size: 18.sp,
                                            color: AppColors.black,
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 10.h),
                                      Text(
                                        "${gridArticle['description']}",
                                        maxLines: 3,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.inter(
                                          fontSize: 14.sp,
                                          color: Colors.grey.shade600,
                                          height: 1.5,
                                        ),
                                      ),
                                      const Spacer(),
                                      Row(
                                        children: [
                                          CircleAvatar(
                                            radius: 18.r,
                                            backgroundImage: AssetImage(
                                              "${gridArticle['authorImage']}",
                                            ),
                                          ),
                                          SizedBox(width: 10.w),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  "${gridArticle['authorName']}",
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: GoogleFonts.inter(
                                                    fontSize: 13.sp,
                                                    fontWeight: FontWeight.w700,
                                                    color: AppColors.black,
                                                  ),
                                                ),
                                                Text(
                                                  "${gridArticle['date']}",
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: GoogleFonts.inter(
                                                    fontSize: 11.sp,
                                                    color: Colors.grey.shade500,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    SizedBox(height: 50.h),
                  ],
                ),
              ),
            ),
          ),

          // 2. YON PANEL (Sidebar - Most Read)
          // Asosiy kontentdan biroz uzoqlashtirish va chiroyli joylashtirish
          Container(
            padding: EdgeInsets.only(top: 30.h, right: 30.w),
            child: MostReadCard(list: dollarTushishSabablari),
          ),
        ],
      ),
    );
  }
}
