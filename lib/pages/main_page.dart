import 'package:boqiy_qahramonlar/core/app_colors.dart';
import 'package:boqiy_qahramonlar/pages/desctop_appbar_widget.dart';
import 'package:boqiy_qahramonlar/pages/desctop_articles_page.dart';
import 'package:boqiy_qahramonlar/pages/desctop_persons_page.dart';
import 'package:boqiy_qahramonlar/pages/desctop_poems_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart'; // Font qo'shildi

import 'desctop_home_page.dart';
import 'footer_widget.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  void _scrollToIndex(int index) {
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

  // Drawer elementlarini chizish uchun yordamchi metod
  Widget _buildDrawerItem(String title, int index) {
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
        _scrollToIndex(index); // Tegishli joyga o'tish
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    bool isMobile = size.width < 800; // Ekran kengligi bo'yicha tekshiruv

    return Scaffold(
      backgroundColor: AppColors.background,
      // Mobil versiya uchun yon tomondan chiquvchi menyu
      endDrawer: isMobile
          ? Drawer(
              backgroundColor: const Color(
                0xFFFDFCF6,
              ), // Appbar rangiga moslashdi
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
                  _buildDrawerItem("ASOSIY", 0),
                  _buildDrawerItem("MAQOLALAR", 1),
                  _buildDrawerItem("SHE'RLAR", 2),
                  _buildDrawerItem("SHAXSLAR", 3),
                ],
              ),
            )
          : null,
      appBar: AppBar(
        title: DesctopAppbarWidget(

        ),
        scrolledUnderElevation: 0.0,
        surfaceTintColor: Colors.transparent,
        backgroundColor: AppColors.appbar,
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
              const DesctopHomePage(),
              const DesctopArticlesPage(),
              const DesctopPoemsPage(),
              const DesctopPersonsPage(),
              const FooterWidget()
            ],
          ),
        ),
      ),
    );
  }
}
