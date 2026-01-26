// lib/features/admin/attendance_rules.dart
//
// شاشة إدارة قواعد البصمة (Attendance Rules) كاملة.
// - إضافة/تعديل/حذف Rule
// - تخزين مباشر في Firestore داخل collection: attendance_rules
// - بدون أي اعتماد على ملفات Models خارجية
//
// ملاحظة مهمة:
// هذا الملف لا يفرض القواعد على تسجيل الحضور بعد.
// هو فقط "لوحة إعدادات" لتكوين القواعد.
// تطبيق القواعد على بصمة الموظف يكون بالملف التالي لاحقاً (Attendance Engine).

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// نوع البصمة/الحدث داخل اليوم
enum RuleType { checkIn, checkOut, breakIn, breakOut }

extension RuleTypeX on RuleType {
  String get key {
    switch (this) {
      case RuleType.checkIn:
        return 'check_in';
      case RuleType.checkOut:
        return 'check_out';
      case RuleType.breakIn:
        return 'break_in';
      case RuleType.breakOut:
        return 'break_out';
    }
  }

  String get labelAr {
    switch (this) {
      case RuleType.checkIn:
        return 'دخول';
      case RuleType.checkOut:
        return 'خروج';
      case RuleType.breakIn:
        return 'استراحة دخول';
      case RuleType.breakOut:
        return 'استراحة خروج';
    }
  }

  static RuleType fromKey(String v) {
    switch (v) {
      case 'check_out':
        return RuleType.checkOut;
      case 'break_in':
        return RuleType.breakIn;
      case 'break_out':
        return RuleType.breakOut;
      case 'check_in':
      default:
        return RuleType.checkIn;
    }
  }
}

/// نموذج Rule داخل نفس الملف (بدون اعتماد خارجي)
class AttendanceRule {
  final String id;
  final String name;
  final RuleType type;
  final int startMinutes; // بداية الوقت بالدقائق من 00:00
  final int endMinutes; // نهاية الوقت بالدقائق من 00:00
  final List<int> days; // 1=Mon ... 7=Sun
  final int maxPerDay; // كم مرة مسموح باليوم لنفس rule
  final bool requireLocation; // هل نتحقق من الموقع
  final bool requireFace; // هل نتحقق من الوجه (لاحقاً)
  final bool enabled;

