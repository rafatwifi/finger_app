// lib/features/admin/widgets/admin_settings_attendance_card.dart
// هذا الملف مسؤول عن:
// - كارت اختيار نظام الوقت (12H / 24H)
// - كارت تحديد الحد الأقصى للمسحات اليومية
// لا يوجد أي تغيير سلوك.
// يرجّع نسخة Draft جديدة عبر onDraftChanged.

import 'package:flutter/material.dart';

import '../../../data/models/app_settings_model.dart';
import '../../../l10n/app_localizations.dart';

class AdminSettingsAttendanceCard extends StatelessWidget {
  const AdminSettingsAttendanceCard({
    super.key,
    required this.settings,
    required this.primary,
    required this.accent,
    required this.onDraftChanged,
  });

  final AppSettingsModel settings;
  final Color primary;
  final Color accent;

  final ValueChanged<AppSettingsModel> onDraftChanged;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);

    return Column(
      children: [
        _card(
          title: t.timeFormat,
          child: Row(
            children: [
              Expanded(
                child: _chipChoice(
                  label: '24H',
                  selected: settings.timeFormat == '24',
                  color: accent,
                  onTap: () => onDraftChanged(
                    settings.copyWith(timeFormat: '24'),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _chipChoice(
                  label: '12H',
                  selected: settings.timeFormat == '12',
                  color: accent,
                  onTap: () => onDraftChanged(
                    settings.copyWith(timeFormat: '12'),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _card(
          title: t.dailyScansLimit,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${t.maxScansPerDay}: ${settings.maxScansPerDay}',
                style: const TextStyle(color: Colors.white70),
              ),
              Slider(
                value: settings.maxScansPerDay.toDouble(),
                min: 1,
                max: 20,
                divisions: 19,
                activeColor: primary,
                inactiveColor: Colors.white12,
                onChanged: (v) => onDraftChanged(
                  settings.copyWith(maxScansPerDay: v.round()),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

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

  Widget _chipChoice({
    required String label,
    required bool selected,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected ? color.withOpacity(0.18) : Colors.black,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? color.withOpacity(0.8) : Colors.white10,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: selected ? color : Colors.white70,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }
}
