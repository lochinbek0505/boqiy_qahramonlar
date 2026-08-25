import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../core/app_colors.dart';

// Barcha menyu va navigatsiya mantiqi bitta joyda
void navigateToPage(BuildContext context, int index) {
  if (index == 0) {
    context.replace('/');
  } else if (index == 1) {
    context.replace('/article');
  } else if (index == 2) {
    context.replace('/poems');
  } else {
    context.replace('/historys');
  }
}

class DesctopAppbarWidget extends StatefulWidget {
  const DesctopAppbarWidget({super.key});

  @override
  State<DesctopAppbarWidget> createState() => _DesctopAppbarWidgetState();
}

class _DesctopAppbarWidgetState extends State<DesctopAppbarWidget> {
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

            // Mobil bo'lsa Drawer ikonkasi
            if (isMobile)
              IconButton(
                icon: const Icon(Icons.menu, color: Colors.black, size: 30),
                onPressed: () {
                  // To'g'ridan-to'g'ri shu yerdan drawerni ochish
                  Scaffold.of(context).openEndDrawer();
                },
              )
            // Desktop bo'lsa Menyular va Qidiruv chiqadi
            else ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_list.length, (index) {
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: 15.w),
                    child: InkWell(
                      onTap: () => navigateToPage(context, index),
                      hoverColor: Colors.transparent,
                      splashColor: Colors.transparent,
                      child: Text(
                        _list[index],
                        style: GoogleFonts.cinzel(
                          fontSize: 16.sp,
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

// Mobil versiya uchun Drawer alohida komponent sifatida ajratildi
class MobileMenuDrawer extends StatelessWidget {
  const MobileMenuDrawer({super.key});

  Widget _buildDrawerItem(BuildContext context, String title, int index) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 5.h),
      title: Text(
        title,
        style: GoogleFonts.cinzel(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.black,
        ),
      ),
      onTap: () {
        Navigator.pop(context); // Menyuni yopish
        navigateToPage(context, index); // Appbar'dagi bir xil navigatsiya ishlaydi
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFFFDFCF6),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: AppColors.background,
              border: Border(
                bottom: BorderSide(
                  color: AppColors.brown.withOpacity(0.3),
                  width: 1,
                ),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 35,
                  backgroundColor: Colors.black,
                  child: Image.asset(
                    "assets/logo.png",
                    fit: BoxFit.fill,
                  ),
                ),
                SizedBox(height: 10.h),
                Text(
                  "MENYU",
                  style: GoogleFonts.cinzel(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.black,
                  ),
                ),
              ],
            ),
          ),
          _buildDrawerItem(context, "ASOSIY", 0),
          _buildDrawerItem(context, "MAQOLALAR", 1),
          _buildDrawerItem(context, "SHE'RLAR", 2),
          _buildDrawerItem(context, "SHAXSLAR", 3),
        ],
      ),
    );
  }
}