import 'package:boqiy_qahramonlar/pages/widgets/battle_card.dart';
import 'package:boqiy_qahramonlar/pages/widgets/more_button.dart';
import 'package:boqiy_qahramonlar/pages/widgets/page_title_text.dart';
import 'package:boqiy_qahramonlar/provider/battle_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../core/breakpoints.dart';

class DesctopBattlesPage extends ConsumerWidget {
  const DesctopBattlesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    bool isMobile = MediaQuery.of(context).size.width < Breakpoints.mobile;
    final battleState = ref.watch(battleProvider);

    return Column(
      children: [
        SizedBox(height: isMobile ? 30 : 60.h),
        PageTitleText(title: "Janglar"),
        SizedBox(height: isMobile ? 30 : 60.h),

        if (battleState.isLoading)
          const Center(child: CircularProgressIndicator())
        else if (battleState.error != null)
          Center(child: Text(battleState.error!))
        else
          Padding(
            padding: EdgeInsets.symmetric(horizontal: isMobile ? 20 : 70.w),
            child: BattleCardsWrap(
              battles: battleState.battles.take(3).toList(),
              isMobile: isMobile,
            ),
          ),
        SizedBox(height: isMobile ? 30 : 50.h),
        GestureDetector(
          onTap: () {
            context.go('/battles');
          },
          child: MoreButton(),
        ),
        SizedBox(height: isMobile ? 40 : 80.h),
      ],
    );
  }
}
