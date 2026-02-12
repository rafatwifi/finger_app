// lib/features/admin/admin_settings_screen.dart
// شاشة إعدادات الأدمن (تحكم مركزي)
//
// بعد التقسيم:
// - تم فصل كارت اللغة في ملف مستقل
// - تم فصل كارت لوغو تسجيل الدخول في ملف مستقل
// - تم فصل كارت الوقت + الحد اليومي في ملف مستقل
// - تم فصل كارت قواعد التحقق في ملف مستقل
// - تم فصل كارت الثيم في ملف مستقل
// - تم فصل الهيدر في ملف مستقل
// - كل الميزات السابقة محفوظة 100%
// - SAVE و APPLY بدون تغيير

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/models/app_settings_model.dart';
import '../../data/repositories/settings_repository.dart';
import '../../l10n/app_localizations.dart';
import 'controller/settings_draft_controller.dart';
import 'widgets/admin_settings_attendance_card.dart';
import 'widgets/admin_settings_header_card.dart';
import 'widgets/admin_settings_language_card.dart';
import 'widgets/admin_settings_logo_card.dart';
import 'widgets/admin_settings_theme_card.dart';
import 'widgets/admin_settings_validation_card.dart';

class AdminSettingsScreen extends StatefulWidget {
  const AdminSettingsScreen({super.key});

  @override
  State<AdminSettingsScreen> createState() => _AdminSettingsScreenState();
}

class _AdminSettingsScreenState extends State<AdminSettingsScreen> {
  late final SettingsDraftController _draft;
  bool _savedLocal = false;

  static const _palette = <String>[
    '#FF6A00',
    '#00FFAA',
    '#00B7FF',
    '#B100FF',
    '#FF2D55',
    '#FFD60A',
  ];

  @override
  void initState() {
    super.initState();
    _draft = SettingsDraftController(SettingsRepository());
    _draft.load();
  }

  void _onUpdate(SettingsDraftController ctrl, AppSettingsModel updated) {
    ctrl.update(updated);
    if (_savedLocal) {
      setState(() => _savedLocal = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);

    return ChangeNotifierProvider<SettingsDraftController>.value(
      value: _draft,
      child: Consumer<SettingsDraftController>(
        builder: (context, ctrl, _) {
          if (!ctrl.isReady) {
            return const Scaffold(
              backgroundColor: Colors.black,
              body: Center(
                child: CircularProgressIndicator(color: Colors.orange),
              ),
            );
          }

          final settings = ctrl.value;
          final primary = _hexToColor(settings.primaryColorHex);
          final accent = _hexToColor(settings.accentColorHex);

          return Scaffold(
            backgroundColor: Colors.black,
            appBar: AppBar(
              title: Text(t.adminSettingsTitle),
              backgroundColor: Colors.black,
            ),
            bottomNavigationBar: _actionBar(context, ctrl, primary, accent),
            body: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // ===== Header Card (ملف منفصل) =====
                AdminSettingsHeaderCard(
                  settings: settings,
                  primary: primary,
                  accent: accent,
                  onDraftChanged: (updated) => _onUpdate(ctrl, updated),
                ),

                const SizedBox(height: 12),

                AdminSettingsLanguageCard(
                  settings: settings,
                  accent: accent,
                  onDraftChanged: (updated) => _onUpdate(ctrl, updated),
                ),

                const SizedBox(height: 12),

                AdminSettingsLogoCard(
                  accent: accent,
                  onLogoRemoved: () {
                    _notify(context, t.removeLoginLogo, accent);
                  },
                ),

                const SizedBox(height: 12),

                AdminSettingsAttendanceCard(
                  settings: settings,
                  primary: primary,
                  accent: accent,
                  onDraftChanged: (updated) => _onUpdate(ctrl, updated),
                ),

                const SizedBox(height: 12),

                AdminSettingsValidationCard(
                  settings: settings,
                  primary: primary,
                  onDraftChanged: (updated) => _onUpdate(ctrl, updated),
                ),

                const SizedBox(height: 12),

                AdminSettingsThemeCard(
                  settings: settings,
                  primary: primary,
                  accent: accent,
                  palette: _palette,
                  onDraftChanged: (updated) => _onUpdate(ctrl, updated),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _actionBar(
    BuildContext context,
    SettingsDraftController ctrl,
    Color primary,
    Color accent,
  ) {
    final t = AppLocalizations.of(context);

    if (!ctrl.hasChanges && !_savedLocal) return const SizedBox.shrink();

    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
        decoration: const BoxDecoration(
          color: Color(0xFF0E0E0E),
          border: Border(top: BorderSide(color: Colors.white10)),
        ),
        child: Row(
          children: [
            if (!_savedLocal)
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    ctrl.saveDraft();
                    setState(() => _savedLocal = true);
                    _notify(context, t.saved, accent);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accent,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    t.save.toUpperCase(),
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ),
            if (_savedLocal)
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    await ctrl.apply();
                    setState(() => _savedLocal = false);
                    _notify(context, t.applied, primary);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    t.apply.toUpperCase(),
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _notify(BuildContext context, String text, Color glow) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.black,
        content: Text(text, style: const TextStyle(color: Colors.white)),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Color _hexToColor(String hex) {
    final cleaned = hex.replaceAll('#', '').trim();
    final value = int.parse('FF$cleaned', radix: 16);
    return Color(value);
  }
}
