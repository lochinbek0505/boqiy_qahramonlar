import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/app_colors.dart';

class DesctopArticlesPage extends StatefulWidget {
  const DesctopArticlesPage({super.key});

  @override
  State<DesctopArticlesPage> createState() => _DesctopArticlesPageState();
}

class _DesctopArticlesPageState extends State<DesctopArticlesPage> {
  final List<String> _articleName = ["Tarix", "Siyosat", "O'zlik", "Erkin","O'zlik","Haqlik","Yo'qlik"];
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
    return Column(
      children: [
        SizedBox(height: 60.h),
        Text(
          "MAQOLALAR",
          style: GoogleFonts.cinzel(
            fontSize: 44.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.midnightBlue,
            height: 1.3,
          ),
        ),
        SizedBox(height: 50.h),
        Padding(
          padding:  EdgeInsets.only(left: 70.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(_articleName.length, (index) {
              bool isActive = index == 0;
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Container(
                  width: 150.w,
                  height: 50.w,
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
                        fontSize: 24.sp,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
        SizedBox(height: 60.h),
        SizedBox(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 70.w),
            child: GridView.builder(
              physics: NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,       // Ustunlar soni
                mainAxisSpacing: 5.h,     // Vertikal masofa
                crossAxisSpacing: 60.w,    // Gorizontal masofa
                childAspectRatio: 5/7,     // Elementning eniga bo'yi nisbati
              ),
              shrinkWrap: true,
              itemCount: _articles.length,
              itemBuilder: (context, index) {
                final article = _articles[index];
                return Padding(
                  padding: EdgeInsets.only(bottom: 55.h),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 5,
                          offset: Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(22.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: double.infinity,
                            height: 300.w,
                            decoration: BoxDecoration(
                              color: Colors.blueGrey.shade100,

                              // TODO: Rasm qo'yilgandan keyin bu qismni ochish kerak
                              // image: DecorationImage(image: AssetImage("${article['image']}"))
                            ),
                          ),
                          SizedBox(height: 30.h),
                          Text(
                            "${article['category']}",
                            style: TextStyle(
                              fontSize: 15.sp,
                              color: AppColors.brown,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 16.h),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "${article['title']}",
                                style: TextStyle(
                                  fontSize: 22.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Icon(Icons.arrow_outward, size: 16.sp),
                            ],
                          ),
                          SizedBox(height: 16.h),
                          Text(
                            "${article['description']}",
                            maxLines: 7,

                            overflow: TextOverflow.ellipsis,

                            style: TextStyle(
                              fontSize: 17.5.sp,

                              color: Colors.grey.shade600,
                            ),
                          ),
                          SizedBox(height: 12.h),
                          Spacer(),
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 25.r,
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
                                      fontSize: 15.sp,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    "${article['date']}",
                                    style: TextStyle(
                                      fontSize: 15.sp,
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
                  ),
                );
              },
            ),
          ),
        ),
        SizedBox(height: 24.h),
        Container(
          width: 340.w,
          decoration: BoxDecoration(
            color: AppColors.steelBlue,
            borderRadius: BorderRadius.circular(5),
          ),
          child: Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 18.h),
              child: Text(
                "KO'PROQ",
                style: GoogleFonts.cinzel(
                  fontSize: 28.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  // height: 1.2,
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: 40.h),
      ],
    );;
  }
}
