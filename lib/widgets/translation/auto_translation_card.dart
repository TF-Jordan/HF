import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/translation_provider.dart';
import '../common/glass_card.dart';
import '../common/gradient_button.dart';
import '../common/section_header.dart';
import '../common/status_indicator.dart';

/// Automatic continuous translation card.
class AutoTranslationCard extends StatelessWidget {
  const AutoTranslationCard({super.key});

  @override
  Widget build(BuildContext context) {
    final c = HarmonyColors.of(context);
    final t = context.watch<TranslationProvider>();
    final outputText = t.autoOutput ?? 'En attente...';
    final history = t.autoHistory.take(5).toList();
    final bufferProgress =
        t.autoBufferCount / AppConstants.translationBatchSize;

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: 'Traduction auto',
            icon: Icons.auto_awesome_rounded,
            trailing: StatusIndicator(
              active: t.isAutoActive,
              label: t.isAutoActive ? 'ACTIF' : 'INACTIF',
              activeColor: c.success,
            ),
          ),
          const SizedBox(height: 16),

          // Buffer progress
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Buffer',
                          style: TextStyle(
                            color: c.textHint,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          '${t.autoBufferCount} / ${AppConstants.translationBatchSize}',
                          style: TextStyle(
                            color: c.textSecondary,
                            fontSize: 12,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: LinearProgressIndicator(
                        value: bufferProgress.clamp(0.0, 1.0),
                        backgroundColor: c.surface,
                        valueColor: AlwaysStoppedAnimation(
                          t.isAutoActive
                              ? c.success
                              : c.textHint,
                        ),
                        minHeight: 5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              GradientButton(
                label: t.isAutoActive ? 'Stop' : 'Demarrer',
                icon: t.isAutoActive
                    ? Icons.stop_rounded
                    : Icons.play_arrow_rounded,
                gradient: t.isAutoActive
                    ? c.dangerGradient
                    : c.successGradient,
                compact: true,
                onPressed:
                    t.modelReady ? t.toggleAutoTranslation : null,
              ),
            ],
          ),

          if (t.autoInferenceInFlight) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor:
                        AlwaysStoppedAnimation(c.success),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Inference en cours...',
                  style: TextStyle(
                    color: c.success,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],

          const SizedBox(height: 16),

          // Current output
          Text(
            'DERNIERE REPONSE',
            style: TextStyle(
              color: c.textHint,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: t.autoOutput != null
                  ? LinearGradient(
                      colors: [
                        c.success.withAlpha(20),
                        c.accent.withAlpha(10),
                      ],
                    )
                  : null,
              color: t.autoOutput == null ? c.scaffold : null,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: c.glassBorder),
            ),
            child: Text(
              outputText,
              style: TextStyle(
                color: t.autoOutput != null
                    ? c.success
                    : c.textHint,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),

          // History
          if (history.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              'HISTORIQUE',
              style: TextStyle(
                color: c.textHint,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            ...history.asMap().entries.map((entry) {
              final opacity = 1.0 - (entry.key * 0.15);
              return Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    Container(
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: c.textHint.withAlpha(
                            (opacity * 255).toInt()),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        entry.value,
                        style: TextStyle(
                          color: c.textSecondary
                              .withAlpha((opacity * 255).toInt()),
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ],
      ),
    );
  }
}
