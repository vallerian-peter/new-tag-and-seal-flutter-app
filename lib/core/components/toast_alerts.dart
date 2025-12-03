import 'dart:async';

import 'package:flutter/material.dart';
import 'package:new_tag_and_seal_flutter_app/core/utils/constants.dart';

class ToastAlerts {
  ToastAlerts._();

  static void showError(
    BuildContext context, {
    required String message,
  }) {
    _show(
      context,
      message: message,
      icon: Icons.error_outline,
      backgroundColor: Constants.dangerColor,
      textColor: Colors.white,
    );
  }

  static void showSuccess(
    BuildContext context, {
    required String message,
  }) {
    _show(
      context,
      message: message,
      icon: Icons.check_circle_outline,
      backgroundColor: Constants.successColor,
      textColor: Colors.white,
    );
  }

  static void showWarning(
    BuildContext context, {
    required String message,
  }) {
    _show(
      context,
      message: message,
      icon: Icons.warning_amber_rounded,
      backgroundColor: Colors.amber,
      textColor: Colors.white,
    );
  }

  static void showInfo(
    BuildContext context, {
    required String message,
  }) {
    final theme = Theme.of(context);
    _show(
      context,
      message: message,
      icon: Icons.info_outline,
      backgroundColor: theme.colorScheme.surfaceContainerHighest.withValues(
        alpha: 0.98,
      ),
      textColor: Colors.white,
    );
  }

  static void _show(
    BuildContext context, {
    required String message,
    required Color backgroundColor,
    required Color textColor,
    required IconData icon,
    Duration duration = const Duration(seconds: 3),
  }) {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (ctx) {
        final mediaQuery = MediaQuery.of(ctx);
        final topPadding = mediaQuery.padding.top;
        return Positioned(
          top: topPadding + 16,
          left: 16,
          right: 16,
          child: Material(
            color: Colors.transparent,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(milliseconds: 200),
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: Transform.translate(
                    offset: Offset(0, (1 - value) * -10),
                    child: child,
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.25),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      icon,
                      color: textColor,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        message,
                        style: Theme.of(ctx).textTheme.bodyMedium?.copyWith(
                              color: textColor,
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );

    overlay.insert(entry);

    Timer(duration, () {
      if (entry.mounted) {
        entry.remove();
      }
    });
  }
}


