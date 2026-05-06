import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/app_colors.dart';

class MobilePersonsPage extends StatefulWidget {
  const MobilePersonsPage({super.key});

  @override
  State<MobilePersonsPage> createState() => _MobilePersonsPageState();
}

class _MobilePersonsPageState extends State<MobilePersonsPage> {
  final List<Map<String, dynamic>> _heroes = [
    {
      'name': 'ALP ARSLON',
      'years': '1063-1072',
      'description':
      "(forscha: آلپ ارسلان)(20-yanvar 1029-yil — noyabr 1075-yil) — Saljuqiylarlarning ikkinchi sultoni (1063-1072), mohir sarkarda. Uning asl ismi Muhammad ibn Dovud.",
    },
    {
      'name': 'ALP ARSLON',
      'years': '1063-1072',
      'description':
      "(forscha: آلپ ارسلان)(20-yanvar 1029-yil — noyabr 1075-yil) — Saljuqiylarlarning ikkinchi sultoni (1063-1072), mohir sarkarda. Uning asl ismi Muhammad ibn Dovud.",
    },

  ];
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 40.h),
        Text(
          "SHAXSLAR",
          style: GoogleFonts.cinzel(
            fontSize: 24.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.midnightBlue,
            height: 1.3,
          ),
        ),
        SizedBox(height: 40.h),
        SizedBox(
          child: Padding(
            padding:  EdgeInsets.symmetric(horizontal: 85.w),
            child: ListView.builder(
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: _heroes.length,
              itemBuilder: (context, index) {
                final heroe = _heroes[index];
                return Padding(
                  padding:  EdgeInsets.only(bottom: 70.h),
                  child:
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 2,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 22.w, vertical: 20.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [

                        Text(
                          heroe['name'],
                          textAlign: TextAlign.center,
                          style: GoogleFonts.cinzel(
                            fontSize: 19.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkBlue,
                          ),
                        ),
                        SizedBox(height: 14.h),

                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.brown, width: 1),
                          ),
                          child: Text(
                            heroe['years'],
                            style: GoogleFonts.roboto(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w700,
                              color: AppColors.brown,
                            ),
                          ),
                        ),
                        SizedBox(height: 14.h),

                        Text(
                          heroe['description'],
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 6,
                          style: GoogleFonts.crimsonText(
                            fontSize: 12.sp,
                            color:Colors.transparent,
                            height: 1.5,
                             shadows:  [
                              Shadow(
                              color: AppColors.darkBlue,
                              offset: Offset(0, -1.2.h)
                        )],
                            decoration: TextDecoration.underline,
                            decorationColor: AppColors.darkBlue,
                          ),
                        ),
                        SizedBox(height: 30.h),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(width: 20,),
                            Text(
                              "Davomini o'qish",
                              style: GoogleFonts.roboto(
                                fontSize: 13.sp,
                                color: AppColors.brown,
                                fontWeight: FontWeight.w400,

                              ),
                            ),
                            SizedBox(width: 6.w),
                            ImageIcon(AssetImage("assets/icons/arrow.png"),size: 17,color: AppColors.brown,)
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        Container(
          width: 150.w,
          decoration: BoxDecoration(
            color: AppColors.steelBlue,
            borderRadius: BorderRadius.circular(3),
          ),
          child: Center(
            child: Padding(
              padding:  EdgeInsets.symmetric(vertical: 10.h),
              child: Text("KO'PROQ",          style: GoogleFonts.cinzel(
                fontSize: 15.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                // height: 1.2,
              ),
              ),
            ),
          ),),
        SizedBox(height: 20.h,)
      ],

    );
  }
}
