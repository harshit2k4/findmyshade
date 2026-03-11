import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppSnackbar {
  AppSnackbar._();

  static void show({
    required String message,
    SnackbarType type = SnackbarType.info,
  }) {
    final cs = Get.theme.colorScheme;

    Color bgColor;
    Color fgColor;
    IconData icon;

    switch (type) {
      case SnackbarType.error:
        bgColor = cs.errorContainer;
        fgColor = cs.onErrorContainer;
        icon = Icons.error_outline_rounded;
      case SnackbarType.success:
        bgColor = cs.primaryContainer;
        fgColor = cs.onPrimaryContainer;
        icon = Icons.check_circle_outline_rounded;
      case SnackbarType.info:
        bgColor = cs.secondaryContainer;
        fgColor = cs.onSecondaryContainer;
        icon = Icons.info_outline_rounded;
    }

    Get.showSnackbar(
      GetSnackBar(
        messageText: Row(
          children: [
            Icon(icon, color: fgColor, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: fgColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: bgColor,
        borderRadius: 16,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
        snackPosition: SnackPosition.BOTTOM,
        snackStyle: SnackStyle.FLOATING,
      ),
    );
  }
}

enum SnackbarType { info, success, error }
