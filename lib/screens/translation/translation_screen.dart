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

/// Reading mode for predictions.
enum ReadingMode { word, phrase }

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
  ReadingMode _readingMode = ReadingMode.word;

  // Track last processed outputs for phrase auto-append
  String? _lastSeenManualOutput;
  String? _lastSeenAutoOutput;

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

  /// Extract the first predicted word from model output like "harmony 95.2% | appeler 4.8%"
  String _extractWord(String? output) {
    if (output == null) return '';
    return output.split(' ').first.trim();
  }

  /// Convert "espace" to a literal space, otherwise return the word as-is.
  String _displayWord(String word) {
    if (word.toLowerCase() == 'espace') return ' ';
    return word;
  }

  /// Whether a word is valid for display/addition (not an error message).
  bool _isValidWord(String word) {
    return word.isNotEmpty &&
        word != 'Aucune' &&
        word != 'Erreur' &&
        word != 'Modele';
  }

  void _addWordToPhrase(String? output) {
    if (output == null) return;
    final word = _extractWord(output);
    if (!_isValidWord(word)) return;

    setState(() {
      if (word.toLowerCase() == 'espace') {
        // "espace" → add a space marker (we join with empty string in phrase mode)
        _phraseWords.add(' ');
      } else {
        _phraseWords.add(word);
      }
    });
  }

  /// Auto-append in phrase mode when a new prediction arrives.
  void _autoAppendIfNeeded(String? output, String? lastSeen) {
    if (output == null || output == lastSeen) return;
    final word = _extractWord(output);
    if (!_isValidWord(word)) return;

    // Schedule setState after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() {
        if (word.toLowerCase() == 'espace') {
          _phraseWords.add(' ');
        } else {
          _phraseWords.add(word);
        }
      });

      // Auto-speak in TTS mode
      if (_ttsEnabled) {
        _speakWord(word);
      }
    });
  }

  String _buildPhraseDisplay() {
    if (_phraseWords.isEmpty) return '';
    final buffer = StringBuffer();
    for (final w in _phraseWords) {
      if (w == ' ') {
        // "espace" → literal space separator
        if (buffer.isNotEmpty && !buffer.toString().endsWith(' ')) {
          buffer.write(' ');
        }
      } else {
        buffer.write(w);
      }
    }
    return buffer.toString();
  }

  Future<void> _speakWord(String word) async {
    if (word.toLowerCase() == 'espace') return; // don't speak "espace"
    await _tts.speak(word);
  }

  Future<void> _speakPrediction(String? output) async {
    if (output == null) return;
    final word = _extractWord(output);
    if (word.isNotEmpty && word.toLowerCase() != 'espace') {
      await _tts.speak(word);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = HarmonyColors.of(context);
    final t = context.watch<TranslationProvider>();
    final conn = context.watch<ConnectionProvider>();

    // ── Phrase mode auto-append ──
    if (_readingMode == ReadingMode.phrase) {
      if (t.manualOutput != null && t.manualOutput != _lastSeenManualOutput) {
        _autoAppendIfNeeded(t.manualOutput, _lastSeenManualOutput);
        _lastSeenManualOutput = t.manualOutput;
      }
      if (t.autoOutput != null && t.autoOutput != _lastSeenAutoOutput) {
        _autoAppendIfNeeded(t.autoOutput, _lastSeenAutoOutput);
        _lastSeenAutoOutput = t.autoOutput;
      }
    } else {
      // Keep in sync even in word mode
      _lastSeenManualOutput = t.manualOutput;
      _lastSeenAutoOutput = t.autoOutput;
    }

    // Determine the latest prediction from active mode
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

    // Apply "espace" → literal space display
    final displayedWord = _displayWord(predictedWord);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          // ── Hero Prediction Panel ──
          _buildHeroPanel(c, displayedWord, predictedWord, confidenceText,
              confidenceValue, hasResult),

          // ── Reading mode toggle (Mot / Phrase) ──
          _buildReadingModeToggle(c),

          // ── Phrase Bar (in phrase mode, always show; in word mode, show if populated) ──
          if (_readingMode == ReadingMode.phrase || _phraseWords.isNotEmpty)
            _buildPhraseBar(c),

          // ── Status Row ──
          _buildStatusRow(c, t, conn),

          // ── Mode Toggle (Manuel / Temps reel) ──
          _buildModeToggle(c, t),

          // ── Active mode content (only one visible) ──
          if (t.activeMode == TranslationMode.manual)
            _buildManualSection(c, t, conn),

          if (t.activeMode == TranslationMode.auto) ...[
            _buildAutoSection(c, t),
            if (t.autoHistory.isNotEmpty) _buildHistory(c, t),
          ],

          // ── Placeholder when no mode selected ──
          if (t.activeMode == TranslationMode.none) _buildNoModeHint(c),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildHeroPanel(HarmonyColors c, String displayWord,
      String rawWord, String confidence,
      double confidenceValue, bool hasResult) {
    // In phrase mode, show the accumulated phrase in the hero panel
    final bool isPhraseMode = _readingMode == ReadingMode.phrase;
    final phraseText = _buildPhraseDisplay();

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
          if (isPhraseMode && phraseText.isNotEmpty) ...[
            // Phrase display
            Text(
              phraseText,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: c.textPrimary,
                fontSize: phraseText.length > 20 ? 28 : 36,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
              ),
            ),
            if (hasResult) ...[
              const SizedBox(height: 8),
              // Show the latest word added
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_rounded, color: c.accent, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    rawWord.toLowerCase() == 'espace'
                        ? '(espace)'
                        : displayWord,
                    style: TextStyle(
                      color: c.accent,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ] else ...[
            // Word display (default / word mode)
            Text(
              hasResult
                  ? (rawWord.toLowerCase() == 'espace' ? '⎵' : displayWord)
                  : 'harmony',
              style: TextStyle(
                color: hasResult ? c.textPrimary : c.textHint,
                fontSize: hasResult ? 48 : 36,
                fontWeight: FontWeight.w900,
                letterSpacing: -1,
              ),
            ),
          ],
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
          if (!hasResult && (!isPhraseMode || phraseText.isEmpty)) ...[
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

  Widget _buildReadingModeToggle(HarmonyColors c) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: c.glassBorder),
        ),
        child: Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _readingMode = ReadingMode.word),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    gradient: _readingMode == ReadingMode.word
                        ? c.primaryGradient
                        : null,
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.text_fields_rounded,
                        color: _readingMode == ReadingMode.word
                            ? Colors.white
                            : c.textHint,
                        size: 18,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Mot',
                        style: TextStyle(
                          color: _readingMode == ReadingMode.word
                              ? Colors.white
                              : c.textSecondary,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _readingMode = ReadingMode.phrase),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    gradient: _readingMode == ReadingMode.phrase
                        ? c.primaryGradient
                        : null,
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.short_text_rounded,
                        color: _readingMode == ReadingMode.phrase
                            ? Colors.white
                            : c.textHint,
                        size: 18,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Phrase',
                        style: TextStyle(
                          color: _readingMode == ReadingMode.phrase
                              ? Colors.white
                              : c.textSecondary,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhraseBar(HarmonyColors c) {
    final phraseDisplay = _buildPhraseDisplay();
    if (phraseDisplay.isEmpty && _readingMode == ReadingMode.phrase) {
      // Show placeholder in phrase mode
      return GlassCard(
        child: Row(
          children: [
            Icon(Icons.short_text_rounded, color: c.textHint, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Les mots signes apparaitront ici...',
                style: TextStyle(
                  color: c.textHint,
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ),
      );
    }
    if (phraseDisplay.isEmpty) return const SizedBox.shrink();

    return GlassCard(
      child: Row(
        children: [
          Icon(Icons.short_text_rounded, color: c.primary, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              phraseDisplay,
              style: TextStyle(
                color: c.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          // Speak phrase
          GestureDetector(
            onTap: () async {
              if (phraseDisplay.isNotEmpty) {
                await _tts.speak(phraseDisplay);
              }
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
          // Clear phrase
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
                if (t.activeMode == TranslationMode.manual) return;
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
                if (t.activeMode == TranslationMode.auto) return;
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

          // Output (word mode only — phrase mode auto-appends)
          if (t.manualOutput != null && _readingMode == ReadingMode.word) ...[
            const SizedBox(height: 16),
            _buildOutputRow(c, t.manualOutput!),
          ],
        ],
      ),
    );
  }

  Widget _buildOutputRow(HarmonyColors c, String output) {
    final word = _extractWord(output);
    final displayed = word.toLowerCase() == 'espace' ? '(espace)' : output;

    return Container(
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
              displayed,
              style: TextStyle(
                color: c.accent,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => _addWordToPhrase(output),
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: c.success.withAlpha(20),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.add_rounded, color: c.success, size: 18),
            ),
          ),
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

    final canRec =
        canAct && !t.isManualRecording && !t.manualInferenceInFlight;
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
                gradient:
                    t.isAutoActive ? c.dangerGradient : c.successGradient,
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

          // Auto output (word mode only)
          if (t.autoOutput != null && _readingMode == ReadingMode.word) ...[
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
                      _extractWord(t.autoOutput).toLowerCase() == 'espace'
                          ? '(espace)'
                          : t.autoOutput!,
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
            final word = _extractWord(entry.value);
            final display = word.toLowerCase() == 'espace'
                ? '(espace)'
                : entry.value;
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
                      display,
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
