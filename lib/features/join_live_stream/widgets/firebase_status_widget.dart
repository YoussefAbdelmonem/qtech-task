import 'package:flutter/material.dart';
import '../../../core/extensions/enums.dart';

class FirebaseStatusWidget extends StatelessWidget {
  final FirebaseConnectionStatus status;
  final VoidCallback onRetry;

  const FirebaseStatusWidget({
    super.key,
    required this.status,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: _getBackgroundColor(),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _getBorderColor()),
      ),
      child: Row(
        children: [
          Icon(
            _getIcon(),
            color: _getIconColor(),
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _getStatusText(),
              style: TextStyle(
                color: _getTextColor(),
                fontSize: 12,
              ),
            ),
          ),
          if (_showRetryButton())
            GestureDetector(
              onTap: onRetry,
              child: Icon(
                Icons.refresh,
                color: _getIconColor(),
                size: 20,
              ),
            ),
        ],
      ),
    );
  }

  Color _getBackgroundColor() {
    switch (status) {
      case FirebaseConnectionStatus.connected:
        return Colors.green.withOpacity(0.1);
      case FirebaseConnectionStatus.error:
        return Colors.red.withOpacity(0.1);
      case FirebaseConnectionStatus.connecting:
      case FirebaseConnectionStatus.disconnected:
        return Colors.orange.withOpacity(0.1);
    }
  }

  Color _getBorderColor() {
    switch (status) {
      case FirebaseConnectionStatus.connected:
        return Colors.green.withOpacity(0.3);
      case FirebaseConnectionStatus.error:
        return Colors.red.withOpacity(0.3);
      case FirebaseConnectionStatus.connecting:
      case FirebaseConnectionStatus.disconnected:
        return Colors.orange.withOpacity(0.3);
    }
  }

  IconData _getIcon() {
    switch (status) {
      case FirebaseConnectionStatus.connected:
        return Icons.cloud_done;
      case FirebaseConnectionStatus.error:
        return Icons.cloud_off;
      case FirebaseConnectionStatus.connecting:
        return Icons.cloud_sync;
      case FirebaseConnectionStatus.disconnected:
        return Icons.cloud_off;
    }
  }

  Color _getIconColor() {
    switch (status) {
      case FirebaseConnectionStatus.connected:
        return Colors.green;
      case FirebaseConnectionStatus.error:
        return Colors.red;
      case FirebaseConnectionStatus.connecting:
      case FirebaseConnectionStatus.disconnected:
        return Colors.orange;
    }
  }

  Color _getTextColor() {
    return _getIconColor();
  }

  String _getStatusText() {
    switch (status) {
      case FirebaseConnectionStatus.connected:
        return "Connected to Firebase";
      case FirebaseConnectionStatus.error:
        return "Firebase connection failed";
      case FirebaseConnectionStatus.connecting:
        return "Connecting to Firebase...";
      case FirebaseConnectionStatus.disconnected:
        return "Firebase disconnected";
    }
  }

  bool _showRetryButton() {
    return status == FirebaseConnectionStatus.error || 
           status == FirebaseConnectionStatus.disconnected;
  }
}