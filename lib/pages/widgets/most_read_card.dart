import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/app_colors.dart';

class MostReadCard extends StatelessWidget {
  final List<String> list; // StatelessWidget ichida o'zgaruvchilar 'final' bo'lishi shart

  const MostReadCard({super.key, required this.list});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 340.w, // Kengligi biroz moslashtirildi
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r), // Asosiy sahifadagi kartalar bilan bir xil
          border: Border.all(color: Colors.grey.shade100, width: 1), // Yupqa chegara
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04), // Yumshoq va zamonaviy soya
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min, // Ichidagi elementlar qancha bo'lsa shuncha joy oladi
            children: [
              Text(
                "Ko'p o'qilganlar",
                style: GoogleFonts.inter(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w800,
                  color: Colors.black,
                  letterSpacing: 0.5,
                ),
              ),
              SizedBox(height: 16.h),

              // Ro'yxatni chizish va orasiga chiziq (Divider) qo'shish
              ...List.generate(list.length, (index) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 14.h), // Matnlar atrofida bo'shliq
                      child: Text(
                        list[index],
                        style: GoogleFonts.inter(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade800, // Qora emas, to'q kulrang o'qishga qulayroq
                          height: 1.5, // Qatorlar orasidagi masofa
                        ),
                      ),
                    ),

                    // Eng oxirgi elementdan tashqari hammasining tagiga chiziq tortamiz
                    if (index < list.length - 1)
                      Divider(
                        color: Colors.grey.shade200,
                        thickness: 1,
                        height: 1,
                      ),
                  ],
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}