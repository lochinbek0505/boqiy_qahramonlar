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
    return  Column(
        children: [
          Text("Boqiy Qahramonlar:\n Tarix , Shonli O'tmish\n va Bugun siymolari",style: GoogleFonts.cinzel(
            fontSize: 24.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.brown,
           // height: 1.2,
          ),)
        ],
    );
  }
}
