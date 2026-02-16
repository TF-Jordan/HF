import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../providers/translation_provider.dart';
import '../common/glass_card.dart';
import '../common/gradient_button.dart';
import '../common/section_header.dart';
import '../common/status_indicator.dart';

/// Manual translation control card.
class ManualTranslationCard extends StatelessWidget {
  const ManualTranslationCard({super.key});

  @override
  Widget build(BuildContext context) {
    final c = HarmonyColors.of(context);
    final t = context.watch<TranslationProvider>();
    final outputText = t.manualOutput ?? 'En attente de donnees...';

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: 'Traduction manuelle',
            icon: Icons.front_hand_rounded,
            trailing: StatusIndicator(
              active: t.isManualRecording,
              label: t.isManualRecording ? 'REC' : 'PAUSE',
              activeColor: c.error,
            ),
          ),
          const SizedBox(height: 12),

          // Model status
          _ModelStatusRow(
            modelReady: t.modelReady,
            hasScaler: t.hasScaler,
            error: t.modelError,
          ),
          const SizedBox(height: 12),

          // Frame counter
          Row(
            children: [
              Icon(Icons.timeline_rounded,
                  color: c.textHint, size: 16),
              const SizedBox(width: 6),
              Text(
                '${t.manualFrameCount} frames captures',
                style: TextStyle(
                  color: c.textSecondary,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Controls
          Row(
            children: [
              GradientButton(
                label: t.isManualRecording ? 'Stop' : 'Enregistrer',
                icon: t.isManualRecording
                    ? Icons.stop_rounded
                    : Icons.play_arrow_rounded,
                gradient: t.isManualRecording
                    ? c.dangerGradient
                    : c.primaryGradient,
                onPressed:
                    t.modelReady ? t.toggleManualTranslation : null,
              ),
              if (t.manualInferenceInFlight) ...[
                const SizedBox(width: 16),
                SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor:
                        AlwaysStoppedAnimation(c.accent),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Analyse...',
                  style: TextStyle(
                    color: c.accent,
                    fontSize: 13,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 16),

          // Output
          Text(
            'RESULTAT',
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
              color: c.scaffold,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: c.glassBorder),
            ),
            child: Text(
              outputText,
              style: TextStyle(
                color: t.manualOutput != null
                    ? c.accent
                    : c.textHint,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ModelStatusRow extends StatelessWidget {
  final bool modelReady;
  final bool hasScaler;
  final String? error;

  const _ModelStatusRow({
    required this.modelReady,
    required this.hasScaler,
    this.error,
  });

  @override
  Widget build(BuildContext context) {
    final c = HarmonyColors.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            StatusIndicator(
              active: modelReady,
              label: modelReady ? 'Modele OK' : 'Modele absent',
            ),
            const SizedBox(width: 16),
            StatusIndicator(
              active: hasScaler,
              label: hasScaler ? 'Scaler OK' : 'Scaler absent',
            ),
          ],
        ),
        if (error != null) ...[
          const SizedBox(height: 6),
          Text(
            error!,
            style: TextStyle(color: c.error, fontSize: 12),
          ),
        ],
      ],
    );
  }
}
