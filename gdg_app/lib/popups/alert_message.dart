import 'package:flutter/material.dart';

class AlertMessage {
  static void showAlert(
    BuildContext context, {
    required String message,
    required List<AlertOption> options,
  }) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Alert'),
          content: Text(message),
          actions: options.map((option) {
            return TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                option.onPressed();
              },
              child: Text(option.label),
            );
          }).toList(),
        );
      },
    );
  }
}

class AlertOption {
  final String label;
  final VoidCallback onPressed;

  AlertOption({required this.label, required this.onPressed});
}