// lib/features/admin/widgets/admin_settings_logo_card.dart
// هذا الملف مسؤول عن كارت إدارة لوغو شاشة تسجيل الدخول.
//
// الوظيفة:
// - عرض ExpansionTile لإدارة لوغو تسجيل الدخول
// - تغيير اللوغو
// - حذف اللوغو
// - لا يغير أي سلوك Draft أو Firestore
// - يرجع إشعار الحذف عبر callback

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/ui/login_logo_controller.dart';
import '../../../l10n/app_localizations.dart';

class AdminSettingsLogoCard extends StatelessWidget {
  const AdminSettingsLogoCard({
    super.key,
    required this.accent,
    required this.onLogoRemoved,
  });

  final Color accent;
  final VoidCallback onLogoRemoved;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);

    return _card(
      title: t.loginScreenLogo,
      child: ExpansionTile(
        collapsedIconColor: Colors.white70,
        iconColor: accent,
        title: Text(
          t.manage,
          style: const TextStyle(color: Colors.white),
        ),
        children: [
          ListTile(
            leading: const Icon(
              Icons.image_outlined,
              color: Colors.white70,
            ),
            title: Text(
              t.changeLoginLogo,
              style: const TextStyle(color: Colors.white),
            ),
            onTap: () async {
              await context
                  .read<LoginLogoController>()
                  .pickAndCropLogo(context);
            },
          ),
          ListTile(
            leading: const Icon(
              Icons.delete_outline,
              color: Colors.white70,
            ),
            title: Text(
              t.removeLoginLogo,
              style: const TextStyle(color: Colors.white),
            ),
            onTap: () async {
              await context.read<LoginLogoController>().clearLogo();
              onLogoRemoved();
            },
          ),
        ],
      ),
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
}
