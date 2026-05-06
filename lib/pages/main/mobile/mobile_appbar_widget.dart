import 'package:boqiy_qahramonlar/core/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class MobileAppbarWidget extends StatefulWidget {
  const MobileAppbarWidget({super.key});

  @override
  State<MobileAppbarWidget> createState() => _MobileAppbarWidgetState();
}

class _MobileAppbarWidgetState extends State<MobileAppbarWidget> {
  @override
  Widget build(BuildContext context) {
    return Row(children: [
       CircleAvatar(radius: 20.r,backgroundColor: Colors.black,),
       SizedBox(width: 12.w,),
       Column(
         crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("BOQIY", style: GoogleFonts.cinzel(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.black,
            height: 1.2,
          ),),
          Text(
            "QAHRAMONLAR",
            style: GoogleFonts.cinzel(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
                color: AppColors.black,
              height: 1.2,

            ),
          ),
        ],
      ),
      Spacer(),
      ImageIcon(AssetImage("assets/icons/menu.png"),size: 28.sp,color: AppColors.black,),

    ],
    );
  }
}
