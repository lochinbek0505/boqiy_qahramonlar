import 'package:boqiy_qahramonlar/core/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class DesctopHomePage extends StatelessWidget {
  const DesctopHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    bool isMobile = MediaQuery.of(context).size.width < 800;

    return Container(
      color: AppColors.background,
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 20.w : 80.w, // Ikkala holatda ham .w ishlatildi
        vertical: isMobile ? 30.h : 40.h,   // Ikkala holatda ham .h ishlatildi
      ),
      child: isMobile
          ? Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildTextContent(isMobile),
          SizedBox(height: 40.h),
          _buildImageContent(isMobile),
        ],
      )
          : Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(flex: 6, child: _buildTextContent(isMobile)),
          SizedBox(width: 40.w),
          Expanded(flex: 5, child: _buildImageContent(isMobile)),
        ],
      ),
    );
  }

  Widget _buildTextContent(bool isMobile) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      // Mobilda matnlar markazda, desktopda esa chapga taqalgan bo'ladi
      crossAxisAlignment: isMobile ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          "Boqiy Qahramonlar: Tarix,\nShonli O'tmish va Bugun Siymolari",
          textAlign: isMobile ? TextAlign.center : TextAlign.start,
          style: GoogleFonts.cinzel(
            fontSize: isMobile ? 26.sp : 44.sp, // .sp qo'shildi
            fontWeight: FontWeight.bold,
            color: AppColors.brown,
            height: 1.2,
          ),
        ),
        SizedBox(height: isMobile ? 30.h : 60.h),
        Container(
          padding: EdgeInsets.only(left: isMobile ? 16.w : 24.w),
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(
                color: AppColors.brown.withOpacity(0.8),
                width: isMobile ? 3.w : 4.w,
              ),
            ),
          ),
          child: Text(
            "O‘zlikni tanish — bu bobolarning ismini bilish emas, ularning qalbida yonib turgan iymon va g‘oya bilan yashashingdir. Qahramon bo‘lish esa shu ikkovi uchun har neni qilmog‘ingdir.",
            textAlign: isMobile ? TextAlign.left : TextAlign.start,
            style: GoogleFonts.inter(
              fontSize: isMobile ? 14.sp : 24.sp, // .sp qo'shildi
              fontWeight: FontWeight.w500,
              color: AppColors.midnightBlue,
              height: 1.6,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImageContent(bool isMobile) {
    return Align(
      alignment: isMobile ? Alignment.center : Alignment.centerRight,
      child: Image.asset(
        "assets/images/personaj.png",
        height: isMobile ? 350.h : 700.h, // .h qo'shildi
        fit: BoxFit.contain,
      ),
    );
  }
}