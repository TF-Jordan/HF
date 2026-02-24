import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/connection_provider.dart';
import '../../providers/recording_provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/translation_provider.dart';
import '../../widgets/common/glass_card.dart';
import '../../widgets/common/gradient_button.dart';
import '../../widgets/common/section_header.dart';
import '../../widgets/common/status_indicator.dart';

/// Settings page — all configuration in one place.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late final TextEditingController _ipController;
  late final TextEditingController _portController;
  late final TextEditingController _labelController;
  late final TextEditingController _pointsController;
  late final TextEditingController _durationController;

  @override
  void initState() {
    super.initState();
    final conn = context.read<ConnectionProvider>();
    final rec = context.read<RecordingProvider>();
    _ipController = TextEditingController(text: conn.ip);
    _portController = TextEditingController(text: '${conn.port}');
    _labelController = TextEditingController();
    _pointsController =
        TextEditingController(text: '${rec.collectionTargetPoints}');
    _durationController =
        TextEditingController(text: '${rec.captureDurationSeconds}');
  }

  @override
  void dispose() {
    _ipController.dispose();
    _portController.dispose();
    _labelController.dispose();
    _pointsController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = HarmonyColors.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          _buildConnectionSection(c),
          _buildThemeSection(c),
          _buildLabelsSection(c),
          _buildCollectionSection(c),
          _buildModelSection(c),
          _buildExportSection(c),
          _buildAboutSection(c),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // ── Connection ──
  Widget _buildConnectionSection(HarmonyColors c) {
    final conn = context.watch<ConnectionProvider>();

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: 'Connexion ESP32',
            icon: Icons.router_rounded,
            trailing: StatusIndicator(
              active: conn.isConnected,
              label: conn.isConnected
                  ? 'Connecte'
                  : conn.isConnecting
                      ? 'Connexion...'
                      : 'Deconnecte',
              activeColor: c.success,
              inactiveColor: conn.isConnecting ? c.warning : c.error,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _ipController,
            style: TextStyle(color: c.textPrimary),
            decoration: InputDecoration(
              labelText: 'Adresse IP',
              prefixIcon: Icon(Icons.language, color: c.textHint),
            ),
            onChanged: (v) => conn.ip = v,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _portController,
            style: TextStyle(color: c.textPrimary),
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Port',
              prefixIcon: Icon(Icons.numbers_rounded, color: c.textHint),
            ),
            onChanged: (v) {
              final port = int.tryParse(v);
              if (port != null) conn.port = port;
            },
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: conn.isConnected
                    ? GradientButton(
                        label: 'Deconnecter',
                        icon: Icons.link_off,
                        gradient: c.dangerGradient,
                        onPressed: conn.disconnect,
                      )
                    : conn.isConnecting
                        ? GradientButton(
                            label: 'Connexion...',
                            icon: Icons.sync_rounded,
                            gradient: LinearGradient(
                              colors: [c.warning, c.warning.withAlpha(180)],
                            ),
                            onPressed: conn.disconnect,
                          )
                        : GradientButton(
                            label: 'Connecter',
                            icon: Icons.link,
                            gradient: c.primaryGradient,
                            onPressed: conn.connect,
                          ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Theme ──
  Widget _buildThemeSection(HarmonyColors c) {
    final themeProv = context.watch<ThemeProvider>();

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            title: 'Apparence',
            icon: Icons.palette_rounded,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _ThemeCard(
                  label: 'Blue',
                  primary: const Color(0xFF1D4ED8),
                  background: const Color(0xFFF0F4FF),
                  textColor: const Color(0xFF0F172A),
                  selected: themeProv.mode == HarmonyThemeMode.shazamBlue,
                  onTap: () =>
                      themeProv.setTheme(HarmonyThemeMode.shazamBlue),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _ThemeCard(
                  label: 'Orange',
                  primary: const Color(0xFFFF6B00),
                  background: const Color(0xFF0A0A0A),
                  textColor: const Color(0xFFF5F5F5),
                  selected: themeProv.mode == HarmonyThemeMode.shazamOrange,
                  onTap: () =>
                      themeProv.setTheme(HarmonyThemeMode.shazamOrange),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _ThemeCard(
                  label: 'Doodle',
                  primary: const Color(0xFF1565C0),
                  background: const Color(0xFF3D6898),
                  textColor: const Color(0xFFF5F5F5),
                  selected: themeProv.mode == HarmonyThemeMode.doodle,
                  onTap: () =>
                      themeProv.setTheme(HarmonyThemeMode.doodle),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _ThemeCard(
                  label: 'Chalk',
                  primary: const Color(0xFF43A047),
                  background: const Color(0xFF141414),
                  textColor: const Color(0xFFE8E8E8),
                  selected: themeProv.mode == HarmonyThemeMode.chalk,
                  onTap: () =>
                      themeProv.setTheme(HarmonyThemeMode.chalk),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Labels management (with delete & rename) ──
  Widget _buildLabelsSection(HarmonyColors c) {
    final rec = context.watch<RecordingProvider>();

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: 'Labels de gestes',
            icon: Icons.label_rounded,
            trailing: Text(
              '${rec.labels.length} labels',
              style: TextStyle(
                color: c.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: rec.labels.map((label) {
              final selected = rec.selectedLabel == label;
              return GestureDetector(
                onTap: () => rec.selectLabel(label),
                onLongPress: () => _showLabelActions(context, rec, label, c),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    gradient: selected ? c.primaryGradient : null,
                    color: selected ? null : c.surface,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: selected ? Colors.transparent : c.glassBorder,
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
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        label,
                        style: TextStyle(
                          color: selected ? Colors.white : c.textSecondary,
                          fontSize: 13,
                          fontWeight:
                              selected ? FontWeight.w700 : FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: () =>
                            _showLabelActions(context, rec, label, c),
                        child: Icon(
                          Icons.more_vert_rounded,
                          size: 16,
                          color: selected
                              ? Colors.white70
                              : c.textHint,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _labelController,
                  style: TextStyle(color: c.textPrimary, fontSize: 14),
                  decoration: InputDecoration(
                    labelText: 'Nouveau label',
                    prefixIcon:
                        Icon(Icons.add_rounded, color: c.textHint),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                  ),
                  onSubmitted: (_) => _addLabel(rec),
                ),
              ),
              const SizedBox(width: 8),
              GradientButton(
                label: 'Ajouter',
                compact: true,
                gradient: c.primaryGradient,
                onPressed: () => _addLabel(rec),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Appui long ou icone ... pour modifier / supprimer',
            style: TextStyle(
              color: c.textHint,
              fontSize: 11,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  void _showLabelActions(BuildContext context, RecordingProvider rec,
      String label, HarmonyColors c) {
    showModalBottomSheet(
      context: context,
      backgroundColor: c.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: c.textHint,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Label: $label',
                  style: TextStyle(
                    color: c.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${rec.labelCounts[label] ?? 0} echantillons collectes',
                  style: TextStyle(
                    color: c.textSecondary,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 20),
                ListTile(
                  leading: Icon(Icons.edit_rounded, color: c.primary),
                  title: Text(
                    'Renommer',
                    style: TextStyle(color: c.textPrimary),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                    _showRenameDialog(context, rec, label, c);
                  },
                ),
                ListTile(
                  leading: Icon(Icons.delete_rounded, color: c.error),
                  title: Text(
                    'Supprimer',
                    style: TextStyle(color: c.error),
                  ),
                  subtitle: Text(
                    'Supprime le label et ses donnees',
                    style: TextStyle(color: c.textHint, fontSize: 12),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                    _confirmDeleteLabel(context, rec, label, c);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showRenameDialog(BuildContext context, RecordingProvider rec,
      String oldLabel, HarmonyColors c) {
    final controller = TextEditingController(text: oldLabel);
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: c.card,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            'Renommer le label',
            style: TextStyle(color: c.textPrimary),
          ),
          content: TextField(
            controller: controller,
            autofocus: true,
            style: TextStyle(color: c.textPrimary),
            decoration: InputDecoration(
              labelText: 'Nouveau nom',
              prefixIcon: Icon(Icons.edit_rounded, color: c.textHint),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                'Annuler',
                style: TextStyle(color: c.textSecondary),
              ),
            ),
            TextButton(
              onPressed: () {
                rec.renameLabel(oldLabel, controller.text);
                Navigator.pop(ctx);
              },
              child: Text(
                'Renommer',
                style: TextStyle(color: c.primary),
              ),
            ),
          ],
        );
      },
    );
  }

  void _confirmDeleteLabel(BuildContext context, RecordingProvider rec,
      String label, HarmonyColors c) {
    final count = rec.labelCounts[label] ?? 0;
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: c.card,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            'Supprimer "$label" ?',
            style: TextStyle(color: c.textPrimary),
          ),
          content: Text(
            count > 0
                ? 'Ce label contient $count echantillon(s). Toutes les donnees seront perdues.'
                : 'Ce label sera supprime definitivement.',
            style: TextStyle(color: c.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                'Annuler',
                style: TextStyle(color: c.textSecondary),
              ),
            ),
            TextButton(
              onPressed: () {
                rec.removeLabel(label);
                Navigator.pop(ctx);
              },
              child: Text(
                'Supprimer',
                style: TextStyle(color: c.error),
              ),
            ),
          ],
        );
      },
    );
  }

  // ── Collection settings (now editable) ──
  Widget _buildCollectionSection(HarmonyColors c) {
    final rec = context.watch<RecordingProvider>();

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            title: 'Collecte de donnees',
            icon: Icons.data_array_rounded,
          ),
          const SizedBox(height: 16),
          // Configurable: points per gesture
          TextField(
            controller: _pointsController,
            style: TextStyle(color: c.textPrimary),
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Points par geste',
              prefixIcon: Icon(Icons.grain_rounded, color: c.textHint),
              helperText: 'Nombre de frames a capturer par echantillon',
              helperStyle: TextStyle(color: c.textHint, fontSize: 11),
            ),
            onChanged: (v) {
              final pts = int.tryParse(v);
              if (pts != null && pts > 0) {
                rec.collectionTargetPoints = pts;
              }
            },
          ),
          const SizedBox(height: 12),
          // Configurable: capture duration
          TextField(
            controller: _durationController,
            style: TextStyle(color: c.textPrimary),
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Duree max de capture (secondes)',
              prefixIcon: Icon(Icons.timer_rounded, color: c.textHint),
              helperText: '0 = pas de limite (arret par nombre de points)',
              helperStyle: TextStyle(color: c.textHint, fontSize: 11),
            ),
            onChanged: (v) {
              final dur = int.tryParse(v);
              if (dur != null) {
                rec.captureDurationSeconds = dur;
              }
            },
          ),
        ],
      ),
    );
  }

  // ── Model info ──
  Widget _buildModelSection(HarmonyColors c) {
    final t = context.watch<TranslationProvider>();

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            title: 'Modele ML',
            icon: Icons.psychology_rounded,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              StatusIndicator(
                active: t.modelReady,
                label: t.modelReady ? 'Modele charge' : 'Modele absent',
                activeColor: c.success,
                inactiveColor: c.error,
              ),
              const SizedBox(width: 16),
              StatusIndicator(
                active: t.hasScaler,
                label: t.hasScaler ? 'Scaler OK' : 'Scaler absent',
                activeColor: c.success,
                inactiveColor: c.warning,
              ),
            ],
          ),
          if (t.modelError != null) ...[
            const SizedBox(height: 8),
            Text(
              t.modelError!,
              style: TextStyle(color: c.error, fontSize: 12),
            ),
          ],
        ],
      ),
    );
  }

  // ── Export ──
  Widget _buildExportSection(HarmonyColors c) {
    final rec = context.watch<RecordingProvider>();

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: 'Export des données (JSON)',
            icon: Icons.save_alt_rounded,
            trailing: Text(
              '${rec.totalSamples} échantillons',
              style: TextStyle(
                color: c.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: GradientButton(
                  label: 'Copier',
                  icon: Icons.copy_rounded,
                  gradient: c.successGradient,
                  onPressed: rec.totalSamples > 0
                      ? () async {
                          final result = await rec.copyJson();
                          if (!context.mounted) return;
                          final msg = result > 0
                              ? 'JSON copie ! ($result caracteres)'
                              : result == 0
                                  ? 'Erreur: impossible de copier dans le presse-papier'
                                  : 'Aucune donnee a exporter (echantillons vides)';
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(msg)),
                          );
                        }
                      : null,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: GradientButton(
                  label: 'Exporter',
                  icon: Icons.file_download_rounded,
                  gradient: c.successGradient,
                  onPressed: rec.totalSamples > 0
                      ? () async {
                          final path = await rec.exportToFile();
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                path != null
                                    ? 'Sauvegarde: $path'
                                    : 'Erreur export',
                              ),
                            ),
                          );
                        }
                      : null,
                ),
              ),
            ],
          ),
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
          if (rec.totalSamples > 0) ...[
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: rec.clearAll,
              icon: Icon(Icons.delete_outline_rounded,
                  color: c.error, size: 18),
              label: Text(
                'Effacer toutes les donnees',
                style: TextStyle(color: c.error, fontSize: 13),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ── About ──
  Widget _buildAboutSection(HarmonyColors c) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            title: 'A propos',
            icon: Icons.info_outline_rounded,
          ),
          const SizedBox(height: 16),
          _InfoRow(label: 'Application', value: AppConstants.appName, c: c),
          const SizedBox(height: 8),
          _InfoRow(label: 'Version', value: '2.0.0', c: c),
          const SizedBox(height: 8),
          _InfoRow(
            label: 'Description',
            value: AppConstants.appTagline,
            c: c,
          ),
        ],
      ),
    );
  }

  void _addLabel(RecordingProvider rec) {
    rec.addLabel(_labelController.text);
    _labelController.clear();
  }
}

// ── Reusable info row ──
class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final HarmonyColors c;

  const _InfoRow({
    required this.label,
    required this.value,
    required this.c,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(
            label,
            style: TextStyle(
              color: c.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            value,
            style: TextStyle(
              color: c.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}

// ── Theme preview card ──
class _ThemeCard extends StatelessWidget {
  final String label;
  final Color primary;
  final Color background;
  final Color textColor;
  final bool selected;
  final VoidCallback onTap;

  const _ThemeCard({
    required this.label,
    required this.primary,
    required this.background,
    required this.textColor,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? primary : Colors.transparent,
            width: 2.5,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: primary.withAlpha(60),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: primary,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: textColor,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              label,
              style: TextStyle(
                color: textColor,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (selected) ...[
              const SizedBox(height: 6),
              Icon(Icons.check_circle_rounded, color: primary, size: 20),
            ],
          ],
        ),
      ),
    );
  }
}
