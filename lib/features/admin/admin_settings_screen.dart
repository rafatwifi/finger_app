// lib/features/admin/admin_settings_screen.dart
// شاشة إعدادات الأدمن (تحكم مركزي) - تصميم Dark + Neon

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/models/app_settings_model.dart';
import '../../data/repositories/settings_repository.dart';
import '../../core/ui/login_logo_controller.dart';

class AdminSettingsScreen extends StatefulWidget {
  const AdminSettingsScreen({super.key});

  @override
  State<AdminSettingsScreen> createState() => _AdminSettingsScreenState();
}

class _AdminSettingsScreenState extends State<AdminSettingsScreen> {
  final _repo = SettingsRepository();

  // لوحة ألوان جاهزة بدون حزم إضافية
  static const _palette = <String>[
    '#FF6A00', // برتقالي ناري
    '#00FFAA', // نيون أخضر
    '#00B7FF', // أزرق نيون
    '#B100FF', // بنفسجي نيون
    '#FF2D55', // أحمر وردي
    '#FFD60A', // أصفر
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Admin Settings'),
        backgroundColor: Colors.black,
      ),
      body: StreamBuilder<AppSettingsModel>(
        stream: _repo.watch(),
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.orange),
            );
          }

          final settings = snap.data!;
          final primary = _hexToColor(settings.primaryColorHex);
          final accent = _hexToColor(settings.accentColorHex);

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _headerCard(primary, accent, settings),

              const SizedBox(height: 12),

              // ==============================
              // 🔽 Login Screen Logo (NEW)
              // ==============================
              _card(
                title: 'Login Screen Logo',
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.image_outlined,
                          color: Colors.white70),
                      title: const Text(
                        'Change login logo',
                        style: TextStyle(color: Colors.white),
                      ),
                      subtitle: const Text(
                        'Pick image with crop & rotate',
                        style: TextStyle(color: Colors.white54),
                      ),
                      onTap: () async {
                        await context
                            .read<LoginLogoController>()
                            .pickAndCropLogo(context); // ✅ التعديل الوحيد
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.delete_outline,
                          color: Colors.white70),
                      title: const Text(
                        'Remove login logo',
                        style: TextStyle(color: Colors.white),
                      ),
                      subtitle: const Text(
                        'Restore default fingerprint icon',
                        style: TextStyle(color: Colors.white54),
                      ),
                      onTap: () async {
                        await context.read<LoginLogoController>().clearLogo();
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // ===== باقي إعداداتك كما هي بدون أي تغيير =====

              _card(
                title: 'Time Format',
                child: Row(
                  children: [
                    Expanded(
                      child: _chipChoice(
                        label: '24H',
                        selected: settings.timeFormat == '24',
                        color: accent,
                        onTap: () =>
                            _repo.save(settings.copyWith(timeFormat: '24')),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _chipChoice(
                        label: '12H',
                        selected: settings.timeFormat == '12',
                        color: accent,
                        onTap: () =>
                            _repo.save(settings.copyWith(timeFormat: '12')),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              _card(
                title: 'Daily Scans Limit',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Max scans per day: ${settings.maxScansPerDay}',
                      style: const TextStyle(color: Colors.white70),
                    ),
                    Slider(
                      value: settings.maxScansPerDay.toDouble(),
                      min: 1,
                      max: 20,
                      divisions: 19,
                      activeColor: primary,
                      inactiveColor: Colors.white12,
                      onChanged: (v) async {
                        await _repo.save(
                          settings.copyWith(maxScansPerDay: v.round()),
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              _card(
                title: 'Validation Rules',
                child: Column(
                  children: [
                    _switchRow(
                      label: 'Require Supervisor Approval',
                      value: settings.requireSupervisor,
                      color: primary,
                      onChanged: (v) =>
                          _repo.save(settings.copyWith(requireSupervisor: v)),
                    ),
                    _switchRow(
                      label: 'Require Location',
                      value: settings.requireLocation,
                      color: primary,
                      onChanged: (v) =>
                          _repo.save(settings.copyWith(requireLocation: v)),
                    ),
                    _switchRow(
                      label: 'Require Biometric (Device)',
                      value: settings.requireBiometric,
                      color: primary,
                      onChanged: (v) =>
                          _repo.save(settings.copyWith(requireBiometric: v)),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              _card(
                title: 'Theme',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Primary Color',
                      style: TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 10),
                    _colorRow(
                      selectedHex: settings.primaryColorHex,
                      accent: accent,
                      onPick: (hex) =>
                          _repo.save(settings.copyWith(primaryColorHex: hex)),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Accent Color',
                      style: TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 10),
                    _colorRow(
                      selectedHex: settings.accentColorHex,
                      accent: accent,
                      onPick: (hex) =>
                          _repo.save(settings.copyWith(accentColorHex: hex)),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Logo size: ${settings.logoSize.toStringAsFixed(0)}',
                      style: const TextStyle(color: Colors.white70),
                    ),
                    Slider(
                      value: settings.logoSize,
                      min: 80,
                      max: 220,
                      divisions: 14,
                      activeColor: primary,
                      inactiveColor: Colors.white12,
                      onChanged: (v) =>
                          _repo.save(settings.copyWith(logoSize: v)),
                    ),
                    const SizedBox(height: 12),
                    _sloganEditor(
                      initial: settings.slogan,
                      primary: primary,
                      onSave: (txt) =>
                          _repo.save(settings.copyWith(slogan: txt)),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ===== جميع دوالك الأصلية بدون أي تغيير =====

  Widget _headerCard(Color primary, Color accent, AppSettingsModel s) {
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
                const Text(
                  'CONTROL CORE',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  s.slogan,
                  style: TextStyle(
                    color: accent.withOpacity(0.85),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Time: ${s.timeFormat}H  •  Scans/day: ${s.maxScansPerDay}',
                  style: const TextStyle(color: Colors.white60),
                ),
              ],
            ),
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
              letterSpacing: 1.0,
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
              letterSpacing: 1.2,
            ),
          ),
        ),
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
          child: Text(label, style: const TextStyle(color: Colors.white70)),
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
      runSpacing: 10,
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

  Widget _sloganEditor({
    required String initial,
    required Color primary,
    required ValueChanged<String> onSave,
  }) {
    final controller = TextEditingController(text: initial);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Slogan', style: TextStyle(color: Colors.white70)),
        const SizedBox(height: 10),
        TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Type slogan...',
            hintStyle: const TextStyle(color: Colors.white38),
            filled: true,
            fillColor: Colors.black,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Colors.white10),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: primary.withOpacity(0.8)),
            ),
          ),
          onSubmitted: (v) => onSave(v.trim().isEmpty ? initial : v.trim()),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: primary,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            onPressed: () {
              final v = controller.text.trim();
              onSave(v.isEmpty ? initial : v);
            },
            child: const Text(
              'SAVE SLOGAN',
              style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.2),
            ),
          ),
        ),
      ],
    );
  }

  Color _hexToColor(String hex) {
    final cleaned = hex.replaceAll('#', '').trim();
    final value = int.parse('FF$cleaned', radix: 16);
    return Color(value);
  }
}
