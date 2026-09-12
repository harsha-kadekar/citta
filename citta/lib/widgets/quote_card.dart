import 'package:flutter/material.dart';
import '../models/quote_model.dart';
import '../theme/adaptive_colors.dart';

class QuoteCard extends StatelessWidget {
  final QuoteModel quote;

  const QuoteCard({super.key, required this.quote});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final adaptiveColors = context.adaptiveColors;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: adaptiveColors.cardShadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Original text
          Text(
            quote.originalText,
            style: TextStyle(
              fontSize: 15,
              height: 1.7,
              color: adaptiveColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          // Divider
          Container(
            width: 30,
            height: 1,
            color: Theme.of(context).dividerColor,
          ),
          const SizedBox(height: 12),
          // Translation
          Text(
            quote.translation,
            style: TextStyle(
              fontSize: 13,
              height: 1.6,
              color: adaptiveColors.textSecondary,
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
          if (quote.reference.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              '— ${quote.reference}',
              style: TextStyle(
                fontSize: 11,
                color: adaptiveColors.textHint,
                letterSpacing: 0.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}
