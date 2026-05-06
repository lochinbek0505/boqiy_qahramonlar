import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/app_colors.dart';

class DesctopPersonsPage extends StatefulWidget {
  const DesctopPersonsPage({super.key});

  @override
  State<DesctopPersonsPage> createState() => _DesctopPersonsPageState();
}

class _DesctopPersonsPageState extends State<DesctopPersonsPage> {
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
    return  Column(
      children: [
        SizedBox(height: 60.h),
        Text(
          "SHAXSLAR",
          style: GoogleFonts.cinzel(
            fontSize: 44.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.midnightBlue,
            height: 1.3,
          ),
        ),
        SizedBox(height: 80.h),
        SizedBox(
          child: Padding(
            padding:  EdgeInsets.symmetric(horizontal: 70.w),
            child: GridView.builder(
              physics: NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                mainAxisSpacing: 10.h,
                crossAxisSpacing: 50.w,
                childAspectRatio: 5/7,
              ),

              shrinkWrap: true,
              itemCount: _heroes.length,
              itemBuilder: (context, index) {
                final heroe = _heroes[index];
                return Padding(
                  padding:  EdgeInsets.only(bottom: 60.h),
                  child:                   Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 4,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 34.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [

                        Text(
                          heroe['name'],
                          textAlign: TextAlign.center,
                          style: GoogleFonts.cinzel(
                            fontSize: 36.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkBlue,
                          ),
                        ),
                        SizedBox(height: 14.h),

                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.brown, width: 1.2),
                          ),
                          child: Text(
                            heroe['years'],
                            style: GoogleFonts.roboto(
                              fontSize: 20.sp,
                              fontWeight: FontWeight.w600,
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
                            fontSize: 22.sp,
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
                        Spacer(),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(width: 20,),
                            Text(
                              "Davomini o'qish",
                              style: GoogleFonts.roboto(
                                fontSize: 21.sp,
                                color: AppColors.brown,
                                fontWeight: FontWeight.w400,

                              ),
                            ),
                            SizedBox(width: 6.w),
                            ImageIcon(AssetImage("assets/icons/arrow.png"),size: 25,color: AppColors.brown,)
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
        SizedBox(height: 60.h,),


        Container(
          width: 340.w,
          decoration: BoxDecoration(
            color: AppColors.steelBlue,
            borderRadius: BorderRadius.circular(5),
          ),
          child: Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 18.h),
              child: Text(
                "KO'PROQ",
                style: GoogleFonts.cinzel(
                  fontSize: 28.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  // height: 1.2,
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: 60.h,)
      ],
    );
  }
}
