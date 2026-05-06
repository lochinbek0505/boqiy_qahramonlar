import 'package:boqiy_qahramonlar/core/app_colors.dart';
import 'package:boqiy_qahramonlar/pages/main/mobile_appbar_widget.dart';
import 'package:boqiy_qahramonlar/pages/main/mobile_articles_page.dart';
import 'package:boqiy_qahramonlar/pages/main/mobile_persons_page.dart';
import 'package:boqiy_qahramonlar/pages/main/mobile_poems_page.dart';
import 'package:flutter/material.dart';

import 'desctop_home_page.dart';
import 'mobile_home_page.dart';

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
      appBar: size.width < 400
          ? AppBar(
              title: MobileAppbarWidget(),
              backgroundColor: AppColors.appbar,
            )
          : AppBar(),
      body: Container(
        width: size.width,
        height: size.height,
        color: AppColors.background,
        child: SingleChildScrollView(
          child: Column(
            children: [
              size.width < 400 ? MobileHomePage() : DesctopHomePage(),
              size.width < 400 ? MobileArticlesPage() : DesctopHomePage(),
              size.width < 400 ? MobilePoemsPage() : DesctopHomePage(),
              size.width < 400 ? MobilePersonsPage() : DesctopHomePage(),

            ],
          ),
        ),
      ),
    );
  }
}
