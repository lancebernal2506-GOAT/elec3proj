import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'firebase_options.dart';

// ═════════ core ═════════

// ───────── Theme ─────────
const kRed = Color(0xFF6857D9); // gallery violet
const kDarkRed = Color(0xFF49359B);
const kBlack = Color(0xFFF6F5FA);
const kCard = Color(0xFFFFFFFF);
const kMuted = Color(0xFF5B596D);
const kError = Color(0xFFB3261E);
const kBorder = Color(0xFFE5E2ED);
const kCardRadius = 18.0;
// Gym-floor additions: dark "rubber mat" chrome + a gradient "floor tape" accent.
const kInk = Color(0xFF191433);
const kInkSoft = Color(0xFF2E2370);
const kPink = Color(0xFFD886A7);
const kLilac = Color(0xFFBDB2FF);
const kText = Color(0xFF25243A);
const kTape = LinearGradient(colors: [kRed, kPink]);

ThemeData appTheme() => ThemeData(
  brightness: Brightness.light,
  useMaterial3: true,
  scaffoldBackgroundColor: kBlack,
  colorScheme: const ColorScheme.light(
    primary: kRed,
    secondary: kPink,
    surface: kCard,
    onSurface: kText,
    error: kError,
  ),
  fontFamily: 'Manrope',
  textTheme: ThemeData.light().textTheme.apply(
    fontFamily: 'Manrope',
    bodyColor: kText,
    displayColor: kText,
  ),
  progressIndicatorTheme: const ProgressIndicatorThemeData(color: kRed),
  appBarTheme: const AppBarTheme(
    backgroundColor: kInk,
    foregroundColor: Colors.white,
    surfaceTintColor: Colors.transparent,
    elevation: 0,
    centerTitle: false,
    scrolledUnderElevation: 0,
    systemOverlayStyle: SystemUiOverlayStyle.light,
    titleTextStyle: TextStyle(
      fontFamily: 'Manrope',
      color: Colors.white,
      fontSize: 19,
      fontWeight: FontWeight.w700,
      letterSpacing: -.2,
    ),
  ),
  cardTheme: CardThemeData(
    color: kCard,
    elevation: 0,
    margin: EdgeInsets.zero,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(kCardRadius),
      side: const BorderSide(color: kBorder),
    ),
  ),
  drawerTheme: const DrawerThemeData(
    backgroundColor: kInk,
    surfaceTintColor: Colors.transparent,
    scrimColor: Color(0x990D1020),
  ),
  dialogTheme: DialogThemeData(
    backgroundColor: Colors.white,
    surfaceTintColor: Colors.transparent,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(kCardRadius),
    ),
    titleTextStyle: const TextStyle(
      fontFamily: 'Manrope',
      color: kText,
      fontSize: 19,
      fontWeight: FontWeight.w700,
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    border: const OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(14)),
    ),
    enabledBorder: const OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(14)),
      borderSide: BorderSide(color: kBorder),
    ),
    focusedBorder: const OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(14)),
      borderSide: BorderSide(color: kRed, width: 1.8),
    ),
    filled: true,
    fillColor: const Color(0xFFFBFAFD),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    floatingLabelStyle: const TextStyle(
      color: kRed,
      fontWeight: FontWeight.w700,
    ),
    prefixIconColor: WidgetStateColor.resolveWith(
      (states) => states.contains(WidgetState.focused) ? kRed : kMuted,
    ),
  ),
  navigationBarTheme: NavigationBarThemeData(
    backgroundColor: Colors.white,
    indicatorColor: kRed.withValues(alpha: .18),
    labelTextStyle: WidgetStateProperty.resolveWith(
      (states) => TextStyle(
        color: states.contains(WidgetState.selected) ? kRed : kMuted,
        fontSize: 12,
        fontWeight: states.contains(WidgetState.selected)
            ? FontWeight.w600
            : FontWeight.w400,
      ),
    ),
  ),
  navigationRailTheme: const NavigationRailThemeData(
    backgroundColor: kInk,
    indicatorColor: kRed,
    selectedIconTheme: IconThemeData(color: Colors.white),
    unselectedIconTheme: IconThemeData(color: Color(0xFF9B93C9)),
    selectedLabelTextStyle: TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.w700,
    ),
    unselectedLabelTextStyle: TextStyle(
      color: Color(0xFF9B93C9),
      fontWeight: FontWeight.w600,
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: kRed,
      foregroundColor: Colors.white,
      minimumSize: const Size.fromHeight(50),
      textStyle: const TextStyle(
        fontFamily: 'Manrope',
        fontWeight: FontWeight.w700,
        fontSize: 15,
        letterSpacing: .2,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 0,
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: kDarkRed,
      minimumSize: const Size(0, 44),
      side: const BorderSide(color: Color(0xFFD6D1F0), width: 1.3),
      textStyle: const TextStyle(
        fontFamily: 'Manrope',
        fontWeight: FontWeight.w700,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: kRed,
      textStyle: const TextStyle(
        fontFamily: 'Manrope',
        fontWeight: FontWeight.w700,
      ),
    ),
  ),
  dataTableTheme: const DataTableThemeData(
    headingRowColor: WidgetStatePropertyAll(Color(0xFFEFECFA)),
    headingTextStyle: TextStyle(
      fontWeight: FontWeight.w700,
      color: kText,
      fontSize: 13,
    ),
    dataTextStyle: TextStyle(fontSize: 13, color: kText),
    dividerThickness: .6,
    headingRowHeight: 46,
  ),
  snackBarTheme: SnackBarThemeData(
    backgroundColor: kInk,
    contentTextStyle: const TextStyle(
      fontFamily: 'Manrope',
      color: Colors.white,
      fontWeight: FontWeight.w600,
    ),
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
  ),
);

// ───────── Plans / formatting ─────────
class Plan {
  final double price;
  final int days;
  const Plan(this.price, this.days);
}

const plans = {
  'Daily': Plan(30, 1),
  'Weekly': Plan(195, 7),
  'Monthly': Plan(750, 30),
};
const expiringSoonDays = 3;
const newMemberWindowDays = 30;

String money(num n) =>
    NumberFormat.currency(symbol: '₱', decimalDigits: 2).format(n);
String fmtDate(DateTime d) => DateFormat('MMM d, y').format(d);
String fmtDateTime(DateTime d) => DateFormat('MMM d, y h:mm a').format(d);
String planLabel(String t) => '$t – ${money(plans[t]!.price)}';
DateTime dt(dynamic ts) => (ts as Timestamp).toDate();

String statusOf(Map<String, dynamic> m) {
  if (m['status'] == 'Frozen') return 'Frozen';
  final now = DateTime.now();
  final exp = dt(m['expirationDate']);
  if (exp.isBefore(now)) return 'Expired';
  if (exp.difference(now).inDays < expiringSoonDays) return 'Expiring Soon';
  return 'Active';
}

int daysLeft(DateTime exp) =>
    max(0, (exp.difference(DateTime.now()).inMinutes / 1440).ceil());

bool expiresWithinWeek(Map<String, dynamic> member, {DateTime? now}) {
  if (member['status'] == 'Frozen') return false;
  final today = now ?? DateTime.now();
  final expiration = dt(member['expirationDate']);
  return expiration.isAfter(today) &&
      !expiration.isAfter(today.add(const Duration(days: 7)));
}

// ───────── Shared UI helpers ─────────
final emailRe = RegExp(r'^[\w.+-]+@[\w-]+(\.[\w-]+)+$');

String? reqRule(String? v) =>
    (v == null || v.trim().isEmpty) ? 'Required' : null;
String? emailRule(String? v) =>
    (v == null || !emailRe.hasMatch(v.trim())) ? 'Enter a valid email' : null;
String? phoneRule(String? v) =>
    (v == null || !RegExp(r'^\+639\d{9}$').hasMatch(v.trim()))
    ? 'Enter +63 followed by 10 mobile digits'
    : null;

void snack(BuildContext c, String msg) =>
    ScaffoldMessenger.of(c).showSnackBar(SnackBar(content: Text(msg)));

Future<bool> confirm(BuildContext c, String title, String msg) async {
  final r = await showDialog<bool>(
    context: c,
    builder: (_) => AlertDialog(
      title: Text(title),
      content: Text(msg),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(c, false),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(c, true),
          child: const Text('Confirm'),
        ),
      ],
    ),
  );
  return r ?? false;
}

class EmptyState extends StatelessWidget {
  final String text;
  final IconData icon;
  const EmptyState(
    this.text, {
    this.icon = Icons.fitness_center_rounded,
    super.key,
  });
  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              color: kRed.withValues(alpha: .1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 34, color: kRed.withValues(alpha: .7)),
          ),
          const SizedBox(height: 14),
          Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(color: kMuted, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    ),
  );
}

class PageLoadingSkeleton extends StatefulWidget {
  const PageLoadingSkeleton({super.key});

  @override
  State<PageLoadingSkeleton> createState() => _PageLoadingSkeletonState();
}

class _PageLoadingSkeletonState extends State<PageLoadingSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 850),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Center(
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 560),
      child: AnimatedBuilder(
        animation: _pulse,
        builder: (context, _) => Opacity(
          opacity: .48 + _pulse.value * .38,
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.all(16),
            children: [
              for (var i = 0; i < 3; i++)
                Container(
                  height: i == 0 ? 104 : 82,
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: kCard,
                    borderRadius: BorderRadius.circular(kCardRadius),
                    border: Border.all(color: kBorder),
                  ),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        backgroundColor: Color(0xFFEAE8F0),
                        radius: 23,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: 13,
                              width: 170,
                              decoration: BoxDecoration(
                                color: const Color(0xFFEAE8F0),
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Container(
                              height: 10,
                              width: 120,
                              decoration: BoxDecoration(
                                color: const Color(0xFFEAE8F0),
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    ),
  );
}

Color statusColor(String status) => switch (status) {
  'Active' => const Color(0xFF17623A),
  'Expiring Soon' => const Color(0xFF814500),
  'Frozen' => const Color(0xFF075985),
  _ => const Color(0xFF9F1D1D),
};

class StatusChip extends StatelessWidget {
  final String status;
  const StatusChip(this.status, {super.key});
  @override
  Widget build(BuildContext context) {
    final c = statusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: c.withValues(alpha: .1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: c, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            status,
            style: TextStyle(
              color: c,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

/// Thin gradient strip — the "gym floor tape" used as the app's signature accent.
class _Tape extends StatelessWidget {
  final double height;
  const _Tape([this.height = 3]);
  @override
  Widget build(BuildContext context) => Container(
    height: height,
    decoration: const BoxDecoration(gradient: kTape),
  );
}

class SectionTitle extends StatelessWidget {
  final String text;
  const SectionTitle(this.text, {super.key});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 4, bottom: 10),
    child: Row(
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [kRed, kPink],
            ),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          text,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            letterSpacing: -.2,
          ),
        ),
      ],
    ),
  );
}

class _Initials extends StatelessWidget {
  final String name;
  const _Initials(this.name);
  @override
  Widget build(BuildContext context) {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    final text = parts.isEmpty
        ? '?'
        : (parts.length == 1 ? parts.first[0] : parts.first[0] + parts.last[0])
              .toUpperCase();
    return Container(
      width: 44,
      height: 44,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [kRed, kDarkRed],
        ),
        borderRadius: BorderRadius.circular(13),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 16,
        ),
      ),
    );
  }
}

/// Member card with a status-coloured stripe down the left edge.
class MemberCard extends StatelessWidget {
  final Color stripe;
  final Widget child;
  const MemberCard({required this.stripe, required this.child, super.key});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Material(
      color: kCard,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(kCardRadius),
        side: const BorderSide(color: kBorder),
      ),
      child: Stack(
        children: [
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            width: 5,
            child: ColoredBox(color: stripe),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(19, 14, 14, 12),
            child: child,
          ),
        ],
      ),
    ),
  );
}

class _MemberHeader extends StatelessWidget {
  final Map<String, dynamic> m;
  final String status;
  const _MemberHeader(this.m, this.status);
  @override
  Widget build(BuildContext context) => Row(
    children: [
      _Initials('${m['fullName'] ?? ''}'),
      const SizedBox(width: 12),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${m['fullName']}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                Text(
                  '#${m['memberId']}',
                  style: const TextStyle(
                    color: kRed,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${m['membershipType']}',
                  style: const TextStyle(
                    color: kMuted,
                    fontWeight: FontWeight.w600,
                    fontSize: 12.5,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      const SizedBox(width: 8),
      StatusChip(status),
    ],
  );
}

class _Info extends StatelessWidget {
  final IconData icon;
  final String text;
  const _Info(this.icon, this.text);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 5),
    child: Row(
      children: [
        Icon(icon, size: 16, color: kMuted),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 13.5),
          ),
        ),
      ],
    ),
  );
}

ButtonStyle tonalIcon() => IconButton.styleFrom(
  backgroundColor: kRed.withValues(alpha: .12),
  foregroundColor: kRed,
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
);

/// Energy-bar style countdown for the time left on a membership.
class _ExpiryBar extends StatelessWidget {
  final DateTime exp;
  final int planDays;
  final Color color;
  const _ExpiryBar({
    required this.exp,
    required this.planDays,
    required this.color,
  });
  @override
  Widget build(BuildContext context) {
    final left = daysLeft(exp);
    final v = planDays <= 0
        ? 0.0
        : (left / planDays).clamp(0.0, 1.0).toDouble();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Expires ${fmtDate(exp)}',
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
            ),
            Text(
              left == 1 ? '1 day left' : '$left days left',
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ],
        ),
        const SizedBox(height: 7),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: v,
            minHeight: 7,
            backgroundColor: color.withValues(alpha: .15),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}

