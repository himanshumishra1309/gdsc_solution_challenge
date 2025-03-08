import 'package:flutter/material.dart';

class AlertMessage {
  static void showAlert(
    BuildContext context, {
    required String message,
    String? title,
    List<AlertOption>? options,
    IconData? icon,
    AlertType type = AlertType.info,
  }) {
    final theme = Theme.of(context);
    
    // Define color and icon based on alert type
    Color alertColor;
    IconData alertIcon;
    
    switch (type) {
      case AlertType.success:
        alertColor = Colors.green.shade700;
        alertIcon = icon ?? Icons.check_circle;
        break;
      case AlertType.warning:
        alertColor = Colors.orange.shade700;
        alertIcon = icon ?? Icons.warning_amber;
        break;
      case AlertType.error:
        alertColor = Colors.red.shade700;
        alertIcon = icon ?? Icons.error;
        break;
      case AlertType.info:
      default:
        alertColor = Colors.deepPurple;
        alertIcon = icon ?? Icons.info;
        break;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon header
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: alertColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    alertIcon,
                    color: alertColor,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Title
                if (title != null)
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                    ),
                    textAlign: TextAlign.center,
                  ),
                
                // Message
                Padding(
                  padding: EdgeInsets.only(
                    top: title != null ? 12 : 0,
                    bottom: 20,
                  ),
                  child: Text(
                    message,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade700,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                
                // Action buttons
                if (options != null && options.isNotEmpty)
                  options.length == 1
                      ? SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              options[0].onPressed();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: alertColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              elevation: 0,
                            ),
                            child: Text(options[0].label),
                          ),
                        )
                      : Row(
                          children: options.asMap().entries.map((entry) {
                            final int idx = entry.key;
                            final option = entry.value;
                            final isLast = idx == options.length - 1;
                            
                            return Expanded(
                              child: Padding(
                                padding: EdgeInsets.only(
                                  left: idx == 0 ? 0 : 8,
                                  right: isLast ? 0 : 8,
                                ),
                                child: isLast
                                    ? ElevatedButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                          option.onPressed();
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: alertColor,
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(vertical: 12),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          elevation: 0,
                                        ),
                                        child: Text(option.label),
                                      )
                                    : OutlinedButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                          option.onPressed();
                                        },
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: alertColor,
                                          side: BorderSide(color: alertColor),
                                          padding: const EdgeInsets.symmetric(vertical: 12),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                        ),
                                        child: Text(option.label),
                                      ),
                              ),
                            );
                          }).toList(),
                        ),
                
                // When no options provided, show a default close button
                if (options == null || options.isEmpty)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: alertColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      child: const Text('OK'),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
  
  // Simplified helper methods for common alert types
  static void showSuccess(
    BuildContext context, {
    required String message,
    String? title,
    List<AlertOption>? options,
  }) {
    showAlert(
      context,
      message: message, 
      title: title ?? 'Success',
      options: options,
      type: AlertType.success,
    );
  }
  
  static void showError(
    BuildContext context, {
    required String message,
    String? title,
    List<AlertOption>? options,
  }) {
    showAlert(
      context,
      message: message, 
      title: title ?? 'Error',
      options: options,
      type: AlertType.error,
    );
  }
  
  static void showWarning(
    BuildContext context, {
    required String message,
    String? title,
    List<AlertOption>? options,
  }) {
    showAlert(
      context,
      message: message, 
      title: title ?? 'Warning',
      options: options,
      type: AlertType.warning,
    );
  }
  
  static void showInfo(
    BuildContext context, {
    required String message,
    String? title,
    List<AlertOption>? options,
  }) {
    showAlert(
      context,
      message: message, 
      title: title ?? 'Information',
      options: options,
      type: AlertType.info,
    );
  }
  
  // Confirmation dialog with preset Yes/No options
  static void showConfirmation(
    BuildContext context, {
    required String message,
    String? title,
    required VoidCallback onConfirm,
    VoidCallback? onCancel,
    String confirmLabel = 'Yes',
    String cancelLabel = 'No',
  }) {
    showAlert(
      context,
      message: message,
      title: title ?? 'Confirm',
      type: AlertType.warning,
      options: [
        AlertOption(
          label: cancelLabel,
          onPressed: onCancel ?? () {},
        ),
        AlertOption(
          label: confirmLabel,
          onPressed: onConfirm,
        ),
      ],
    );
  }
}

// Alert option class with improved features
class AlertOption {
  final String label;
  final VoidCallback onPressed;
  final bool isPrimary;
  final bool isDangerous;

  AlertOption({
    required this.label,
    required this.onPressed,
    this.isPrimary = false,
    this.isDangerous = false,
  });
}

// Alert types for different visual styles
enum AlertType {
  info,
  success,
  warning,
  error,
}