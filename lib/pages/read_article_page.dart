import 'dart:convert';
import 'package:boqiy_qahramonlar/pages/footer_widget.dart';
import 'package:boqiy_qahramonlar/pages/widgets/most_read_card.dart';
import 'package:boqiy_qahramonlar/provider/article_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/app_colors.dart';
import '../core/breakpoints.dart';
import 'desctop_appbar_widget.dart';

class ReadArticlePage extends ConsumerStatefulWidget {
  final int id;

  const ReadArticlePage({super.key, required this.id});

  @override
  ConsumerState<ReadArticlePage> createState() => _ReadArticlePageState();
}

class _ReadArticlePageState extends ConsumerState<ReadArticlePage> {
  QuillController? _quillController;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  @override
  void didUpdateWidget(ReadArticlePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.id != widget.id) {
      _fetchData();
    }
  }

  void _fetchData() {
    Future.microtask(() async {
      await ref.read(articleProvider.notifier).fetchArticleById(widget.id);
      final article = ref.read(articleProvider).selectedArticle;
      if (article != null) {
        if (article.author?.name != null) {
          ref.read(articleProvider.notifier).fetchAuthorArticles(article.author!.name!);
        }
        _initQuillController(article.content);
      }
      ref.read(articleProvider.notifier).fetchMostReadArticles();
      ref.read(articleProvider.notifier).increaseArticleView(widget.id);
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
    final articleState = ref.watch(articleProvider);
    final article = articleState.selectedArticle;
    final palette = context.palette;

    if (articleState.isLoading && article == null) {
      return Scaffold(
        backgroundColor: palette.background,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (articleState.error != null && article == null) {
      return Scaffold(
        backgroundColor: palette.background,
        body: Center(child: Text(articleState.error!)),
      );
    }

    if (article == null) {
      return Scaffold(
        backgroundColor: palette.background,
        body: const Center(child: Text("Maqola topilmadi")),
      );
    }

    final mostReadTitles = articleState.mostReadArticles.map((e) => e.title ?? "").toList();
    final width = MediaQuery.of(context).size.width;
    // Yon panelli (sidebar) sahifa uchun bu qatordagi eng katta chegara
    // ishlatiladi — aks holda planshet/telefon kengligida asosiy matn va
    // "Ko'p o'qilganlar" ustuni bir qatorga siqilib, o'qib bo'lmas holga
    // kelardi.
    final isMobile = width < Breakpoints.tablet;

    final mainContent = Padding(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 20.w : 40.w, vertical: 30.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Breadcrumbs (Navigatsiya)
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              InkWell(
                onTap: () => context.go('/'),
                child: Text(
                  "Bosh sahifa",
                  style: GoogleFonts.inter(
                    fontSize: 11.sp,
                    color: palette.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Text(
                "  >  ",
                style: TextStyle(fontSize: 11.sp, color: palette.textSecondary),
              ),
              InkWell(
                onTap: () => context.go('/article'),
                child: Text(
                  "Maqolalar",
                  style: GoogleFonts.inter(
                    fontSize: 11.sp,
                    color: palette.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Text(
                "  >  ",
                style: TextStyle(fontSize: 11.sp, color: palette.textSecondary),
              ),
              Text(
                article.title ?? "",
                style: GoogleFonts.inter(
                  fontSize: 12.sp,
                  color: AppColors.brown, // Aktiv sahifa rangi
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 24.h),

          // Kategoriya
          Text(
            article.categoriesList?.isNotEmpty == true
                ? article.categoriesList!.first.name?.toUpperCase() ?? "MAQOLA"
                : "MAQOLA",
            style: GoogleFonts.inter(
              fontSize: 13.sp,
              color: AppColors.brown,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
          SizedBox(height: 16.h),

          // Maqola sarlavhasi
          Text(
            article.title ?? "",
            style: GoogleFonts.inter(
              fontSize: isMobile ? 24.sp : 30.sp,
              color: palette.textPrimary,
              fontWeight: FontWeight.w800,
              height: 1.3,
            ),
          ),
          SizedBox(height: 24.h),

          // Lidi (Kirish matni)
          Text(
            article.description ?? "",
            style: GoogleFonts.inter(
              fontSize: 17.sp,
              color: palette.textSecondary,
              height: 1.6,
            ),
          ),
          SizedBox(height: 32.h),

          // Muallif (Tepa qism)
          Row(
            children: [
              CircleAvatar(
                radius: 24.r,
                backgroundImage: article.author?.profileImageUrl != null
                    ? NetworkImage("https://api.boqiyqahramonlar.uz${article.author!.profileImageUrl!}")
                    : null,
                child: article.author?.profileImageUrl == null ? const Icon(Icons.person) : null,
              ),
              SizedBox(width: 14.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    article.author?.name ?? "Noma'lum",
                    style: GoogleFonts.inter(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w700,
                      color: palette.textPrimary,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    "${article.createAt?.substring(0, 10) ?? ""}  •  ${article.readTime ?? 0} daq. o'qish",
                    style: GoogleFonts.inter(
                      fontSize: 13.sp,
                      color: palette.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 40.h),

          // Asosiy Rasm
          if (article.bannerUrl != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(20.r),
              child: Image.network(
                article.bannerUrl!,
                width: double.infinity,
                height: isMobile ? 220.h : 500.h,
                fit: BoxFit.cover,
              ),
            ),
          SizedBox(height: 40.h),

          // Asosiy Matn (Body)
          if (_quillController != null)
            QuillEditor.basic(
              controller: _quillController!,
              config: QuillEditorConfig(
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
          if (article.hashTegsList != null && article.hashTegsList!.isNotEmpty)
            Wrap(
              spacing: 10.w,
              runSpacing: 10.h,
              children: article.hashTegsList!.map((tag) {
                return InkWell(
                  onTap: () {
                    ref.read(articleProvider.notifier).fetchArticles(tag: tag.hashteg);
                    context.go('/article');
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
          SizedBox(height: 60.h),

          // "Muallifdan yana" sarlavhasi
          Divider(color: palette.divider, thickness: 1),
          SizedBox(height: 40.h),
          Text(
            "Boshqa maqolalar",
            style: GoogleFonts.inter(
              fontSize: isMobile ? 22.sp : 26.sp,
              color: palette.textPrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 40.h),

          // GridView qismi
          GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isMobile ? 1 : 3,
              mainAxisSpacing: 30.h,
              crossAxisSpacing: 24.w,
              childAspectRatio: isMobile ? 1.1 : 0.72,
            ),
            shrinkWrap: true,
            itemCount: articleState.authorArticles.length > 6 ? 6 : articleState.authorArticles.length,
            itemBuilder: (context, index) {
              final gridArticle = articleState.authorArticles[index];
              return GestureDetector(
                onTap: () {
                  context.go('/article/${gridArticle.id}');
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: palette.cardBg,
                    borderRadius: BorderRadius.circular(16.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(16.r),
                        ),
                        child: Container(
                          width: double.infinity,
                          height: 250.h,
                          decoration: BoxDecoration(
                            color: palette.placeholder,
                            image: gridArticle.bannerUrl != null
                                ? DecorationImage(
                                    image: NetworkImage(gridArticle.bannerUrl!),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          child: gridArticle.bannerUrl == null
                              ? Center(child: Icon(Icons.image, color: palette.textMuted))
                              : null,
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.all(20.w),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                gridArticle.categoriesList?.isNotEmpty == true
                                    ? gridArticle.categoriesList!.first.name ?? ""
                                    : "Maqola",
                                style: GoogleFonts.inter(
                                  fontSize: 12.sp,
                                  color: AppColors.brown,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.1,
                                ),
                              ),
                              SizedBox(height: 10.h),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Text(
                                      gridArticle.title ?? "",
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.inter(
                                        fontSize: 18.sp,
                                        fontWeight: FontWeight.w800,
                                        color: palette.textPrimary,
                                        height: 1.2,
                                      ),
                                    ),
                                  ),
                                  Icon(
                                    Icons.arrow_outward,
                                    size: 18.sp,
                                    color: palette.textPrimary,
                                  ),
                                ],
                              ),
                              SizedBox(height: 10.h),
                              Text(
                                gridArticle.description ?? "",
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.inter(
                                  fontSize: 14.sp,
                                  color: palette.textSecondary,
                                  height: 1.5,
                                ),
                              ),
                              const Spacer(),
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 18.r,
                                    backgroundImage: gridArticle.author?.profileImageUrl != null
                                        ? NetworkImage("https://api.boqiyqahramonlar.uz${gridArticle.author!.profileImageUrl!}")
                                        : null,
                                    child: gridArticle.author?.profileImageUrl == null ? const Icon(Icons.person) : null,
                                  ),
                                  SizedBox(width: 10.w),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          gridArticle.author?.name ?? "Noma'lum",
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: GoogleFonts.inter(
                                            fontSize: 13.sp,
                                            fontWeight: FontWeight.w700,
                                            color: palette.textPrimary,
                                          ),
                                        ),
                                        Text(
                                          gridArticle.createAt?.substring(0, 10) ?? "",
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: GoogleFonts.inter(
                                            fontSize: 11.sp,
                                            color: palette.textMuted,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
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
    );

    final sidebar = Padding(
      padding: EdgeInsets.only(
        top: isMobile ? 0 : 30.h,
        right: isMobile ? 0 : 30.w,
        left: isMobile ? 20.w : 0,
        bottom: isMobile ? 30.h : 0,
      ),
      child: MostReadCard(
        list: mostReadTitles,
        onItemTap: (index) => context.go('/article/${articleState.mostReadArticles[index].id}'),
      ),
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
              // Footer Row'dan tashqarida — shunda u yon panel ostida ham
              // sahifaning to'liq kengligini egallaydi.
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: mainContent),
                      sidebar,
                    ],
                  ),
                  const FooterWidget(),
                ],
              ),
            ),
    );
  }
}
