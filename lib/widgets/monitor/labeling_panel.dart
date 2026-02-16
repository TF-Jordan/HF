import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../providers/connection_provider.dart';
import '../../providers/recording_provider.dart';
import '../common/glass_card.dart';
import '../common/gradient_button.dart';
import '../common/section_header.dart';
import '../common/status_indicator.dart';

/// The labelling and recording control panel with live chronometer.
class LabelingPanel extends StatefulWidget {
  const LabelingPanel({super.key});

  @override
  State<LabelingPanel> createState() => _LabelingPanelState();
}

class _LabelingPanelState extends State<LabelingPanel> {
  Timer? _chronoTimer;

  @override
  void dispose() {
    _chronoTimer?.cancel();
    super.dispose();
  }

  void _startChronoTimer() {
    _chronoTimer?.cancel();
    _chronoTimer = Timer.periodic(
      const Duration(milliseconds: 100),
      (_) => setState(() {}),
    );
  }

  void _stopChronoTimer() {
    _chronoTimer?.cancel();
    _chronoTimer = null;
  }

  String _formatDuration(Duration d) {
    final mins = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final secs = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    final tenths = (d.inMilliseconds.remainder(1000) ~/ 100).toString();
    return '$mins:$secs.$tenths';
  }

  @override
  Widget build(BuildContext context) {
    final c = HarmonyColors.of(context);
    final rec = context.watch<RecordingProvider>();
    final conn = context.watch<ConnectionProvider>();

    // Manage chrono timer based on recording state
    if (rec.isRecording && !rec.isPaused && _chronoTimer == null) {
      _startChronoTimer();
    } else if ((!rec.isRecording || rec.isPaused) && _chronoTimer != null) {
      _stopChronoTimer();
    }

    final targetPoints = rec.collectionTargetPoints;
    final progress = targetPoints > 0
        ? (rec.sessionSamples / targetPoints).clamp(0.0, 1.0)
        : 0.0;

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          SectionHeader(
            title: 'Collecte de donnees',
            icon: Icons.data_array_rounded,
            trailing: StatusIndicator(
              active: rec.isRecording,
              label: rec.isPaused
                  ? 'PAUSE'
                  : rec.isRecording
                      ? 'REC'
                      : 'PRET',
              activeColor: rec.isPaused ? c.warning : c.error,
            ),
          ),
          const SizedBox(height: 16),

          // Label chips (read-only selector)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: rec.labels.map((label) {
              final selected = rec.selectedLabel == label;
              return GestureDetector(
                onTap: rec.isRecording ? null : () => rec.selectLabel(label),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    gradient: selected ? c.primaryGradient : null,
                    color: selected ? null : c.surface,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: selected
                          ? Colors.transparent
                          : c.glassBorder,
                    ),
                    boxShadow: selected
                        ? [
                            BoxShadow(
                              color: c.primary.withAlpha(50),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Text(
                    label,
                    style: TextStyle(
                      color: selected
                          ? Colors.white
                          : c.textSecondary,
                      fontSize: 13,
                      fontWeight:
                          selected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          // Stats + Chronometer
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: c.scaffold.withAlpha(120),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    _StatChip(
                      label: 'Total',
                      value: '${rec.totalSamples}',
                      color: c.primary,
                    ),
                    _StatChip(
                      label: rec.selectedLabel,
                      value: '${rec.labelCounts[rec.selectedLabel] ?? 0}',
                      color: c.accent,
                    ),
                    _StatChip(
                      label: 'Points',
                      value: '${rec.sessionSamples}/$targetPoints',
                      color: c.success,
                    ),
                  ],
                ),
                // Chronometer row (visible during & after recording)
                if (rec.isRecording ||
                    rec.captureElapsed.inMilliseconds > 0) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: rec.isPaused
                          ? c.warning.withAlpha(20)
                          : rec.isRecording
                              ? c.error.withAlpha(20)
                              : c.success.withAlpha(20),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: rec.isPaused
                            ? c.warning.withAlpha(60)
                            : rec.isRecording
                                ? c.error.withAlpha(60)
                                : c.success.withAlpha(60),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          rec.isPaused
                              ? Icons.pause_rounded
                              : rec.isRecording
                                  ? Icons.timer_rounded
                                  : Icons.timer_off_rounded,
                          color: rec.isPaused
                              ? c.warning
                              : rec.isRecording
                                  ? c.error
                                  : c.success,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _formatDuration(rec.captureElapsed),
                          style: TextStyle(
                            color: rec.isPaused
                                ? c.warning
                                : rec.isRecording
                                    ? c.error
                                    : c.success,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            fontFeatures: const [
                              FontFeature.tabularFigures()
                            ],
                          ),
                        ),
                        if (rec.captureDurationSeconds > 0) ...[
                          const SizedBox(width: 8),
                          Text(
                            '/ ${rec.captureDurationSeconds}s',
                            style: TextStyle(
                              color: c.textHint,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Progress bar
          if (rec.isRecording) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: c.surface,
                valueColor: AlwaysStoppedAnimation(
                  rec.isPaused ? c.warning : c.accent,
                ),
                minHeight: 6,
              ),
            ),
            const SizedBox(height: 16),
          ],

          // ── Control buttons: Collecte / Pause / Supprimer ──
          if (rec.isRecording)
            _buildRecordingControls(c, rec)
          else
            _buildStartButton(c, rec, conn),

          // Clear button
          if (rec.totalSamples > 0 && !rec.isRecording) ...[
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: rec.clearAll,
                icon: Icon(
                  Icons.delete_outline_rounded,
                  color: c.error,
                  size: 18,
                ),
                label: Text(
                  'Tout effacer',
                  style: TextStyle(color: c.error, fontSize: 13),
                ),
              ),
            ),
          ],

          // Last export path
          if (rec.lastExportPath != null) ...[
            const SizedBox(height: 8),
            Text(
              rec.lastExportPath!,
              style: TextStyle(
                color: c.textHint,
                fontSize: 11,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Three buttons during active recording: Pause/Reprendre + Supprimer.
  Widget _buildRecordingControls(HarmonyColors c, RecordingProvider rec) {
    return Row(
      children: [
        // Pause / Resume
        Expanded(
          child: GradientButton(
            label: rec.isPaused ? 'Reprendre' : 'Pause',
            icon: rec.isPaused
                ? Icons.play_arrow_rounded
                : Icons.pause_rounded,
            gradient: rec.isPaused
                ? c.successGradient
                : LinearGradient(
                    colors: [c.warning, c.warning.withAlpha(180)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
            onPressed: rec.isPaused
                ? rec.resumeRecording
                : rec.pauseRecording,
          ),
        ),
        const SizedBox(width: 12),
        // Cancel / Delete
        Expanded(
          child: GradientButton(
            label: 'Supprimer',
            icon: Icons.delete_forever_rounded,
            gradient: c.dangerGradient,
            onPressed: rec.cancelRecording,
          ),
        ),
      ],
    );
  }

  /// Start button when not recording.
  Widget _buildStartButton(
      HarmonyColors c, RecordingProvider rec, ConnectionProvider conn) {
    final targetPoints = rec.collectionTargetPoints;
    return GradientButton(
      label: 'Collecter $targetPoints pts',
      icon: Icons.play_arrow_rounded,
      gradient: c.primaryGradient,
      onPressed: conn.isConnected ? rec.startRecording : null,
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatChip({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final c = HarmonyColors.of(context);
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.w800,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: c.textHint,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
