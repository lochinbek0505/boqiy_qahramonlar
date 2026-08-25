import 'package:boqiy_qahramonlar/pages/read_poem_page.dart';
import 'package:boqiy_qahramonlar/pages/widgets/more_button.dart';
import 'package:boqiy_qahramonlar/pages/widgets/page_title_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/app_colors.dart';
// O'zingizdagi yo'llarni (path) to'g'irlab olasiz
import '../provider/poems_provider.dart';

class DesctopPoemsPage extends ConsumerWidget {
  const DesctopPoemsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    double width = MediaQuery.of(context).size.width;
    bool isMobile = width < 600;

    // Provider orqali state'ni o'qib olamiz
    final poemState = ref.watch(poemsProvider);

    int getCrossAxisCount() {
      if (width > 1000) return 3;
      if (width > 650) return 2;
      return 1;
    }

    return Column(
      children: [
        SizedBox(height: isMobile ? 30.h : 60.h),
        PageTitleText(title: "She'rlar"),
        SizedBox(height: isMobile ? 30.h : 60.h),

        // Yuklanish holati
        if (poemState.isLoading)
          const Center(child: CircularProgressIndicator())

        // Xatolik holati
        else if (poemState.error != null)
          Center(
            child: Text(
              poemState.error!,
              style: const TextStyle(color: Colors.red),
            ),
          )

        // Ma'lumotlar kelganda
        else ...[
            Padding(
              padding: EdgeInsets.symmetric(horizontal: isMobile ? 20.w : 80.w),
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: getCrossAxisCount(),
                  mainAxisSpacing: isMobile ? 30.h : 60.h,
                  crossAxisSpacing: isMobile ? 20.w : 80.w,
                  childAspectRatio: isMobile ? 1.0 : 0.9,
                ),
                shrinkWrap: true,
                itemCount: poemState.poems.length,
                itemBuilder: (context, index) {
                  final poem = poemState.poems[index];

                  return GestureDetector(
                    onTap: () {

                      // ref.read(poemsProvider.notifier).increasePoems(poem.id!.toInt());

                     context.go('/poems/${poem.id}');
                    },
                    child: Container(
                      color: Colors.transparent,
                      child: Stack(
                        children: [
                          // Burchakdagi ramkalar (Tepasi chap)
                          Positioned(
                            top: 0,
                            left: 0,
                            child: Container(
                              width: isMobile ? 40.w : 80.w,
                              height: isMobile ? 40.h : 80.h,
                              decoration: BoxDecoration(
                                border: Border(
                                  top: BorderSide(color: AppColors.brown, width: 2.w),
                                  left: BorderSide(color: AppColors.brown, width: 2.w),
                                ),
                              ),
                            ),
                          ),
                          // Burchakdagi ramkalar (Pasti o'ng)
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              width: isMobile ? 40.w : 80.w,
                              height: isMobile ? 40.h : 80.h,
                              decoration: BoxDecoration(
                                border: Border(
                                  right: BorderSide(color: Colors.grey.shade400, width: 2.w),
                                  bottom: BorderSide(color: Colors.grey.shade400, width: 2.w),
                                ),
                              ),
                            ),
                          ),

                          Padding(
                            padding: EdgeInsets.all(isMobile ? 20.w : 40.w),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Sarlavha
                                Text(
                                  poem.title ?? "",
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.copse(
                                    fontSize: isMobile ? 20.sp : 24.sp,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.darkBlue,
                                    height: 1.3,
                                  ),
                                ),
                                SizedBox(height: 12.h),

                                // Muallif
                                Text(
                                  "Muallif: ${poem.author?.name ?? "Noma'lum"}",
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.copse(
                                    fontSize: 14.sp,
                                    color: AppColors.brown,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                SizedBox(height: isMobile ? 15.h : 30.h),

                                // She'r matni
                                Expanded(
                                  child: Text(
                                    poem.content ?? "",
                                    overflow: TextOverflow.fade,
                                    style: GoogleFonts.crimsonPro(
                                      fontSize: isMobile ? 14.sp : 16.sp,
                                      color: Colors.black87,
                                      height: 1.6,
                                      fontStyle: FontStyle.italic,
                                    ),
                                    textAlign: TextAlign.left,
                                  ),
                                ),

                                SizedBox(height: 12.h),

                                // YANIGI QO'SHILGAN QISM: Hashteglar va Statistikalar
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    // Chap taraf: Hashteglar
                                    Expanded(
                                      child: poem.hashTegsList != null && poem.hashTegsList!.isNotEmpty
                                          ? Text(
                                        poem.hashTegsList!.map((e) => '#${e.hashteg}').join(' '),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: isMobile ? 11.sp : 13.sp,
                                          color: Colors.blueAccent,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      )
                                          : const SizedBox(),
                                    ),

                                    // O'ng taraf: View count va Read time
                                    Row(
                                      children: [
                                        // View count
                                        Icon(Icons.visibility_outlined, size: isMobile ? 14.sp : 16.sp, color: Colors.grey.shade600),
                                        SizedBox(width: 4.w),
                                        Text(
                                          "${poem.viewCount ?? 0}",
                                          style: TextStyle(
                                            fontSize: isMobile ? 11.sp : 13.sp,
                                            color: Colors.grey.shade600,
                                          ),
                                        ),

                                        SizedBox(width: 12.w),

                                        // Read time
                                        Icon(Icons.access_time, size: isMobile ? 14.sp : 16.sp, color: Colors.grey.shade600),
                                        SizedBox(width: 4.w),
                                        Text(
                                          "${poem.readTime ?? 0} daq",
                                          style: TextStyle(
                                            fontSize: isMobile ? 11.sp : 13.sp,
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: isMobile ? 20.h : 40.h),
             GestureDetector(
                 onTap: (){
                   context.go('/poems');
                 },
                 child: MoreButton()),
            SizedBox(height: isMobile ? 30.h : 60.h),
          ],
      ],
    );
  }
}