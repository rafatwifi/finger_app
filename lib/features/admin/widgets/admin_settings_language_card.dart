// lib/features/admin/widgets/admin_settings_language_card.dart
// هذا الملف مسؤول عن Widget كارت اختيار اللغة داخل شاشة إعدادات الأدمن.
//
// الوظيفة:
// - عرض Dropdown لاختيار لغة التطبيق (System / AR / EN)
// - تغيير اللغة فورًا على MaterialApp عبر AppLocale
// - لا يحفظ أي شيء في Firestore
// - يرجّع نسخة settings جديدة إلى الشاشة الأم عبر onDraftChanged

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/localization/app_locale.dart';
import '../../../data/models/app_settings_model.dart';
import '../../../l10n/app_localizations.dart';

class AdminSettingsLanguageCard extends StatelessWidget {
  const AdminSettingsLanguageCard({
    super.key,
    required this.settings,
    required this.accent,
    required this.onDraftChanged,
  });

  final AppSettingsModel settings;
  final Color accent;

  /// يرجّع نسخة settings جديدة (Draft) إلى الشاشة الأم
  final ValueChanged<AppSettingsModel> onDraftChanged;

  static const String _langSystem = 'system';
  static const String _langAr = 'ar';
  static const String _langEn = 'en';

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);

    // null = system في Firestore
    final String current = settings.appLanguageCode ?? _langSystem;

    return _card(
      title: t.language,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: accent.withOpacity(0.35),
          ),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: current,
            dropdownColor: const Color(0xFF0E0E0E),
            iconEnabledColor: accent,
            isExpanded: true,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
            items: [
              DropdownMenuItem<String>(
                value: _langSystem,
                child: Text(t.system),
              ),
              const DropdownMenuItem<String>(
                value: _langAr,
                child: Text('AR'),
              ),
              const DropdownMenuItem<String>(
                value: _langEn,
                child: Text('EN'),
              ),
            ],
            onChanged: (v) {
              if (v == null) return;

              // تحويل قيمة UI إلى قيمة Firestore
              final String? firestoreValue = (v == _langSystem) ? null : v;

              // تطبيق اللغة فورًا على التطبيق
              context.read<AppLocale>().applyLanguageCode(firestoreValue);

              // تحديث الـ Draft فقط (بدون حفظ)
              onDraftChanged(
                settings.copyWith(appLanguageCode: firestoreValue),
              );
            },
          ),
        ),
      ),
    );
  }

  // ===== UI Helper =====
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
}
