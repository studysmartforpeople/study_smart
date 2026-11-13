import 'package:flutter/material.dart';

class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxHeight < 96;

        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: isCompact ? 8 : 18,
            vertical: isCompact ? 4 : 18,
          ),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                maxLines: isCompact ? 2 : null,
                overflow: isCompact ? TextOverflow.ellipsis : null,
                style: TextStyle(
                  fontSize: isCompact ? 11 : null,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: isCompact ? 1 : 14),
              Text(
                value,
                style: TextStyle(
                  fontSize: isCompact ? 16 : 28,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
