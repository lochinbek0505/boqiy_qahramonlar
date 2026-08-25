import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/app_colors.dart';

class MoreButton extends StatelessWidget {
  const MoreButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200.w,
      height: 70.h,
      decoration: BoxDecoration(
        color: AppColors.steelBlue,
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 18.h),
          child: Text(
            "KO'PROQ",
            style: GoogleFonts.cinzel(
              fontSize: 20.sp,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              // height: 1.2,
            ),
          ),
        ),
      ),
    );
  }
}
