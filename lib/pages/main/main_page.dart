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
        body: Container(
      width: size.width,
      height: size.height,
          child: SingleChildScrollView(
            child: Column(
              children: [
                size.width<400? const MobileHomePage() : const DesctopHomePage(),
              ],
            ),
          ),
        ),
    );
  }
}
