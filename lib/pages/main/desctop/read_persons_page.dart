import 'package:boqiy_qahramonlar/pages/main/desctop/widgets/most_read_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/app_colors.dart';
import '../mobile/mobile_appbar_widget.dart';
import 'desctop_appbar_widget.dart';

class ReadPersonPage extends StatefulWidget {
  const ReadPersonPage({super.key});

  @override
  State<ReadPersonPage> createState() => _ReadPersonPageState();
}

class _ReadPersonPageState extends State<ReadPersonPage> {
  // Yon panel (Sidebar) uchun eng ko'p o'qilgan shaxslar ro'yxati
  final List<String> popularPersons = [
    "1. Amir Temur",
    "2. Jaloliddin Manguberdi",
    "3. Zahiriddin Muhammad Bobur",
    "4. Sulton Mahmud G'aznaviy",
    "5. Mirzo Ulug'bek",
    "6. Alp Arslon",
  ];

  // Boshqa shaxslar (Grid) uchun ma'lumotlar
  final List<Map<String, dynamic>> _otherHeroes = [
    {
      'name': 'SULTON SANJAR',
      'years': '1118-1157',
      'description':
      "Saljuqiylar davlatining so'nggi buyuk sultoni. Uning davrida Movarounnahr va Xuroson saljuqiylar ta'sirida bo'lgan.",
    },
    {
      'name': 'JALOLIDDIN MANGUBERDI',
      'years': '1199-1231',
      'description':
      "Xorazmshohlar davlatining so'nggi hukmdori, mo'g'ullar bosqiniga qarshi kurashgan buyuk sarkarda.",
    },
    {
      'name': 'AMIR TEMUR',
      'years': '1336-1405',
      'description':
      "Buyuk sarkarda, Temuriylar imperiyasi asoschisi. O'z davrining eng qudratli davlatini barpo etgan.",
    },
  ];

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

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
          // 1. ASOSIY MA'LUMOT QISMI (Chap tomon)
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 30.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Breadcrumbs (Navigatsiya)
                    Text(
                      "Bosh sahifa  >  Shaxslar  >  Alp Arslon",
                      style: GoogleFonts.inter(
                        fontSize: 12.sp,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 24.h),

                    // Kategoriya yoki Davlat nomi
                    Text(
                      "SALJUQIYLAR DAVLATI SULTONI",
                      style: GoogleFonts.inter(
                        fontSize: 13.sp,
                        color: AppColors.brown,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.5,
                      ),
                    ),
                    SizedBox(height: 16.h),

                    // Shaxsning Ismi
                    Text(
                      "ALP ARSLON",
                      style: GoogleFonts.cinzel(
                        fontSize: 42.sp, // Shaxs ismi uchun yirik o'lcham
                        color: AppColors.black,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                    ),
                    SizedBox(height: 12.h),

                    // Yashagan yoki hukmronlik yillari
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.brown, width: 1.5),
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      child: Text(
                        "1029 — 1075 yillar",
                        style: GoogleFonts.roboto(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.brown,
                        ),
                      ),
                    ),
                    SizedBox(height: 40.h),

                    // Asosiy Rasm (Portret)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20.r),
                      child: Image.asset(
                        "assets/images/alparslon.png", // Rasm nomini o'zingizga moslang
                        width: double.infinity,
                        height: 550.h,
                        fit: BoxFit.cover,
                      ),
                    ),
                    SizedBox(height: 40.h),

                    // Asosiy Matn (Biografiya)
                    Text(
                      "(forscha: آلپ ارسلان) (20-yanvar 1029-yil — noyabr 1075-yil) — Saljuqiylarlarning ikkinchi sultoni (1063-1072), mohir sarkarda. Uning asl ismi Muhammad ibn Dovud.\n\n"
                          "Alp Arslon davrida Saljuqiylar davlati o'zining eng qudratli cho'qqilaridan biriga chiqdi. Uning eng mashhur g'alabalaridan biri 1071-yilda Vizantiya imperiyasiga qarshi bo'lib o'tgan Malazgirt jangi hisoblanadi. Bu jangdagi g'alaba Anadolu (hozirgi Turkiya) hududining turkiy xalqlar tomonidan o'zlashtirilishiga asosiy eshikni ochib berdi.\n\n"
                          "Sulton o'zining adolatliligi, jasorati va islom dini rivojiga qo'shgan hissasi bilan tarixda nom qoldirgan. Uning davrida ilm-fan, madaniyat va me'morchilik yuqori darajada rivoj topdi. Vazir Nizomulmulk kabi yetuk davlat arboblari bilan birgalikda davlatni boshqarish tizimini mukammallashtirdi.",
                      style: GoogleFonts.inter(
                        fontSize: 18.sp,
                        color: Colors.black87,
                        height: 1.8,
                      ),
                    ),
                    SizedBox(height: 60.h),

                    // "Boshqa shaxslar" sarlavhasi
                    Divider(color: Colors.grey.shade300, thickness: 1),
                    SizedBox(height: 40.h),
                    Text(
                      "Boshqa tarixiy shaxslar",
                      style: GoogleFonts.inter(
                        fontSize: 26.sp,
                        color: AppColors.black,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 40.h),

                    // GridView qismi (Shaxslar uchun moslashtirilgan)
                    GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3, // Yonma-yon 3 ta chiqadi
                        mainAxisSpacing: 30.h,
                        crossAxisSpacing: 30.w,
                        childAspectRatio: 0.75, // Shaxslar kartasi nisbati
                      ),
                      shrinkWrap: true,
                      itemCount: _otherHeroes.length,
                      itemBuilder: (context, index) {
                        final hero = _otherHeroes[index];
                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12.r),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.06),
                                blurRadius: 15,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 30.h),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                hero['name'],
                                textAlign: TextAlign.center,
                                style: GoogleFonts.cinzel(
                                  fontSize: 20.sp,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.darkBlue,
                                ),
                              ),
                              SizedBox(height: 16.h),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
                                decoration: BoxDecoration(
                                  border: Border.all(color: AppColors.brown, width: 1.2),
                                  borderRadius: BorderRadius.circular(4.r),
                                ),
                                child: Text(
                                  hero['years'],
                                  style: GoogleFonts.roboto(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.brown,
                                  ),
                                ),
                              ),
                              SizedBox(height: 24.h),
                              Expanded(
                                child: Text(
                                  hero['description'],
                                  textAlign: TextAlign.center,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 4,
                                  style: GoogleFonts.crimsonText(
                                    fontSize: 16.sp,
                                    color: Colors.grey.shade800,
                                    height: 1.5,
                                  ),
                                ),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Batafsil",
                                    style: GoogleFonts.roboto(
                                      fontSize: 15.sp,
                                      color: AppColors.brown,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  SizedBox(width: 8.w),
                                  Icon(
                                    Icons.arrow_forward_outlined,
                                    size: 18.sp,
                                    color: AppColors.brown,
                                  ),
                                ],
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
          Container(
            padding: EdgeInsets.only(top: 30.h, right: 30.w),
            // MostReadCard ga shaxslar ro'yxatini beramiz
            child: MostReadCard(list: popularPersons),
          ),
        ],
      ),
    );
  }
}