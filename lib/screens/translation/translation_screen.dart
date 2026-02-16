import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/connection_provider.dart';
import '../../providers/translation_provider.dart';
import '../../widgets/common/glass_card.dart';
import '../../widgets/common/gradient_button.dart';
import '../../widgets/common/section_header.dart';
import '../../widgets/common/status_indicator.dart';

/// The Translation tab — exclusive manual/auto modes with diamond button layout.
class TranslationScreen extends StatefulWidget {
  const TranslationScreen({super.key});

  @override
  State<TranslationScreen> createState() => _TranslationScreenState();
}

class _TranslationScreenState extends State<TranslationScreen> {
  final List<String> _phraseWords = [];
  final FlutterTts _tts = FlutterTts();
  bool _ttsEnabled = false;

  @override
  void initState() {
    super.initState();
    _initTts();
  }

  Future<void> _initTts() async {
    await _tts.setLanguage('fr-FR');
    await _tts.setSpeechRate(0.5);
    await _tts.setVolume(1.0);
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }

  void _addWordToPhrase(String? output) {
    if (output == null) return;
    final word = output.split(' ').first.trim();
    if (word.isNotEmpty &&
        word != 'Aucune' &&
        word != 'Erreur' &&
        word != 'Modele') {
      setState(() => _phraseWords.add(word));
    }
  }

