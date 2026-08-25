import 'package:boqiy_qahramonlar/pages/articles_page.dart';
import 'package:boqiy_qahramonlar/pages/main_page.dart';
import 'package:boqiy_qahramonlar/pages/peoms_page.dart';
import 'package:boqiy_qahramonlar/pages/persons_page.dart';
import 'package:boqiy_qahramonlar/pages/read_article_page.dart';
import 'package:boqiy_qahramonlar/pages/read_persons_page.dart';
import 'package:boqiy_qahramonlar/pages/read_poem_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

void main() {
  runApp(ProviderScope(child: MyApp()));
}


final GoRouter _router = GoRouter(
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      builder: (BuildContext context, GoRouterState state) {
        return  MainPage();
      },
      routes: <RouteBase>[
        GoRoute(
          path: 'article',
          builder: (BuildContext context, GoRouterState state) {
            return  ArticlesPage();
          },
        ),
        GoRoute(
          path: 'article/:id',
          builder: (BuildContext context, GoRouterState state) {
            return  ReadArticlePage(id: int.parse(state.pathParameters['id']!));
          },
        ),
        GoRoute(
          path: 'poems/:id',
          builder: (BuildContext context, GoRouterState state) {
            return  ReadPoemPage(id: int.parse(state.pathParameters['id']!));
          },
        ),
        GoRoute(
          path: 'poems',
          builder: (BuildContext context, GoRouterState state) {
            return  PoemsPage();
          },
        ),
        GoRoute(
          path: 'historys/:id',
          builder: (BuildContext context, GoRouterState state) {
            return  ReadPersonPage(id: int.parse(state.pathParameters['id']!));
          },
        ),
        GoRoute(
          path: 'historys',
          builder: (BuildContext context, GoRouterState state) {
            return  PersonsPage();
          },
        ),
      ],
    ),
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {

    return ScreenUtilInit(
      designSize: const Size(1512, 982),

      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp.router(
          title: 'Boqiy Qahramonlar',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(

            colorScheme: .fromSeed(seedColor: Colors.deepPurple),
          ),
          routerConfig: _router,
        );
      },
    );
  }
}
