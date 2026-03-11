import 'package:flutter/material.dart';
import 'package:get/get.dart';

// Slide + fade transition used for all forward navigation
class SlideTransitionPage extends CustomTransition {
  @override
  Widget buildTransition(
    BuildContext context,
    Curve? curve,
    Alignment? alignment,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return SlideTransition(
      position: Tween<Offset>(begin: const Offset(1.0, 0.0), end: Offset.zero)
          .animate(
            CurvedAnimation(
              parent: animation,
              curve: curve ?? Curves.easeOutCubic,
            ),
          ),
      child: FadeTransition(
        opacity: CurvedAnimation(
          parent: animation,
          curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
        ),
        child: child,
      ),
    );
  }
}