  Future<void> _speakPrediction(String? output) async {
    if (output == null) return;
    final word = output.split(' ').first.trim();
    if (word.isNotEmpty) {
      await _tts.speak(word);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = HarmonyColors.of(context);
    final t = context.watch<TranslationProvider>();
    final conn = context.watch<ConnectionProvider>();

    // Determine the latest prediction from either mode
    final latestOutput = t.activeMode == TranslationMode.auto
        ? t.autoOutput
        : t.manualOutput;
    final hasResult = latestOutput != null;

    // Parse prediction: "harmony 95.2% | appeler 4.8%"
    String predictedWord = '';
    String confidenceText = '';
    double confidenceValue = 0.0;
    if (hasResult) {
      final parts = latestOutput.split('|');
      final mainPart = parts.first.trim();
      final mainTokens = mainPart.split(' ');
      if (mainTokens.length >= 2) {
        predictedWord = mainTokens[0];
        final pctStr = mainTokens[1].replaceAll('%', '');
        confidenceValue = double.tryParse(pctStr) ?? 0;
        confidenceText = '${confidenceValue.toStringAsFixed(1)}%';
      } else {
        predictedWord = mainPart;
      }
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          // ── Hero Prediction Panel ──
          _buildHeroPanel(c, predictedWord, confidenceText, confidenceValue,
              hasResult),

          // ── Phrase Bar ──
          if (_phraseWords.isNotEmpty) _buildPhraseBar(c),

          // ── Status Row ──
          _buildStatusRow(c, t, conn),

          // ── Mode Toggle ──
          _buildModeToggle(c, t),

          // ── Active mode content (only one visible) ──
          if (t.activeMode == TranslationMode.manual)
            _buildManualSection(c, t, conn),

          if (t.activeMode == TranslationMode.auto) ...[
            _buildAutoSection(c, t),
            if (t.autoHistory.isNotEmpty) _buildHistory(c, t),
          ],

          // ── Placeholder when no mode selected ──
          if (t.activeMode == TranslationMode.none)
            _buildNoModeHint(c),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildHeroPanel(HarmonyColors c, String word, String confidence,
      double confidenceValue, bool hasResult) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
      decoration: BoxDecoration(
        gradient: hasResult
            ? LinearGradient(
                colors: [
                  c.primary.withAlpha(30),
                  c.accent.withAlpha(15),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: hasResult ? null : c.card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: hasResult ? c.primary.withAlpha(60) : c.glassBorder,
        ),
        boxShadow: hasResult
            ? [
                BoxShadow(
                  color: c.primary.withAlpha(20),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ]
            : null,
      ),
      child: Column(
        children: [
          Text(
            hasResult ? word : 'harmony',
            style: TextStyle(
              color: hasResult ? c.textPrimary : c.textHint,
              fontSize: hasResult ? 48 : 36,
              fontWeight: FontWeight.w900,
              letterSpacing: -1,
            ),
          ),
          if (hasResult && confidence.isNotEmpty) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: 200,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.bolt_rounded, color: c.accent, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        'Confiance: $confidence',
                        style: TextStyle(
                          color: c.textSecondary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: (confidenceValue / 100).clamp(0.0, 1.0),
                      backgroundColor: c.surface,
                      valueColor: AlwaysStoppedAnimation(
                        confidenceValue > 80
                            ? c.success
                            : confidenceValue > 50
                                ? c.warning
                                : c.error,
                      ),
                      minHeight: 6,
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (!hasResult) ...[
            const SizedBox(height: 8),
            Text(
              'Pret a traduire',
              style: TextStyle(color: c.textHint, fontSize: 14),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPhraseBar(HarmonyColors c) {
    return GlassCard(
      child: Row(
        children: [
          Icon(Icons.short_text_rounded, color: c.primary, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _phraseWords.join(' '),
              style: TextStyle(
                color: c.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () async {
              final phrase = _phraseWords.join(' ');
              await _tts.speak(phrase);
            },
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: c.primary.withAlpha(20),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.volume_up_rounded,
                color: c.primary,
                size: 18,
              ),
            ),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: () => setState(() => _phraseWords.clear()),
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: c.error.withAlpha(20),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.delete_outline_rounded,
                color: c.error,
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusRow(
      HarmonyColors c, TranslationProvider t, ConnectionProvider conn) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          StatusIndicator(
            active: conn.isConnected,
            label: conn.isConnected ? 'ESP32' : 'Hors ligne',
            activeColor: c.success,
            inactiveColor: c.error,
          ),
          const SizedBox(width: 12),
          StatusIndicator(
            active: t.modelReady,
            label: t.modelReady ? 'Modele OK' : 'Modele absent',
            activeColor: c.success,
            inactiveColor: c.error,
          ),
          if (t.hasScaler) ...[
            const SizedBox(width: 12),
            StatusIndicator(
              active: true,
              label: 'Scaler OK',
              activeColor: c.success,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildModeToggle(HarmonyColors c, TranslationProvider t) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                if (t.activeMode == TranslationMode.manual) {
                  // Already manual — deselect (but keep mode for state)
                  return;
                }
                t.setManualMode();
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  gradient: t.activeMode == TranslationMode.manual
                      ? c.primaryGradient
                      : null,
                  color: t.activeMode == TranslationMode.manual
                      ? null
                      : c.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: t.activeMode == TranslationMode.manual
                        ? Colors.transparent
                        : c.glassBorder,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.front_hand_rounded,
                      color: t.activeMode == TranslationMode.manual
                          ? Colors.white
                          : c.textHint,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Manuel',
                      style: TextStyle(
                        color: t.activeMode == TranslationMode.manual
                            ? Colors.white
                            : c.textSecondary,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: GestureDetector(
              onTap: () {
                if (t.activeMode == TranslationMode.auto) {
                  return;
                }
                t.setAutoMode();
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  gradient: t.activeMode == TranslationMode.auto
                      ? c.successGradient
                      : null,
                  color: t.activeMode == TranslationMode.auto
                      ? null
                      : c.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: t.activeMode == TranslationMode.auto
                        ? Colors.transparent
                        : c.glassBorder,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.auto_awesome_rounded,
                      color: t.activeMode == TranslationMode.auto
                          ? Colors.white
                          : c.textHint,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Temps reel',
                      style: TextStyle(
                        color: t.activeMode == TranslationMode.auto
                            ? Colors.white
                            : c.textSecondary,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoModeHint(HarmonyColors c) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        children: [
          Icon(Icons.touch_app_rounded, color: c.textHint, size: 48),
          const SizedBox(height: 12),
          Text(
            'Choisissez un mode de traduction',
            style: TextStyle(color: c.textHint, fontSize: 15),
          ),
        ],
      ),
    );
  }

  // ── Manual mode: diamond button layout ──

  Widget _buildManualSection(
      HarmonyColors c, TranslationProvider t, ConnectionProvider conn) {
    final canAct = t.modelReady && conn.isConnected;

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: 'Traduction manuelle',
            icon: Icons.front_hand_rounded,
            trailing: StatusIndicator(
              active: t.isManualRecording,
              label: t.isManualRecording
                  ? 'REC'
                  : t.hasManualFrames
                      ? '${t.manualFrameCount} frames'
                      : 'PRET',
              activeColor: c.error,
            ),
          ),
          const SizedBox(height: 8),

          // Frame counter
          Row(
            children: [
              Icon(Icons.timeline_rounded, color: c.textHint, size: 16),
              const SizedBox(width: 6),
              Text(
                '${t.manualFrameCount} frames captures',
                style: TextStyle(color: c.textSecondary, fontSize: 13),
              ),
              if (t.manualInferenceInFlight) ...[
                const SizedBox(width: 12),
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(c.accent),
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  'Analyse...',
                  style: TextStyle(color: c.accent, fontSize: 12),
                ),
              ],
            ],
          ),
          const SizedBox(height: 16),

          // ── Diamond button layout ──
          _buildDiamondControls(c, t, canAct),

          // Output
          if (t.manualOutput != null) ...[
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: c.scaffold,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: c.glassBorder),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      t.manualOutput!,
                      style: TextStyle(
                        color: c.accent,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => _addWordToPhrase(t.manualOutput),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: c.success.withAlpha(20),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.add_rounded,
                          color: c.success, size: 18),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Diamond/losange layout: REC (north), PREDIRE (west), RESET (east),
  /// STOP (south), TTS (center).
  Widget _buildDiamondControls(
      HarmonyColors c, TranslationProvider t, bool canAct) {
    const double size = 220;
    const double btnSize = 56;

    // Button states
    final canRec = canAct && !t.isManualRecording && !t.manualInferenceInFlight;
    final canStop = t.isManualRecording;
    final canPredict =
        canAct && t.hasManualFrames && !t.manualInferenceInFlight;
    final canReset = !t.isManualRecording &&
        (t.manualOutput != null || t.manualFrameCount > 0);

    return Center(
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          children: [
            // REC — North
            Positioned(
              left: (size - btnSize) / 2,
              top: 0,
              child: _DiamondButton(
                icon: Icons.fiber_manual_record_rounded,
                label: 'REC',
                color: c.error,
                gradient: c.dangerGradient,
                size: btnSize,
                enabled: canRec,
                onTap: canRec ? t.startRecording : null,
              ),
            ),
            // PREDIRE — West
            Positioned(
              left: 0,
              top: (size - btnSize) / 2,
              child: _DiamondButton(
                icon: Icons.psychology_rounded,
                label: 'Predire',
                color: c.accent,
                gradient: c.primaryGradient,
                size: btnSize,
                enabled: canPredict,
                onTap: canPredict ? () => t.predict() : null,
              ),
            ),
            // RESET — East
            Positioned(
              right: 0,
              top: (size - btnSize) / 2,
              child: _DiamondButton(
                icon: Icons.refresh_rounded,
                label: 'Reset',
                color: c.warning,
                gradient: LinearGradient(
                  colors: [c.warning, c.warning.withAlpha(180)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                size: btnSize,
                enabled: canReset,
                onTap: canReset ? t.resetManual : null,
              ),
            ),
            // STOP — South
            Positioned(
              left: (size - btnSize) / 2,
              bottom: 0,
              child: _DiamondButton(
                icon: Icons.stop_rounded,
                label: 'Stop',
                color: c.textSecondary,
                gradient: LinearGradient(
                  colors: [c.textSecondary, c.textHint],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                size: btnSize,
                enabled: canStop,
                onTap: canStop ? t.stopRecording : null,
              ),
            ),
            // TTS — Center
            Positioned(
              left: (size - btnSize) / 2,
              top: (size - btnSize) / 2,
              child: _DiamondButton(
                icon: _ttsEnabled
                    ? Icons.volume_up_rounded
                    : Icons.volume_off_rounded,
                label: 'TTS',
                color: c.primary,
                gradient: _ttsEnabled
                    ? c.successGradient
                    : LinearGradient(
                        colors: [c.surface, c.card],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                size: btnSize,
                enabled: true,
                outlined: !_ttsEnabled,
                borderColor: c.glassBorder,
                onTap: () {
                  setState(() => _ttsEnabled = !_ttsEnabled);
                  if (_ttsEnabled && t.manualOutput != null) {
                    _speakPrediction(t.manualOutput);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Auto mode ──

  Widget _buildAutoSection(HarmonyColors c, TranslationProvider t) {
    final bufferProgress =
        t.autoBufferCount / AppConstants.translationBatchSize;

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: 'Mode temps reel',
            icon: Icons.auto_awesome_rounded,
            trailing: StatusIndicator(
              active: t.isAutoActive,
              label: t.isAutoActive ? 'ACTIF' : 'INACTIF',
              activeColor: c.success,
            ),
          ),
          const SizedBox(height: 16),

          // Buffer + Controls
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
                          style: TextStyle(color: c.textHint, fontSize: 12),
                        ),
                        Text(
                          '${t.autoBufferCount} / ${AppConstants.translationBatchSize}',
                          style: TextStyle(
                            color: c.textSecondary,
                            fontSize: 12,
                            fontFeatures: const [
                              FontFeature.tabularFigures()
                            ],
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
                          t.isAutoActive ? c.success : c.textHint,
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
                onPressed: t.modelReady ? t.toggleAutoTranslation : null,
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
                    valueColor: AlwaysStoppedAnimation(c.success),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Inference en cours...',
                  style: TextStyle(color: c.success, fontSize: 12),
                ),
              ],
            ),
          ],

          // Auto output + add to phrase
          if (t.autoOutput != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          c.success.withAlpha(20),
                          c.accent.withAlpha(10),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: c.glassBorder),
                    ),
                    child: Text(
                      t.autoOutput!,
                      style: TextStyle(
                        color: c.success,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GradientButton(
                  label: '+',
                  compact: true,
                  gradient: c.successGradient,
                  onPressed: () => _addWordToPhrase(t.autoOutput),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHistory(HarmonyColors c, TranslationProvider t) {
    final history = t.autoHistory.take(5).toList();
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            title: 'Historique',
            icon: Icons.history_rounded,
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
                      color: c.textHint.withAlpha((opacity * 255).toInt()),
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
      ),
    );
  }
}

/// A circular button used in the diamond/losange layout.
class _DiamondButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Gradient gradient;
  final double size;
  final bool enabled;
  final bool outlined;
  final Color? borderColor;
  final VoidCallback? onTap;

  const _DiamondButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.gradient,
    required this.size,
    required this.enabled,
    this.outlined = false,
    this.borderColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveOpacity = enabled ? 1.0 : 0.35;

    return AnimatedOpacity(
      opacity: effectiveOpacity,
      duration: const Duration(milliseconds: 200),
      child: GestureDetector(
        onTap: enabled ? onTap : null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: outlined ? null : gradient,
                color: outlined ? Colors.transparent : null,
                border: outlined
                    ? Border.all(color: borderColor ?? color, width: 2)
                    : null,
                boxShadow: enabled && !outlined
                    ? [
                        BoxShadow(
                          color: color.withAlpha(60),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: Icon(
                icon,
                color: outlined ? color : Colors.white,
                size: size * 0.42,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