/// Pass-style plan selector (Daily / Weekly / Monthly).
class _PlanPicker extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onChanged;
  const _PlanPicker({required this.selected, required this.onChanged});
  @override
  Widget build(BuildContext context) => Row(
    children: [
      for (final e in plans.entries) ...[
        Expanded(
          child: _PlanTile(
            e.key,
            e.value,
            e.key == selected,
            () => onChanged(e.key),
          ),
        ),
        if (e.key != plans.keys.last) const SizedBox(width: 8),
      ],
    ],
  );
}

class _PlanTile extends StatelessWidget {
  final String name;
  final Plan plan;
  final bool on;
  final VoidCallback onTap;
  const _PlanTile(this.name, this.plan, this.on, this.onTap);
  @override
  Widget build(BuildContext context) {
    final fg = on ? Colors.white : kText;
    return Material(
      color: on ? kRed : const Color(0xFFFBFAFD),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: on ? kDarkRed : kBorder,
              width: on ? 1.6 : 1,
            ),
          ),
          child: Column(
            children: [
              Text(
                name,
                style: TextStyle(
                  color: fg,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 4),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  money(plan.price),
                  style: TextStyle(
                    color: fg,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                plan.days == 1 ? '1 day' : '${plan.days} days',
                style: TextStyle(
                  color: on ? Colors.white70 : kMuted,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ───────── Firestore ─────────
final db = FirebaseFirestore.instance;

Future<void> recordChange(String action, {String? subject}) async {
  final actor = Auth.admin;
  if (actor == null) return;
  try {
    await db.collection('activity').add({
      'action': action,
      'subject': subject ?? '',
      'actorId': actor['id'],
      'actorName': actor['fullName'] ?? 'Administrator',
      'createdAt': Timestamp.now(),
    });
  } catch (_) {
    // Keep a successful business change successful if activity logging is unavailable.
  }
}

/// Auto-increment integer IDs (members, expenses) via transaction.
Future<int> nextId(String name) => db.runTransaction((tx) async {
  final ref = db.collection('counters').doc(name);
  final s = await tx.get(ref);
  final n = ((s.data()?['value'] ?? 0) as int) + 1;
  tx.set(ref, {'value': n});
  return n;
});

Future<void> addMember({
  required String name,
  required String contact,
  required String email,
  required String address,
  required String type,
}) async {
  final id = await nextId('members');
  final plan = plans[type]!;
  final now = DateTime.now();
  final exp = now.add(Duration(days: plan.days));
  final mRef = db.collection('members').doc();
  final b = db.batch();
  b.set(mRef, {
    'memberId': id,
    'fullName': name,
    'contact': contact,
    'email': email,
    'address': address,
    'membershipType': type,
    'status': 'Active',
    'expirationDate': Timestamp.fromDate(exp),
    'createdAt': Timestamp.fromDate(now),
  });
  b.set(db.collection('payments').doc(), {
    'memberDocId': mRef.id,
    'memberId': id,
    'memberName': name,
    'type': type,
    'amount': plan.price,
    'paymentDate': Timestamp.fromDate(now),
    'expirationDate': Timestamp.fromDate(exp),
  });
  await b.commit();
  await recordChange('Added member', subject: name);
}

Future<void> renewMember(
  String docId,
  Map<String, dynamic> m,
  String type,
) async {
  final plan = plans[type]!;
  final now = DateTime.now();
  final cur = dt(m['expirationDate']);
  final exp = (cur.isAfter(now) ? cur : now).add(Duration(days: plan.days));
  final b = db.batch();
  b.update(db.collection('members').doc(docId), {
    'membershipType': type,
    'expirationDate': Timestamp.fromDate(exp),
  });
  b.set(db.collection('payments').doc(), {
    'memberDocId': docId,
    'memberId': m['memberId'],
    'memberName': m['fullName'],
    'type': type,
    'amount': plan.price,
    'paymentDate': Timestamp.fromDate(now),
    'expirationDate': Timestamp.fromDate(exp),
  });
  await b.commit();
  await recordChange('Renewed membership', subject: m['fullName']);
}

Future<void> renewMemberFlow(
  BuildContext context,
  String docId,
  Map<String, dynamic> member,
) async {
  if (member['status'] == 'Frozen') {
    snack(context, 'Unfreeze this member before renewing.');
    return;
  }
  var type = member['membershipType'] as String? ?? 'Monthly';
  final confirmRenewal = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (dialogContext, setDialogState) => AlertDialog(
        title: Text('Renew ${member['fullName']}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Choose a membership plan. This records the renewal in FitCore.',
            ),
            const SizedBox(height: 16),
            _PlanPicker(
              selected: type,
              onChanged: (value) => setDialogState(() => type = value),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text('Confirm ${money(plans[type]!.price)}'),
          ),
        ],
      ),
    ),
  );
  if (confirmRenewal != true) return;
  try {
    await renewMember(docId, member, type);
    if (context.mounted) snack(context, 'Membership renewed.');
  } catch (_) {
    if (context.mounted) {
      snack(
        context,
        'Renewal could not be saved. Check your connection and try again.',
      );
    }
  }
}

// ───────── Firebase Authentication + admin profile ─────────
class Auth {
  static Map<String, dynamic>? admin;
  static final FirebaseAuth _firebase = FirebaseAuth.instance;
  static Future<void>? _googleInitialization;
  static const _googleWebClientId =
      '65173926856-8ki6s3qdvr384tcnrotgu9c62pouh82d.apps.googleusercontent.com';
  static const _googleAppleClientId =
      '65173926856-4ij69cucgomh071p0pmhddmik7ase17l.apps.googleusercontent.com';

  static Future<String?> loginWithGoogle({required bool rememberMe}) async {
    try {
      UserCredential credential;
      if (kIsWeb) {
        credential = await _firebase.signInWithPopup(GoogleAuthProvider());
      } else if (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS ||
          defaultTargetPlatform == TargetPlatform.macOS) {
        _googleInitialization ??= GoogleSignIn.instance.initialize(
          clientId:
              defaultTargetPlatform == TargetPlatform.iOS ||
                  defaultTargetPlatform == TargetPlatform.macOS
              ? _googleAppleClientId
              : null,
          serverClientId: _googleWebClientId,
        );
        await _googleInitialization;
        final googleUser = await GoogleSignIn.instance.authenticate();
        final idToken = googleUser.authentication.idToken;
        if (idToken == null) {
          return 'Google did not return an authentication token. Check OAuth client setup.';
        }
        credential = await _firebase.signInWithCredential(
          GoogleAuthProvider.credential(idToken: idToken),
        );
      } else {
        return 'Google sign-in is not available on this platform.';
      }

      final user = credential.user;
      if (user == null || user.email == null) {
        await _firebase.signOut();
        return 'Google did not provide an email address for this account.';
      }
      final profileRef = db.collection('admins').doc(user.uid);
      await db.runTransaction((transaction) async {
        final profileDoc = await transaction.get(profileRef);
        if (profileDoc.exists) return;

        final email = user.email!.trim();
        final emailName = email.split('@').first;
        final displayName = user.displayName?.trim();
        final fullName = displayName == null || displayName.isEmpty
            ? emailName
            : displayName;
        final username = 'google_${user.uid.substring(0, 8)}';
        transaction.set(profileRef, {
          'fullName': fullName,
          'email': email,
          'emailLower': email.toLowerCase(),
          'username': username,
          'usernameLower': username,
          'authProvider': 'google',
          'createdAt': FieldValue.serverTimestamp(),
        });
      });
      final savedProfile = await profileRef.get();
      if (!savedProfile.exists) {
        await _firebase.signOut();
        return 'Could not create your account profile. Please try again.';
      }
      admin = {...savedProfile.data()!, 'id': savedProfile.id};
      final preferences = await SharedPreferences.getInstance();
      if (rememberMe) {
        await preferences.setString('adminId', user.uid);
      } else {
        await preferences.remove('adminId');
      }
      return null;
    } on FirebaseAuthException catch (error) {
      if (error.code == 'account-exists-with-different-credential') {
        return 'An account already exists with this email. Log in with that method first.';
      }
      if (error.code == 'operation-not-allowed') {
        return 'Google sign-in is not enabled for this Firebase project.';
      }
      if (error.code == 'network-request-failed') {
        return 'Network error. Check your connection and try again.';
      }
      return 'Google sign-in failed. Please try again.';
    } on FirebaseException catch (error) {
      if (error.code == 'permission-denied') {
        return 'Google sign-in succeeded, but Firestore rules blocked account setup.';
      }
      return 'Google sign-in succeeded, but the account profile could not be saved.';
    } catch (error) {
      final message = error.toString().toLowerCase();
      if (message.contains('cancel')) return 'Google sign-in was canceled.';
      return 'Google sign-in failed. Check the Google OAuth setup and try again.';
    }
  }

  static String _hash(String pw, String salt) {
    List<int> h = utf8.encode('$salt$pw');
    for (var i = 0; i < 2000; i++) {
      h = sha256.convert([...h, ...utf8.encode(salt)]).bytes;
    }
    return base64.encode(h);
  }

  static Future<bool> restore() async {
    try {
      final p = await SharedPreferences.getInstance();
      final id = p.getString('adminId');
      final user = _firebase.currentUser;
      if (id == null) {
        if (user != null) await _firebase.signOut();
        return false;
      }
      if (user == null || user.uid != id) {
        await p.remove('adminId');
        return false;
      }
      final d = await db.collection('admins').doc(id).get();
      if (!d.exists) {
        await p.remove('adminId');
        await _firebase.signOut();
        return false;
      }
      final profile = Map<String, dynamic>.from(d.data()!);
      // Firebase only changes an email address after its verification link is
      // opened. Sync Firestore once the verified address is used to sign in.
      if (user.email != null &&
          profile['emailLower'] != user.email!.toLowerCase()) {
        await d.reference.update({
          'email': user.email,
          'emailLower': user.email!.toLowerCase(),
          'pendingEmail': FieldValue.delete(),
        });
        profile['email'] = user.email;
        profile['emailLower'] = user.email!.toLowerCase();
        profile.remove('pendingEmail');
      }
      admin = {...profile, 'id': d.id};
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Returns an error message, or null on success.
  static Future<String?> register(
    String name,
    String email,
    String username,
    String pw,
  ) async {
    return 'Administrator registration is managed by the FitCore app owner.';
  }

  static Future<QueryDocumentSnapshot<Map<String, dynamic>>?> _findLegacyAdmin(
    String identifier,
  ) async {
    final key = identifier.trim().toLowerCase();
    final admins = db.collection('admins');
    final searches = <Future<QuerySnapshot<Map<String, dynamic>>>>[];
    if (key.contains('@')) {
      searches.add(admins.where('emailLower', isEqualTo: key).limit(5).get());
      searches.add(admins.where('email', isEqualTo: key).limit(5).get());
    } else {
      searches.add(
        admins.where('usernameLower', isEqualTo: key).limit(5).get(),
      );
      searches.add(
        admins.where('username', isEqualTo: identifier.trim()).limit(5).get(),
      );
    }

    for (final search in searches) {
      for (final document in (await search).docs) {
        final data = document.data();
        if (data['passwordHash'] is String && data['salt'] is String) {
          return document;
        }
      }
    }
    return null;
  }

  static Future<String?> activateAccountWithPassword(
    String email,
    String newPassword,
  ) async {
    if (newPassword.length < 6) {
      return 'Choose a password with at least 6 characters.';
    }
    final normalizedEmail = email.trim().toLowerCase();
    User? firebaseUser;
    var createdAccount = false;
    var profileSaved = false;
    try {
      final profile = await _findLegacyAdmin(normalizedEmail);
      if (profile == null) {
        return 'No account with saved credentials was found for this email.';
      }

      UserCredential credential;
      try {
        credential = await _firebase.createUserWithEmailAndPassword(
          email: normalizedEmail,
          password: newPassword,
        );
        createdAccount = true;
      } on FirebaseAuthException catch (error) {
        if (error.code != 'email-already-in-use') rethrow;
        try {
          // If the same password already works in Firebase, finish migrating
          // the saved admin profile. Otherwise the Gmail reset route is needed.
          credential = await _firebase.signInWithEmailAndPassword(
            email: normalizedEmail,
            password: newPassword,
          );
        } on FirebaseAuthException {
          return 'This email already has a Firebase account. Use the Gmail reset option to change its password.';
        }
      }

      firebaseUser = credential.user;
      if (firebaseUser == null) {
        return 'Could not create the email/password account. Please try again.';
      }

      final upgraded = Map<String, dynamic>.from(profile.data())
        ..['passwordHash'] = FieldValue.delete()
        ..['salt'] = FieldValue.delete()
        ..['email'] = normalizedEmail
        ..['emailLower'] = normalizedEmail;
      final batch = db.batch();
      batch.set(
        db.collection('admins').doc(firebaseUser.uid),
        upgraded,
        SetOptions(merge: true),
      );
      if (profile.id != firebaseUser.uid) batch.delete(profile.reference);
      await batch.commit();
      profileSaved = true;
      return null;
    } on FirebaseAuthException catch (error) {
      switch (error.code) {
        case 'invalid-email':
          return 'Enter a valid email address.';
        case 'weak-password':
          return 'Choose a password with at least 6 characters.';
        case 'operation-not-allowed':
          return 'Email/password sign-in is not enabled in Firebase.';
        case 'network-request-failed':
          return 'Network error. Check your connection and try again.';
        default:
          return 'Could not activate this email/password account. Please try again.';
      }
    } catch (_) {
      return 'Could not activate this email/password account. Please try again.';
    } finally {
      if (firebaseUser != null) {
        if (createdAccount && !profileSaved) {
          try {
            await firebaseUser.delete();
          } catch (_) {}
        }
        try {
          await _firebase.signOut();
        } catch (_) {}
      }
    }
  }

  static Future<String?> sendGmailPasswordReset(String email) async {
    final normalizedEmail = email.trim().toLowerCase();
    if (!emailRe.hasMatch(normalizedEmail)) {
      return 'Enter a valid Gmail address.';
    }
    if (!normalizedEmail.endsWith('@gmail.com')) {
      return 'Enter an address ending in @gmail.com.';
    }
    try {
      await _firebase.sendPasswordResetEmail(email: normalizedEmail);
      return null;
    } on FirebaseAuthException catch (error) {
      switch (error.code) {
        case 'invalid-email':
          return 'Enter a valid Gmail address.';
        case 'user-not-found':
          return 'No Firebase account was found for this Gmail address.';
        case 'too-many-requests':
          return 'Too many requests. Please wait and try again.';
        case 'network-request-failed':
          return 'Network error. Check your connection and try again.';
        default:
          return 'Could not send the reset email. Please try again.';
      }
    } catch (_) {
      return 'Could not send the reset email. Please try again.';
    }
  }

  static Future<String?> login(
    String id,
    String pw, {
    required bool rememberMe,
  }) async {
    const generic = 'Invalid username/email or password.';
    final k = id.trim().toLowerCase();
    try {
      var email = k;
      var legacyProfile = await db
          .collection('admins')
          .where('emailLower', isEqualTo: k)
          .limit(1)
          .get();
      if (legacyProfile.docs.isEmpty && k.contains('@')) {
        legacyProfile = await db
            .collection('admins')
            .where('email', isEqualTo: k)
            .limit(1)
            .get();
      }
      if (!k.contains('@')) {
        var byUsername = await db
            .collection('admins')
            .where('usernameLower', isEqualTo: k)
            .limit(1)
            .get();
        if (byUsername.docs.isEmpty) {
          byUsername = await db
              .collection('admins')
              .where('username', isEqualTo: id.trim())
              .limit(1)
              .get();
        }
        if (byUsername.docs.isEmpty) return generic;
        final usernameProfile = byUsername.docs.first.data();
        email =
            (usernameProfile['pendingEmail'] ??
                    usernameProfile['email'] as String)
                .toString()
                .trim()
                .toLowerCase();
        legacyProfile = byUsername;
      }

      UserCredential credential;
      try {
        credential = await _firebase.signInWithEmailAndPassword(
          email: email,
          password: pw,
        );
      } on FirebaseAuthException catch (error) {
        // Older accounts may have salted database credentials. Upgrade a
        // matching account to Firebase Authentication on successful login.
        final profile = legacyProfile.docs.isNotEmpty
            ? legacyProfile.docs.first
            : null;
        final old = profile?.data();
        if (old == null ||
            old['passwordHash'] == null ||
            old['salt'] == null ||
            _hash(pw, old['salt'] as String) != old['passwordHash']) {
          return _authError(error);
        }
        try {
          credential = await _firebase.createUserWithEmailAndPassword(
            email: email,
            password: pw,
          );
          final upgraded = Map<String, dynamic>.from(old)
            ..remove('passwordHash')
            ..remove('salt')
            ..['email'] = email
            ..['emailLower'] = email;
          await db.collection('admins').doc(credential.user!.uid).set(upgraded);
          await profile!.reference.delete();
        } on FirebaseAuthException catch (migrationError) {
          return _authError(migrationError);
        }
      }

      final user = credential.user;
      if (user == null) return generic;
      final d = await db.collection('admins').doc(user.uid).get();
      if (!d.exists) {
        await _firebase.signOut();
        return 'This account does not have an administrator profile.';
      }
      admin = {...d.data()!, 'id': d.id};
      final p = await SharedPreferences.getInstance();
      if (rememberMe) {
        await p.setString('adminId', user.uid);
      } else {
        await p.remove('adminId');
      }
      return null;
    } catch (_) {
      return 'Something went wrong. Please try again.';
    }
  }

  static Future<void> logout() async {
    admin = null;
    final p = await SharedPreferences.getInstance();
    await p.remove('adminId');
    await _firebase.signOut();
  }

  /// Updates an administrator's Firebase credentials and Firestore profile.
  /// The current password is required so profile and credential changes are
  /// protected by Firebase's recent-login requirement.
  static Future<String?> updateAccount({
    required String fullName,
    required String username,
    required String email,
    required String currentPassword,
    String? newPassword,
  }) async {
    final user = _firebase.currentUser;
    final uid = user?.uid;
    if (user == null || uid == null || user.email == null) {
      return 'Your session has expired. Please log in again.';
    }
    final normalizedEmail = email.trim().toLowerCase();
    final normalizedUsername = username.trim().toLowerCase();
    if (!emailRe.hasMatch(normalizedEmail)) {
      return 'Enter a valid email address.';
    }
    if (normalizedUsername.length < 3) {
      return 'Username must be at least 3 characters.';
    }
    if (fullName.trim().isEmpty) return 'Enter your name.';
    if (newPassword != null && newPassword.length < 6) {
      return 'Choose a stronger password (at least 6 characters).';
    }
    try {
      final matchingEmail = await db
          .collection('admins')
          .where('emailLower', isEqualTo: normalizedEmail)
          .limit(1)
          .get();
      if (matchingEmail.docs.any((doc) => doc.id != uid)) {
        return 'This email is already used by another administrator.';
      }
      final matchingUsername = await db
          .collection('admins')
          .where('usernameLower', isEqualTo: normalizedUsername)
          .limit(1)
          .get();
      if (matchingUsername.docs.any((doc) => doc.id != uid)) {
        return 'That username is already taken.';
      }

      await user.reauthenticateWithCredential(
        EmailAuthProvider.credential(
          email: user.email!,
          password: currentPassword,
        ),
      );
      final changingEmail = normalizedEmail != user.email!.toLowerCase();
      if (changingEmail) await user.verifyBeforeUpdateEmail(normalizedEmail);
      if (newPassword != null && newPassword.isNotEmpty) {
        await user.updatePassword(newPassword);
      }
      final profile = {
        'fullName': fullName.trim(),
        'email': changingEmail ? user.email : normalizedEmail,
        'emailLower': changingEmail
            ? user.email!.toLowerCase()
            : normalizedEmail,
        'pendingEmail': changingEmail ? normalizedEmail : FieldValue.delete(),
        'username': username.trim(),
        'usernameLower': normalizedUsername,
      };
      await db.collection('admins').doc(uid).update(profile);
      admin = {...?admin, ...profile, 'id': uid};
      if (!changingEmail) admin!.remove('pendingEmail');
      return null;
    } on FirebaseAuthException catch (error) {
      switch (error.code) {
        case 'wrong-password':
        case 'invalid-credential':
          return 'The current password is incorrect.';
        case 'requires-recent-login':
          return 'Please enter your current password and try again.';
        case 'email-already-in-use':
          return 'This email is already used by another administrator.';
        case 'invalid-email':
          return 'Enter a valid email address.';
        case 'weak-password':
          return 'Choose a stronger password (at least 6 characters).';
        case 'network-request-failed':
          return 'Network error. Check your connection and try again.';
        default:
          return 'Could not update your account. Please try again.';
      }
    } catch (_) {
      return 'Could not save your profile. Your sign-in details may have updated; please retry or log in again.';
    }
  }

  static String _authError(
    FirebaseAuthException error, {
    bool registering = false,
  }) {
    switch (error.code) {
      case 'email-already-in-use':
        return registering
            ? 'This email is already registered. Use a different email or log in.'
            : 'Invalid username/email or password.';
      case 'invalid-email':
        return 'Enter a valid email address.';
      case 'weak-password':
        return 'Choose a stronger password (at least 6 characters).';
      case 'user-disabled':
        return 'This account has been disabled. Contact an administrator.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Invalid username/email or password.';
      case 'too-many-requests':
        return 'Too many attempts. Please wait and try again.';
      case 'operation-not-allowed':
        return 'Email/password sign-in is not enabled in Firebase.';
      case 'network-request-failed':
        return 'Network error. Check your connection and try again.';
      default:
        return registering
            ? 'Could not create your account. Please try again.'
            : 'Could not sign in. Please try again.';
    }
  }
}

// ═════════ auth_pages ═════════

class _AuthFrame extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _AuthFrame({required this.title, required this.children});
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: kInk,
    body: Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [kInk, kInkSoft],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -50,
            bottom: -30,
            child: Transform.rotate(
              angle: -.35,
              child: Icon(
                Icons.fitness_center_rounded,
                size: 300,
                color: Colors.white.withValues(alpha: .04),
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Column(
                    children: [
                      Container(
                        width: 68,
                        height: 68,
                        decoration: BoxDecoration(
                          gradient: kTape,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(
                          Icons.fitness_center_rounded,
                          size: 36,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        'FitCore',
                        style: TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: -.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        title,
                        style: const TextStyle(
                          color: kLilac,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Container(
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(kCardRadius),
                        ),
                        child: Column(
                          children: [
                            const _Tape(4),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(
                                20,
                                20,
                                20,
                                12,
                              ),
                              child: Column(children: children),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

PageRouteBuilder<T> _authFadeRoute<T>(Widget page) => PageRouteBuilder<T>(
  transitionDuration: const Duration(milliseconds: 240),
  pageBuilder: (_, animation, secondaryAnimation) => page,
  transitionsBuilder: (_, animation, secondaryAnimation, child) {
    final curved = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutCubic,
    );
    return FadeTransition(
      opacity: curved,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, .025),
          end: Offset.zero,
        ).animate(curved),
        child: child,
      ),
    );
  },
);

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _form = GlobalKey<FormState>();
  final idC = TextEditingController();
  final pwC = TextEditingController();
  bool busy = false, hide = true;
  bool rememberMe = true;
  String? error, credentialError;

  @override
  void dispose() {
    idC.dispose();
    pwC.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_form.currentState!.validate()) return;
    setState(() {
      busy = true;
      error = null;
      credentialError = null;
    });
    final err = await Auth.login(idC.text, pwC.text, rememberMe: rememberMe);
    if (!mounted) return;
    if (err != null) {
      setState(() {
        busy = false;
        if (err == 'Invalid username/email or password.') {
          credentialError = err;
        } else {
          error = err;
        }
      });
      return;
    }
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomeShell()),
    );
  }

  Future<void> _googleLogin() async {
    setState(() {
      busy = true;
      error = null;
      credentialError = null;
    });
    final err = await Auth.loginWithGoogle(rememberMe: rememberMe);
    if (!mounted) return;
    if (err != null) {
      setState(() {
        busy = false;
        error = err;
      });
      return;
    }
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomeShell()),
    );
  }

  Future<void> _forgotPassword() async {
    final email = await Navigator.of(context).push<String>(
      _authFadeRoute<String>(
        ForgotPasswordPage(
          initialEmail: idC.text.contains('@') ? idC.text.trim() : '',
        ),
      ),
    );
    if (email != null && mounted) {
      setState(() {
        idC.text = email;
        pwC.clear();
      });
      snack(
        context,
        'Request complete. Use your new password or follow the Gmail reset link.',
      );
    }
  }

  @override
  Widget build(BuildContext context) => _AuthFrame(
    title: 'Admin Login',
    children: [
      Form(
        key: _form,
        child: Column(
          children: [
            TextFormField(
              controller: idC,
              decoration: const InputDecoration(
                labelText: 'Username or Email',
                prefixIcon: Icon(Icons.person_outline),
              ),
              validator: reqRule,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: pwC,
              obscureText: hide,
              decoration: InputDecoration(
                labelText: 'Password',
                prefixIcon: const Icon(Icons.lock_outline),
                errorText: credentialError,
                suffixIcon: IconButton(
                  icon: Icon(
                    hide
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                  onPressed: () => setState(() => hide = !hide),
                ),
              ),
              validator: reqRule,
              onChanged: (_) => setState(() => credentialError = null),
              onFieldSubmitted: (_) => _login(),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: busy ? null : _forgotPassword,
                child: const Text('Forgot password?'),
              ),
            ),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              value: rememberMe,
              onChanged: (value) => setState(() => rememberMe = value ?? false),
              title: const Text('Remember me'),
              controlAffinity: ListTileControlAffinity.leading,
            ),
            if (error != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFEDEA),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    error!,
                    style: const TextStyle(
                      color: Color(0xFF8E1B16),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: busy ? null : _login,
              child: busy
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Login'),
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: busy ? null : _googleLogin,
              icon: const Icon(Icons.account_circle_outlined),
              label: const Text('Continue with Google'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
                side: const BorderSide(color: Color(0xFFE3E0EB)),
                foregroundColor: kText,
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

class ForgotPasswordPage extends StatefulWidget {
  final String initialEmail;

  const ForgotPasswordPage({this.initialEmail = '', super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

enum _PasswordResetMethod { normalEmail, gmail }

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _form = GlobalKey<FormState>();
  late final TextEditingController _emailController;
  final _passwordController = TextEditingController();
  _PasswordResetMethod _method = _PasswordResetMethod.normalEmail;
  bool _busy = false;
  bool _complete = false;
  bool _hidePassword = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.initialEmail);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    setState(() {
      _busy = true;
      _error = null;
    });

    final email = _emailController.text.trim().toLowerCase();
    final error = _method == _PasswordResetMethod.gmail
        ? await Auth.sendGmailPasswordReset(email)
        : await Auth.activateAccountWithPassword(
            email,
            _passwordController.text,
          );
    if (!mounted) return;
    setState(() {
      _busy = false;
      _error = error;
      _complete = error == null;
    });
  }

  void _backToLogin() {
    Navigator.of(context).pop(_emailController.text.trim());
  }

  @override
  Widget build(BuildContext context) => _AuthFrame(
    title: 'Reset password',
    children: [
      if (_complete) ...[
        const SizedBox(height: 16),
        Icon(
          _method == _PasswordResetMethod.gmail
              ? Icons.mark_email_read_outlined
              : Icons.check_circle_outline_rounded,
          size: 64,
          color: kRed,
        ),
        const SizedBox(height: 18),
        Text(
          _method == _PasswordResetMethod.gmail
              ? 'Check your Gmail'
              : 'Account ready',
          style: Theme.of(context).textTheme.titleLarge
              ?.copyWith(color: kText, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 10),
        Text(
          _method == _PasswordResetMethod.gmail
              ? 'If this address belongs to a Firebase email and password account, '
                    'a reset link was sent. Check your inbox and spam folder.'
              : 'Your email and password account is ready. Sign in with this '
                    'email and your new password.',
          textAlign: TextAlign.center,
          style: const TextStyle(color: kMuted, height: 1.5),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: _backToLogin,
          child: const Text('Back to login'),
        ),
      ] else ...[
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: _busy ? null : () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back_rounded),
            label: const Text('Back to login'),
          ),
        ),
        const SizedBox(height: 8),
        const Icon(Icons.lock_reset_rounded, size: 42, color: kRed),
        const SizedBox(height: 12),
        Text(
          'Choose a reset method',
          style: Theme.of(context).textTheme.titleLarge
              ?.copyWith(color: kText, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        const Text(
          'Set an email and password for an account in the database, or request '
          'a Firebase reset link for a Gmail account.',
          textAlign: TextAlign.center,
          style: TextStyle(color: kMuted, height: 1.5),
        ),
        const SizedBox(height: 18),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 10,
          children: [
            ChoiceChip(
              avatar: const Icon(Icons.storage_outlined, size: 18),
              label: const Text('Normal email'),
              selected: _method == _PasswordResetMethod.normalEmail,
              onSelected: _busy
                  ? null
                  : (_) => setState(() {
                      _method = _PasswordResetMethod.normalEmail;
                      _error = null;
                    }),
            ),
            ChoiceChip(
              avatar: const Icon(Icons.mark_email_unread_outlined, size: 18),
              label: const Text('Gmail'),
              selected: _method == _PasswordResetMethod.gmail,
              onSelected: _busy
                  ? null
                  : (_) => setState(() {
                      _method = _PasswordResetMethod.gmail;
                      _error = null;
                    }),
            ),
          ],
        ),
        const SizedBox(height: 18),
        Form(
          key: _form,
          child: Column(
            children: [
              TextFormField(
                controller: _emailController,
                autofocus: true,
                keyboardType: TextInputType.emailAddress,
                textInputAction: _method == _PasswordResetMethod.gmail
                    ? TextInputAction.done
                    : TextInputAction.next,
                autofillHints: const [AutofillHints.email],
                decoration: InputDecoration(
                  labelText: _method == _PasswordResetMethod.gmail
                      ? 'Gmail address'
                      : 'Account email',
                  prefixIcon: const Icon(Icons.email_outlined),
                ),
                validator: (value) {
                  final error = emailRule(value);
                  if (error != null) return error;
                  if (_method == _PasswordResetMethod.gmail &&
                      !value!.trim().toLowerCase().endsWith('@gmail.com')) {
                    return 'Enter an address ending in @gmail.com';
                  }
                  return null;
                },
                onChanged: (_) {
                  if (_error != null) setState(() => _error = null);
                },
                onFieldSubmitted: (_) {
                  if (_method == _PasswordResetMethod.gmail && !_busy) {
                    _submit();
                  }
                },
              ),
              if (_method == _PasswordResetMethod.normalEmail) ...[
                const SizedBox(height: 12),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _hidePassword,
                  textInputAction: TextInputAction.done,
                  decoration: InputDecoration(
                    labelText: 'New password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      onPressed: () =>
                          setState(() => _hidePassword = !_hidePassword),
                      icon: Icon(
                        _hidePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                    ),
                  ),
                  validator: (value) => value == null || value.length < 6
                      ? 'Use at least 6 characters'
                      : null,
                  onFieldSubmitted: (_) {
                    if (!_busy) _submit();
                  },
                ),
              ],
              if (_error != null) ...[
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    _error!,
                    style: const TextStyle(
                      color: kError,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 18),
              ElevatedButton(
                onPressed: _busy ? null : _submit,
                child: _busy
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        _method == _PasswordResetMethod.gmail
                            ? 'Send reset link'
                            : 'Set account password',
                      ),
              ),
            ],
          ),
        ),
      ],
    ],
  );
}

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});
  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _form = GlobalKey<FormState>();
  final nameC = TextEditingController();
  final emailC = TextEditingController();
  final userC = TextEditingController();
  final pwC = TextEditingController();
  final confirmC = TextEditingController();
  bool hidePassword = true;
  bool hideConfirmation = true;
  bool busy = false;
  bool rememberMe = true;
  String? error;

  @override
  void dispose() {
    nameC.dispose();
    emailC.dispose();
    userC.dispose();
    pwC.dispose();
    confirmC.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_form.currentState!.validate()) return;
    setState(() {
      busy = true;
      error = null;
    });
    final err = await Auth.register(
      nameC.text,
      emailC.text,
      userC.text,
      pwC.text,
    );
    if (!mounted) return;
    if (err != null) {
      setState(() {
        busy = false;
        error = err;
      });
      return;
    }
    if (rememberMe) {
      final loginError = await Auth.login(
        userC.text,
        pwC.text,
        rememberMe: true,
      );
      if (loginError == null && mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const HomeShell()),
          (_) => false,
        );
        return;
      }
    } else {
      await Auth.logout();
    }
    if (!mounted) return;
    snack(context, 'Account created. Please log in.');
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) => _AuthFrame(
    title: 'Create Admin Account',
    children: [
      Form(
        key: _form,
        child: Column(
          children: [
            TextFormField(
              controller: nameC,
              decoration: const InputDecoration(
                labelText: 'Full Name',
                prefixIcon: Icon(Icons.badge_outlined),
              ),
              validator: reqRule,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: emailC,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.mail_outline),
              ),
              validator: emailRule,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: userC,
              decoration: const InputDecoration(
                labelText: 'Username',
                prefixIcon: Icon(Icons.alternate_email),
              ),
              validator: (v) => (v == null || v.trim().length < 3)
                  ? 'At least 3 characters'
                  : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: pwC,
              obscureText: hidePassword,
              decoration: InputDecoration(
                labelText: 'Password',
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  tooltip: hidePassword ? 'Show password' : 'Hide password',
                  icon: Icon(
                    hidePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                  onPressed: () => setState(() => hidePassword = !hidePassword),
                ),
              ),
              validator: (v) =>
                  (v == null || v.length < 6) ? 'At least 6 characters' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: confirmC,
              obscureText: hideConfirmation,
              decoration: InputDecoration(
                labelText: 'Confirm password',
                prefixIcon: const Icon(Icons.verified_user_outlined),
                suffixIcon: IconButton(
                  tooltip: hideConfirmation ? 'Show password' : 'Hide password',
                  icon: Icon(
                    hideConfirmation
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                  onPressed: () =>
                      setState(() => hideConfirmation = !hideConfirmation),
                ),
              ),
              validator: (v) => v != pwC.text ? 'Passwords do not match' : null,
            ),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              value: rememberMe,
              onChanged: (value) => setState(() => rememberMe = value ?? false),
              title: const Text('Remember me'),
              controlAffinity: ListTileControlAffinity.leading,
            ),
            if (error != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(error!, style: const TextStyle(color: kError)),
              ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: busy ? null : _register,
              child: busy
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Register'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Back to Login'),
            ),
          ],
        ),
      ),
    ],
  );
}

// ═════════ home ═════════

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});
  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell>
    with SingleTickerProviderStateMixin {
  int index = 0;
  String _renewalFilter = 'All';
  int _transitionDirection = 1;

  // Page-transition tuning.
  static const _pageTransition = Duration(milliseconds: 300);
  // How long to let the drawer slide away before the page swap starts.
  static const _drawerSettle = Duration(milliseconds: 160);
  // Horizontal travel of the slide, as a fraction of the page width.
  static const _slideDistance = .025;
  final List<int> _pageHistory = [];
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final ScrollController _drawerScrollController = ScrollController();
  late final List<GlobalKey> _featureKeys = List.generate(
    items.length,
    (_) => GlobalKey(),
  );
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _activitySub;
  bool _activityReady = false;
  late final AnimationController _menuAnimation;

  @override
  void initState() {
    super.initState();
    _menuAnimation = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );
    _activitySub = db
        .collection('activity')
        .orderBy('createdAt', descending: true)
        .limit(1)
        .snapshots()
        .listen((snapshot) {
          if (!_activityReady) {
            _activityReady = true;
            return;
          }
          for (final change in snapshot.docChanges) {
            if (change.type != DocumentChangeType.added ||
                change.doc.data()?['actorId'] == Auth.admin?['id']) {
              continue;
            }
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    '${change.doc.data()?['actorName']}: ${change.doc.data()?['action']} ${change.doc.data()?['subject']}',
                  ),
                ),
              );
            }
          }
        });
  }

  @override
  void dispose() {
    _activitySub?.cancel();
    _drawerScrollController.dispose();
    _menuAnimation.dispose();
    super.dispose();
  }

  static const items = [
    ('Dashboard', Icons.dashboard),
    ('Add Members', Icons.person_add),
    ('Members', Icons.people),
    ('Renewal', Icons.autorenew),
    ('Payments', Icons.receipt_long),
    ('Income', Icons.trending_up),
    ('Expenses', Icons.money_off),
  ];

  Widget _page() => switch (index) {
    0 => DashboardPage(onNavigate: _navigateTo, onRenewalFilter: _openRenewals),
    1 => const AddMemberPage(),
    2 => const ManageMembersPage(),
    3 => RenewalPage(initialFilter: _renewalFilter),
    4 => const PaymentsTrackerPage(),
    5 => const GrossIncomePage(),
    7 => AccountManagementPage(onLogout: _logout),
    8 => MorePage(onNavigate: _navigateTo, onLogout: _logout),
    _ => const ExpensesPage(),
  };

  void _openRenewals(String filter) {
    if (index == 3) {
      setState(() => _renewalFilter = filter);
    } else {
      _renewalFilter = filter;
      _navigateTo(3);
    }
  }

  /// Close the drawer first and swap pages once it has mostly slid away, so the
  /// drawer animation and the new page's first build don't land in the same frames.
  void _selectFromDrawer(int i) {
    Navigator.pop(context);
    Future.delayed(_drawerSettle, () {
      if (mounted) _navigateTo(i);
    });
  }

  void _navigateTo(int nextIndex) {
    if (nextIndex == index) return;
    _transitionDirection = nextIndex >= index ? 1 : -1;
    _pageHistory.add(index);
    setState(() => index = nextIndex);
  }

  // AnimatedSwitcher already applies switchInCurve / switchOutCurve to `animation`,
  // so it is used as-is here (the old code curved it a second time, which made the
  // motion front-loaded and abrupt). The incoming page slides in from the travel
  // side and the outgoing page slides out the opposite way.
  Widget _pageTransitionBuilder(Widget child, Animation<double> animation) =>
      FadeTransition(
        opacity: animation,
        child: AnimatedBuilder(
          animation: animation,
          child: child,
          builder: (_, cached) {
            final leaving = animation.status == AnimationStatus.reverse;
            final side = leaving ? -_transitionDirection : _transitionDirection;
            return IgnorePointer(
              ignoring: leaving,
              child: FractionalTranslation(
                translation: Offset(
                  side * _slideDistance * (1 - animation.value),
                  0,
                ),
                child: cached,
              ),
            );
          },
        ),
      );

  Widget _animatedPage() => AnimatedSwitcher(
    duration: _pageTransition,
    switchInCurve: Curves.easeOutCubic,
    switchOutCurve: Curves.easeInCubic,
    transitionBuilder: _pageTransitionBuilder,
    child: KeyedSubtree(
      key: ValueKey(index),
      child: RepaintBoundary(child: _page()),
    ),
  );

  Widget _responsivePage() => LayoutBuilder(
    builder: (context, constraints) {
      final width = min(constraints.maxWidth, 1120.0);
      return Center(
        child: SizedBox(
          width: width,
          height: constraints.maxHeight,
          child: _animatedPage(),
        ),
      );
    },
  );

  int get _navigationSelection => switch (index) {
    0 => 0,
    2 => 1,
    3 => 2,
    4 => 3,
    _ => 4,
  };

  void _selectNavigation(int destination) {
    const destinations = [0, 2, 3, 4, 8];
    _navigateTo(destinations[destination]);
  }

  void _scrollToSelectedFeature() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_drawerScrollController.hasClients) return;
      if (index >= _featureKeys.length) return;
      final selectedContext = _featureKeys[index].currentContext;
      if (selectedContext == null) return;
      Scrollable.ensureVisible(
        selectedContext,
        alignment: .35,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeInOutCubic,
      );
    });
  }

  void _handleBack() {
    if (_scaffoldKey.currentState?.isDrawerOpen ?? false) {
      Navigator.of(context).pop();
      return;
    }
    if (_pageHistory.isNotEmpty) {
      final previous = _pageHistory.removeLast();
      _transitionDirection = -1;
      setState(() => index = previous);
    } else if (index != 0) {
      _transitionDirection = -1;
      setState(() => index = 0);
    }
    // At the dashboard, keep the app open instead of popping its root route.
  }

  Future<void> _logout({bool closeDrawer = false}) async {
    if (closeDrawer) Navigator.pop(context);
    if (!await confirm(context, 'Logout', 'Do you want to log out?')) return;
    await Auth.logout();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final desktop = MediaQuery.sizeOf(context).width >= 900;
    return PopScope<Object?>(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _handleBack();
      },
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          leadingWidth: 64,
          leading: Padding(
            padding: const EdgeInsets.only(left: 8),
            child: IconButton(
              tooltip: 'Go to dashboard',
              onPressed: () => _navigateTo(0),
              icon: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  gradient: kTape,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.fitness_center_rounded,
                  color: Colors.white,
                  size: 21,
                ),
              ),
            ),
          ),
          title: Text(switch (index) {
            7 => 'Edit Account',
            8 => 'More',
            _ => items[index].$1,
          }),
          actions: [
            if (desktop)
              Builder(
                builder: (drawerContext) => IconButton(
                  tooltip: _menuAnimation.isCompleted
                      ? 'Close navigation menu'
                      : 'Open navigation menu',
                  icon: AnimatedIcon(
                    icon: AnimatedIcons.menu_close,
                    progress: _menuAnimation,
                  ),
                  onPressed: () => Scaffold.of(drawerContext).openDrawer(),
                ),
              ),
          ],
          bottom: const PreferredSize(
            preferredSize: Size.fromHeight(3),
            child: _Tape(),
          ),
        ),
        onDrawerChanged: (isOpen) {
          if (isOpen) {
            _menuAnimation.forward();
            _scrollToSelectedFeature();
          } else {
            _menuAnimation.reverse();
          }
        },
        drawer: Drawer(
          child: ListView(
            controller: _drawerScrollController,
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                margin: EdgeInsets.zero,
                decoration: const BoxDecoration(
                  border: Border(),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [kInkSoft, kInk],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () => _selectFromDrawer(0),
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          gradient: kTape,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.fitness_center_rounded,
                          size: 26,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      Auth.admin?['fullName'] ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Administrator',
                      style: TextStyle(
                        color: kLilac,
                        fontWeight: FontWeight.w600,
                        fontSize: 12.5,
                      ),
                    ),
                  ],
                ),
              ),
              const _Tape(),
              const SizedBox(height: 10),
              for (var i = 0; i < items.length; i++)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 2,
                  ),
                  child: AnimatedContainer(
                    key: _featureKeys[i],
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOutCubic,
                    decoration: BoxDecoration(
                      color: i == index
                          ? kRed.withValues(alpha: .2)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: i == index
                            ? kRed.withValues(alpha: .48)
                            : Colors.transparent,
                      ),
                    ),
                    child: ListTile(
                      leading: Icon(items[i].$2),
                      title: Text(
                        items[i].$1,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      selected: i == index,
                      selectedColor: Colors.white,
                      selectedTileColor: Colors.transparent,
                      iconColor: const Color(0xFF9B93C9),
                      textColor: const Color(0xFFD9D4F5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      onTap: () => _selectFromDrawer(i),
                    ),
                  ),
                ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                child: Divider(color: Color(0x22FFFFFF), height: 1),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 2,
                ),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  decoration: BoxDecoration(
                    color: index == 7
                        ? kRed.withValues(alpha: .2)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: const Icon(Icons.manage_accounts_outlined),
                    title: const Text(
                      'Edit Account',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    iconColor: index == 7
                        ? Colors.white
                        : const Color(0xFF9B93C9),
                    textColor: index == 7
                        ? Colors.white
                        : const Color(0xFFD9D4F5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    onTap: () => _selectFromDrawer(7),
                  ),
                ),
              ),
            ],
          ),
        ),
        body: desktop
            ? Row(
                children: [
                  NavigationRail(
                    extended: MediaQuery.sizeOf(context).width >= 1200,
                    selectedIndex: index < items.length ? index : null,
                    onDestinationSelected: _navigateTo,
                    destinations: [
                      for (final item in items)
                        NavigationRailDestination(
                          icon: Icon(item.$2),
                          label: Text(item.$1),
                        ),
                    ],
                  ),
                  Expanded(child: _responsivePage()),
                ],
              )
            : _responsivePage(),
        bottomNavigationBar: desktop
            ? null
            : NavigationBar(
                selectedIndex: _navigationSelection,
                onDestinationSelected: _selectNavigation,
                destinations: const [
                  NavigationDestination(
                    icon: Icon(Icons.dashboard_outlined),
                    selectedIcon: Icon(Icons.dashboard_rounded),
                    label: 'Dashboard',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.people_outline),
                    selectedIcon: Icon(Icons.people_rounded),
                    label: 'Members',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.autorenew_rounded),
                    label: 'Renewal',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.receipt_long_outlined),
                    selectedIcon: Icon(Icons.receipt_long_rounded),
                    label: 'Payments',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.more_horiz_rounded),
                    label: 'More',
                  ),
                ],
              ),
      ),
    );
  }
}

