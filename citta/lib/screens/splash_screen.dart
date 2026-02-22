import 'package:flutter/material.dart';
import '../models/quote_model.dart';

class SplashScreen extends StatelessWidget {
  final QuoteModel? quote;
  final String? userName;
  final VoidCallback onDismiss;

  const SplashScreen({
    super.key,
    required this.quote,
    required this.onDismiss,
    this.userName,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final onBg = colorScheme.onSurface;

    return GestureDetector(
      onTap: onDismiss,
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Spacer(flex: 2),
                // Namaskara greeting
                Text(
                  userName != null ? 'Namaskara, $userName' : 'Namaskara',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: onBg.withValues(alpha: 0.6),
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 16),
                // App name
                Text(
                  'Citta',
                  style: TextStyle(
                    fontSize: 42,
                    fontWeight: FontWeight.w300,
                    color: onBg.withValues(alpha: 0.9),
                    letterSpacing: 8,
                  ),
                ),
                const SizedBox(height: 48),
                if (quote != null) ...[
                  // Original text
                  Text(
                    quote!.originalText,
                    style: TextStyle(
                      fontSize: 18,
                      height: 1.8,
                      color: onBg.withValues(alpha: 0.85),
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  // Divider
                  Container(
                    width: 40,
                    height: 1,
                    color: onBg.withValues(alpha: 0.3),
                  ),
                  const SizedBox(height: 24),
                  // Translation
                  Text(
                    quote!.translation,
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.6,
                      color: onBg.withValues(alpha: 0.7),
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  // Source
                  Text(
                    '— ${quote!.reference}',
                    style: TextStyle(
                      fontSize: 12,
                      color: onBg.withValues(alpha: 0.5),
                      letterSpacing: 1,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
                const Spacer(flex: 3),
                // Tap to dismiss hint
                Text(
                  'tap to begin',
                  style: TextStyle(
                    fontSize: 12,
                    color: onBg.withValues(alpha: 0.3),
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
