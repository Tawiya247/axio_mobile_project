import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

CustomTransitionPage<T> createSlideRightRoute<T>({
  required BuildContext context,
  required Widget child,
}) {
  return CustomTransitionPage<T>(
    key: ValueKey('slide_right_${DateTime.now()}'),
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(1.0, 0.0);
      const end = Offset.zero;
      const curve = Curves.easeInOut;

      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

      return SlideTransition(position: animation.drive(tween), child: child);
    },
  );
}

CustomTransitionPage<T> createFadeRoute<T>({
  required BuildContext context,
  required Widget child,
}) {
  return CustomTransitionPage<T>(
    key: ValueKey('fade_${DateTime.now()}'),
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(opacity: animation, child: child);
    },
  );
}

CustomTransitionPage<T> createScaleRoute<T>({
  required BuildContext context,
  required Widget child,
}) {
  return CustomTransitionPage<T>(
    key: ValueKey('scale_${DateTime.now()}'),
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return ScaleTransition(
        scale: Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(parent: animation, curve: Curves.fastOutSlowIn),
        ),
        child: child,
      );
    },
  );
}
