// lib/features/admin/widgets/admin_settings_header_card.dart
// هذا الملف مسؤول عن الهيدر العلوي داخل شاشة إعدادات الأدمن.
//
// الوظيفة:
// - عرض عنوان Control Core
// - عرض Slogan الحالي
// - زر تعديل Slogan عبر Dialog
// - لا يحفظ مباشرة
// - يرجّع نسخة Draft جديدة عبر onDraftChanged
//
// ملاحظة:
// - تم نقل نفس UI والسلوك من admin_settings_screen.dart بدون أي تغيير.

import 'package:flutter/material.dart';

import '../../../data/models/app_settings_model.dart';
import '../../../l10n/app_localizations.dart';

class AdminSettingsHeaderCard extends StatelessWidget {
  const AdminSettingsHeaderCard({
    super.key,
    required this.settings,
    required this.primary,
    required this.accent,
    required this.onDraftChanged,
  });

  final AppSettingsModel settings;
  final Color primary;
  final Color accent;

  /// يرجّع نسخة settings جديدة (Draft) إلى الشاشة الأم
  final ValueChanged<AppSettingsModel> onDraftChanged;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final s = settings;

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
                      onPressed: () => _editSlogan(context, s),
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

  Future<void> _editSlogan(BuildContext context, AppSettingsModel s) async {
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
      onDraftChanged(s.copyWith(slogan: result));
    }
  }
}
