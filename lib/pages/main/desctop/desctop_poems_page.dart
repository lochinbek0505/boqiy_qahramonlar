import 'package:boqiy_qahramonlar/pages/main/desctop/read_poem_page.dart';
import 'package:boqiy_qahramonlar/pages/main/desctop/widgets/more_button.dart';
import 'package:boqiy_qahramonlar/pages/main/desctop/widgets/page_title_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/app_colors.dart';

class DesctopPoemsPage extends StatelessWidget {
  // Statik bo'lgani uchun StatelessWidget qildik
  const DesctopPoemsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> poems = [
      {
        'title': 'Balki sen Haqdirsan',
        'author': 'Muallif: Yengilmas',
        'content': '''Balki sen haqdirsan, achchiq haqiqat,
Alloh sinov berdi har ikkimizga.
O'tolmadik afsus uvol ketti baxt,
Alamli xotira yo'ldoshdir bizga.

Bilaman gunohim, aybim sanoqsiz,
Bilaman ko'nglinga ko'p azob berdim.
Ayt kim yashagandir shubha xatosiz,
Men ham dunyo uchun baxtimni berdim.''',
      },
      {
        'title': 'Balki sen Haqdirsan',
        'author': 'Muallif: Yengilmas',
        'content': '''Balki sen haqdirsan, achchiq haqiqat,
Alloh sinov berdi har ikkimizga.
O'tolmadik afsus uvol ketti baxt,
Alamli xotira yo'ldoshdir bizga.

Bilaman gunohim, aybim sanoqsiz,
Bilaman ko'nglinga ko'p azob berdim.
Ayt kim yashagandir shubha xatosiz,
Men ham dunyo uchun baxtimni berdim.''',
      },
      // Boshqa elementlar ham shu yerda bo'ladi...
      {
        'title': 'Balki sen Haqdirsan',
        'author': 'Muallif: Yengilmas',
        'content': '''Balki sen haqdirsan, achchiq haqiqat,
Alloh sinov berdi har ikkimizga.
O'tolmadik afsus uvol ketti baxt,
Alamli xotira yo'ldoshdir bizga.

Bilaman gunohim, aybim sanoqsiz,
Bilaman ko'nglinga ko'p azob berdim.
Ayt kim yashagandir shubha xatosiz,
Men ham dunyo uchun baxtimni berdim.''',
      },
    ];

    return Column(
      children: [
        SizedBox(height: 60.h),
        PageTitleText(title: "She'rlar"),
        SizedBox(height: 60.h), // Masofa biroz tartibga solindi

        Padding(
          padding: EdgeInsets.symmetric(horizontal: 80.w),
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 60.h, // Kartalar orasidagi vertikal masofa
              crossAxisSpacing: 80.w, // Kartalar orasidagi gorizontal masofa
              childAspectRatio: 0.9, // Karta nisbati
            ),
            shrinkWrap: true,
            itemCount: poems.length,
            itemBuilder: (context, index) {
              final poem = poems[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (builder) => ReadPoemPage()),
                  );
                },
                child: Container(
                  color: Colors.transparent, // Orqa fon ochiq
                  child: Stack(
                    children: [
                      // Tepa chap burchakdagi dizayn
                      Positioned(
                        top: 0,
                        left: 0,
                        child: Container(
                          width: 80.w, // Kichraytirildi (100 -> 80)
                          height: 80.h,
                          decoration: BoxDecoration(
                            border: Border(
                              top: BorderSide(
                                color: AppColors.brown,
                                width: 2.w,
                              ),
                              left: BorderSide(
                                color: AppColors.brown,
                                width: 2.w,
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Pastki o'ng burchakdagi dizayn
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 80.w,
                          height: 80.h,
                          decoration: BoxDecoration(
                            border: Border(
                              right: BorderSide(
                                color: Colors.grey.shade400,
                                width: 2.w,
                              ),
                              // AppColors.gray bo'lmasa ishlaydi
                              bottom: BorderSide(
                                color: Colors.grey.shade400,
                                width: 2.w,
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Asosiy Kontent
                      Padding(
                        padding: EdgeInsets.all(40.w),
                        // Yozuv burchak chiziqlariga yopishib qolmasligi uchun
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "${poem['title']}",
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.copse(
                                fontSize: 24.sp,
                                fontWeight: FontWeight.bold,
                                color: AppColors.darkBlue,
                                height: 1.3,
                              ),
                            ),
                            SizedBox(height: 12.h),
                            Text(
                              "${poem['author']}",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.copse(
                                fontSize: 14.sp,
                                color: AppColors.brown,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: 30.h),

                            // She'r matni
                            Expanded(
                              // Overflow qizil xato bermasligi uchun
                              child: Text(
                                "${poem['content']}",
                                overflow: TextOverflow.fade,
                                // Yozuv sig'masa oxiri xira bo'lib yo'qoladi
                                style: GoogleFonts.crimsonPro(
                                  fontSize: 16.sp,
                                  color: Colors.black87,
                                  height: 1.6,
                                  // She'r o'qilishi oson bo'lishi uchun
                                  fontStyle: FontStyle
                                      .italic, // She'riyat atmosferasi uchun qiya qildik (ixtiyoriy)
                                ),
                                textAlign: TextAlign
                                    .left, // She'r chapga taqalishi shart
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        SizedBox(height: 40.h),
        const MoreButton(),
        SizedBox(height: 60.h),
      ],
    );
  }
}
