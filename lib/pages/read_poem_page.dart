import 'package:boqiy_qahramonlar/pages/widgets/most_read_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/app_colors.dart';
import 'desctop_appbar_widget.dart';

class ReadPoemPage extends StatefulWidget {
  num id;

  ReadPoemPage({super.key, required this.id});

  @override
  State<ReadPoemPage> createState() => _ReadPoemPageState();
}

class _ReadPoemPageState extends State<ReadPoemPage> {
  // Yon panel (Sidebar) uchun mashhur she'rlar
  final List<String> popularPoems = [
    "1. Men nechun sevaman O'zbekistonni",
    "2. O'zbegim",
    "3. Onajon",
    "4. Bahor keldi seni so'roqlab",
    "5. Kuzgi yaproqlar",
    "6. Balki sen Haqdirsan",
  ];

  final String fullPoem = '''Balki sen haqdirsan, achchiq haqiqat,
Alloh sinov berdi har ikkimizga.
O'tolmadik afsus uvol ketti baxt,
Alamli xotira yo'ldoshdir bizga.

Bilaman gunohim, aybim sanoqsiz,
Bilaman ko'nglinga ko'p azob berdim.
Ayt kim yashagandir shubha xatosiz,
Men ham dunyo uchun baxtimni berdim.

Ko'zlarim ko'r ekan, qalbim ham so'qir,
Qadringga yetmadim, kech anglab yetdim.
Yuragim ezilib ming boro o'qir,
Seni o'z qo'limla men uzoq etdim.

Mayli yashayvergin mendan yiroqda,
Faqat tilagim shu: bo'lgin salomat.
Meni unutarsan balki qachondir,
Lekin sevgim yashar to qiyomat.''';

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: DesctopAppbarWidget(onMenuTap: (int p1) {}, onOpenDrawer: () {}),
        scrolledUnderElevation: 0.0,
        surfaceTintColor: Colors.transparent,
        backgroundColor: AppColors.appbar,
        toolbarHeight: 90.sp,
        automaticallyImplyLeading: false,
      ),
      backgroundColor: AppColors.background,
      // She'rlar sahifasida nafislik muhim, shuning uchun background'ni biroz ochiqroq qilsa ham bo'ladi
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. ASOSIY SHE'R QISMI (Chap tomon)
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 30.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  // Barcha narsa markazda turadi
                  children: [
                    // Breadcrumbs (Navigatsiya)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Bosh sahifa  >  She'rlar  >  Balki sen Haqdirsan",
                        style: GoogleFonts.inter(
                          fontSize: 12.sp,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    SizedBox(height: 50.h),

                    // Kategoriya (Ixtiyoriy, nafis ko'rinish uchun)
                    Text(
                      "M U H A B B A T   L I R I K A S I",
                      style: GoogleFonts.inter(
                        fontSize: 12.sp,
                        color: AppColors.brown,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 4.0, // Harflar orasini ochish
                      ),
                    ),
                    SizedBox(height: 20.h),

                    // She'r Sarlavhasi
                    Text(
                      "Balki Sen Haqdirsan",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.copse(
                        fontSize: 48.sp,
                        color: AppColors.darkBlue,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                    ),
                    SizedBox(height: 16.h),

                    // Muallif
                    Text(
                      "Muallif: Yengilmas",
                      style: GoogleFonts.cinzel(
                        fontSize: 18.sp,
                        color: AppColors.brown,
                        fontWeight: FontWeight.w700,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    SizedBox(height: 50.h),

                    // SHE'R RAMKASI (Poem Frame)
                    Container(
                      width: 700.w,
                      // She'r qutisi juda kengayib ketmasligi uchun qat'iyroq o'lcham
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 30,
                            offset: const Offset(0, 15),
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          // Tepa-chap burchak chizig'i
                          Positioned(
                            top: 20.h,
                            left: 20.w,
                            child: Container(
                              width: 60.w,
                              height: 60.h,
                              decoration: BoxDecoration(
                                border: Border(
                                  top: BorderSide(
                                    color: AppColors.brown,
                                    width: 2,
                                  ),
                                  left: BorderSide(
                                    color: AppColors.brown,
                                    width: 2,
                                  ),
                                ),
                              ),
                            ),
                          ),

                          // Past-o'ng burchak chizig'i
                          Positioned(
                            bottom: 20.h,
                            right: 20.w,
                            child: Container(
                              width: 60.w,
                              height: 60.h,
                              decoration: BoxDecoration(
                                border: Border(
                                  right: BorderSide(
                                    color: AppColors.brown.withOpacity(0.4),
                                    width: 2,
                                  ),
                                  bottom: BorderSide(
                                    color: AppColors.brown.withOpacity(0.4),
                                    width: 2,
                                  ),
                                ),
                              ),
                            ),
                          ),

                          // She'r Matni
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 100.w,
                              vertical: 80.h,
                            ),
                            child: Align(
                              alignment: Alignment.center,
                              child: Text(
                                fullPoem,
                                style: GoogleFonts.crimsonPro(
                                  fontSize: 22.sp,
                                  // Kattaroq, o'qishga qulay
                                  color: Colors.black87,
                                  height: 1.8,
                                  // Qatorlar orasidagi masofa katta bo'lishi kerak
                                  fontStyle: FontStyle.italic,
                                ),
                                textAlign: TextAlign
                                    .left, // She'r vizual tarzda markazda, lekin o'zi chapga taqalgan
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 80.h),

                    // Bezovchi ajratuvchi chiziq
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 100.w,
                          height: 1.h,
                          color: AppColors.brown.withOpacity(0.3),
                        ),
                        SizedBox(width: 16.w),
                        Icon(
                          Icons.diamond_outlined,
                          color: AppColors.brown,
                          size: 16.sp,
                        ),
                        SizedBox(width: 16.w),
                        Container(
                          width: 100.w,
                          height: 1.h,
                          color: AppColors.brown.withOpacity(0.3),
                        ),
                      ],
                    ),
                    SizedBox(height: 60.h),
                  ],
                ),
              ),
            ),
          ),

          // 2. YON PANEL (Sidebar)
          Container(
            padding: EdgeInsets.only(top: 30.h, right: 30.w),
            child: MostReadCard(
              list: popularPoems,
            ), // She'rlar ro'yxatini beramiz
          ),
        ],
      ),
    );
  }
}
