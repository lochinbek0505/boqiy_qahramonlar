import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/app_colors.dart';

class DesctopPoemsPage extends StatefulWidget {
  const DesctopPoemsPage({super.key});

  @override
  State<DesctopPoemsPage> createState() => _DesctopPoemsPageState();
}

class _DesctopPoemsPageState extends State<DesctopPoemsPage> {
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


  ];

  @override
  Widget build(BuildContext context) {
    return  Column(
      children: [
        SizedBox(height: 60.h),
        Text(
          "SHE'RLAR",
          style: GoogleFonts.cinzel(
            fontSize: 44.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.midnightBlue,
            height: 1.3,
          ),
        ),
        SizedBox(height: 80.h),
        SizedBox(
          child: Padding(
            padding:  EdgeInsets.symmetric(horizontal: 90.w),
            child: GridView.builder(
              physics: NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 5.h,
                crossAxisSpacing: 90.w,
                childAspectRatio: 3/5,
              ),

              shrinkWrap: true,
              itemCount: _poems.length,
              itemBuilder: (context, index) {
                final poem = _poems[index];
                return Padding(
                  padding:  EdgeInsets.only(bottom: 90.h),
                  child: Stack(
                    children: [
                      Positioned(
                        top:0,
                        left: 0,

                        child: Container(
                          width:120.w,
                          height: 120.h,
                          decoration: BoxDecoration(
                              border: Border(
                                top: BorderSide(
                                    color: AppColors.brown,width: 3
                                ),
                                left: BorderSide(
                                    color: AppColors.brown,width: 3
                                ),

                              )
                          ),
                        ),
                      ),
                      Positioned(
                        bottom:0,
                        right: 0,

                        child: Container(
                          width:120.w,
                          height: 120.h,
                          decoration: BoxDecoration(
                              border: Border(
                                right: BorderSide(
                                    color: AppColors.gray,width: 3
                                ),
                                bottom: BorderSide(
                                    color: AppColors.gray,width: 3
                                ),

                              )
                          ),
                        ),
                      ),

                      Container(
                        padding: EdgeInsets.all(50.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "${poem['title']}",
                              style: GoogleFonts.copse(
                                fontSize: 36.sp,
                                fontWeight: FontWeight.w400,
                                color: AppColors.darkBlue,
                              ),
                            ),
                            SizedBox(height: 16.h),
                            Text(
                              "${poem['author']}",
                              style: GoogleFonts.copse(
                                  fontSize: 24.sp,
                                  color: AppColors.brown,
                                  fontWeight: FontWeight.w400
                              ),
                            ),
                            SizedBox(height: 36.h),
                            Text(
                              "${poem['content']}",
                              style: GoogleFonts.crimsonPro(
                                  fontSize: 26.sp,
                                  color: Colors.black,
                                  height: 1.5,
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
        SizedBox(height: 20.h,),


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
        SizedBox(height: 40.h,)
      ],
    );
  }
}
