import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/app_colors.dart';

class MobilePoemsPage extends StatefulWidget {
  const MobilePoemsPage({super.key});

  @override
  State<MobilePoemsPage> createState() => _MobilePoemsPageState();
}

class _MobilePoemsPageState extends State<MobilePoemsPage> {
  final List<Map<String, dynamic>> _poems = [
    {
      'title': 'Balki sen Haqdirsan',
      'author': 'Muallif : Yengilmas',
      'content': '''Balki sen haqdirsam , achchiq haqiqat ,
Alloh sinov berdi har ikkimizga.
O'tolmadik afsus uvol ketti baxt,
Alamli xotira yo'ldoshdir bizga.

Bilaman gunohim , aybim sanoqsiz,
Bilaman ko'nglinga ko'p azob berdim.
Ayt kim yashagandir shubha xatosiz,
Men ham dunyo uchun baxtimni berdim.''',
    },
    {
      'title': 'Balki sen Haqdirsan',
      'author': 'Muallif : Yengilmas',
      'content': '''Balki sen haqdirsam , achchiq haqiqat ,
Alloh sinov berdi har ikkimizga.
O'tolmadik afsus uvol ketti baxt,
Alamli xotira yo'ldoshdir bizga.

Bilaman gunohim , aybim sanoqsiz,
Bilaman ko'nglinga ko'p azob berdim.
Ayt kim yashagandir shubha xatosiz,
Men ham dunyo uchun baxtimni berdim.''',
    },

  ];  @override
  Widget build(BuildContext context) {
    return  Column(
      children: [
        SizedBox(height: 40.h),
        Text(
          "SHE'RLAR",
          style: GoogleFonts.cinzel(
            fontSize: 24.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.midnightBlue,
            height: 1.3,
          ),
        ),
        SizedBox(height: 40.h),
        SizedBox(
          child: Padding(
            padding:  EdgeInsets.symmetric(horizontal: 70.w),
            child: ListView.builder(
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: _poems.length,
              itemBuilder: (context, index) {
                final poem = _poems[index];
                return Padding(
                  padding:  EdgeInsets.only(bottom: 100.h),
                  child: Stack(
                    children: [
                      Positioned(
                        top:0,
                        left: 0,

                        child: Container(
                          width:60.w,
                          height: 60.h,
                          decoration: BoxDecoration(
                            border: Border(
                              top: BorderSide(
                                color: AppColors.brown,width: 2
                              ),
                              left: BorderSide(
                                  color: AppColors.brown,width: 2
                              ),

                            )
                          ),
                        ),
                      ),
                      Positioned(
                        bottom:0,
                        right: 0,

                        child: Container(
                          width:60.w,
                          height: 60.h,
                          decoration: BoxDecoration(
                              border: Border(
                                right: BorderSide(
                                    color: AppColors.gray,width: 2
                                ),
                                bottom: BorderSide(
                                    color: AppColors.gray,width: 2
                                ),

                              )
                          ),
                        ),
                      ),

                      Container(
                        padding: EdgeInsets.all(20.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "${poem['title']}",
                              style: GoogleFonts.copse(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w400,
                                color: AppColors.darkBlue,
                              ),
                            ),
                            SizedBox(height: 6.h),
                            Text(
                              "${poem['author']}",
                              style: GoogleFonts.copse(
                                fontSize: 12.sp,
                                color: AppColors.brown,
                                fontWeight: FontWeight.w400
                              ),
                            ),
                            SizedBox(height: 16.h),
                            Text(
                            "${poem['content']}",
                              style: GoogleFonts.crimsonPro(
                                fontSize: 13.sp,
                                color: Colors.black,
                                height: 1.2,
                                fontWeight: FontWeight.w400
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
        Container(
          width: 150.w,
          decoration: BoxDecoration(
            color: AppColors.steelBlue,
            borderRadius: BorderRadius.circular(3),
          ),
          child: Center(
            child: Padding(
              padding:  EdgeInsets.symmetric(vertical: 10.h),
              child: Text("KO'PROQ",          style: GoogleFonts.cinzel(
                fontSize: 15.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                // height: 1.2,
              ),
              ),
            ),
          ),),
        SizedBox(height: 20.h,)
      ],
    );
  }
}
