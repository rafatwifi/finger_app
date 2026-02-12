// lib/features/admin/widgets/admin_settings_theme_card.dart
// هذا الملف مسؤول عن كارت الثيم داخل شاشة إعدادات الأدمن.
//
// الوظيفة:
// - اختيار اللون الأساسي Primary Color
// - اختيار لون Accent
// - تغيير حجم الشعار Logo Size
// - لا يحفظ أي شيء مباشرة
// - يرجّع نسخة Draft جديدة عبر onDraftChanged
//
// ملاحظة مهمة:
// - تم نقل نفس UI والسلوك من admin_settings_screen.dart بدون أي تغيير.

import 'package:flutter/material.dart';

import '../../../data/models/app_settings_model.dart';
import '../../../l10n/app_localizations.dart';

class AdminSettingsThemeCard extends StatelessWidget {
  const AdminSettingsThemeCard({
    super.key,
    required this.settings,
    required this.primary,
    required this.accent,
    required this.palette,
    required this.onDraftChanged,
  });

  final AppSettingsModel settings;
  final Color primary;
  final Color accent;

  /// نفس palette الموجودة في الشاشة
  final List<String> palette;

  /// يرجّع نسخة settings جديدة (Draft) إلى الشاشة الأم
  final ValueChanged<AppSettingsModel> onDraftChanged;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);

    return _card(
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
            onPick: (hex) => onDraftChanged(
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
            onPick: (hex) => onDraftChanged(
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
            onChanged: (v) => onDraftChanged(
              settings.copyWith(logoSize: v),
            ),
          ),
        ],
      ),
    );
  }

  // ===== UI Helpers =====

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

  Widget _colorRow({
    required String selectedHex,
    required Color accent,
    required ValueChanged<String> onPick,
  }) {
    return Wrap(
      spacing: 10,
      children: palette.map((hex) {
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
}
