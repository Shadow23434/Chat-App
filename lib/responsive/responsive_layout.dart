import 'package:flutter/material.dart';

class ResponsiveLayout extends StatelessWidget {
  final Widget mobileScafford;
  final Widget tabletScafford;
  final Widget desktopScafford;

  const ResponsiveLayout({
    super.key,
    required this.mobileScafford,
    required this.tabletScafford,
    required this.desktopScafford,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 500) {
          return mobileScafford;
        } else if (constraints.maxWidth < 1100) {
          return tabletScafford;
        } else {
          return desktopScafford;
        }
      },
    );
  }
}
