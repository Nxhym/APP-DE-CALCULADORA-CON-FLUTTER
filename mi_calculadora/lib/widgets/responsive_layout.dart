import 'package:flutter/material.dart';

class ResponsiveLayout extends StatelessWidget {
  final Widget mobileBody;
  final Widget? tabletBody;
  final Widget? desktopBody;

  // Breakpoints estándar de Material Design
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 1200;

  const ResponsiveLayout({
    super.key,
    required this.mobileBody,
    this.tabletBody,
    this.desktopBody,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= tabletBreakpoint) {
          return desktopBody?? tabletBody?? mobileBody;
        } else if (constraints.maxWidth >= mobileBreakpoint) {
          return tabletBody?? mobileBody;
        } else {
          return mobileBody;
        }
      },
    );
  }
}