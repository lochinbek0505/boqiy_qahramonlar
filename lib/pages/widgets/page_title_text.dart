import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/app_colors.dart';

class PageTitleText extends StatelessWidget {
  final String title;

  PageTitleText({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: GoogleFonts.cinzel(
        fontSize: 38.sp,
        fontWeight: FontWeight.bold,
        color: AppColors.midnightBlue,
      ),
    );
  }
}
