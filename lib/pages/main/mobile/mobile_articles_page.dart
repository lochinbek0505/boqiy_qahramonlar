import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/app_colors.dart';

class MobileArticlesPage extends StatefulWidget {
  const MobileArticlesPage({super.key});

  @override
  State<MobileArticlesPage> createState() => _MobileArticlesPageState();
}

class _MobileArticlesPageState extends State<MobileArticlesPage> {
  final List<String> _articleName = ["Tarix", "Siyosat", "O'zlik", "Erkin"];
  final List<Map<String, String>> articles = [
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
    //  var size = MediaQuery.of(context).size;

    return Column(
      children: [
        SizedBox(height: 40.h),
        Text(
          "MAQOLALAR",
          style: GoogleFonts.cinzel(
            fontSize: 24.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.midnightBlue,
            height: 1.3,
          ),
        ),
        SizedBox(height: 30.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_articleName.length, (index) {
            bool isActive = index == 0;
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.w),
              child: Container(
                width: 70.w,
                height: 24.w,
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  border: Border.all(
                    color: isActive ? AppColors.brown : AppColors.indigoBlue,
                    width: 1.w,
                  ),
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: Center(
                  child: Text(
                    _articleName[index],
                    style: GoogleFonts.notoSansHebrew(
                      fontWeight: FontWeight.w400,
                      color: isActive ? AppColors.brown : AppColors.black,
                      fontSize: 14.sp,
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
        SizedBox(height: 40.h),
        SizedBox(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 70.w),
            child: ListView.builder(
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: articles.length,
              itemBuilder: (context, index) {
                final article = articles[index];
                return Padding(
                  padding: EdgeInsets.only(bottom: 50.h),
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
                      padding: EdgeInsets.all(12.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: double.infinity,
                            height: 140.h,
                            decoration: BoxDecoration(
                              color: Colors.blueGrey.shade100,

                              // TODO: Rasm qo'yilgandan keyin bu qismni ochish kerak
                              // image: DecorationImage(image: AssetImage("${article['image']}"))
                            ),
                          ),
                          SizedBox(height: 16.h),
                          Text(
                            "${article['category']}",
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: AppColors.brown,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 4.h),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "${article['title']}",
                                style: TextStyle(
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Icon(Icons.arrow_outward, size: 16.sp),
                            ],
                          ),
                          SizedBox(height: 6.h),
                          Text(
                            "${article['description']}",
                            maxLines: 7,

                            overflow: TextOverflow.ellipsis,

                            style: TextStyle(
                              fontSize: 12.sp,

                              color: Colors.grey.shade600,
                              height: 1.2,
                            ),
                          ),
                          SizedBox(height: 12.h),
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 12.r,
                                backgroundImage: AssetImage(
                                  "${article['authorImage']}",
                                ),
                              ),
                              SizedBox(width: 6.w),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "${article['authorName']}",
                                    style: TextStyle(
                                      fontSize: 10.sp,
                                      fontWeight: FontWeight.w600,
                                      height: 1.2,
                                    ),
                                  ),
                                  Text(
                                    "${article['date']}",
                                    style: TextStyle(
                                      fontSize: 10.sp,
                                      color: Colors.grey.shade500,
                                      height: 1.2,
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
        SizedBox(height: 6.h),
        Container(
          width: 150.w,
          decoration: BoxDecoration(
            color: AppColors.steelBlue,
            borderRadius: BorderRadius.circular(3),
          ),
          child: Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 10.h),
              child: Text(
                "KO'PROQ",
                style: GoogleFonts.cinzel(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  // height: 1.2,
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: 20.h),
      ],
    );
  }
}