  AttendanceRule({
    required this.id,
    required this.name,
    required this.type,
    required this.startMinutes,
    required this.endMinutes,
    required this.days,
    required this.maxPerDay,
    required this.requireLocation,
    required this.requireFace,
    required this.enabled,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'type': type.key,
      'startMinutes': startMinutes,
      'endMinutes': endMinutes,
      'days': days,
      'maxPerDay': maxPerDay,
      'requireLocation': requireLocation,
      'requireFace': requireFace,
      'enabled': enabled,
      'updatedAt': FieldValue.serverTimestamp(),
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  Map<String, dynamic> toMapForUpdate() {
    return {
      'name': name,
      'type': type.key,
      'startMinutes': startMinutes,
      'endMinutes': endMinutes,
      'days': days,
      'maxPerDay': maxPerDay,
      'requireLocation': requireLocation,
      'requireFace': requireFace,
      'enabled': enabled,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  static AttendanceRule fromDoc(DocumentSnapshot doc) {
    final data = (doc.data() as Map<String, dynamic>? ?? {});
    return AttendanceRule(
      id: doc.id,
      name: (data['name'] ?? '').toString(),
      type: RuleTypeX.fromKey((data['type'] ?? 'check_in').toString()),
      startMinutes: _asInt(data['startMinutes'], 7 * 60),
      endMinutes: _asInt(data['endMinutes'], 17 * 60),
      days: _asIntList(data['days'], const [1, 2, 3, 4, 5]),
      maxPerDay: _asInt(data['maxPerDay'], 1),
      requireLocation: _asBool(data['requireLocation'], true),
      requireFace: _asBool(data['requireFace'], false),
      enabled: _asBool(data['enabled'], true),
    );
  }

  static int _asInt(dynamic v, int fallback) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    return fallback;
  }

  static bool _asBool(dynamic v, bool fallback) {
    if (v is bool) return v;
    if (v is String) {
      final s = v.toLowerCase();
      if (s == 'true') return true;
      if (s == 'false') return false;
    }
    return fallback;
  }

  static List<int> _asIntList(dynamic v, List<int> fallback) {
    if (v is List) {
      return v
          .map((e) {
            if (e is int) return e;
            if (e is num) return e.toInt();
            return 0;
          })
          .where((x) => x >= 1 && x <= 7)
          .toList();
    }
    return fallback;
  }
}

/// شاشة إدارة القواعد
class AttendanceRulesScreen extends StatefulWidget {
  const AttendanceRulesScreen({super.key});

  @override
  State<AttendanceRulesScreen> createState() => _AttendanceRulesScreenState();
}

class _AttendanceRulesScreenState extends State<AttendanceRulesScreen> {
  final _db = FirebaseFirestore.instance;
  final _col = FirebaseFirestore.instance.collection('attendance_rules');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Attendance Rules'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _openEditor(context, rule: null),
            tooltip: 'Add Rule',
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _col.orderBy('updatedAt', descending: true).snapshots(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.orange),
            );
          }

          final docs = snap.data?.docs ?? const [];
          if (docs.isEmpty) {
            return const Center(
              child: Text('No rules yet', style: TextStyle(color: Colors.grey)),
            );
          }

          final rules = docs.map(AttendanceRule.fromDoc).toList();

          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: rules.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, i) {
              final r = rules[i];
              return _RuleCard(
                rule: r,
                onToggle: (v) => _toggleEnabled(r.id, v),
                onEdit: () => _openEditor(context, rule: r),
                onDelete: () => _deleteRule(r.id),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _toggleEnabled(String id, bool v) async {
    try {
      await _col.doc(id).update({
        'enabled': v,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      _toast('Toggle failed: $e');
    }
  }

  Future<void> _deleteRule(String id) async {
    try {
      await _col.doc(id).delete();
      _toast('Deleted');
    } catch (e) {
      _toast('Delete failed: $e');
    }
  }

  Future<void> _openEditor(
    BuildContext context, {
    required AttendanceRule? rule,
  }) async {
    final res = await showModalBottomSheet<_EditorResult>(
      context: context,
      backgroundColor: const Color(0xFF111111),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _RuleEditor(initial: rule),
    );

    if (res == null) return;

    // حفظ rule جديدة أو تحديث الحالية
    try {
      if (rule == null) {
        // إنشاء Rule جديدة
        final doc = _db.collection('attendance_rules').doc();
        await doc.set(res.rule.toMap());
        _toast('Created');
      } else {
        // تحديث Rule موجودة
        await _col.doc(rule.id).update(res.rule.toMapForUpdate());
        _toast('Updated');
      }
    } catch (e) {
      _toast('Save failed: $e');
    }
  }

  void _toast(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
}

/// كارت عرض Rule
class _RuleCard extends StatelessWidget {
  final AttendanceRule rule;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final ValueChanged<bool> onToggle;

  const _RuleCard({
    required this.rule,
    required this.onEdit,
    required this.onDelete,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final t = _formatTimeRange(rule.startMinutes, rule.endMinutes);
    final d = _formatDays(rule.days);
    final req = [
      if (rule.requireLocation) 'Location',
      if (rule.requireFace) 'Face',
    ].join(' + ');

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2A2A2A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  rule.name.isEmpty ? '(Unnamed Rule)' : rule.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Switch(
                value: rule.enabled,
                onChanged: onToggle,
                activeColor: Colors.orange,
              ),
            ],
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _pill('${rule.type.labelAr}'),
              _pill(t),
              _pill(d),
              _pill('max/day: ${rule.maxPerDay}'),
              _pill(req.isEmpty ? 'No extra checks' : req),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              TextButton.icon(
                onPressed: onEdit,
                icon: const Icon(Icons.edit, color: Colors.orange),
                label: const Text(
                  'Edit',
                  style: TextStyle(color: Colors.orange),
                ),
              ),
              const SizedBox(width: 8),
              TextButton.icon(
                onPressed: onDelete,
                icon: const Icon(Icons.delete, color: Colors.redAccent),
                label: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.redAccent),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static Widget _pill(String t) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFF2A2A2A)),
      ),
      child: Text(t, style: const TextStyle(color: Colors.grey, fontSize: 12)),
    );
  }

  static String _formatTimeRange(int s, int e) {
    String fmt(int m) {
      final h = (m ~/ 60).toString().padLeft(2, '0');
      final mm = (m % 60).toString().padLeft(2, '0');
      return '$h:$mm';
    }

    return '${fmt(s)} → ${fmt(e)}';
  }

  static String _formatDays(List<int> days) {
    const map = {
      1: 'Mon',
      2: 'Tue',
      3: 'Wed',
      4: 'Thu',
      5: 'Fri',
      6: 'Sat',
      7: 'Sun',
    };
    final d = days.map((x) => map[x] ?? '?').join(',');
    return 'Days: $d';
  }
}

/// نتيجة محرر Rule (نرجع rule جاهزة للحفظ)
class _EditorResult {
  final AttendanceRule rule;
  _EditorResult(this.rule);
}

/// محرر Rule (Add/Edit)
class _RuleEditor extends StatefulWidget {
  final AttendanceRule? initial;
  const _RuleEditor({required this.initial});

