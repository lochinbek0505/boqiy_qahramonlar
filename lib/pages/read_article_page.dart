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

    if (articleState.isLoading && article == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (articleState.error != null && article == null) {
      return Scaffold(
        body: Center(child: Text(articleState.error!)),
      );
    }

    if (article == null) {
      return const Scaffold(
        body: Center(child: Text("Maqola topilmadi")),
      );
    }

    final mostReadTitles = articleState.mostReadArticles.map((e) => e.title ?? "").toList();

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
          // 1. ASOSIY MAQOLA QISMI (Chap tomon)
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
                                  fontSize: 11.sp,
                                  color: Colors.grey.shade600,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            Text(
                              "  >  ",
                              style: TextStyle(fontSize: 11.sp, color: Colors.grey.shade600),
                            ),
                            InkWell(
                              onTap: () => context.go('/article'),
                              child: Text(
                                "Maqolalar",
                                style: GoogleFonts.inter(
                                  fontSize: 11.sp,
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
                            fontSize: 30.sp,
                            color: AppColors.black,
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
                            color: Colors.grey.shade800,
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
                                    color: AppColors.black,
                                  ),
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  "${article.createAt?.substring(0, 10) ?? ""}  •  ${article.readTime ?? 0} daq. o'qish",
                                  style: GoogleFonts.inter(
                                    fontSize: 13.sp,
                                    color: Colors.grey.shade600,
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
                              height: 500.h,
                              fit: BoxFit.cover,
                            ),
                          ),
                        SizedBox(height: 40.h),

                        // Asosiy Matn (Body)
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

                        // "Muallifdan yana" sarlavhasi
                        Divider(color: Colors.grey.shade300, thickness: 1),
                        SizedBox(height: 40.h),
                        Text(
                          "Boshqa maqolalar",
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
                            crossAxisSpacing: 24.w,
                            childAspectRatio: 0.72,
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
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16.r),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.04),
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
                                          color: Colors.blueGrey.shade50,
                                          image: gridArticle.bannerUrl != null
                                              ? DecorationImage(
                                                  image: NetworkImage(gridArticle.bannerUrl!),
                                                  fit: BoxFit.cover,
                                                )
                                              : null,
                                        ),
                                        child: gridArticle.bannerUrl == null
                                            ? const Center(child: Icon(Icons.image, color: Colors.grey))
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
                                                      color: AppColors.black,
                                                      height: 1.2,
                                                    ),
                                                  ),
                                                ),
                                                Icon(
                                                  Icons.arrow_outward,
                                                  size: 18.sp,
                                                  color: AppColors.black,
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
                                                color: Colors.grey.shade600,
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
                                                          color: AppColors.black,
                                                        ),
                                                      ),
                                                      Text(
                                                        gridArticle.createAt?.substring(0, 10) ?? "",
                                                        maxLines: 1,
                                                        overflow: TextOverflow.ellipsis,
                                                        style: GoogleFonts.inter(
                                                          fontSize: 11.sp,
                                                          color: Colors.grey.shade500,
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

