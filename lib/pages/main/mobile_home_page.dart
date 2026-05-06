import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/app_colors.dart';

class MobileHomePage extends StatefulWidget {
  const MobileHomePage({super.key});

  @override
  State<MobileHomePage> createState() => _MobileHomePageState();
}

class _MobileHomePageState extends State<MobileHomePage> {
  @override
  Widget build(BuildContext context) {
    //  var size = MediaQuery.of(context).size;

    return Column(
      children: [
        SizedBox(height: 20.h),
        Text(
          "Boqiy Qahramonlar:\nTarix , Shonli O'tmish\nva Bugun siymolari",
          style: GoogleFonts.cinzel(
            fontSize: 24.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.brown,
             height: 1.3,
          ),
        ),
        SizedBox(height: 15.h),

        Image(
          image: AssetImage("assets/images/personaj.png"),
          fit: BoxFit.fitHeight,
          height: 360.h,
        ),
        SizedBox(height: 30.h),

        Text(
          "O'ZLIKNI TANISH — BU BOBOLARNING\nISMINI BILISH EMAS, ULARNING\nQALBIDA YONIB TURGAN IYMON VA\nG'OYA BILAN YASHASHINGDIR.\nQAHRAMON BO'LISH ESA SHU IKKOVI\nUCHUN HAR NENI QILMOG'INGDIR.",
          style: GoogleFonts.cinzel(
            fontSize: 15.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.midnightBlue,
            // height: 1.2,
          ),
        ),
        SizedBox(height: 40.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(6, (index) {
            bool isActive = index == 0;
            return Container(
              margin: EdgeInsets.symmetric(horizontal: 4.w),
              width: 12.w,
              height: 12.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                border: Border.all(color: AppColors.indigoBlue, width: 1.5.w),
              ),
              child: isActive
                  ? Center(
                      child: Container(
                        width: 6.w,
                        height: 6.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.indigoBlue,
                        ),
                      ),
                    )
                  : null,
            );
          }),
        ),
      ],
    );
  }
}
