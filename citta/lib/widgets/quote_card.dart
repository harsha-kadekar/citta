import 'package:flutter/material.dart';
import '../models/quote_model.dart';
import '../theme/app_theme.dart';

class QuoteCard extends StatelessWidget {
  final QuoteModel quote;

  const QuoteCard({super.key, required this.quote});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Original text
          Text(
            quote.originalText,
            style: const TextStyle(
              fontSize: 15,
              height: 1.7,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          // Divider
          Container(
            width: 30,
            height: 1,
            color: AppColors.divider,
          ),
          const SizedBox(height: 12),
          // Translation
          Text(
            quote.translation,
            style: const TextStyle(
              fontSize: 13,
              height: 1.6,
              color: AppColors.textSecondary,
              fontStyle: FontStyle.italic,
            ),
          ),
          if (quote.reference.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              '— ${quote.reference}',
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textHint,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
