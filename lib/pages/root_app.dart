import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../widgets/bottombar_item.dart';
import 'home_page.dart';
import 'wallet_page.dart';
import 'transfer_page.dart';
import 'statistics_page.dart';
import 'account_page.dart';

class RootApp extends StatefulWidget {
  const RootApp({super.key});

  @override
  State<RootApp> createState() => _RootAppState();
}

class _RootAppState extends State<RootApp> {
  int activeTab = 0;

  final List<Widget> _pages = const [
    HomePage(),
    WalletPage(),
    TransferPage(),
    StatisticsPage(),
    AccountPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColor.appBgColor.withAlpha(242),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(40),
          topRight: Radius.circular(40),
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        bottomNavigationBar: _buildBottomBar(),
        floatingActionButton: _buildMidButton(),
        floatingActionButtonLocation: FloatingActionButtonLocation.miniCenterDocked,
        body: IndexedStack(
          index: activeTab,
          children: _pages,
        ),
      ),
    );
  }

  Widget _buildMidButton() {
    return Container(
      margin: const EdgeInsets.only(top: 35),
      padding: const EdgeInsets.all(5),
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: AppColor.bottomBarColor,
      ),
      child: GestureDetector(
        onTap: () {
          setState(() {
            activeTab = 2;
          });
        },
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: const BoxDecoration(
            color: AppColor.primary,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.swap_horiz_rounded,
            color: Colors.white,
            size: 28,
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      height: 75,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColor.bottomBarColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColor.shadowColor.withAlpha(26),
            blurRadius: .5,
            spreadRadius: .5,
            offset: const Offset(0, 1),
          )
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 25, right: 25, top: 15),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            BottomBarItem(
              icon: Icons.home_rounded,
              label: 'Home',
              isActive: activeTab == 0,
              activeColor: AppColor.primary,
              onTap: () => setState(() => activeTab = 0),
            ),
            BottomBarItem(
              icon: Icons.account_balance_wallet_rounded,
              label: 'Wallet',
              isActive: activeTab == 1,
              activeColor: AppColor.primary,
              onTap: () => setState(() => activeTab = 1),
            ),
            const SizedBox(width: 50), // Space for FAB
            BottomBarItem(
              icon: Icons.insert_chart_rounded,
              label: 'Stats',
              isActive: activeTab == 3,
              activeColor: AppColor.primary,
              onTap: () => setState(() => activeTab = 3),
            ),
            BottomBarItem(
              icon: Icons.person_rounded,
              label: 'Account',
              isActive: activeTab == 4,
              activeColor: AppColor.primary,
              onTap: () => setState(() => activeTab = 4),
            ),
          ],
        ),
      ),
    );
  }
}
