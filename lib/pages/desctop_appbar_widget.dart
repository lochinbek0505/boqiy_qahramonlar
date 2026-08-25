import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/app_colors.dart';

class DesctopAppbarWidget extends StatefulWidget {
  final Function(int) onMenuTap;
  final VoidCallback onOpenDrawer;

  const DesctopAppbarWidget({
    super.key,
    required this.onMenuTap,
    required this.onOpenDrawer,
  });

  @override
  State<DesctopAppbarWidget> createState() => _DesctopAppbarWidgetState();
}

class _DesctopAppbarWidgetState extends State<DesctopAppbarWidget> {
  // Asosiy menyusi qo'shildi
  final List<String> _list = ["ASOSIY", "MAQOLALAR", "SHE'RLAR", "SHAXSLAR"];

  @override
  Widget build(BuildContext context) {
    bool isMobile = MediaQuery.of(context).size.width < 800; // Breakpoint

    return Container(
      color: const Color(0xFFFDFCF6),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 8.w),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: isMobile ? 20 : 28.sp,
              backgroundColor: Colors.black,
              child: Image.asset("assets/logo.png", fit: BoxFit.fill),
            ),
            SizedBox(width: isMobile ? 10 : 20.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "BOQIY",
                  style: GoogleFonts.cinzel(
                    fontSize: isMobile ? 16 : 26.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.black,
                  ),
                ),
                Text(
                  "QAHRAMONLAR",
                  style: GoogleFonts.cinzel(
                    fontSize: isMobile ? 12 : 20.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.black,
                    height: 1.2,
                  ),
                ),
              ],
            ),
            const Spacer(),

            // Mobil bo'lsa Drawer ikonkasi, Desktop bo'lsa Menyular va Qidiruv chiqadi
            if (isMobile)
              IconButton(
                icon: const Icon(Icons.menu, color: Colors.black, size: 30),
                onPressed: widget.onOpenDrawer,
              )
            else ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_list.length, (index) {
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: 15.w), // Joy yetishi uchun biroz qisqartirildi
                    child: InkWell(
                      onTap: () => widget.onMenuTap(index),
                      hoverColor: Colors.transparent,
                      splashColor: Colors.transparent,
                      child: Text(
                        _list[index],
                        style: GoogleFonts.cinzel(
                          fontSize: 16.sp, // Shrift biroz moslashtirildi
                          fontWeight: FontWeight.bold,
                          color: AppColors.black,
                          height: 1.2,
                        ),
                      ),
                    ),
                  );
                }),
              ),
              SizedBox(width: 30.w),
              SizedBox(
                width: 220.w,
                height: 45.h,
                child: TextField(
                  textAlignVertical: TextAlignVertical.center,
                  expands: false,
                  maxLines: 1,
                  minLines: 1,
                  style: GoogleFonts.cinzel(
                    color: Colors.black,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                  decoration: InputDecoration(
                    hintText: "qidirish",
                    hintStyle: GoogleFonts.cinzel(
                      color: Colors.black,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                    ),
                    prefixIcon: Padding(
                      padding: EdgeInsets.only(left: 15.w, right: 10.w),
                      child: Icon(Icons.search, color: Colors.black, size: 20.sp),
                    ),
                    filled: true,
                    fillColor: Colors.transparent,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(100.r),
                      borderSide: const BorderSide(color: Colors.black, width: 1),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(100.r),
                      borderSide: const BorderSide(color: Colors.black, width: 1.3),
                    ),
                    contentPadding: EdgeInsets.symmetric(vertical: 0.h),
                  ),
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}