import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/app_colors.dart';

class DesctopAppbarWidget extends StatefulWidget {
  const DesctopAppbarWidget({super.key});

  @override
  State<DesctopAppbarWidget> createState() => _DesctopAppbarWidgetState();
}

class _DesctopAppbarWidgetState extends State<DesctopAppbarWidget> {
   final List<String> _list=["MAQOLALAR","SHE'RLAR","SHAXSLAR"];
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Padding(
      padding:  EdgeInsets.symmetric(horizontal: 8.w),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
        CircleAvatar(radius: 32.sp,backgroundColor: Colors.black,),
        SizedBox(width: 28.w,),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("BOQIY", style: GoogleFonts.cinzel(
              fontSize: 29.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.black,
            ),),
            Text(
              "QAHRAMONLAR   ${size.width } ${size.height}",
              style: GoogleFonts.cinzel(
                fontSize: 23.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.black,
                height: 1.2,

              ),
            ),
          ],
        ),
        Spacer(),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_list.length, (index) {
            bool isActive = index == 0;
            return             Padding(
              padding:  EdgeInsets.symmetric(horizontal: 35.w),
              child: Text(
               _list[index],
                style: GoogleFonts.cinzel(
                  fontSize: 21.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.black,
                  height: 1.2,

                ),
              ),
            );
          }),
        ),
        SizedBox(width: 70.w,),
      SizedBox(
        width: 310.w,
        height: 64.w,
        child: TextField(
          textAlignVertical: TextAlignVertical.center,
          expands: false,
          maxLines: 1,
          minLines: 1,
          style: GoogleFonts.cinzel(

            color: Colors.black,
            fontSize: 18.sp,
            fontWeight: FontWeight.w600
          ),
          decoration: InputDecoration(
            hintText: "qidirish",
            hintStyle: GoogleFonts.cinzel(
              color: Colors.black,
              fontSize: 18.sp,
              fontWeight: FontWeight.w500,
            ),
            prefixIcon: Padding(
              padding: EdgeInsets.only(left: 15.w, right: 10.w),
              child: Icon(
                Icons.search,
                color: Colors.black,
                size: 28.sp,
              ),
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
            contentPadding: EdgeInsets.symmetric(vertical: 10.h),
          ),
        ),
      )



      ],
      ),
    );
  }
}
