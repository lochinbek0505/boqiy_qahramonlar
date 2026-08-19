import 'package:boqiy_qahramonlar/pages/main/desctop/read_persons_page.dart';
import 'package:boqiy_qahramonlar/pages/main/desctop/widgets/more_button.dart';
import 'package:boqiy_qahramonlar/pages/main/desctop/widgets/page_title_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/app_colors.dart';

class DesctopPersonsPage extends StatelessWidget { // Statik ro'yxat bo'lgani uchun StatelessWidget qildik
  const DesctopPersonsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Ro'yxat build metodining ichiga yoki alohida faylga/modelga o'tkazilsa yaxshi. Hozircha shu yerda qoldi.
    final List<Map<String, dynamic>> heroes = [
      {
        'name': 'ALP ARSLON',
        'years': '1063-1072',
        'description':
        "(forscha: آلپ ارسلان)(20-yanvar 1029-yil — noyabr 1075-yil) — Saljuqiylarlarning ikkinchi sultoni (1063-1072), mohir sarkarda. Uning asl ismi Muhammad ibn Dovud.",
      },
      {
        'name': 'ALP ARSLON',
        'years': '1063-1072',
        'description':
        "(forscha: آلپ ارسلان)(20-yanvar 1029-yil — noyabr 1075-yil) — Saljuqiylarlarning ikkinchi sultoni (1063-1072), mohir sarkarda. Uning asl ismi Muhammad ibn Dovud.",
      },
      // ... Boshqa elementlar
      {
        'name': 'ALP ARSLON',
        'years': '1063-1072',
        'description':
        "(forscha: آلپ ارسلان)(20-yanvar 1029-yil — noyabr 1075-yil) — Saljuqiylarlarning ikkinchi sultoni (1063-1072), mohir sarkarda. Uning asl ismi Muhammad ibn Dovud.",
      },
    ];

    return Column(
      children: [
        SizedBox(height: 60.h),
        PageTitleText(title: "Shaxslar"),
        SizedBox(height: 60.h), // Masofa biroz qisqartirildi

        Padding(
          padding: EdgeInsets.symmetric(horizontal: 70.w),
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            // Grid parametrlari vizual jihatdan to'g'rilandi
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 40.h, // Kartalar orasidagi vertikal masofa
              crossAxisSpacing: 30.w, // Kartalar orasidagi gorizontal masofa
              childAspectRatio: 0.75, // Kartaning nisbati
            ),
            shrinkWrap: true,
            itemCount: heroes.length,
            itemBuilder: (context, index) {
              final hero = heroes[index];
              return GestureDetector(
                onTap: (){
                  Navigator.push(context, MaterialPageRoute(builder: (builder)=>ReadPersonPage()));
                },
                child: Container(
                  // Karta dizayni
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.r), // Yengil yumaloqlik
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06), // Yumshoq soya
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 30.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Ism
                      Text(
                        hero['name'],
                        textAlign: TextAlign.center,
                        style: GoogleFonts.cinzel(
                          fontSize: 22.sp, // Biroz yiriklashtirildi
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkBlue,
                        ),
                      ),
                      SizedBox(height: 16.h),
                
                      // Yillar (Quticha)
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.brown, width: 1.2),
                          borderRadius: BorderRadius.circular(4.r), // Kichik yumaloqlik
                        ),
                        child: Text(
                          hero['years'],
                          style: GoogleFonts.roboto(
                            fontSize: 12.sp, // O'qilishi oson bo'lishi uchun kattalashtirildi
                            fontWeight: FontWeight.w700,
                            color: AppColors.brown,
                          ),
                        ),
                      ),
                      SizedBox(height: 24.h),
                
                      // Ma'lumot (Description)
                      Expanded(
                        child: Text(
                          hero['description'],
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 5,
                          style: GoogleFonts.crimsonText(
                            fontSize: 16.sp,
                            color: Colors.grey.shade800, // Qulay o'qiladigan rang
                            height: 1.5, // Qatorlar orasidagi bo'shliq
                          ),
                        ),
                      ),
                
                      // Davomi tugmasi
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Davomi",
                            style: GoogleFonts.roboto(
                              fontSize: 15.sp,
                              color: AppColors.brown,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Icon(
                            Icons.arrow_forward_outlined, // Maxsus rasm o'rniga material icon ishlatish ko'proq tavsiya etiladi (agar rasm shart bo'lmasa)
                            size: 18.sp,
                            color: AppColors.brown,
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

        SizedBox(height: 50.h),
        const MoreButton(),
        SizedBox(height: 80.h),
      ],
    );
  }
}