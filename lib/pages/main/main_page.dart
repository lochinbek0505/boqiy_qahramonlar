import 'package:boqiy_qahramonlar/core/app_colors.dart';
import 'package:boqiy_qahramonlar/pages/main/desctop/desctop_appbar_widget.dart';
import 'package:boqiy_qahramonlar/pages/main/desctop/desctop_articles_page.dart';
import 'package:boqiy_qahramonlar/pages/main/desctop/desctop_persons_page.dart';
import 'package:boqiy_qahramonlar/pages/main/desctop/desctop_poems_page.dart';
import 'package:boqiy_qahramonlar/pages/main/mobile/mobile_appbar_widget.dart';
import 'package:boqiy_qahramonlar/pages/main/mobile/mobile_articles_page.dart';
import 'package:boqiy_qahramonlar/pages/main/mobile/mobile_persons_page.dart';
import 'package:boqiy_qahramonlar/pages/main/mobile/mobile_poems_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'desctop/desctop_home_page.dart';
import 'mobile/mobile_home_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: size.width < 500
          ? AppBar(
              title: MobileAppbarWidget(),
              backgroundColor: AppColors.appbar,
            )
          : AppBar(title: DesctopAppbarWidget(),backgroundColor: AppColors.appbar,toolbarHeight: 90.sp,),
      body: Container(
        width: size.width,
        height: size.height,
        color: AppColors.background,
        child: SingleChildScrollView(
          child: Column(
            children: [
              size.width < 500 ? MobileHomePage() : DesctopHomePage(),
              size.width < 500 ? MobileArticlesPage() : DesctopArticlesPage(),
              size.width < 500 ? MobilePoemsPage() : DesctopPoemsPage(),
              size.width < 500 ? MobilePersonsPage() : DesctopPersonsPage(),
            ],
          ),
        ),
      ),
    );
  }
}
