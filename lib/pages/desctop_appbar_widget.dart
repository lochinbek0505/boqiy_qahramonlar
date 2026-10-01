import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../core/app_colors.dart';
import '../core/breakpoints.dart';
import '../provider/theme_provider.dart';

// Barcha menyu va navigatsiya mantiqi bitta joyda
void navigateToPage(BuildContext context, int index) {
  if (index == 0) {
    context.replace('/');
  } else if (index == 1) {
    context.replace('/article');
  } else if (index == 2) {
    context.replace('/historys');
  } else if (index == 3) {
    context.replace('/battles');
  } else {
    context.replace('/poems');
  }
}

class DesctopAppbarWidget extends ConsumerStatefulWidget {
  const DesctopAppbarWidget({super.key});

  @override
  ConsumerState<DesctopAppbarWidget> createState() =>
      _DesctopAppbarWidgetState();
}

class _DesctopAppbarWidgetState extends ConsumerState<DesctopAppbarWidget> {
  final List<String> _list = ["ASOSIY", "MAQOLALAR", "SHAXSLAR", "JANGLAR", "SHE'RLAR"];

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    // Eslatma: bu breakpoint ilovadagi eng "og'ir" qator (logo + 4 ta menyu
    // + qidiruv maydoni), shuning uchun u Breakpoints.tablet (1000) ga
    // moslashtirilgan — aks holda 800-1000px oralig'ida menyu qatori
    // sig'may (RenderFlex overflow) qolardi.
    bool isMobile = MediaQuery.of(context).size.width < Breakpoints.tablet;

    return Container(
      color: palette.appbarBg,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 8.w),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: isMobile ? 20 : 28.sp,
              backgroundColor: Colors.black,
              child: Image.asset("assets/logo.png", fit: BoxFit.fill),
            ),
            SizedBox(width: isMobile ? 10 : 20.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "BOQIY",
                  style: GoogleFonts.cinzel(
                    fontSize: isMobile ? 16 : 24.sp,
                    fontWeight: FontWeight.bold,
                    color: palette.textPrimary,
                  ),
                ),
                Text(
                  "QAHRAMONLAR",
                  style: GoogleFonts.cinzel(
                    fontSize: isMobile ? 12 : 16.sp,
                    fontWeight: FontWeight.bold,
                    color: palette.textPrimary,
                    height: 1.2,
                  ),
                ),
              ],
            ),
            const Spacer(),

            // Tungi/kunduzgi rejim almashtirgichi (har doim ko'rinadi)
            IconButton(
              tooltip: "Mavzuni almashtirish",
              icon: Icon(
                Theme.of(context).brightness == Brightness.dark
                    ? Icons.light_mode_outlined
                    : Icons.dark_mode_outlined,
                color: palette.textPrimary,
                size: isMobile ? 24 : 26.sp,
              ),
              onPressed: () => ref.read(themeModeProvider.notifier).toggle(),
            ),

            // Mobil bo'lsa Drawer ikonkasi
            if (isMobile)
              IconButton(
                icon: Icon(Icons.menu, color: palette.textPrimary, size: 30),
                onPressed: () {
                  // To'g'ridan-to'g'ri shu yerdan drawerni ochish
                  Scaffold.of(context).openEndDrawer();
                },
              )
            // Desktop bo'lsa Menyular va Qidiruv chiqadi
            else
              // Flexible + FittedBox(scaleDown): nav+qidiruv qatori
              // hech qachon ortiqcha joy egallab RenderFlex overflow
              // bermaydi — tor joyda butun qator bir xilda kichrayadi,
              // keng joyda esa tabiiy o'lchamida chiqadi.
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerRight,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ...List.generate(_list.length, (index) {
                        return Padding(
                          padding: EdgeInsets.symmetric(horizontal: 15.w),
                          child: InkWell(
                            onTap: () => navigateToPage(context, index),
                            hoverColor: Colors.transparent,
                            splashColor: Colors.transparent,
                            child: Text(
                              _list[index],
                              style: GoogleFonts.cinzel(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                                color: palette.textPrimary,
                                height: 1.2,
                              ),
                            ),
                          ),
                        );
                      }),
                      SizedBox(width: 30.w),
                      SizedBox(
                        width: 220.w,
                        height: 45.h,
                        child: TextField(
                          textAlignVertical: TextAlignVertical.center,
                          expands: false,
                          maxLines: 1,
                          minLines: 1,
                          style: GoogleFonts.cinzel(
                            color: palette.textPrimary,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                          ),
                          decoration: InputDecoration(
                            hintText: "qidirish",
                            hintStyle: GoogleFonts.cinzel(
                              color: palette.textSecondary,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                            ),
                            prefixIcon: Padding(
                              padding: EdgeInsets.only(left: 15.w, right: 10.w),
                              child: Icon(Icons.search, color: palette.textPrimary, size: 20.sp),
                            ),
                            filled: true,
                            fillColor: Colors.transparent,
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(100.r),
                              borderSide: BorderSide(color: palette.textPrimary, width: 1),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(100.r),
                              borderSide: BorderSide(color: palette.textPrimary, width: 1.3),
                            ),
                            contentPadding: EdgeInsets.symmetric(vertical: 0.h),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// Mobil versiya uchun Drawer alohida komponent sifatida ajratildi
class MobileMenuDrawer extends StatelessWidget {
  const MobileMenuDrawer({super.key});

  Widget _buildDrawerItem(BuildContext context, String title, int index) {
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
        navigateToPage(context, index); // Appbar'dagi bir xil navigatsiya ishlaydi
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Drawer(
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
                const CircleAvatar(
                  radius: 35,
                  backgroundColor: Colors.black,
                  child: Image(
                    image: AssetImage("assets/logo.png"),
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
          _buildDrawerItem(context, "ASOSIY", 0),
          _buildDrawerItem(context, "MAQOLALAR", 1),
          _buildDrawerItem(context, "SHAXSLAR", 2),
          _buildDrawerItem(context, "JANGLAR", 3),
          _buildDrawerItem(context, "SHE'RLAR", 4),
        ],
      ),
    );
  }
}
