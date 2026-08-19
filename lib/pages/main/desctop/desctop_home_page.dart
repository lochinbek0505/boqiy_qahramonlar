import 'package:boqiy_qahramonlar/core/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class DesctopHomePage extends StatelessWidget {
  const DesctopHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      width: double.infinity, // Ekranni to'liq egallashi uchun
      padding: EdgeInsets.symmetric(horizontal: 80.w, vertical: 40.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 1. MATN QISMI (Chap tomon)
          Expanded(
            flex: 6, // Ekranning 6 qismini matn egallaydi
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min, // Konteyner faqat o'ziga kerakli joyni oladi
              children: [
                Text(
                  "Boqiy Qahramonlar: Tarix,\nShonli O'tmish va Bugun Siymolari",
                  style: GoogleFonts.cinzel(
                    fontSize: 44.sp, // Asosiy sahifa bo'lgani uchun sarlavha biroz yirikroq
                    fontWeight: FontWeight.bold,
                    color: AppColors.brown,
                    height: 1.2, // Qatorlar orasidagi masofa
                  ),
                ),
                SizedBox(height: 60.h),

                // Iqtibos (Quote) qismi uchun zamonaviy dizayn
                Container(
                  padding: EdgeInsets.only(left: 24.w), // Chiziqdan biroz uzoqlashtirish
                  decoration: BoxDecoration(
                    border: Border(
                      left: BorderSide(
                        color: AppColors.brown.withOpacity(0.8),
                        width: 4.w, // Chap tomondagi iqtibos chizig'i
                      ),
                    ),
                  ),
                  child: Text(
                    "O‘zlikni tanish — bu bobolarning ismini bilish emas, ularning qalbida yonib turgan iymon va g‘oya bilan yashashingdir. Qahramon bo‘lish esa shu ikkovi uchun har neni qilmog‘ingdir.",
                    style: GoogleFonts.inter(
                      fontSize: 24.sp, // O'qishga qulay hajm
                      fontWeight: FontWeight.w500,
                      color: AppColors.midnightBlue,
                      height: 1.6,
                      fontStyle: FontStyle.italic, // Iqtibos bo'lgani uchun qiya shrift
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(width: 40.w), // Matn va rasm o'rtasidagi masofa

          // 2. RASM QISMI (O'ng tomon)
          Expanded(
            flex: 5, // Ekranning 5 qismini rasm egallaydi
            child: Align(
              alignment: Alignment.centerRight,
              child: Image.asset(
                "assets/images/personaj.png",
                height: 700.h,
                fit: BoxFit.contain, // Rasm proporsiyasi buzilmasligini ta'minlash
              ),
            ),
          ),
        ],
      ),
    );
  }
}