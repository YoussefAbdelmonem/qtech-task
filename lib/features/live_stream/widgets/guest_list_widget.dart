import 'package:flutter/material.dart';

class GuestListWidget extends StatelessWidget {
  const GuestListWidget({super.key, required this.guests});
  final Map<String, dynamic> guests;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 16,
      top: 120,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 200),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.8),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Guests Watching:",
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ...guests.entries.map(
              (entry) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.person, color: Colors.green, size: 16),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        entry.value['name'] ?? entry.key,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
