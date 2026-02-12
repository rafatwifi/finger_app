// lib/features/admin/admin_settings_screen.dart
// شاشة إعدادات الأدمن (تحكم مركزي)
//
// بعد التقسيم:
// - تم فصل كارت اللغة في ملف مستقل
// - تم فصل كارت لوغو تسجيل الدخول في ملف مستقل
// - تم فصل كارت الوقت + الحد اليومي في ملف مستقل
// - كل الميزات السابقة محفوظة 100%
// - SAVE و APPLY بدون تغيير

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/models/app_settings_model.dart';
import '../../data/repositories/settings_repository.dart';
import '../../l10n/app_localizations.dart';
import 'controller/settings_draft_controller.dart';
import 'widgets/admin_settings_attendance_card.dart';
import 'widgets/admin_settings_language_card.dart';
import 'widgets/admin_settings_logo_card.dart';

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
                _headerCard(context, ctrl, primary, accent, settings),
                const SizedBox(height: 12),

                // ===== Language Card (ملف منفصل) =====
                AdminSettingsLanguageCard(
                  settings: settings,
                  accent: accent,
                  onDraftChanged: (updated) => _onUpdate(ctrl, updated),
                ),

                const SizedBox(height: 12),

                // ===== Login Screen Logo (ملف منفصل) =====
                AdminSettingsLogoCard(
                  accent: accent,
                  onLogoRemoved: () {
                    _notify(context, t.removeLoginLogo, accent);
                  },
                ),

                const SizedBox(height: 12),

                // ===== Attendance Card (Time + Daily Limit) =====
                AdminSettingsAttendanceCard(
                  settings: settings,
                  primary: primary,
                  accent: accent,
                  onDraftChanged: (updated) => _onUpdate(ctrl, updated),
                ),

                const SizedBox(height: 12),

                _card(
                  title: t.validationRules,
                  child: Column(
                    children: [
                      _switchRow(
                        label: t.requireSupervisor,
                        value: settings.requireSupervisor,
                        color: primary,
                        onChanged: (v) => _onUpdate(
                          ctrl,
                          settings.copyWith(requireSupervisor: v),
                        ),
                      ),
                      _switchRow(
                        label: t.requireLocation,
                        value: settings.requireLocation,
                        color: primary,
                        onChanged: (v) => _onUpdate(
                          ctrl,
                          settings.copyWith(requireLocation: v),
                        ),
                      ),
                      _switchRow(
                        label: t.requireBiometric,
                        value: settings.requireBiometric,
                        color: primary,
                        onChanged: (v) => _onUpdate(
                          ctrl,
                          settings.copyWith(requireBiometric: v),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                _card(
                  title: t.theme,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        t.primaryColor,
                        style: const TextStyle(color: Colors.white70),
                      ),
                      const SizedBox(height: 10),
                      _colorRow(
                        selectedHex: settings.primaryColorHex,
                        accent: accent,
                        onPick: (hex) => _onUpdate(
                          ctrl,
                          settings.copyWith(primaryColorHex: hex),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        t.accentColor,
                        style: const TextStyle(color: Colors.white70),
                      ),
                      const SizedBox(height: 10),
                      _colorRow(
                        selectedHex: settings.accentColorHex,
                        accent: accent,
                        onPick: (hex) => _onUpdate(
                          ctrl,
                          settings.copyWith(accentColorHex: hex),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '${t.logoSize}: ${settings.logoSize.toStringAsFixed(0)}',
                        style: const TextStyle(color: Colors.white70),
                      ),
                      Slider(
                        value: settings.logoSize,
                        min: 80,
                        max: 220,
                        divisions: 14,
                        activeColor: primary,
                        inactiveColor: Colors.white12,
                        onChanged: (v) => _onUpdate(
                          ctrl,
                          settings.copyWith(logoSize: v),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ===== Action Bar (Styled) =====
  Widget _actionBar(
    BuildContext context,
    SettingsDraftController ctrl,
    Color primary,
    Color accent,
  ) {
    final t = AppLocalizations.of(context);

    // لا يظهر شيء إذا لا توجد تغييرات ولم يتم حفظ محلي
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

  // ===== Helpers =====
  Widget _card({required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF121212),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _switchRow({
    required String label,
    required bool value,
    required Color color,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(color: Colors.white70),
          ),
        ),
        Switch(value: value, activeColor: color, onChanged: onChanged),
      ],
    );
  }

  Widget _colorRow({
    required String selectedHex,
    required Color accent,
    required ValueChanged<String> onPick,
  }) {
    return Wrap(
      spacing: 10,
      children: _palette.map((hex) {
        final c = _hexToColor(hex);
        final selected = hex.toUpperCase() == selectedHex.toUpperCase();
        return InkWell(
          onTap: () => onPick(hex),
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: c,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: selected ? accent : Colors.black,
                width: selected ? 2 : 1,
              ),
              boxShadow: [
                BoxShadow(color: c.withOpacity(0.25), blurRadius: 12),
              ],
            ),
            child:
                selected ? const Icon(Icons.check, color: Colors.black) : null,
          ),
        );
      }).toList(),
    );
  }

  Color _hexToColor(String hex) {
    final cleaned = hex.replaceAll('#', '').trim();
    final value = int.parse('FF$cleaned', radix: 16);
    return Color(value);
  }

  // ===== Header with editable slogan =====
  Widget _headerCard(
    BuildContext context,
    SettingsDraftController ctrl,
    Color primary,
    Color accent,
    AppSettingsModel s,
  ) {
    final t = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
          colors: [primary.withOpacity(0.25), Colors.black],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: accent.withOpacity(0.35)),
      ),
      child: Row(
        children: [
          Container(
            width: s.logoSize * 0.45,
            height: s.logoSize * 0.45,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: accent.withOpacity(0.18),
              border: Border.all(color: accent.withOpacity(0.6)),
              boxShadow: [
                BoxShadow(color: accent.withOpacity(0.25), blurRadius: 18),
              ],
            ),
            child: Icon(Icons.shield, color: accent, size: s.logoSize * 0.22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t.controlCore,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        s.slogan,
                        style: TextStyle(
                          color: accent.withOpacity(0.85),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.edit, color: accent, size: 18),
                      onPressed: () => _editSlogan(context, ctrl, s),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _editSlogan(
    BuildContext context,
    SettingsDraftController ctrl,
    AppSettingsModel s,
  ) async {
    final t = AppLocalizations.of(context);
    final controller = TextEditingController(text: s.slogan);

    final result = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF121212),
        title: Text(
          t.editTitle,
          style: const TextStyle(color: Colors.white),
        ),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: t.title,
            hintStyle: const TextStyle(color: Colors.white38),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(t.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: Text(t.ok),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      _onUpdate(ctrl, s.copyWith(slogan: result));
    }
  }
}
