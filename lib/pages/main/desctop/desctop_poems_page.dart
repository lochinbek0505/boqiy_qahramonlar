import 'package:boqiy_qahramonlar/pages/main/desctop/widgets/more_button.dart';
import 'package:boqiy_qahramonlar/pages/main/desctop/widgets/page_title_text.dart';
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
    return Column(
      children: [
        SizedBox(height: 60.h),
        PageTitleText(title: "She'rlar"),
        SizedBox(height: 80.h),
        SizedBox(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 90.w),
            child: GridView.builder(
              physics: NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 5.h,
                crossAxisSpacing: 90.w,
                childAspectRatio: 0.7,
              ),

              shrinkWrap: true,
              itemCount: _poems.length,
              itemBuilder: (context, index) {
                final poem = _poems[index];
                return Padding(
                  padding: EdgeInsets.only(bottom: 90.h),
                  child: Stack(
                    children: [
                      Positioned(
                        top: 0,
                        left: 0,

                        child: Container(
                          width: 100.w,
                          height: 100.h,
                          decoration: BoxDecoration(
                            border: Border(
                              top: BorderSide(color: AppColors.brown, width: 2),
                              left: BorderSide(
                                color: AppColors.brown,
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,

                        child: Container(
                          width: 100.w,
                          height: 100.h,
                          decoration: BoxDecoration(
                            border: Border(
                              right: BorderSide(
                                color: AppColors.gray,
                                width: 2,
                              ),
                              bottom: BorderSide(
                                color: AppColors.gray,
                                width: 2,
                              ),
                            ),
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
                                fontSize: 26.sp,
                                fontWeight: FontWeight.w400,
                                color: AppColors.darkBlue,
                              ),
                            ),
                            SizedBox(height: 16.h),
                            Text(
                              "${poem['author']}",
                              style: GoogleFonts.copse(
                                fontSize: 15.sp,
                                color: AppColors.brown,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            SizedBox(height: 36.h),
                            Text(
                              overflow: TextOverflow.ellipsis,
                              "${poem['content']}",
                              style: GoogleFonts.crimsonPro(
                                fontSize: 17.sp,
                                color: Colors.black,
                              ),
                              maxLines: 13,
                              textAlign: TextAlign.justify,
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
        SizedBox(height: 20.h),

       MoreButton(),
        SizedBox(height: 40.h),
      ],
    );
  }
}
