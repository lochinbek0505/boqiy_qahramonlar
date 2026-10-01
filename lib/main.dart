import 'package:boqiy_qahramonlar/battle/battle_theme.dart';
import 'package:boqiy_qahramonlar/battle/data/unit_catalog.dart';
import 'package:boqiy_qahramonlar/battle/screens/glossary_screen.dart';
import 'package:boqiy_qahramonlar/core/app_theme.dart';
import 'package:boqiy_qahramonlar/pages/articles_page.dart';
import 'package:boqiy_qahramonlar/pages/battles_page.dart';
import 'package:boqiy_qahramonlar/pages/main_page.dart';
import 'package:boqiy_qahramonlar/pages/peoms_page.dart';
import 'package:boqiy_qahramonlar/pages/persons_page.dart';
import 'package:boqiy_qahramonlar/pages/read_article_page.dart';
import 'package:boqiy_qahramonlar/pages/read_battle_page.dart';
import 'package:boqiy_qahramonlar/pages/read_persons_page.dart';
import 'package:boqiy_qahramonlar/pages/read_poem_page.dart';
import 'package:boqiy_qahramonlar/provider/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Janglar xaritasidagi qo'shin ikonlari katalogi
  await UnitCatalog.load();
  runApp(ProviderScope(child: MyApp()));
}

// Sahifalar orasidagi o'tish animatsiyasi: yumshoq paydo bo'lish (fade)
// va pastdan biroz yuqoriga siljish.
CustomTransitionPage<void> _fadePage(GoRouterState state, Widget child) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 350),
    reverseTransitionDuration: const Duration(milliseconds: 250),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
      return FadeTransition(
        opacity: curved,
        child: SlideTransition(
          position: Tween<Offset>(begin: const Offset(0, 0.03), end: Offset.zero).animate(curved),
          child: child,
        ),
      );
    },
  );
}

final GoRouter _router = GoRouter(
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      pageBuilder: (BuildContext context, GoRouterState state) {
        return _fadePage(state, MainPage());
      },
      routes: <RouteBase>[
        GoRoute(
          path: 'article',
          pageBuilder: (BuildContext context, GoRouterState state) {
            return _fadePage(state, ArticlesPage());
          },
        ),
        GoRoute(
          path: 'article/:id',
          pageBuilder: (BuildContext context, GoRouterState state) {
            return _fadePage(state, ReadArticlePage(id: int.parse(state.pathParameters['id']!)));
          },
        ),
        GoRoute(
          path: 'poems/:id',
          pageBuilder: (BuildContext context, GoRouterState state) {
            return _fadePage(state, ReadPoemPage(id: int.parse(state.pathParameters['id']!)));
          },
        ),
        GoRoute(
          path: 'poems',
          pageBuilder: (BuildContext context, GoRouterState state) {
            return _fadePage(state, PoemsPage());
          },
        ),
        GoRoute(
          path: 'historys/:id',
          pageBuilder: (BuildContext context, GoRouterState state) {
            return _fadePage(state, ReadPersonPage(id: int.parse(state.pathParameters['id']!)));
          },
        ),
        GoRoute(
          path: 'historys',
          pageBuilder: (BuildContext context, GoRouterState state) {
            return _fadePage(state, PersonsPage());
          },
        ),
        GoRoute(
          path: 'battles',
          pageBuilder: (BuildContext context, GoRouterState state) {
            return _fadePage(state, BattlesPage());
          },
        ),
        GoRoute(
          path: 'battles/types',
          pageBuilder: (BuildContext context, GoRouterState state) {
            return _fadePage(state, Theme(data: battleTheme, child: const GlossaryScreen()));
          },
        ),
        GoRoute(
          path: 'battles/:key',
          pageBuilder: (BuildContext context, GoRouterState state) {
            return _fadePage(
              state,
              ReadBattlePage(
                battleKey: state.pathParameters['key']!,
                initialProgress: double.tryParse(state.uri.queryParameters['t'] ?? ''),
                initialFullscreen: state.uri.queryParameters['fs'] == '1',
              ),
            );
          },
        ),
      ],
    ),
  ],
);

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return ScreenUtilInit(
      designSize: const Size(1512, 982),

      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp.router(
          title: 'Boqiy Qahramonlar',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: themeMode,
          routerConfig: _router,
        );
      },
    );
  }
}
