import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/app_colors.dart';

class FooterWidget extends StatelessWidget {
  final Function(int)? onMenuTap; // Menyularni bosganda skroll qilish uchun

  const FooterWidget({super.key, this.onMenuTap});

  @override
  Widget build(BuildContext context) {
    bool isMobile = MediaQuery.of(context).size.width < 800;

    return Container(
      width: double.infinity,
      color: const Color(0xFF1A1A1A), // Footer uchun to'q fon
      padding: EdgeInsets.only(
        top: isMobile ? 40.h : 60.h,
        bottom: isMobile ? 20.h : 30.h,
        left: isMobile ? 20.w : 80.w,
        right: isMobile ? 20.w : 80.w,
      ),
      child: Column(
        children: [
          // Asosiy qism
          isMobile
              ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildBrandInfo(isMobile),
              SizedBox(height: 40.h),
              _buildLinks(isMobile),
              SizedBox(height: 40.h),
              _buildContact(isMobile),
            ],
          )
              : Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(flex: 2, child: _buildBrandInfo(isMobile)),
              SizedBox(width: 40.w),
              Expanded(flex: 1, child: _buildLinks(isMobile)),
              SizedBox(width: 40.w),
              Expanded(flex: 1, child: _buildContact(isMobile)),
            ],
          ),

          SizedBox(height: isMobile ? 30.h : 50.h),

          // Chiziq
          Divider(color: Colors.grey.shade800, thickness: 1),

          SizedBox(height: 20.h),

          // Copyright qismi
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  "© 2026 Boqiy Qahramonlar. Barcha huquqlar himoyalangan.",
                  style: GoogleFonts.inter(
                    fontSize: isMobile ? 12.sp : 14.sp,
                    color: Colors.grey.shade500,
                  ),
                ),
              ),
              if (!isMobile)
                Text(
                  "Yaratuvchi: Turon Beka",
                  style: GoogleFonts.inter(
                    fontSize: 14.sp,
                    color: Colors.grey.shade500,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  // 1-qism: Logo va Qisqacha ma'lumot
  Widget _buildBrandInfo(bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: isMobile ? 20.r : 25.r,
              backgroundColor: Colors.white,
              child: Image.asset("assets/logo.png", fit: BoxFit.fill),
            ),
            SizedBox(width: 15.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "BOQIY",
                  style: GoogleFonts.cinzel(
                    fontSize: isMobile ? 18.sp : 22.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  "QAHRAMONLAR",
                  style: GoogleFonts.cinzel(
                    fontSize: isMobile ? 14.sp : 16.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ],
        ),
        SizedBox(height: 20.h),
        Text(
          "O‘zlikni tanish — bu bobolarning ismini bilish emas, ularning qalbida yonib turgan iymon va g‘oya bilan yashashingdir.",
          style: GoogleFonts.inter(
            fontSize: isMobile ? 13.sp : 15.sp,
            color: Colors.grey.shade400,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  // 2-qism: Tezkor havolalar (Menyular)
  Widget _buildLinks(bool isMobile) {
    List<String> links = ["Asosiy", "Maqolalar", "She'rlar", "Shaxslar"];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "BO'LIMLAR",
          style: GoogleFonts.cinzel(
            fontSize: isMobile ? 16.sp : 18.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 20.h),
        ...List.generate(links.length, (index) {
          return Padding(
            padding: EdgeInsets.only(bottom: 12.h),
            child: InkWell(
              onTap: onMenuTap != null ? () => onMenuTap!(index) : null,
              child: Text(
                links[index],
                style: GoogleFonts.inter(
                  fontSize: isMobile ? 14.sp : 15.sp,
                  color: Colors.grey.shade400,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  // 3-qism: Aloqa va ijtimoiy tarmoqlar
  Widget _buildContact(bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "BOG'LANISH",
          style: GoogleFonts.cinzel(
            fontSize: isMobile ? 16.sp : 18.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 20.h),
        _buildContactItem(Icons.location_on_outlined, "Samarqand shahar, O'zbekiston", isMobile),
        SizedBox(height: 12.h),
        _buildContactItem(Icons.phone_outlined, "+998 90 123 45 67", isMobile),
        SizedBox(height: 12.h),
        _buildContactItem(Icons.email_outlined, "info@boqiyqahramonlar.uz", isMobile),
      ],
    );
  }

  Widget _buildContactItem(IconData icon, String text, bool isMobile) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, color: AppColors.brown, size: isMobile ? 18.sp : 20.sp),
        SizedBox(width: 10.w),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.inter(
              fontSize: isMobile ? 13.sp : 14.sp,
              color: Colors.grey.shade400,
            ),
          ),
        ),
      ],
    );
  }
}