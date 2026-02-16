import 'package:flutter/material.dart';
import '../models/quote_model.dart';
import '../theme/app_theme.dart';

class SplashScreen extends StatelessWidget {
  final QuoteModel? quote;
  final VoidCallback onDismiss;

  const SplashScreen({
    super.key,
    required this.quote,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onDismiss,
      child: Scaffold(
        backgroundColor: AppColors.primaryDark,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 2),
                // App name
                Text(
                  'Citta',
                  style: TextStyle(
                    fontSize: 42,
                    fontWeight: FontWeight.w300,
                    color: Colors.white.withOpacity(0.9),
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
                      color: Colors.white.withOpacity(0.85),
                      fontWeight: FontWeight.w400,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  // Divider
                  Container(
                    width: 40,
                    height: 1,
                    color: Colors.white.withOpacity(0.3),
                  ),
                  const SizedBox(height: 24),
                  // Translation
                  Text(
                    quote!.translation,
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.6,
                      color: Colors.white.withOpacity(0.7),
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
                      color: Colors.white.withOpacity(0.5),
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
                    color: Colors.white.withOpacity(0.3),
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
