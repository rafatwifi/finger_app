// lib/features/admin/widgets/admin_settings_validation_card.dart
// هذا الملف مسؤول عن كارت قواعد التحقق داخل إعدادات الأدمن.
//
// الوظيفة:
// - عرض 3 سويتشات: المشرف / الموقع / البصمة
// - لا يحفظ أي شيء مباشرة
// - يرجّع نسخة Draft جديدة عبر onDraftChanged

import 'package:flutter/material.dart';

import '../../../data/models/app_settings_model.dart';
import '../../../l10n/app_localizations.dart';

class AdminSettingsValidationCard extends StatelessWidget {
  const AdminSettingsValidationCard({
    super.key,
    required this.settings,
    required this.primary,
    required this.onDraftChanged,
  });

  final AppSettingsModel settings;
  final Color primary;

  /// يرجّع نسخة settings جديدة (Draft) إلى الشاشة الأم
  final ValueChanged<AppSettingsModel> onDraftChanged;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);

    return _card(
      title: t.validationRules,
      child: Column(
        children: [
          _switchRow(
            label: t.requireSupervisor,
            value: settings.requireSupervisor,
            color: primary,
            onChanged: (v) => onDraftChanged(
              settings.copyWith(requireSupervisor: v),
            ),
          ),
          _switchRow(
            label: t.requireLocation,
            value: settings.requireLocation,
            color: primary,
            onChanged: (v) => onDraftChanged(
              settings.copyWith(requireLocation: v),
            ),
          ),
          _switchRow(
            label: t.requireBiometric,
            value: settings.requireBiometric,
            color: primary,
            onChanged: (v) => onDraftChanged(
              settings.copyWith(requireBiometric: v),
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
}
