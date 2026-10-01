import 'package:boqiy_qahramonlar/core/app_colors.dart';
import 'package:boqiy_qahramonlar/core/breakpoints.dart';
import 'package:boqiy_qahramonlar/pages/desctop_appbar_widget.dart';
import 'package:boqiy_qahramonlar/pages/desctop_articles_page.dart';
import 'package:boqiy_qahramonlar/pages/desctop_battles_page.dart';
import 'package:boqiy_qahramonlar/pages/desctop_persons_page.dart';
import 'package:boqiy_qahramonlar/pages/desctop_poems_page.dart';
import 'package:boqiy_qahramonlar/service/api_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart'; // Font qo'shildi

import 'desctop_home_page.dart';
import 'footer_widget.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  @override
  void initState() {
    super.initState();
    ApiService().increaseMainView();
  }

  void _scrollToIndex(int index) => navigateToPage(context, index);

  // Drawer elementlarini chizish uchun yordamchi metod
  Widget _buildDrawerItem(String title, int index) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 5.h),
      title: Text(
        title,
        style: GoogleFonts.cinzel(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: context.palette.textPrimary,
        ),
      ),
      onTap: () {
        Navigator.pop(context); // Menyuni yopish
        _scrollToIndex(index); // Tegishli joyga o'tish
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    bool isMobile = size.width < Breakpoints.tablet; // Ekran kengligi bo'yicha tekshiruv
    final palette = context.palette;

    return Scaffold(
      backgroundColor: palette.background,
      // Mobil versiya uchun yon tomondan chiquvchi menyu
      endDrawer: isMobile
          ? Drawer(
              backgroundColor: palette.appbarBg,
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  DrawerHeader(
                    decoration: BoxDecoration(
                      color: palette.background,
                      border: Border(
                        bottom: BorderSide(
                          color: AppColors.brown.withValues(alpha: 0.3),
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
                            color: palette.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildDrawerItem("ASOSIY", 0),
                  _buildDrawerItem("MAQOLALAR", 1),
                  _buildDrawerItem("SHAXSLAR", 2),
                  _buildDrawerItem("JANGLAR", 3),
                  _buildDrawerItem("SHE'RLAR", 4),
                ],
              ),
            )
          : null,
      appBar: AppBar(
        title: const DesctopAppbarWidget(),
        scrolledUnderElevation: 0.0,
        surfaceTintColor: Colors.transparent,
        backgroundColor: palette.appbarBg,
        toolbarHeight: 90.sp,
        automaticallyImplyLeading: false,
        // Default back/menu buttonni olib tashlash
        titleSpacing: 0,
      ),
      body: SizedBox(
        width: size.width,
        height: size.height,
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Barcha qismlarga o'z kaliti (key) berildi
              // RepaintBoundary: skroll qilinganda bo'limlar qayta chizilmaydi,
              // tayyor qatlam faqat siljitiladi.
              const RepaintBoundary(child: DesctopHomePage()),
              const RepaintBoundary(child: DesctopArticlesPage()),
              const RepaintBoundary(child: DesctopPersonsPage()),
              const RepaintBoundary(child: DesctopBattlesPage()),
              const RepaintBoundary(child: DesctopPoemsPage()),
              const RepaintBoundary(child: FooterWidget())
            ],
          ),
        ),
      ),
    );
  }
}
