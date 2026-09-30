import 'dart:convert';
import 'package:boqiy_qahramonlar/core/utils.dart';
import 'package:boqiy_qahramonlar/pages/footer_widget.dart';
import 'package:boqiy_qahramonlar/pages/widgets/most_read_card.dart';
import 'package:boqiy_qahramonlar/provider/poems_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/app_colors.dart';
import '../core/breakpoints.dart';
import 'desctop_appbar_widget.dart';

class ReadPoemPage extends ConsumerStatefulWidget {
  final int id;

  const ReadPoemPage({super.key, required this.id});

  @override
  ConsumerState<ReadPoemPage> createState() => _ReadPoemPageState();
}

class _ReadPoemPageState extends ConsumerState<ReadPoemPage> {
  QuillController? _quillController;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  @override
  void didUpdateWidget(ReadPoemPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.id != widget.id) {
      _fetchData();
    }
  }

  void _fetchData() {
    Future.microtask(() async {
      await ref.read(poemsProvider.notifier).fetchPoemById(widget.id);
      final poem = ref.read(poemsProvider).selectedPoem;
      if (poem != null) {
        if (poem.author?.name != null) {
          ref.read(poemsProvider.notifier).fetchAuthorPoems(poem.author!.name!);
        }
        _initQuillController(poem.content);
      }
      ref.read(poemsProvider.notifier).fetchMostReadPoems();
      ref.read(poemsProvider.notifier).increasePoems(widget.id);
    });
  }

  void _initQuillController(String? content) {
    if (content == null || content.isEmpty) {
      _quillController = QuillController.basic();
      return;
    }
    try {
      final doc = Document.fromJson(jsonDecode(content));
      setState(() {
        _quillController = QuillController(
          document: doc,
          selection: const TextSelection.collapsed(offset: 0),
          readOnly: true,
        );
      });
    } catch (e) {
      _quillController = QuillController.basic();
    }
  }

  @override
  void dispose() {
    _quillController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final poemState = ref.watch(poemsProvider);
    final poem = poemState.selectedPoem;
    final palette = context.palette;

    if (poemState.isLoading && poem == null) {
      return Scaffold(
        backgroundColor: palette.background,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (poemState.error != null && poem == null) {
      return Scaffold(
        backgroundColor: palette.background,
        body: Center(child: Text(poemState.error!)),
      );
    }

    if (poem == null) {
      return Scaffold(
        backgroundColor: palette.background,
        body: const Center(child: Text("She'r topilmadi")),
      );
    }

    final mostReadTitles = poemState.mostReadPoems.map((e) => e.title ?? "").toList();
    final width = MediaQuery.of(context).size.width;
    // Yon panelli (sidebar) sahifa uchun bu qatordagi eng katta chegara
    // ishlatiladi — aks holda planshet/telefon kengligida asosiy matn va
    // "Ko'p o'qilganlar" ustuni bir qatorga siqilib qolardi.
    final isMobile = width < Breakpoints.tablet;

    final mainContent = Padding(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 20.w : 40.w, vertical: 30.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Breadcrumbs (Navigatsiya)
          Align(
            alignment: Alignment.centerLeft,
            child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                InkWell(
                  onTap: () => context.go('/'),
                  child: Text(
                    "Bosh sahifa",
                    style: GoogleFonts.inter(
                      fontSize: 12.sp,
                      color: palette.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Text(
                  "  >  ",
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: palette.textSecondary,
                  ),
                ),
                InkWell(
                  onTap: () => context.go('/poems'),
                  child: Text(
                    "She'rlar",
                    style: GoogleFonts.inter(
                      fontSize: 12.sp,
                      color: palette.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Text(
                  "  >  ",
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: palette.textSecondary,
                  ),
                ),
                Text(
                  poem.title ?? "",
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    color: AppColors.brown, // Aktiv sahifa rangi
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 50.h),

          // Kategoriya
          Text(
            "S H E ' R I Y A T",
            style: GoogleFonts.inter(
              fontSize: 12.sp,
              color: AppColors.brown,
              fontWeight: FontWeight.w600,
              letterSpacing: 4.0,
            ),
          ),
          SizedBox(height: 20.h),

          // She'r Sarlavhasi
          Text(
            poem.title ?? "",
            textAlign: TextAlign.center,
            style: GoogleFonts.copse(
              fontSize: isMobile ? 32.sp : 48.sp,
              color: palette.heading,
              fontWeight: FontWeight.bold,
              height: 1.2,
            ),
          ),
          SizedBox(height: 16.h),

          // Muallif
          Text(
            "Muallif: ${poem.author?.name ?? "Noma'lum"}",
            style: GoogleFonts.cinzel(
              fontSize: 18.sp,
              color: AppColors.brown,
              fontWeight: FontWeight.w700,
              fontStyle: FontStyle.italic,
            ),
          ),
          SizedBox(height: 50.h),

          // SHE'R RAMKASI (Poem Frame)
          Container(
            width: isMobile ? double.infinity : 700.w,
            decoration: BoxDecoration(
              color: palette.cardBg,
              borderRadius: BorderRadius.circular(8.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 30,
                  offset: const Offset(0, 15),
                ),
              ],
            ),
            child: Stack(
              children: [
                // Tepa-chap burchak chizig'i
                Positioned(
                  top: 20.h,
                  left: 20.w,
                  child: Container(
                    width: 60.w,
                    height: 60.h,
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(
                          color: AppColors.brown,
                          width: 2,
                        ),
                        left: BorderSide(
                          color: AppColors.brown,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ),

                // Past-o'ng burchak chizig'i
                Positioned(
                  bottom: 20.h,
                  right: 20.w,
                  child: Container(
                    width: 60.w,
                    height: 60.h,
                    decoration: BoxDecoration(
                      border: Border(
                        right: BorderSide(
                          color: AppColors.brown.withValues(alpha: 0.4),
                          width: 2,
                        ),
                        bottom: BorderSide(
                          color: AppColors.brown.withValues(alpha: 0.4),
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ),

                // She'r Matni
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 24.w : 100.w,
                    vertical: isMobile ? 40.h : 80.h,
                  ),
                  child: Align(
                    alignment: Alignment.center,
                    child: _quillController != null
                        ? QuillEditor.basic(
                            controller: _quillController!,
                            config: QuillEditorConfig(
                              showCursor: false,
                              autoFocus: false,
                              expands: false,
                              padding: EdgeInsets.zero,
                            ),
                          )
                        : const Center(child: CircularProgressIndicator()),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 30.h),

          // Hashteglar (Yangi)
          if (poem.hashTegsList != null && poem.hashTegsList!.isNotEmpty)
            Wrap(
              spacing: 10.w,
              runSpacing: 10.h,
              children: poem.hashTegsList!.map((tag) {
                return InkWell(
                  onTap: () {
                    ref.read(poemsProvider.notifier).fetchPoems(tag: tag.hashteg);
                    context.go('/poems');
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: AppColors.brown.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Text(
                      "#${tag.hashteg}",
                      style: GoogleFonts.inter(
                        fontSize: 14.sp,
                        color: AppColors.brown,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          SizedBox(height: 50.h),

          // "Muallifning boshqa she'rlari" (Yangi)
          if (poemState.authorPoems.isNotEmpty) ...[
            Divider(color: palette.divider, thickness: 1),
            SizedBox(height: 40.h),
            Text(
              "Muallifning boshqa she'rlari",
              style: GoogleFonts.inter(
                fontSize: isMobile ? 22.sp : 26.sp,
                color: palette.textPrimary,
                fontWeight: FontWeight.w800,
              ),
            ),
            SizedBox(height: 40.h),
            GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: isMobile ? 1 : 3,
                mainAxisSpacing: 30.h,
                crossAxisSpacing: 24.w,
                childAspectRatio: isMobile ? 1.1 : 0.9,
              ),
              shrinkWrap: true,
              itemCount: poemState.authorPoems.length > 6 ? 6 : poemState.authorPoems.length,
              itemBuilder: (context, index) {
                final authorPoem = poemState.authorPoems[index];
                return GestureDetector(
                  onTap: () => context.go('/poems/${authorPoem.id}'),
                  child: Container(
                    padding: EdgeInsets.all(20.w),
                    decoration: BoxDecoration(
                      color: palette.cardBg,
                      borderRadius: BorderRadius.circular(12.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          authorPoem.title ?? "",
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.copse(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                            color: palette.heading,
                          ),
                        ),
                        SizedBox(height: 10.h),
                        Expanded(
                          child: Text(
                            QuillUtils.parseDeltaToPlainText(authorPoem.content),
                            maxLines: 4,
                            overflow: TextOverflow.fade,
                            style: GoogleFonts.crimsonPro(
                              fontSize: 14.sp,
                              color: palette.textPrimary,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
          SizedBox(height: 80.h),

          // Bezovchi ajratuvchi chiziq
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100.w,
                height: 1.h,
                color: AppColors.brown.withValues(alpha: 0.3),
              ),
              SizedBox(width: 16.w),
              Icon(
                Icons.diamond_outlined,
                color: AppColors.brown,
                size: 16.sp,
              ),
              SizedBox(width: 16.w),
              Container(
                width: 100.w,
                height: 1.h,
                color: AppColors.brown.withValues(alpha: 0.3),
              ),
            ],
          ),
          SizedBox(height: 60.h),
        ],
      ),
    );

    final sidebar = Padding(
      padding: EdgeInsets.only(
        top: isMobile ? 0 : 30.h,
        right: isMobile ? 0 : 30.w,
        left: isMobile ? 20.w : 0,
        bottom: isMobile ? 30.h : 0,
      ),
      child: MostReadCard(list: mostReadTitles),
    );

    return Scaffold(
      appBar: AppBar(
        title: DesctopAppbarWidget(),
        scrolledUnderElevation: 0.0,
        surfaceTintColor: Colors.transparent,
        backgroundColor: palette.appbarBg,
        toolbarHeight: 90.sp,
        automaticallyImplyLeading: false,
      ),
      backgroundColor: palette.background,
      body: isMobile
          ? SingleChildScrollView(
              child: Column(
                children: [
                  mainContent,
                  Align(alignment: Alignment.centerLeft, child: sidebar),
                  const FooterWidget(),
                ],
              ),
            )
          : SingleChildScrollView(
              // Butun sahifa (asosiy matn + yon panel) bitta scroll ichida —
              // aks holda Row balandligi ekran balandligi bilan cheklanib,
              // "Ko'p o'qilganlar" ro'yxati uzun bo'lganda pastki qism
              // (jumladan Footer) kesilib qolardi.
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      children: [mainContent, const FooterWidget()],
                    ),
                  ),
                  sidebar,
                ],
              ),
            ),
    );
  }
}
