import 'package:boqiy_qahramonlar/pages/main_page.dart';
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
        return const MainPage();
      },
      routes: <RouteBase>[
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
          path: 'historys/:id',
          builder: (BuildContext context, GoRouterState state) {
            return  ReadPersonPage(id: int.parse(state.pathParameters['id']!));
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
            // This is the theme of your application.
            //
            // TRY THIS: Try running your application with "flutter run". You'll see
            // the application has a purple toolbar. Then, without quitting the app,
            // try changing the seedColor in the colorScheme below to Colors.green
            // and then invoke "hot reload" (save your changes or press the "hot
            // reload" button in a Flutter-supported IDE, or press "r" if you used
            // the command line to start the app).
            //
            // Notice that the counter didn't reset back to zero; the application
            // state is not lost during the reload. To reset the state, use hot
            // restart instead.
            //
            // This works for code too, not just values: Most code changes can be
            // tested with just a hot reload.
            colorScheme: .fromSeed(seedColor: Colors.deepPurple),
          ),
          routerConfig: _router,
        );
      },
    );
  }
}
