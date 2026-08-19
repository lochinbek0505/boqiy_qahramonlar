import 'package:boqiy_qahramonlar/core/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class DesctopHomePage extends StatefulWidget {
  const DesctopHomePage({super.key});

  @override
  State<DesctopHomePage> createState() => _DesctopHomePageState();
}

class _DesctopHomePageState extends State<DesctopHomePage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,

      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 65.w),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 900.w,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 100.h),
                  Text(
                    "Boqiy Qahramonlar: Tarix  ,\nShonli O'tmish va Bugun siymolari",
                    style: GoogleFonts.cinzel(
                      fontSize: 40.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.brown,
                    ),
                  ),
                  SizedBox(height: 100.h),

                  Text(
                    "O‘zlikni tanish — bu bobolarning\nismini bilish emas, ularning qalbida\nyonib turgan iymon va g‘oya bilan\nyashashingdir. Qahramon bo‘lish\nesa shu ikkovi uchun har neni qilmog‘ingdir.",

                    style: GoogleFonts.inter(
                      fontSize: 30.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColors.midnightBlue,
                    ),
                  ),
                  SizedBox(height: 200.h),
                ],
              ),
            ),
            Image.asset("assets/images/personaj.png", height: 750.h),
          ],
        ),
      ),
    );
  }
}