class AccountManagementPage extends StatefulWidget {
  final Future<void> Function() onLogout;
  const AccountManagementPage({super.key, required this.onLogout});

  @override
  State<AccountManagementPage> createState() => _AccountManagementPageState();
}

class _AccountManagementPageState extends State<AccountManagementPage> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _username = TextEditingController();
  final _email = TextEditingController();
  final _currentPassword = TextEditingController();
  final _newPassword = TextEditingController();
  final _confirmPassword = TextEditingController();
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    final profile = Auth.admin ?? {};
    _name.text = profile['fullName']?.toString() ?? '';
    _username.text = profile['username']?.toString() ?? '';
    _email.text =
        profile['pendingEmail']?.toString() ??
        profile['email']?.toString() ??
        '';
  }

  @override
  void dispose() {
    _name.dispose();
    _username.dispose();
    _email.dispose();
    _currentPassword.dispose();
    _newPassword.dispose();
    _confirmPassword.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final requestedEmail = _email.text.trim().toLowerCase();
    final changingEmail =
        requestedEmail !=
        (Auth.admin?['email']?.toString().toLowerCase() ?? '');
    setState(() => _busy = true);
    final result = await Auth.updateAccount(
      fullName: _name.text,
      username: _username.text,
      email: _email.text,
      currentPassword: _currentPassword.text,
      newPassword: _newPassword.text.isEmpty ? null : _newPassword.text,
    );
    if (!mounted) return;
    setState(() => _busy = false);
    if (result != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(result)));
      return;
    }
    _currentPassword.clear();
    _newPassword.clear();
    _confirmPassword.clear();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          changingEmail
              ? 'Profile updated. Verify the link sent to your new email to finish changing it.'
              : 'Account details updated successfully.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 32),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: kTape,
                    borderRadius: BorderRadius.circular(kCardRadius),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 54,
                        height: 54,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: .2),
                          borderRadius: BorderRadius.circular(17),
                        ),
                        child: const Icon(
                          Icons.manage_accounts_rounded,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Administrator account',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              'Update your profile and sign-in details',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: .86),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Profile',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _name,
                          textCapitalization: TextCapitalization.words,
                          decoration: const InputDecoration(
                            labelText: 'Full name',
                            prefixIcon: Icon(Icons.person_outline),
                          ),
                          validator: reqRule,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _username,
                          textInputAction: TextInputAction.next,
                          decoration: const InputDecoration(
                            labelText: 'Username',
                            prefixIcon: Icon(Icons.alternate_email),
                          ),
                          validator: (value) =>
                              (value == null || value.trim().length < 3)
                              ? 'Use at least 3 characters'
                              : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _email,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            labelText: 'Email address',
                            prefixIcon: Icon(Icons.email_outlined),
                          ),
                          validator: emailRule,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Security',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Confirm your current password to save account changes.',
                          style: TextStyle(color: kMuted),
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _currentPassword,
                          obscureText: true,
                          autofillHints: const [AutofillHints.password],
                          decoration: const InputDecoration(
                            labelText: 'Current password',
                            prefixIcon: Icon(Icons.lock_outline),
                          ),
                          validator: (value) => (value == null || value.isEmpty)
                              ? 'Enter your current password'
                              : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _newPassword,
                          obscureText: true,
                          decoration: const InputDecoration(
                            labelText: 'New password (optional)',
                            prefixIcon: Icon(Icons.lock_reset_outlined),
                            helperText:
                                'Leave blank to keep your current password',
                          ),
                          validator: (value) =>
                              (value != null &&
                                  value.isNotEmpty &&
                                  value.length < 6)
                              ? 'Use at least 6 characters'
                              : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _confirmPassword,
                          obscureText: true,
                          decoration: const InputDecoration(
                            labelText: 'Confirm new password',
                            prefixIcon: Icon(Icons.verified_user_outlined),
                          ),
                          validator: (value) => _newPassword.text.isEmpty
                              ? ((value?.isNotEmpty ?? false)
                                    ? 'Enter a new password above first'
                                    : null)
                              : value != _newPassword.text
                              ? 'Passwords do not match'
                              : null,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: _busy ? null : _save,
                  icon: _busy
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.save_outlined),
                  label: Text(_busy ? 'Saving…' : 'Save account changes'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                ),
                const SizedBox(height: 20),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.logout_rounded, color: kError),
                    title: const Text(
                      'Log out',
                      style: TextStyle(
                        color: kError,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    subtitle: const Text(
                      'Sign out of this administrator account',
                    ),
                    trailing: const Icon(
                      Icons.chevron_right_rounded,
                      color: kMuted,
                    ),
                    onTap: _busy ? null : widget.onLogout,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class MorePage extends StatelessWidget {
  final ValueChanged<int> onNavigate;
  final Future<void> Function() onLogout;
  const MorePage({super.key, required this.onNavigate, required this.onLogout});

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
    children: [
      const SectionTitle('Tools & account'),
      _MoreDestination(
        icon: Icons.person_add_alt_1_rounded,
        title: 'Add member',
        subtitle: 'Register a new gym member',
        onTap: () => onNavigate(1),
      ),
      _MoreDestination(
        icon: Icons.insights_rounded,
        title: 'Income',
        subtitle: 'Review income and net totals',
        onTap: () => onNavigate(5),
      ),
      _MoreDestination(
        icon: Icons.receipt_long_rounded,
        title: 'Expenses',
        subtitle: 'Record and review expenses',
        onTap: () => onNavigate(6),
      ),
      _MoreDestination(
        icon: Icons.manage_accounts_rounded,
        title: 'Edit account',
        subtitle: 'Update admin profile and password',
        onTap: () => onNavigate(7),
      ),
      const SizedBox(height: 12),
      Card(
        child: ListTile(
          minVerticalPadding: 14,
          leading: const Icon(Icons.logout_rounded, color: kError),
          title: const Text(
            'Log out',
            style: TextStyle(color: kError, fontWeight: FontWeight.w700),
          ),
          subtitle: const Text('Sign out of FitCore on this device'),
          trailing: const Icon(Icons.chevron_right_rounded),
          onTap: onLogout,
        ),
      ),
    ],
  );
}

class _MoreDestination extends StatelessWidget {
  final IconData icon;
  final String title, subtitle;
  final VoidCallback onTap;
  const _MoreDestination({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Card(
      child: ListTile(
        minVerticalPadding: 12,
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: kRed.withValues(alpha: .1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: kDarkRed),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: onTap,
      ),
    ),
  );
}

class DashboardPage extends StatelessWidget {
  final ValueChanged<int> onNavigate;
  final ValueChanged<String> onRenewalFilter;

  const DashboardPage({
    super.key,
    required this.onNavigate,
    required this.onRenewalFilter,
  });

  @override
  Widget build(BuildContext context) {
    // Nested live streams: any change to members/payments updates the cards instantly.
    return StreamBuilder<QuerySnapshot>(
      stream: db.collection('members').snapshots(),
      builder: (_, ms) => StreamBuilder<QuerySnapshot>(
        stream: db.collection('payments').snapshots(),
        builder: (_, ps) {
          if (ms.hasError || ps.hasError) {
            return const EmptyState(
              'Could not load the dashboard. Check your connection.',
            );
          }
          if (!ms.hasData || !ps.hasData) {
            return const PageLoadingSkeleton();
          }
          final memberDocs = ms.data!.docs;
          final members = memberDocs
              .map((d) => d.data() as Map<String, dynamic>)
              .toList();
          final cutoff = DateTime.now().subtract(
            const Duration(days: newMemberWindowDays),
          );
          final revenue = ps.data!.docs.fold<double>(
            0,
            (s, d) => s + ((d.data() as Map)['amount'] as num).toDouble(),
          );
          final soon = members.where(expiresWithinWeek).length;
          final expired = members.where((m) => statusOf(m) == 'Expired').length;
          final fresh = members
              .where((m) => dt(m['createdAt']).isAfter(cutoff))
              .length;
          final active = members.where((m) => statusOf(m) == 'Active').length;
          final weekDocs =
              memberDocs
                  .where(
                    (d) => expiresWithinWeek(d.data() as Map<String, dynamic>),
                  )
                  .toList()
                ..sort(
                  (a, b) =>
                      dt(a['expirationDate'])
                          .compareTo(dt(b['expirationDate'])),
                );
          final adminName = (Auth.admin?['fullName'] ?? 'Admin').toString();

          return LayoutBuilder(
            builder: (context, constraints) {
              final maxWidth = constraints.maxWidth >= 900
                  ? 780.0
                  : double.infinity;
              return ListView(
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
                children: [
                  Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: maxWidth),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _Hero(
                            name: adminName,
                            total: members.length,
                            active: active,
                            fresh: fresh,
                            onTap: () => onNavigate(2),
                          ),
                          const SizedBox(height: 22),
                          const SectionTitle('The gym at one glance'),
                          IntrinsicHeight(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Expanded(
                                  child: _Stat(
                                    'Expiring Soon',
                                    '$soon',
                                    Icons.hourglass_bottom,
                                    color: statusColor('Expiring Soon'),
                                    onTap: () => onRenewalFilter('Expiring'),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: _Stat(
                                    'Expired Memberships',
                                    '$expired',
                                    Icons.event_busy,
                                    color: statusColor('Expired'),
                                    onTap: () => onRenewalFilter('Expired'),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                          _Stat(
                            'Total Revenue',
                            money(revenue),
                            Icons.payments,
                            wide: true,
                            onTap: () => onNavigate(4),
                          ),
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              const Expanded(
                                child: SectionTitle('Expiring this week'),
                              ),
                              TextButton(
                                onPressed: () => onRenewalFilter('Expiring'),
                                child: const Text('See all'),
                              ),
                            ],
                          ),
                          if (weekDocs.isEmpty)
                            const Card(
                              child: Padding(
                                padding: EdgeInsets.all(18),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.check_circle_outline_rounded,
                                      color: Color(0xFF17623A),
                                    ),
                                    SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        'No memberships expire in the next 7 days.',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          else
                            for (final doc in weekDocs.take(4))
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Card(
                                  child: ListTile(
                                    leading: _Initials('${doc['fullName']}'),
                                    title: Text(
                                      '${doc['fullName']}',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    subtitle: Text(
                                      'Expires ${fmtDate(dt(doc['expirationDate']))} · ${daysLeft(dt(doc['expirationDate']))} days left',
                                    ),
                                    trailing: FilledButton.tonalIcon(
                                      onPressed: () => renewMemberFlow(
                                        context,
                                        doc.id,
                                        doc.data() as Map<String, dynamic>,
                                      ),
                                      icon: const Icon(
                                        Icons.autorenew_rounded,
                                        size: 18,
                                      ),
                                      label: const Text('Renew'),
                                    ),
                                  ),
                                ),
                              ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

/// Dark "scoreboard" header: the one bold moment on the dashboard.
class _Hero extends StatelessWidget {
  final String name;
  final int total, active, fresh;
  final VoidCallback onTap;
  const _Hero({
    required this.name,
    required this.total,
    required this.active,
    required this.fresh,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final pct = total == 0 ? 0.0 : active / total;
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(kCardRadius),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(kCardRadius),
        child: Container(
          width: double.infinity,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [kInk, kInkSoft],
            ),
            borderRadius: BorderRadius.circular(kCardRadius),
          ),
          child: Stack(
            children: [
              Positioned(
                right: -22,
                top: -18,
                child: Transform.rotate(
                  angle: .45,
                  child: Icon(
                    Icons.fitness_center_rounded,
                    size: 170,
                    color: Colors.white.withValues(alpha: .06),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DateFormat('EEEE, MMMM d').format(DateTime.now()),
                      style: const TextStyle(
                        color: kLilac,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Welcome, $name',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -.3,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          flex: 4,
                          child: _HeroFigure(
                            '$total',
                            'Total Members',
                            big: true,
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: _HeroFigure('$active', 'Active'),
                        ),
                        Expanded(
                          flex: 3,
                          child: _HeroFigure('$fresh', 'New Members'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: pct,
                        minHeight: 8,
                        backgroundColor: Colors.white.withValues(alpha: .12),
                        valueColor: const AlwaysStoppedAnimation<Color>(kLilac),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${(pct * 100).round()}% of members are active',
                      style: const TextStyle(
                        color: Color(0xFFB4ACDA),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeroFigure extends StatelessWidget {
  final String value, label;
  final bool big;
  const _HeroFigure(this.value, this.label, {this.big = false});
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.centerLeft,
        child: Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: big ? 46 : 28,
            height: 1,
            fontWeight: FontWeight.w700,
            letterSpacing: -1,
          ),
        ),
      ),
      const SizedBox(height: 6),
      Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: Color(0xFFB4ACDA),
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    ],
  );
}

class _Stat extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;
  final bool wide;
  final VoidCallback onTap;
  const _Stat(
    this.label,
    this.value,
    this.icon, {
    this.color = kRed,
    this.wide = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final badge = Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: color.withValues(alpha: .13),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: color, size: 21),
    );
    final number = FittedBox(
      alignment: wide ? Alignment.centerRight : Alignment.centerLeft,
      fit: BoxFit.scaleDown,
      child: Text(
        value,
        maxLines: 1,
        style: TextStyle(
          fontSize: wide ? 26 : 30,
          height: 1.05,
          fontWeight: FontWeight.w700,
          letterSpacing: -.5,
        ),
      ),
    );
    final caption = Text(
      label,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(
        color: kMuted,
        fontSize: 13,
        fontWeight: FontWeight.w600,
        height: 1.15,
      ),
    );
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(kCardRadius),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(kCardRadius),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: kCard,
            borderRadius: BorderRadius.circular(kCardRadius),
            border: Border.all(color: kBorder),
          ),
          child: wide
              ? Row(
                  children: [
                    badge,
                    const SizedBox(width: 12),
                    Expanded(child: caption),
                    const SizedBox(width: 8),
                    Flexible(child: number),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    badge,
                    const SizedBox(height: 14),
                    number,
                    const SizedBox(height: 4),
                    caption,
                  ],
                ),
        ),
      ),
    );
  }
}

// ═════════ members ═════════

// ───────── Add Member ─────────
class AddMemberPage extends StatefulWidget {
  const AddMemberPage({super.key});
  @override
  State<AddMemberPage> createState() => _AddMemberPageState();
}

class _AddMemberPageState extends State<AddMemberPage> {
  final _form = GlobalKey<FormState>();
  final nameC = TextEditingController();
  final contactC = TextEditingController();
  final emailC = TextEditingController();
  final addressC = TextEditingController();
  String type = 'Daily';
  bool busy = false;

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    final recordPayment = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Add this member?'),
        content: Text(
          'This will add ${nameC.text.trim()} and record the first ${type.toLowerCase()} membership payment of ${money(plans[type]!.price)}.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Review details'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text('Save · ${money(plans[type]!.price)}'),
          ),
        ],
      ),
    );
    if (recordPayment != true || !mounted) return;
    setState(() => busy = true);
    try {
      await addMember(
        name: nameC.text.trim(),
        contact: '+63${contactC.text.trim()}',
        email: emailC.text.trim(),
        address: addressC.text.trim(),
        type: type,
      );
      if (!mounted) return;
      snack(
        context,
        'Member saved. First payment of ${money(plans[type]!.price)} recorded.',
      );
      for (final c in [nameC, contactC, emailC, addressC]) {
        c.clear();
      }
      setState(() => type = 'Daily');
    } catch (e) {
      if (mounted) {
        snack(context, 'Failed to save member. Check your connection.');
      }
    }
    if (mounted) setState(() => busy = false);
  }

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: const EdgeInsets.all(16),
    child: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640),
        child: Card(
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              const _Tape(4),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _form,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: nameC,
                        decoration: const InputDecoration(
                          labelText: 'Full Name',
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                        validator: reqRule,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: contactC,
                        keyboardType: TextInputType.phone,
                        maxLength: 10,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(10),
                        ],
                        decoration: const InputDecoration(
                          labelText: 'Mobile Number',
                          prefixIcon: Icon(Icons.phone_outlined),
                          prefixText: '+63 ',
                          counterText: '',
                        ),
                        validator: (v) =>
                            (v == null ||
                                !RegExp(r'^9\d{9}$').hasMatch(v.trim()))
                            ? 'Enter 10 digits starting with 9'
                            : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: emailC,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.mail_outline),
                        ),
                        validator: emailRule,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: addressC,
                        decoration: const InputDecoration(
                          labelText: 'Address',
                          prefixIcon: Icon(Icons.location_on_outlined),
                        ),
                        validator: reqRule,
                      ),
                      const SizedBox(height: 20),
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Membership Type',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                      const SizedBox(height: 10),
                      _PlanPicker(
                        selected: type,
                        onChanged: (v) => setState(() => type = v),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: kRed.withValues(alpha: .08),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.event_available_outlined,
                              size: 18,
                              color: kRed,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Expires: ${fmtDate(DateTime.now().add(Duration(days: plans[type]!.days)))}',
                              style: const TextStyle(
                                color: kDarkRed,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: busy ? null : _save,
                        child: busy
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('Save Member'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

// ───────── Manage Members ─────────
class ManageMembersPage extends StatefulWidget {
  const ManageMembersPage({super.key});
  @override
  State<ManageMembersPage> createState() => _ManageMembersPageState();
}

class _ManageMembersPageState extends State<ManageMembersPage> {
  final searchC = TextEditingController();
  bool asc = true;
  late Stream<QuerySnapshot> stream = _make();

  Stream<QuerySnapshot> _make() => db
      .collection('members')
      .orderBy('memberId', descending: !asc)
      .snapshots();

  Future<void> _edit(String id, Map<String, dynamic> m) async {
    final form = GlobalKey<FormState>();
    final n = TextEditingController(text: m['fullName']);
    final c = TextEditingController(
      text: (m['contact'] as String).replaceFirst(RegExp(r'^\+63'), ''),
    );
    final e = TextEditingController(text: m['email']);
    final a = TextEditingController(text: m['address']);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Member'),
        content: SingleChildScrollView(
          child: Form(
            key: form,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: n,
                  decoration: const InputDecoration(labelText: 'Full Name'),
                  validator: reqRule,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: c,
                  keyboardType: TextInputType.phone,
                  maxLength: 10,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(10),
                  ],
                  decoration: const InputDecoration(
                    labelText: 'Mobile Number',
                    prefixText: '+63 ',
                    counterText: '',
                  ),
                  validator: (v) =>
                      (v == null || !RegExp(r'^9\d{9}$').hasMatch(v.trim()))
                      ? 'Enter 10 digits starting with 9'
                      : null,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: e,
                  decoration: const InputDecoration(labelText: 'Email'),
                  validator: emailRule,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: a,
                  decoration: const InputDecoration(labelText: 'Address'),
                  validator: reqRule,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (form.currentState!.validate()) Navigator.pop(ctx, true);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await db.collection('members').doc(id).update({
      'fullName': n.text.trim(),
      'contact': '+63${c.text.trim()}',
      'email': e.text.trim(),
      'address': a.text.trim(),
    });
    await recordChange('Updated member details', subject: n.text.trim());
    if (mounted) snack(context, 'Member updated.');
  }

  Future<void> _delete(String id, String name) async {
    if (!await confirm(
      context,
      'Delete Member',
      'Delete $name? This cannot be undone.',
    )) {
      return;
    }
    await db.collection('members').doc(id).delete();
    await recordChange('Deleted member', subject: name);
    if (mounted) snack(context, 'Member deleted.');
  }

  Future<void> _toggleFreeze(String id, Map<String, dynamic> m) async {
    final frozen = m['status'] == 'Frozen';
    if (!await confirm(
      context,
      frozen ? 'Unfreeze' : 'Freeze',
      '${frozen ? 'Unfreeze' : 'Freeze'} ${m['fullName']}\'s membership?',
    )) {
      return;
    }
    await db.collection('members').doc(id).update({
      'status': frozen ? 'Active' : 'Frozen',
    });
    await recordChange(
      frozen ? 'Unfroze membership' : 'Froze membership',
      subject: m['fullName'],
    );
  }

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: searchC,
                decoration: const InputDecoration(
                  labelText: 'Search by full name',
                  prefixIcon: Icon(Icons.search),
                  isDense: true,
                ),
                onChanged: (_) => setState(() {}),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              style: tonalIcon(),
              tooltip: asc ? 'Member ID ascending' : 'Member ID descending',
              icon: Icon(asc ? Icons.arrow_upward : Icons.arrow_downward),
              onPressed: () => setState(() {
                asc = !asc;
                stream = _make();
              }),
            ),
            const SizedBox(width: 4),
            IconButton(
              style: tonalIcon(),
              tooltip: 'Reset',
              icon: const Icon(Icons.refresh),
              onPressed: () => setState(() {
                searchC.clear();
                asc = true;
                stream = _make();
              }),
            ),
          ],
        ),
      ),
      Expanded(
        child: StreamBuilder<QuerySnapshot>(
          stream: stream,
          builder: (_, snap) {
            if (snap.hasError) {
              return const EmptyState('Failed to load members.');
            }
            if (!snap.hasData) return const PageLoadingSkeleton();
            final q = searchC.text.trim().toLowerCase();
            final docs = snap.data!.docs
                .where(
                  (d) => (d['fullName'] as String).toLowerCase().contains(q),
                )
                .toList();
            if (docs.isEmpty) return const EmptyState('No members found.');
            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 16),
              itemCount: docs.length,
              itemBuilder: (_, i) {
                final m = docs[i].data() as Map<String, dynamic>;
                final id = docs[i].id;
                final st = statusOf(m);
                final frozen = m['status'] == 'Frozen';
                return MemberCard(
                  stripe: statusColor(st),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _MemberHeader(m, st),
                      const SizedBox(height: 8),
                      _Info(Icons.phone_outlined, '${m['contact']}'),
                      _Info(Icons.mail_outline, '${m['email']}'),
                      _Info(Icons.location_on_outlined, '${m['address']}'),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton.filledTonal(
                            tooltip: 'Edit member',
                            style: IconButton.styleFrom(
                              minimumSize: const Size(48, 48),
                              foregroundColor: kDarkRed,
                            ),
                            onPressed: () => _edit(id, m),
                            icon: const Icon(Icons.edit_outlined),
                          ),
                          const SizedBox(width: 8),
                          PopupMenuButton<String>(
                            tooltip: 'More member actions',
                            constraints: const BoxConstraints(minWidth: 200),
                            onSelected: (action) {
                              switch (action) {
                                case 'print':
                                  PdfService.memberRecord(m, st);
                                case 'freeze':
                                  _toggleFreeze(id, m);
                                case 'delete':
                                  _delete(id, m['fullName']);
                              }
                            },
                            itemBuilder: (_) => [
                              const PopupMenuItem(
                                value: 'print',
                                child: ListTile(
                                  leading: Icon(Icons.print_outlined),
                                  title: Text('Print record'),
                                  dense: true,
                                ),
                              ),
                              PopupMenuItem(
                                value: 'freeze',
                                child: ListTile(
                                  leading: Icon(
                                    frozen
                                        ? Icons.play_circle_outline
                                        : Icons.ac_unit,
                                  ),
                                  title: Text(
                                    frozen
                                        ? 'Unfreeze membership'
                                        : 'Freeze membership',
                                  ),
                                  dense: true,
                                ),
                              ),
                              const PopupMenuItem(
                                value: 'delete',
                                child: ListTile(
                                  leading: Icon(
                                    Icons.delete_outline,
                                    color: kError,
                                  ),
                                  title: Text(
                                    'Delete member',
                                    style: TextStyle(color: kError),
                                  ),
                                  dense: true,
                                ),
                              ),
                            ],
                            child: Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: kBorder.withValues(alpha: .55),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Icon(Icons.more_horiz_rounded),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    ],
  );
}

// ───────── Renewal ─────────
class RenewalPage extends StatefulWidget {
  final String initialFilter;
  const RenewalPage({super.key, this.initialFilter = 'All'});

  @override
  State<RenewalPage> createState() => _RenewalPageState();
}

class _RenewalPageState extends State<RenewalPage> {
  late String _filter = widget.initialFilter;

  @override
  void didUpdateWidget(covariant RenewalPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialFilter != widget.initialFilter) {
      _filter = widget.initialFilter;
    }
  }

  int _urgency(Map<String, dynamic> member) {
    if (member['status'] == 'Frozen') return 3;
    final expiration = dt(member['expirationDate']);
    if (expiration.isBefore(DateTime.now())) return 0;
    if (expiresWithinWeek(member)) return 1;
    return 2;
  }

  @override
  Widget build(BuildContext context) => StreamBuilder<QuerySnapshot>(
    stream: db.collection('members').snapshots(),
    builder: (_, snap) {
      if (snap.hasError) return const EmptyState('Failed to load members.');
      if (!snap.hasData) return const PageLoadingSkeleton();
      final docs = snap.data!.docs.toList()
        ..sort((a, b) {
          final am = a.data() as Map<String, dynamic>;
          final bm = b.data() as Map<String, dynamic>;
          final urgency = _urgency(am).compareTo(_urgency(bm));
          if (urgency != 0) return urgency;
          return dt(am['expirationDate']).compareTo(dt(bm['expirationDate']));
        });
      final filtered = docs.where((doc) {
        final member = doc.data() as Map<String, dynamic>;
        return switch (_filter) {
          'Expiring' => expiresWithinWeek(member),
          'Expired' => statusOf(member) == 'Expired',
          _ => true,
        };
      }).toList();
      final expiringCount = docs
          .where((doc) => expiresWithinWeek(doc.data() as Map<String, dynamic>))
          .length;
      final expiredCount = docs
          .where(
            (doc) => statusOf(doc.data() as Map<String, dynamic>) == 'Expired',
          )
          .length;
      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Handle the most urgent memberships first.',
                  style: TextStyle(color: kMuted),
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      for (final entry in [
                        ('Expiring', expiringCount),
                        ('Expired', expiredCount),
                        ('All', docs.length),
                      ]) ...[
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text('${entry.$1} · ${entry.$2}'),
                            selected: _filter == entry.$1,
                            onSelected: (_) =>
                                setState(() => _filter = entry.$1),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: filtered.isEmpty
                ? EmptyState(
                    _filter == 'Expiring'
                        ? 'No memberships expire in the next 7 days.'
                        : _filter == 'Expired'
                        ? 'No expired memberships.'
                        : 'No members to renew.',
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
                    itemCount: filtered.length,
                    itemBuilder: (_, i) {
                      final doc = filtered[i];
                      final m = doc.data() as Map<String, dynamic>;
                      final exp = dt(m['expirationDate']);
                      final st = statusOf(m);
                      final urgent = st == 'Expired' || expiresWithinWeek(m);
                      final frozen = m['status'] == 'Frozen';
                      final planDays = plans[m['membershipType']]?.days ?? 30;
                      return MemberCard(
                        stripe: statusColor(st),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _MemberHeader(m, st),
                            const SizedBox(height: 12),
                            _ExpiryBar(
                              exp: exp,
                              planDays: planDays,
                              color: statusColor(st),
                            ),
                            const SizedBox(height: 6),
                            _Info(Icons.phone_outlined, '${m['contact']}'),
                            _Info(
                              Icons.history,
                              'Added ${fmtDateTime(dt(m['createdAt']))}',
                            ),
                            const SizedBox(height: 8),
                            Align(
                              alignment: Alignment.centerRight,
                              child: urgent
                                  ? FilledButton.icon(
                                      onPressed: frozen
                                          ? null
                                          : () => renewMemberFlow(
                                              context,
                                              doc.id,
                                              m,
                                            ),
                                      icon: const Icon(Icons.autorenew_rounded),
                                      label: Text(
                                        frozen
                                            ? 'Unfreeze to renew'
                                            : 'Renew now',
                                      ),
                                    )
                                  : TextButton.icon(
                                      onPressed: frozen
                                          ? null
                                          : () => renewMemberFlow(
                                              context,
                                              doc.id,
                                              m,
                                            ),
                                      icon: const Icon(Icons.autorenew_rounded),
                                      label: Text(
                                        frozen ? 'Unfreeze to renew' : 'Renew',
                                      ),
                                    ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      );
    },
  );
}

// ═════════ finance ═════════

Widget _hscroll(Widget table) => Container(
  clipBehavior: Clip.antiAlias,
  decoration: BoxDecoration(
    color: kCard,
    borderRadius: BorderRadius.circular(kCardRadius),
    border: Border.all(color: kBorder),
  ),
  child: SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 600),
      child: table,
    ),
  ),
);

// ───────── Member Payments Tracker ─────────
class PaymentsTrackerPage extends StatefulWidget {
  const PaymentsTrackerPage({super.key});
  @override
  State<PaymentsTrackerPage> createState() => _PaymentsTrackerPageState();
}

class _PaymentsTrackerPageState extends State<PaymentsTrackerPage> {
  static const _pageSize = 20;
  final nameC = TextEditingController();
  String? type, aType;
  int? month, aMonth, year, aYear;
  String aName = '';
  int _page = 0;
  final stream = db
      .collection('payments')
      .orderBy('paymentDate', descending: true)
      .snapshots();

  @override
  void dispose() {
    nameC.dispose();
    super.dispose();
  }

  void _thisMonth() {
    final now = DateTime.now();
    setState(() {
      month = aMonth = now.month;
      year = aYear = now.year;
      aName = nameC.text.trim().toLowerCase();
      aType = type;
      _page = 0;
    });
  }

  Widget _dd<T>(
    String label,
    T? value,
    List<DropdownMenuItem<T>> items,
    ValueChanged<T?> cb,
  ) => SizedBox(
    width: 150,
    child: DropdownButtonFormField<T>(
      initialValue: value,
      isExpanded: true,
      decoration: InputDecoration(labelText: label, isDense: true),
      items: items,
      onChanged: cb,
    ),
  );

  @override
  Widget build(BuildContext context) {
    final yr = DateTime.now().year;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: kCard,
              borderRadius: BorderRadius.circular(kCardRadius),
              border: Border.all(color: kBorder),
            ),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                SizedBox(
                  width: 180,
                  child: TextField(
                    controller: nameC,
                    decoration: const InputDecoration(
                      labelText: 'Member name',
                      isDense: true,
                    ),
                  ),
                ),
                _dd<String>('Type', type, [
                  for (final t in plans.keys)
                    DropdownMenuItem(value: t, child: Text(t)),
                ], (v) => setState(() => type = v)),
                _dd<int>('Month', month, [
                  for (var m = 1; m <= 12; m++)
                    DropdownMenuItem(
                      value: m,
                      child: Text(DateFormat.MMMM().format(DateTime(2000, m))),
                    ),
                ], (v) => setState(() => month = v)),
                _dd<int>('Year', year, [
                  for (var y = yr; y >= yr - 5; y--)
                    DropdownMenuItem(value: y, child: Text('$y')),
                ], (v) => setState(() => year = v)),
                FilterChip(
                  label: const Text('This month'),
                  selected:
                      aMonth == DateTime.now().month &&
                      aYear == DateTime.now().year,
                  onSelected: (_) => _thisMonth(),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(110, 44),
                  ),
                  onPressed: () => setState(() {
                    aName = nameC.text.trim().toLowerCase();
                    aType = type;
                    aMonth = month;
                    aYear = year;
                    _page = 0;
                  }),
                  child: const Text('Apply Filters'),
                ),
                OutlinedButton(
                  onPressed: () => setState(() {
                    nameC.clear();
                    type = aType = null;
                    month = aMonth = null;
                    year = aYear = null;
                    aName = '';
                    _page = 0;
                  }),
                  child: const Text('Reset'),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: stream,
            builder: (_, snap) {
              if (snap.hasError) {
                return const EmptyState('Failed to load payments.');
              }
              if (!snap.hasData) return const PageLoadingSkeleton();
              final rows = snap.data!.docs
                  .map((d) => d.data() as Map<String, dynamic>)
                  .where((p) {
                    final d = dt(p['paymentDate']);
                    if (aName.isNotEmpty &&
                        !(p['memberName'] as String).toLowerCase().contains(
                          aName,
                        )) {
                      return false;
                    }
                    if (aType != null && p['type'] != aType) return false;
                    if (aMonth != null && d.month != aMonth) return false;
                    if (aYear != null && d.year != aYear) return false;
                    return true;
                  })
                  .toList();
              if (rows.isEmpty) return const EmptyState('No payments match.');
              final pageCount = max(1, (rows.length / _pageSize).ceil());
              final page = _page.clamp(0, pageCount - 1);
              final visibleRows = rows
                  .skip(page * _pageSize)
                  .take(_pageSize)
                  .toList();
              final mobile = MediaQuery.sizeOf(context).shortestSide < 600;
              return Column(
                children: [
                  Expanded(
                    child: mobile
                        ? ListView.builder(
                            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                            itemCount: visibleRows.length,
                            itemBuilder: (_, i) {
                              final p = visibleRows[i];
                              final expiration = dt(p['expirationDate']);
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Card(
                                  child: Padding(
                                    padding: const EdgeInsets.all(14),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                '${p['memberName']}',
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 15,
                                                ),
                                              ),
                                            ),
                                            Text(
                                              money(p['amount']),
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Wrap(
                                          spacing: 8,
                                          runSpacing: 6,
                                          crossAxisAlignment:
                                              WrapCrossAlignment.center,
                                          children: [
                                            Text(
                                              '#${p['memberId']}',
                                              style: const TextStyle(
                                                color: kMuted,
                                              ),
                                            ),
                                            Text(
                                              '· ${p['type']}',
                                              style: const TextStyle(
                                                color: kMuted,
                                              ),
                                            ),
                                            Text(
                                              '· Paid ${fmtDate(dt(p['paymentDate']))}',
                                              style: const TextStyle(
                                                color: kMuted,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            const Icon(
                                              Icons.event_outlined,
                                              size: 17,
                                              color: kMuted,
                                            ),
                                            const SizedBox(width: 6),
                                            Expanded(
                                              child: Text(
                                                'Expires ${fmtDate(expiration)}',
                                              ),
                                            ),
                                            StatusChip(
                                              expiration.isAfter(DateTime.now())
                                                  ? 'Active'
                                                  : 'Expired',
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          )
                        : SingleChildScrollView(
                            padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
                            child: _hscroll(
                              DataTable(
                                columns: const [
                                  DataColumn(label: Text('ID')),
                                  DataColumn(label: Text('Name')),
                                  DataColumn(label: Text('Type')),
                                  DataColumn(label: Text('Amount')),
                                  DataColumn(label: Text('Paid')),
                                  DataColumn(label: Text('Expires')),
                                  DataColumn(label: Text('Status')),
                                ],
                                rows: [
                                  for (final p in visibleRows)
                                    DataRow(
                                      cells: [
                                        DataCell(Text('${p['memberId']}')),
                                        DataCell(Text(p['memberName'])),
                                        DataCell(Text(p['type'])),
                                        DataCell(Text(money(p['amount']))),
                                        DataCell(
                                          Text(fmtDate(dt(p['paymentDate']))),
                                        ),
                                        DataCell(
                                          Text(
                                            fmtDate(dt(p['expirationDate'])),
                                          ),
                                        ),
                                        DataCell(
                                          StatusChip(
                                            dt(p['expirationDate'])
                                                    .isAfter(DateTime.now())
                                                ? 'Active'
                                                : 'Expired',
                                          ),
                                        ),
                                      ],
                                    ),
                                ],
                              ),
                            ),
                          ),
                  ),
                  if (rows.length > _pageSize)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            '${page * _pageSize + 1}–${min((page + 1) * _pageSize, rows.length)} of ${rows.length}',
                            style: const TextStyle(color: kMuted),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            tooltip: 'Previous page',
                            onPressed: page == 0
                                ? null
                                : () => setState(() => _page = page - 1),
                            icon: const Icon(Icons.chevron_left_rounded),
                          ),
                          IconButton(
                            tooltip: 'Next page',
                            onPressed: page >= pageCount - 1
                                ? null
                                : () => setState(() => _page = page + 1),
                            icon: const Icon(Icons.chevron_right_rounded),
                          ),
                        ],
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

// ───────── Expenses ─────────
class ExpensesPage extends StatefulWidget {
  const ExpensesPage({super.key});
  @override
  State<ExpensesPage> createState() => _ExpensesPageState();
}

class _ExpensesPageState extends State<ExpensesPage> {
  static const types = [
    'Utilities',
    'Maintenance',
    'Salaries',
    'Supplies',
    'Other',
  ];
  final _form = GlobalKey<FormState>();
  final amountC = TextEditingController();
  String type = types.first;
  bool busy = false;
  final stream = db
      .collection('expenses')
      .orderBy('createdAt', descending: true)
      .snapshots();

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    setState(() => busy = true);
    try {
      final id = await nextId('expenses');
      await db.collection('expenses').add({
        'expenseId': id,
        'type': type,
        'amount': double.parse(amountC.text.trim()),
        'createdAt': Timestamp.now(),
      });
      await recordChange('Added expense', subject: '$type expense');
      if (!mounted) return;
      amountC.clear();
      snack(context, 'Expense saved.');
    } catch (_) {
      if (mounted) snack(context, 'Failed to save expense.');
    }
    if (mounted) setState(() => busy = false);
  }

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(16),
    children: [
      Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _form,
            child: Column(
              children: [
                DropdownButtonFormField<String>(
                  initialValue: type,
                  decoration: const InputDecoration(labelText: 'Expense Type'),
                  items: types
                      .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                      .toList(),
                  onChanged: (v) => setState(() => type = v!),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: amountC,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Amount',
                    prefixText: '₱ ',
                  ),
                  validator: (v) {
                    final n = double.tryParse((v ?? '').trim());
                    return (n == null || n <= 0)
                        ? 'Enter an amount greater than 0'
                        : null;
                  },
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: busy ? null : _save,
                  child: busy
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Save Expense'),
                ),
              ],
            ),
          ),
        ),
      ),
      const SizedBox(height: 20),
      StreamBuilder<QuerySnapshot>(
        stream: stream,
        builder: (_, snap) {
          if (snap.hasError) {
            return const EmptyState('Failed to load expenses.');
          }
          if (!snap.hasData) return const PageLoadingSkeleton();
          final list = snap.data!.docs
              .map((d) => d.data() as Map<String, dynamic>)
              .toList();
          final total = list.fold<double>(
            0,
            (s, e) => s + (e['amount'] as num),
          );
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: kCard,
                  borderRadius: BorderRadius.circular(kCardRadius),
                  border: Border.all(color: kBorder),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: kError.withValues(alpha: .1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.money_off,
                        color: kError,
                        size: 21,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Total Expenses',
                        style: TextStyle(
                          color: kMuted,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Text(
                      money(total),
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -.3,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const SectionTitle('Expense History'),
              if (list.isEmpty)
                const EmptyState('No expenses recorded.')
              else if (MediaQuery.sizeOf(context).shortestSide < 600)
                for (final e in list)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Card(
                      child: ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: Color(0xFFFFEDEA),
                          child: Icon(Icons.receipt_long, color: kError),
                        ),
                        title: Text(
                          '${e['type']}',
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        subtitle: Text(
                          '#${e['expenseId']} · ${fmtDateTime(dt(e['createdAt']))}',
                        ),
                        trailing: Text(
                          money(e['amount']),
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  )
              else
                _hscroll(
                  DataTable(
                    columns: const [
                      DataColumn(label: Text('ID')),
                      DataColumn(label: Text('Type')),
                      DataColumn(label: Text('Amount')),
                      DataColumn(label: Text('Date Recorded')),
                    ],
                    rows: [
                      for (final e in list)
                        DataRow(
                          cells: [
                            DataCell(Text('${e['expenseId']}')),
                            DataCell(Text(e['type'])),
                            DataCell(Text(money(e['amount']))),
                            DataCell(Text(fmtDateTime(dt(e['createdAt'])))),
                          ],
                        ),
                    ],
                  ),
                ),
            ],
          );
        },
      ),
    ],
  );
}

// ───────── Gross Income Tracking ─────────
class GrossIncomePage extends StatefulWidget {
  const GrossIncomePage({super.key});
  @override
  State<GrossIncomePage> createState() => _GrossIncomePageState();
}

class _GrossIncomePageState extends State<GrossIncomePage> {
  static DateTime _day(DateTime d) => DateTime(d.year, d.month, d.day);
  DateTime from = DateTime(DateTime.now().year, DateTime.now().month, 1);
  DateTime to = _day(DateTime.now());
  late DateTime aFrom = from, aTo = to;
  final pStream = db
      .collection('payments')
      .orderBy('paymentDate', descending: true)
      .snapshots();
  final eStream = db.collection('expenses').snapshots();

  Future<void> _pick(bool isFrom) async {
    final d = await showDatePicker(
      context: context,
      initialDate: isFrom ? from : to,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (d != null) setState(() => isFrom ? from = d : to = d);
  }

  @override
  Widget build(BuildContext context) => StreamBuilder<QuerySnapshot>(
    stream: pStream,
    builder: (_, ps) => StreamBuilder<QuerySnapshot>(
      stream: eStream,
      builder: (_, es) {
        if (ps.hasError || es.hasError) {
          return const EmptyState('Failed to load data.');
        }
        if (!ps.hasData || !es.hasData) return const PageLoadingSkeleton();
        final start = _day(aFrom);
        final end = _day(aTo).add(const Duration(days: 1));
        bool inRange(DateTime d) => !d.isBefore(start) && d.isBefore(end);

        final pays = ps.data!.docs
            .map((d) => d.data() as Map<String, dynamic>)
            .where((p) => inRange(dt(p['paymentDate'])))
            .toList();
        final income = pays.fold<double>(0, (s, p) => s + (p['amount'] as num));
        final expenses = es.data!.docs
            .map((d) => d.data() as Map<String, dynamic>)
            .where((e) => inRange(dt(e['createdAt'])))
            .fold<double>(0, (s, e) => s + (e['amount'] as num));
        final net = income - expenses;
        final range = '${fmtDate(aFrom)} – ${fmtDate(aTo)}';

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                OutlinedButton.icon(
                  onPressed: () => _pick(true),
                  icon: const Icon(Icons.calendar_today, size: 16),
                  label: Text('From: ${fmtDate(from)}'),
                ),
                OutlinedButton.icon(
                  onPressed: () => _pick(false),
                  icon: const Icon(Icons.calendar_today, size: 16),
                  label: Text('To: ${fmtDate(to)}'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(100, 44),
                  ),
                  onPressed: () {
                    if (to.isBefore(from)) {
                      snack(
                        context,
                        '"To" date must be on or after "From" date.',
                      );
                      return;
                    }
                    setState(() {
                      aFrom = from;
                      aTo = to;
                    });
                  },
                  child: const Text('Filter'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [kInk, kInkSoft],
                ),
                borderRadius: BorderRadius.circular(kCardRadius),
              ),
              child: Column(
                children: [
                  _row('Date Range', range),
                  _row('Total Income', money(income)),
                  _row('Total Expenses', money(expenses)),
                  const Divider(color: Color(0x33FFFFFF), height: 22),
                  _row(
                    'Net Income',
                    money(net),
                    color: net >= 0
                        ? const Color(0xFF5BE3A0)
                        : const Color(0xFFFF8FA3),
                    big: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () => PdfService.incomeReport(
                range: range,
                income: income,
                expenses: expenses,
                rows: [
                  for (final p in pays)
                    [
                      fmtDate(dt(p['paymentDate'])),
                      p['memberName'],
                      p['type'],
                      'PHP ${(p['amount'] as num).toStringAsFixed(2)}',
                    ],
                ],
              ),
              icon: const Icon(Icons.picture_as_pdf),
              label: const Text('Print Report'),
            ),
            const SizedBox(height: 16),
            const SectionTitle('Income Details'),
            if (pays.isEmpty)
              const EmptyState('No income in this date range.')
            else if (MediaQuery.sizeOf(context).shortestSide < 600)
              for (final p in pays)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Card(
                    child: ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Color(0xFFE8F5EC),
                        child: Icon(
                          Icons.payments_outlined,
                          color: Color(0xFF17623A),
                        ),
                      ),
                      title: Text(
                        '${p['memberName']}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      subtitle: Text(
                        '${p['type']} · ${fmtDate(dt(p['paymentDate']))}',
                      ),
                      trailing: Text(
                        money(p['amount']),
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                )
            else
              _hscroll(
                DataTable(
                  columns: const [
                    DataColumn(label: Text('Date')),
                    DataColumn(label: Text('Member')),
                    DataColumn(label: Text('Type')),
                    DataColumn(label: Text('Amount')),
                  ],
                  rows: [
                    for (final p in pays)
                      DataRow(
                        cells: [
                          DataCell(Text(fmtDate(dt(p['paymentDate'])))),
                          DataCell(Text(p['memberName'])),
                          DataCell(Text(p['type'])),
                          DataCell(Text(money(p['amount']))),
                        ],
                      ),
                  ],
                ),
              ),
          ],
        );
      },
    ),
  );

  Widget _row(String l, String v, {Color? color, bool big = false}) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          l,
          style: const TextStyle(
            color: Color(0xFFB4ACDA),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            v,
            textAlign: TextAlign.right,
            style: TextStyle(
              color: color ?? Colors.white,
              fontSize: big ? 26 : 16,
              fontWeight: FontWeight.w700,
              letterSpacing: big ? -.4 : 0,
            ),
          ),
        ),
      ],
    ),
  );
}

// ═════════ pdf_service ═════════

/// Note: the default PDF font has no ₱ glyph, so PDFs use the "PHP" prefix.
class PdfService {
  static final PdfColor _brandViolet = PdfColor.fromInt(0xFF6857D9);

  static pw.Widget _line(String k, String v) => pw.Padding(
    padding: const pw.EdgeInsets.symmetric(vertical: 4),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          width: 130,
          child: pw.Text(
            k,
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          ),
        ),
        pw.Expanded(child: pw.Text(v)),
      ],
    ),
  );

  static Future<void> memberRecord(
    Map<String, dynamic> m,
    String status,
  ) async {
    final doc = pw.Document();
    doc.addPage(
      pw.Page(
        build: (_) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'FitCore',
              style: pw.TextStyle(
                fontSize: 26,
                fontWeight: pw.FontWeight.bold,
                color: _brandViolet,
              ),
            ),
            pw.Text('Member Record'),
            pw.Divider(),
            _line('Member ID', '${m['memberId']}'),
            _line('Full Name', m['fullName']),
            _line('Contact', m['contact']),
            _line('Email', m['email']),
            _line('Address', m['address']),
            _line('Membership Type', m['membershipType']),
            _line('Status', status),
            _line('Expiration Date', fmtDate(dt(m['expirationDate']))),
            _line('Member Since', fmtDate(dt(m['createdAt']))),
            pw.SizedBox(height: 24),
            pw.Text(
              'Printed ${fmtDateTime(DateTime.now())}',
              style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
            ),
          ],
        ),
      ),
    );
    await Printing.layoutPdf(
      onLayout: (_) => doc.save(),
      name: 'member_${m['memberId']}.pdf',
    );
  }

  static Future<void> incomeReport({
    required String range,
    required double income,
    required double expenses,
    required List<List<String>> rows,
  }) async {
    String php(double n) => 'PHP ${n.toStringAsFixed(2)}';
    final doc = pw.Document();
    doc.addPage(
      pw.MultiPage(
        build: (_) => [
          pw.Text(
            'FitCore',
            style: pw.TextStyle(
              fontSize: 26,
              fontWeight: pw.FontWeight.bold,
              color: _brandViolet,
            ),
          ),
          pw.Text('Gross Income Report'),
          pw.Divider(),
          _line('Date Range', range),
          _line('Total Income', php(income)),
          _line('Total Expenses', php(expenses)),
          _line('Net Income', php(income - expenses)),
          pw.SizedBox(height: 16),
          pw.Text(
            'Income Details',
            style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 6),
          if (rows.isEmpty)
            pw.Text('No income in this range.')
          else
            pw.TableHelper.fromTextArray(
              headers: ['Date', 'Member', 'Type', 'Amount'],
              data: rows,
              headerDecoration: pw.BoxDecoration(color: _brandViolet),
              headerStyle: pw.TextStyle(
                color: PdfColors.white,
                fontWeight: pw.FontWeight.bold,
              ),
              cellAlignment: pw.Alignment.centerLeft,
            ),
        ],
      ),
    );
    await Printing.layoutPdf(
      onLayout: (_) => doc.save(),
      name: 'gross_income_report.pdf',
    );
  }
}

// ═════════ main ═════════

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final Future<bool> _startup = _initialize();

  Future<bool> _initialize() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    return Auth.restore();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FitCore',
      debugShowCheckedModeBanner: false,
      theme: appTheme(),
      home: FutureBuilder<bool>(
        future: _startup,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const _StartupScreen(
              message: 'Unable to connect. Please restart the app.',
            );
          }
          if (!snapshot.hasData) return const _StartupScreen();
          return snapshot.data! ? const HomeShell() : const LoginPage();
        },
      ),
    );
  }
}

class _StartupScreen extends StatelessWidget {
  final String message;
  const _StartupScreen({this.message = 'Loading FitCore…'});

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: kInk,
    body: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              gradient: kTape,
              borderRadius: BorderRadius.circular(kCardRadius),
            ),
            child: const Icon(
              Icons.fitness_center_rounded,
              size: 40,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 24),
          const SizedBox(height: 20),
          Text(
            message,
            style: const TextStyle(
              color: Color(0xFFB4ACDA),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: 220,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: const LinearProgressIndicator(
                minHeight: 5,
                backgroundColor: Color(0x33222222),
              ),
            ),
          ),
          const SizedBox(height: 22),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var i = 0; i < 3; i++) ...[
                Container(
                  width: 62,
                  height: 38,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: .09),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                if (i < 2) const SizedBox(width: 8),
              ],
            ],
          ),
        ],
      ),
    ),
  );
}
