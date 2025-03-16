import 'package:flutter/material.dart';

enum SnackBarType {
  success,
  error,
  info,
  warning,
}

class CustomSnackBar {
  static void show({
    required BuildContext context,
    required String message,
    SnackBarType type = SnackBarType.info,
    Duration duration = const Duration(seconds: 3),
    bool showCloseIcon = true,
    VoidCallback? onTap,
  }) {
    // Dismiss any existing snackbars
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    
    // Define colors and icons based on type
    final Color backgroundColor;
    final Color textColor = Colors.white;
    final IconData icon;
    
    switch (type) {
      case SnackBarType.success:
        backgroundColor = Colors.green.shade600;
        icon = Icons.check_circle;
        break;
      case SnackBarType.error:
        backgroundColor = Colors.red.shade600;
        icon = Icons.error;
        break;
      case SnackBarType.warning:
        backgroundColor = Colors.amber.shade700;
        icon = Icons.warning;
        break;
      case SnackBarType.info:
      default:
        backgroundColor = Colors.blue.shade600;
        icon = Icons.info;
        break;
    }
    
    // Create and show the snackbar
    final snackBar = SnackBar(
      content: Row(
        children: [
          Icon(icon, color: textColor),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: textColor, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
      backgroundColor: backgroundColor,
      behavior: SnackBarBehavior.floating,
      duration: duration,
      action: showCloseIcon
          ? SnackBarAction(
              label: 'Dismiss',
              textColor: Colors.white.withOpacity(0.8),
              onPressed: () {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
              },
            )
          : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      elevation: 6,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
    
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
  
  // Helper methods for common use cases
  static void showSuccess(BuildContext context, String message) {
    show(
      context: context,
      message: message,
      type: SnackBarType.success,
    );
  }
  
  static void showError(BuildContext context, String message) {
    show(
      context: context,
      message: message,
      type: SnackBarType.error,
    );
  }
  
  static void showInfo(BuildContext context, String message) {
    show(
      context: context,
      message: message,
      type: SnackBarType.info,
    );
  }
  
  static void showWarning(BuildContext context, String message) {
    show(
      context: context,
      message: message,
      type: SnackBarType.warning,
    );
  }
}