  @override
  State<_RuleEditor> createState() => _RuleEditorState();
}

class _RuleEditorState extends State<_RuleEditor> {
  late final TextEditingController _name;
  RuleType _type = RuleType.checkIn;
  int _start = 7 * 60;
  int _end = 17 * 60;
  List<int> _days = [1, 2, 3, 4, 5];
  int _maxPerDay = 1;
  bool _requireLocation = true;
  bool _requireFace = false;
  bool _enabled = true;

  @override
  void initState() {
    super.initState();

    // تهيئة القيم لو هذا تعديل
    final r = widget.initial;
    _name = TextEditingController(text: r?.name ?? '');

    if (r != null) {
      _type = r.type;
      _start = r.startMinutes;
      _end = r.endMinutes;
      _days = List<int>.from(r.days);
      _maxPerDay = r.maxPerDay;
      _requireLocation = r.requireLocation;
      _requireFace = r.requireFace;
      _enabled = r.enabled;
    }
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 14,
        bottom: bottomPad + 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // عنوان النافذة
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.initial == null ? 'Add Rule' : 'Edit Rule',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: Colors.grey),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // اسم القاعدة
            _label('Rule name'),
            TextField(
              controller: _name,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'مثال: Morning In',
                hintStyle: const TextStyle(color: Colors.grey),
                filled: true,
                fillColor: const Color(0xFF1A1A1A),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // النوع
            _label('Type'),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF2A2A2A)),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<RuleType>(
                  value: _type,
                  dropdownColor: const Color(0xFF1A1A1A),
                  iconEnabledColor: Colors.orange,
                  items: RuleType.values.map((t) {
                    return DropdownMenuItem(
                      value: t,
                      child: Text(
                        t.labelAr,
                        style: const TextStyle(color: Colors.white),
                      ),
                    );
                  }).toList(),
                  onChanged: (v) {
                    if (v == null) return;
                    setState(() => _type = v);
                  },
                ),
              ),
            ),

            const SizedBox(height: 12),

            // الوقت
            _label('Time window'),
            Row(
              children: [
                Expanded(
                  child: _timeButton(
                    title: 'Start',
                    minutes: _start,
                    onPick: () async {
                      final picked = await _pickTime(context, _start);
                      if (picked == null) return;
                      setState(() => _start = picked);
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _timeButton(
                    title: 'End',
                    minutes: _end,
                    onPick: () async {
                      final picked = await _pickTime(context, _end);
                      if (picked == null) return;
                      setState(() => _end = picked);
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // الأيام
            _label('Days'),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: List.generate(7, (i) {
                final day = i + 1; // 1..7
                final selected = _days.contains(day);
                return ChoiceChip(
                  selectedColor: Colors.orange,
                  backgroundColor: const Color(0xFF1A1A1A),
                  labelStyle: TextStyle(
                    color: selected ? Colors.black : Colors.grey,
                  ),
                  label: Text(_dayLabel(day)),
                  selected: selected,
                  onSelected: (v) {
                    setState(() {
                      if (v) {
                        _days.add(day);
                        _days = _days.toSet().toList()..sort();
                      } else {
                        _days.remove(day);
                      }
                    });
                  },
                );
              }),
            ),

            const SizedBox(height: 12),

            // max/day
            _label('Max per day'),
            Row(
              children: [
                IconButton(
                  onPressed: () {
                    setState(() {
                      if (_maxPerDay > 1) _maxPerDay--;
                    });
                  },
                  icon: const Icon(
                    Icons.remove_circle_outline,
                    color: Colors.grey,
                  ),
                ),
                Text(
                  '$_maxPerDay',
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      if (_maxPerDay < 50) _maxPerDay++;
                    });
                  },
                  icon: const Icon(
                    Icons.add_circle_outline,
                    color: Colors.orange,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // متطلبات إضافية
            _label('Checks'),
            SwitchListTile(
              value: _requireLocation,
              onChanged: (v) => setState(() => _requireLocation = v),
              activeColor: Colors.orange,
              title: const Text(
                'Require location',
                style: TextStyle(color: Colors.white),
              ),
              subtitle: const Text(
                'يرفض إذا خارج المنطقة (لاحقاً)',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            SwitchListTile(
              value: _requireFace,
              onChanged: (v) => setState(() => _requireFace = v),
              activeColor: Colors.orange,
              title: const Text(
                'Require face verification',
                style: TextStyle(color: Colors.white),
              ),
              subtitle: const Text(
                'Face + Liveness (لاحقاً)',
                style: TextStyle(color: Colors.grey),
              ),
            ),

            const SizedBox(height: 6),

            // enabled
            SwitchListTile(
              value: _enabled,
              onChanged: (v) => setState(() => _enabled = v),
              activeColor: Colors.orange,
              title: const Text(
                'Enabled',
                style: TextStyle(color: Colors.white),
              ),
              subtitle: const Text(
                'تعطيل/تفعيل القاعدة',
                style: TextStyle(color: Colors.grey),
              ),
            ),

            const SizedBox(height: 14),

            // زر حفظ
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () {
                  final name = _name.text.trim();
                  if (name.isEmpty) {
                    _snack('اكتب اسم القاعدة');
                    return;
                  }
                  if (_days.isEmpty) {
                    _snack('حدد أيام العمل');
                    return;
                  }
                  if (_end <= _start) {
                    _snack('نهاية الوقت لازم تكون بعد البداية');
                    return;
                  }

                  // إنشاء Rule جاهزة
                  final rule = AttendanceRule(
                    id: widget.initial?.id ?? '',
                    name: name,
                    type: _type,
                    startMinutes: _start,
                    endMinutes: _end,
                    days: _days,
                    maxPerDay: _maxPerDay,
                    requireLocation: _requireLocation,
                    requireFace: _requireFace,
                    enabled: _enabled,
                  );

                  Navigator.pop(context, _EditorResult(rule));
                },
                child: const Text('Save'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(String t) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(t, style: const TextStyle(color: Colors.grey)),
    );
  }

  Widget _timeButton({
    required String title,
    required int minutes,
    required Future<void> Function() onPick,
  }) {
    final h = (minutes ~/ 60).toString().padLeft(2, '0');
    final m = (minutes % 60).toString().padLeft(2, '0');

    return InkWell(
      onTap: onPick,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF2A2A2A)),
        ),
        child: Row(
          children: [
            const Icon(Icons.schedule, color: Colors.orange),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                '$title: $h:$m',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<int?> _pickTime(BuildContext context, int currentMinutes) async {
    final initial = TimeOfDay(
      hour: currentMinutes ~/ 60,
      minute: currentMinutes % 60,
    );
    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Colors.orange,
              surface: Color(0xFF111111),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked == null) return null;
    return picked.hour * 60 + picked.minute;
  }

  String _dayLabel(int d) {
    switch (d) {
      case 1:
        return 'Mon';
      case 2:
        return 'Tue';
      case 3:
        return 'Wed';
      case 4:
        return 'Thu';
      case 5:
        return 'Fri';
      case 6:
        return 'Sat';
      case 7:
        return 'Sun';
      default:
        return '?';
    }
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
}
