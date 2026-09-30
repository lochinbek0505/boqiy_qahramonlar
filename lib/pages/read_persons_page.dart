import 'dart:convert';
import 'package:boqiy_qahramonlar/pages/footer_widget.dart';
import 'package:boqiy_qahramonlar/pages/widgets/most_read_card.dart';
import 'package:boqiy_qahramonlar/provider/history_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/app_colors.dart';
import '../../core/utils.dart';
import 'desctop_appbar_widget.dart';

class ReadPersonPage extends ConsumerStatefulWidget {
  final int id;

  const ReadPersonPage({super.key, required this.id});

  @override
  ConsumerState<ReadPersonPage> createState() => _ReadPersonPageState();
}

class _ReadPersonPageState extends ConsumerState<ReadPersonPage> {
  QuillController? _quillController;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  @override
  void didUpdateWidget(ReadPersonPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.id != widget.id) {
      _fetchData();
    }
  }

  void _fetchData() {
    Future.microtask(() async {
      await ref.read(historyProvider.notifier).fetchHistoryById(widget.id);
      final history = ref.read(historyProvider).selectedHistory;
      if (history != null) {
        if (history.author?.name != null) {
          ref.read(historyProvider.notifier).fetchAuthorHistories(history.author!.name!);
        }
        _initQuillController(history.content);
      }
      ref.read(historyProvider.notifier).fetchMostReadHistories();
      ref.read(historyProvider.notifier).increaseHistoryView(widget.id);
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

  // Yon panel (Sidebar) uchun eng ko'p o'qilgan shaxslar ro'yxati
  final List<String> popularPersons = [
    "1. Amir Temur",
    "2. Jaloliddin Manguberdi",
    "3. Zahiriddin Muhammad Bobur",
    "4. Sulton Mahmud G'aznaviy",
    "5. Mirzo Ulug'bek",
    "6. Alp Arslon",
  ];

  @override
  Widget build(BuildContext context) {
    final historyState = ref.watch(historyProvider);
    final history = historyState.selectedHistory;

    if (historyState.isLoading && history == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (historyState.error != null && history == null) {
      return Scaffold(
        body: Center(child: Text(historyState.error!)),
      );
    }

    if (history == null) {
      return const Scaffold(
        body: Center(child: Text("Ma'lumot topilmadi")),
      );
    }

    final mostReadTitles = historyState.mostReadHistories.map((e) => e.title ?? "").toList();

    return Scaffold(
      appBar: AppBar(
        title: DesctopAppbarWidget(),
        scrolledUnderElevation: 0.0,
        surfaceTintColor: Colors.transparent,
        backgroundColor: AppColors.appbar,
        toolbarHeight: 90.sp,
        automaticallyImplyLeading: false,
      ),
      backgroundColor: AppColors.background,
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. ASOSIY MA'LUMOT QISMI (Chap tomon)
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 30.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Breadcrumbs (Navigatsiya)
                        Row(
                          children: [
                            InkWell(
                              onTap: () => context.go('/'),
                              child: Text(
                                "Bosh sahifa",
                                style: GoogleFonts.inter(
                                  fontSize: 12.sp,
                                  color: Colors.grey.shade600,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            Text(
                              "  >  ",
                              style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade600),
                            ),
                            InkWell(
                              onTap: () => context.go('/historys'),
                              child: Text(
                                "Shaxslar",
                                style: GoogleFonts.inter(
                                  fontSize: 12.sp,
                                  color: Colors.grey.shade600,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            Text(
                              "  >  ",
                              style: TextStyle(fontSize: 11.sp, color: Colors.grey.shade600),
                            ),
                            Text(
                              history.title ?? "",
                              style: GoogleFonts.inter(
                                fontSize: 12.sp,
                                color: AppColors.brown, // Aktiv sahifa rangi
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 24.h),

                        // Kategoriya yoki Davlat nomi
                        Text(
                          history.author?.name?.toUpperCase() ?? "TARIXIY SHAXS",
                          style: GoogleFonts.inter(
                            fontSize: 13.sp,
                            color: AppColors.brown,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.5,
                          ),
                        ),
                        SizedBox(height: 16.h),

                        // Shaxsning Ismi
                        Text(
                          history.title ?? "",
                          style: GoogleFonts.cinzel(
                            fontSize: 42.sp,
                            color: AppColors.black,
                            fontWeight: FontWeight.bold,
                            height: 1.2,
                          ),
                        ),
                        SizedBox(height: 12.h),

                        // Yashagan yoki hukmronlik yillari
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 8.h,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.brown, width: 1.5),
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          child: Text(
                            "${history.liveDate}",
                            style: GoogleFonts.roboto(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w700,
                              color: AppColors.brown,
                            ),
                          ),
                        ),
                        SizedBox(height: 40.h),

                        // Asosiy Rasm (Portret)
                        if (history.bannerUrl != null)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(20.r),
                            child: Image.network(
                              history.bannerUrl!,
                              width: double.infinity,
                              height: 550.h,
                              fit: BoxFit.cover,
                            ),
                          ),
                        SizedBox(height: 40.h),

                        // Asosiy Matn (Biografiya)
                        if (_quillController != null)
                          QuillEditor.basic(
                            controller: _quillController!,
                            config:  QuillEditorConfig(
                              showCursor: false,
                              autoFocus: false,
                              expands: false,
                              padding: EdgeInsets.zero,
                            ),
                          )
                        else
                          const Center(child: CircularProgressIndicator()),
                        SizedBox(height: 30.h),

                        // Hashteglar (Yangi)
                        if (history.hashTegsList != null && history.hashTegsList!.isNotEmpty)
                          Wrap(
                            spacing: 10.w,
                            runSpacing: 10.h,
                            children: history.hashTegsList!.map((tag) {
                              return InkWell(
                                onTap: () {
                                  ref.read(historyProvider.notifier).fetchHistories(tag: tag.hashteg);
                                  context.go('/historys');
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                                  decoration: BoxDecoration(
                                    color: AppColors.brown.withOpacity(0.1),
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
                        SizedBox(height: 60.h),

                        // "Boshqa shaxslar" sarlavhasi
                        Divider(color: Colors.grey.shade300, thickness: 1),
                        SizedBox(height: 40.h),
                        Text(
                          "Boshqa tarixiy shaxslar",
                          style: GoogleFonts.inter(
                            fontSize: 26.sp,
                            color: AppColors.black,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        SizedBox(height: 40.h),
                        // GridView qismi
                        GridView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            mainAxisSpacing: 30.h,
                            crossAxisSpacing: 30.w,
                            childAspectRatio: 0.75,
                          ),
                          shrinkWrap: true,
                          itemCount: historyState.authorHistories.length > 3 ? 3 : historyState.authorHistories.length,
                          itemBuilder: (context, index) {
                            final hero = historyState.authorHistories[index];
                            return GestureDetector(
                              onTap: () {
                                context.go('/historys/${hero.id}');
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12.r),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.06),
                                      blurRadius: 15,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                padding: EdgeInsets.symmetric(
                                  horizontal: 24.w,
                                  vertical: 30.h,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      hero.title ?? "",
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.cinzel(
                                        fontSize: 20.sp,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.darkBlue,
                                      ),
                                    ),
                                    SizedBox(height: 16.h),
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 16.w,
                                        vertical: 6.h,
                                      ),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: AppColors.brown,
                                          width: 1.2,
                                        ),
                                        borderRadius: BorderRadius.circular(4.r),
                                      ),
                                      child: Text(
                                        "${hero.liveDate}",
                                        style: GoogleFonts.roboto(
                                          fontSize: 12.sp,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.brown,
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 24.h),
                                    Expanded(
                                      child: Text(
                                        QuillUtils.parseDeltaToPlainText(hero.content),
                                        textAlign: TextAlign.center,
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 4,
                                        style: GoogleFonts.crimsonText(
                                          fontSize: 16.sp,
                                          color: Colors.grey.shade800,
                                          height: 1.5,
                                        ),
                                      ),
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          "Batafsil",
                                          style: GoogleFonts.roboto(
                                            fontSize: 15.sp,
                                            color: AppColors.brown,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        SizedBox(width: 8.w),
                                        Icon(
                                          Icons.arrow_forward_outlined,
                                          size: 18.sp,
                                          color: AppColors.brown,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                        SizedBox(height: 50.h),
                      ],
                    ),
                  ),
                  const FooterWidget(),
                ],
              ),
            ),
          ),

          // 2. YON PANEL (Sidebar - Most Read)
          Container(
            padding: EdgeInsets.only(top: 30.h, right: 30.w),
            child: MostReadCard(list: mostReadTitles),
          ),
        ],
      ),
    );
  }
}

