import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;
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
const kMuted = Color(0xFF74758A);
const kError = Color(0xFFB3261E);
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
        titleTextStyle: TextStyle(fontFamily: 'Manrope', color: Colors.white, fontSize: 19, fontWeight: FontWeight.w800, letterSpacing: -.2),
      ),
      cardTheme: CardThemeData(
        color: kCard,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: Color(0xFFE9E7F0)),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        titleTextStyle: const TextStyle(fontFamily: 'Manrope', color: kText, fontSize: 19, fontWeight: FontWeight.w800),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(14))),
        enabledBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(14)),
          borderSide: BorderSide(color: Color(0xFFE1DFEA)),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(14)),
          borderSide: BorderSide(color: kRed, width: 1.8),
        ),
        filled: true,
        fillColor: const Color(0xFFFBFAFD),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        floatingLabelStyle: const TextStyle(color: kRed, fontWeight: FontWeight.w700),
        prefixIconColor: WidgetStateColor.resolveWith(
            (states) => states.contains(WidgetState.focused) ? kRed : kMuted),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        indicatorColor: kRed.withValues(alpha: .18),
        labelTextStyle: WidgetStateProperty.resolveWith((states) => TextStyle(
          color: states.contains(WidgetState.selected) ? kRed : kMuted,
          fontSize: 11,
          fontWeight: states.contains(WidgetState.selected) ? FontWeight.w600 : FontWeight.w400,
        )),
      ),
      navigationRailTheme: const NavigationRailThemeData(
        backgroundColor: kInk,
        indicatorColor: kRed,
        selectedIconTheme: IconThemeData(color: Colors.white),
        unselectedIconTheme: IconThemeData(color: Color(0xFF9B93C9)),
        selectedLabelTextStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
        unselectedLabelTextStyle: TextStyle(color: Color(0xFF9B93C9), fontWeight: FontWeight.w600),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
            backgroundColor: kRed,
            foregroundColor: Colors.white,
            minimumSize: const Size.fromHeight(50),
            textStyle: const TextStyle(fontFamily: 'Manrope', fontWeight: FontWeight.w800, fontSize: 15, letterSpacing: .2),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            elevation: 0),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: kDarkRed,
          minimumSize: const Size(0, 44),
          side: const BorderSide(color: Color(0xFFD6D1F0), width: 1.3),
          textStyle: const TextStyle(fontFamily: 'Manrope', fontWeight: FontWeight.w700),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: kRed,
          textStyle: const TextStyle(fontFamily: 'Manrope', fontWeight: FontWeight.w800),
        ),
      ),
      dataTableTheme: const DataTableThemeData(
        headingRowColor: WidgetStatePropertyAll(Color(0xFFEFECFA)),
        headingTextStyle: TextStyle(fontWeight: FontWeight.w800, color: kText, fontSize: 13),
        dataTextStyle: TextStyle(fontSize: 13, color: kText),
        dividerThickness: .6,
        headingRowHeight: 46,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: kInk,
        contentTextStyle: const TextStyle(fontFamily: 'Manrope', color: Colors.white, fontWeight: FontWeight.w600),
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

String money(num n) => NumberFormat.currency(symbol: '₱', decimalDigits: 2).format(n);
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
        TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')),
        TextButton(onPressed: () => Navigator.pop(c, true), child: const Text('Confirm')),
      ],
    ),
  );
  return r ?? false;
}

class EmptyState extends StatelessWidget {
  final String text;
  final IconData icon;
  const EmptyState(this.text, {this.icon = Icons.fitness_center_rounded, super.key});
  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(color: kRed.withValues(alpha: .1), shape: BoxShape.circle),
              child: Icon(icon, size: 34, color: kRed.withValues(alpha: .7)),
            ),
            const SizedBox(height: 14),
            Text(text, textAlign: TextAlign.center, style: const TextStyle(color: kMuted, fontWeight: FontWeight.w600)),
          ]),
        ),
      );
}

Color statusColor(String status) => switch (status) {
      'Active' => const Color(0xFF1E9E5A),
      'Expiring Soon' => const Color(0xFFE88A00),
      'Frozen' => const Color(0xFF2A9DF4),
      _ => kError,
    };

class StatusChip extends StatelessWidget {
  final String status;
  const StatusChip(this.status, {super.key});
  @override
  Widget build(BuildContext context) {
    final c = statusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(color: c.withValues(alpha: .13), borderRadius: BorderRadius.circular(8)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 6, height: 6, decoration: BoxDecoration(color: c, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(status, style: TextStyle(color: c, fontSize: 11.5, fontWeight: FontWeight.w800)),
      ]),
    );
  }
}

/// Thin gradient strip — the "gym floor tape" used as the app's signature accent.
class _Tape extends StatelessWidget {
  final double height;
  const _Tape([this.height = 3]);
  @override
  Widget build(BuildContext context) =>
      Container(height: height, decoration: const BoxDecoration(gradient: kTape));
}

class SectionTitle extends StatelessWidget {
  final String text;
  const SectionTitle(this.text, {super.key});
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 4, bottom: 10),
        child: Row(children: [
          Container(
            width: 4,
            height: 18,
            decoration: BoxDecoration(
              gradient: const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [kRed, kPink]),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 10),
          Text(text, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, letterSpacing: -.2)),
        ]),
      );
}

class _Initials extends StatelessWidget {
  final String name;
  const _Initials(this.name);
  @override
  Widget build(BuildContext context) {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    final text = parts.isEmpty
        ? '?'
        : (parts.length == 1 ? parts.first[0] : parts.first[0] + parts.last[0]).toUpperCase();
    return Container(
      width: 44,
      height: 44,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [kRed, kDarkRed]),
        borderRadius: BorderRadius.circular(13),
      ),
      child: Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16)),
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
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Color(0xFFE9E7F0)),
          ),
          child: Stack(children: [
            Positioned(left: 0, top: 0, bottom: 0, width: 5, child: ColoredBox(color: stripe)),
            Padding(padding: const EdgeInsets.fromLTRB(19, 14, 14, 12), child: child),
          ]),
        ),
      );
}

class _MemberHeader extends StatelessWidget {
  final Map<String, dynamic> m;
  final String status;
  const _MemberHeader(this.m, this.status);
  @override
  Widget build(BuildContext context) => Row(children: [
        _Initials('${m['fullName'] ?? ''}'),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('${m['fullName']}',
                maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
            const SizedBox(height: 2),
            Row(children: [
              Text('#${m['memberId']}', style: const TextStyle(color: kRed, fontWeight: FontWeight.w800, fontSize: 12.5)),
              const SizedBox(width: 8),
              Text('${m['membershipType']}', style: const TextStyle(color: kMuted, fontWeight: FontWeight.w600, fontSize: 12.5)),
            ]),
          ]),
        ),
        const SizedBox(width: 8),
        StatusChip(status),
      ]);
}

class _Info extends StatelessWidget {
  final IconData icon;
  final String text;
  const _Info(this.icon, this.text);
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 5),
        child: Row(children: [
          Icon(icon, size: 16, color: kMuted),
          const SizedBox(width: 8),
          Expanded(child: Text(text, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13.5))),
        ]),
      );
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String tooltip;
  final VoidCallback onTap;
  const _ActionBtn(this.icon, this.color, this.tooltip, this.onTap);
  @override
  Widget build(BuildContext context) => Tooltip(
        message: tooltip,
        child: Material(
          color: color.withValues(alpha: .1),
          borderRadius: BorderRadius.circular(10),
          child: InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: onTap,
            child: SizedBox(width: 40, height: 40, child: Icon(icon, size: 20, color: color)),
          ),
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
  const _ExpiryBar({required this.exp, required this.planDays, required this.color});
  @override
  Widget build(BuildContext context) {
    final left = daysLeft(exp);
    final v = planDays <= 0 ? 0.0 : (left / planDays).clamp(0.0, 1.0).toDouble();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text('Expires ${fmtDate(exp)}', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
        Text(left == 1 ? '1 day left' : '$left days left',
            style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 13)),
      ]),
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
    ]);
  }
}

/// Pass-style plan selector (Daily / Weekly / Monthly).
class _PlanPicker extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onChanged;
  const _PlanPicker({required this.selected, required this.onChanged});
  @override
  Widget build(BuildContext context) => Row(children: [
        for (final e in plans.entries) ...[
          Expanded(child: _PlanTile(e.key, e.value, e.key == selected, () => onChanged(e.key))),
          if (e.key != plans.keys.last) const SizedBox(width: 8),
        ],
      ]);
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
            border: Border.all(color: on ? kDarkRed : const Color(0xFFE1DFEA), width: on ? 1.6 : 1),
          ),
          child: Column(children: [
            Text(name, style: TextStyle(color: fg, fontWeight: FontWeight.w800, fontSize: 13)),
            const SizedBox(height: 4),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(money(plan.price), style: TextStyle(color: fg, fontWeight: FontWeight.w800, fontSize: 16)),
            ),
            const SizedBox(height: 2),
            Text(plan.days == 1 ? '1 day' : '${plan.days} days',
                style: TextStyle(color: on ? Colors.white70 : kMuted, fontSize: 11.5, fontWeight: FontWeight.w600)),
          ]),
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

Future<void> renewMember(String docId, Map<String, dynamic> m, String type) async {
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
          clientId: defaultTargetPlatform == TargetPlatform.iOS ||
                  defaultTargetPlatform == TargetPlatform.macOS
              ? _googleAppleClientId
              : null,
          serverClientId: _googleWebClientId,
        );
        await _googleInitialization;
        final googleUser = await GoogleSignIn.instance.authenticate();
        final idToken = googleUser.authentication.idToken;
        if (idToken == null) return 'Google did not return an authentication token. Check OAuth client setup.';
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
      final profileDoc = await profileRef.get();
      if (!profileDoc.exists) {
        final email = user.email!.trim().toLowerCase();
        final name = (user.displayName?.trim().isNotEmpty ?? false)
            ? user.displayName!.trim()
            : email.split('@').first;
        final baseUsername = email
            .split('@')
            .first
            .replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '')
            .toLowerCase();
        final base = baseUsername.length >= 3 ? baseUsername : 'admin';
        var username = base;
        var suffix = 1;
        while (true) {
          final match = await db.collection('admins')
              .where('usernameLower', isEqualTo: username)
              .limit(1)
              .get();
          if (match.docs.isEmpty || match.docs.first.id == user.uid) break;
          username = '$base${suffix++}';
        }
        await profileRef.set({
          'fullName': name,
          'email': email,
          'emailLower': email,
          'username': username,
          'usernameLower': username,
          'role': 'Administrator',
          'createdAt': Timestamp.now(),
          'authProvider': 'google',
        });
      }
      final savedProfile = await profileRef.get();
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
      if (user.email != null && profile['emailLower'] != user.email!.toLowerCase()) {
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
  static Future<String?> register(String name, String email, String username, String pw) async {
    final u = username.trim().toLowerCase();
    final e = email.trim().toLowerCase();
    if (!emailRe.hasMatch(e)) return 'Invalid email address.';
    try {
      final existing = await db.collection('admins').where('emailLower', isEqualTo: e).limit(1).get();
      if (existing.docs.isNotEmpty) {
        return 'This email is already registered. Use a different email or log in.';
      }
      final a = await db.collection('admins').where('usernameLower', isEqualTo: u).limit(1).get();
      if (a.docs.isNotEmpty) return 'Username is already taken.';

      UserCredential credential;
      try {
        credential = await _firebase.createUserWithEmailAndPassword(email: e, password: pw);
      } on FirebaseAuthException catch (error) {
        return _authError(error, registering: true);
      }
      final user = credential.user;
      if (user == null) return 'Could not create the account. Please try again.';
      try {
        await db.collection('admins').doc(user.uid).set({
        'fullName': name.trim(),
        'email': e,
        'emailLower': e,
        'username': username.trim(),
        'usernameLower': u,
        'role': 'Administrator',
        'createdAt': Timestamp.now(),
      });
      } catch (_) {
        await user.delete();
        return 'Your account was created, but its profile could not be saved. Please try again.';
      }
      return null;
    } on FirebaseAuthException catch (error) {
      return _authError(error, registering: true);
    } catch (_) {
      return 'Something went wrong. Please try again.';
    }
  }

  static Future<String?> login(String id, String pw, {required bool rememberMe}) async {
    const generic = 'Invalid username/email or password.';
    final k = id.trim().toLowerCase();
    try {
      var email = k;
      var legacyProfile = await db.collection('admins').where('emailLower', isEqualTo: k).limit(1).get();
      if (!k.contains('@')) {
        final byUsername = await db.collection('admins').where('usernameLower', isEqualTo: k).limit(1).get();
        if (byUsername.docs.isEmpty) return generic;
        final usernameProfile = byUsername.docs.first.data();
        email = (usernameProfile['pendingEmail'] ?? usernameProfile['email'] as String)
            .toString().trim().toLowerCase();
        legacyProfile = byUsername;
      }

      UserCredential credential;
      try {
        credential = await _firebase.signInWithEmailAndPassword(email: email, password: pw);
      } on FirebaseAuthException catch (error) {
        // Existing installations used a local hash. Upgrade a matching legacy account
        // into Firebase Authentication on its first successful login.
        final profile = legacyProfile.docs.isNotEmpty ? legacyProfile.docs.first : null;
        final old = profile?.data();
        if (old == null || old['passwordHash'] == null || old['salt'] == null ||
            _hash(pw, old['salt'] as String) != old['passwordHash']) {
          return _authError(error);
        }
        try {
          credential = await _firebase.createUserWithEmailAndPassword(email: email, password: pw);
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
    if (!emailRe.hasMatch(normalizedEmail)) return 'Enter a valid email address.';
    if (normalizedUsername.length < 3) return 'Username must be at least 3 characters.';
    if (fullName.trim().isEmpty) return 'Enter your name.';
    if (newPassword != null && newPassword.length < 6) {
      return 'Choose a stronger password (at least 6 characters).';
    }
    try {
      final matchingEmail = await db.collection('admins')
          .where('emailLower', isEqualTo: normalizedEmail).limit(1).get();
      if (matchingEmail.docs.any((doc) => doc.id != uid)) {
        return 'This email is already used by another administrator.';
      }
      final matchingUsername = await db.collection('admins')
          .where('usernameLower', isEqualTo: normalizedUsername).limit(1).get();
      if (matchingUsername.docs.any((doc) => doc.id != uid)) {
        return 'That username is already taken.';
      }

      await user.reauthenticateWithCredential(EmailAuthProvider.credential(
        email: user.email!, password: currentPassword,
      ));
      final changingEmail = normalizedEmail != user.email!.toLowerCase();
      if (changingEmail) await user.verifyBeforeUpdateEmail(normalizedEmail);
      if (newPassword != null && newPassword.isNotEmpty) {
        await user.updatePassword(newPassword);
      }
      final profile = {
        'fullName': fullName.trim(),
        'email': changingEmail ? user.email : normalizedEmail,
        'emailLower': changingEmail ? user.email!.toLowerCase() : normalizedEmail,
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

  static String _authError(FirebaseAuthException error, {bool registering = false}) {
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
            gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [kInk, kInkSoft]),
          ),
          child: Stack(children: [
            Positioned(
              right: -50,
              bottom: -30,
              child: Transform.rotate(
                angle: -.35,
                child: Icon(Icons.fitness_center_rounded, size: 300, color: Colors.white.withValues(alpha: .04)),
              ),
            ),
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: Column(children: [
                      Container(
                        width: 68,
                        height: 68,
                        decoration: BoxDecoration(gradient: kTape, borderRadius: BorderRadius.circular(20)),
                        child: const Icon(Icons.fitness_center_rounded, size: 36, color: Colors.white),
                      ),
                      const SizedBox(height: 14),
                      const Text('FitCore',
                          style: TextStyle(fontSize: 34, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: -.5)),
                      const SizedBox(height: 4),
                      Text(title, style: const TextStyle(color: kLilac, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 24),
                      Container(
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
                        child: Column(children: [
                          const _Tape(4),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                            child: Column(children: children),
                          ),
                        ]),
                      ),
                    ]),
                  ),
                ),
              ),
            ),
          ]),
        ),
      );
}

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
  String? error;

  Future<void> _login() async {
    if (!_form.currentState!.validate()) return;
    setState(() { busy = true; error = null; });
    final err = await Auth.login(idC.text, pwC.text, rememberMe: rememberMe);
    if (!mounted) return;
    if (err != null) {
      setState(() { busy = false; error = err; });
      return;
    }
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeShell()));
  }

  Future<void> _googleLogin() async {
    setState(() { busy = true; error = null; });
    final err = await Auth.loginWithGoogle(rememberMe: rememberMe);
    if (!mounted) return;
    if (err != null) {
      setState(() { busy = false; error = err; });
      return;
    }
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeShell()));
  }

  @override
  Widget build(BuildContext context) => _AuthFrame(title: 'Admin Login', children: [
        Form(
          key: _form,
          child: Column(children: [
            TextFormField(
              controller: idC,
              decoration: const InputDecoration(labelText: 'Username or Email', prefixIcon: Icon(Icons.person_outline)),
              validator: reqRule,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: pwC,
              obscureText: hide,
              decoration: InputDecoration(
                labelText: 'Password',
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                    icon: Icon(hide ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                    onPressed: () => setState(() => hide = !hide)),
              ),
              validator: reqRule,
              onFieldSubmitted: (_) => _login(),
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
              onPressed: busy ? null : _login,
              child: busy
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
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
            TextButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterPage())),
              child: const Text("No account? Register"),
            ),
          ]),
        ),
      ]);
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
  bool busy = false;
  bool rememberMe = true;
  String? error;

  Future<void> _register() async {
    if (!_form.currentState!.validate()) return;
    setState(() { busy = true; error = null; });
    final err = await Auth.register(nameC.text, emailC.text, userC.text, pwC.text);
    if (!mounted) return;
    if (err != null) {
      setState(() { busy = false; error = err; });
      return;
    }
    if (rememberMe) {
      final loginError = await Auth.login(userC.text, pwC.text, rememberMe: true);
      if (loginError == null && mounted) {
        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const HomeShell()), (_) => false);
        return;
      }
    } else {
      await Auth.logout();
    }
    if (!mounted) return;
    snack(context, 'Account created. Please log in.');
    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const LoginPage()), (_) => false);
  }

  @override
  Widget build(BuildContext context) => _AuthFrame(title: 'Create Admin Account', children: [
        Form(
          key: _form,
          child: Column(children: [
            TextFormField(controller: nameC, decoration: const InputDecoration(labelText: 'Full Name', prefixIcon: Icon(Icons.badge_outlined)), validator: reqRule),
            const SizedBox(height: 12),
            TextFormField(
                controller: emailC,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.mail_outline)),
                validator: emailRule),
            const SizedBox(height: 12),
            TextFormField(
              controller: userC,
              decoration: const InputDecoration(labelText: 'Username', prefixIcon: Icon(Icons.alternate_email)),
              validator: (v) => (v == null || v.trim().length < 3) ? 'At least 3 characters' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: pwC,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password', prefixIcon: Icon(Icons.lock_outline)),
              validator: (v) => (v == null || v.length < 6) ? 'At least 6 characters' : null,
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
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Register')),
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Back to Login')),
          ]),
        ),
      ]);
}

// ═════════ home ═════════

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});
  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> with SingleTickerProviderStateMixin {
  int index = 0;
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
  late final List<GlobalKey> _featureKeys = List.generate(items.length, (_) => GlobalKey());
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _activitySub;
  bool _activityReady = false;
  late final AnimationController _menuAnimation;

  @override
  void initState() {
    super.initState();
    _menuAnimation = AnimationController(vsync: this, duration: const Duration(milliseconds: 220));
    _activitySub = db.collection('activity').orderBy('createdAt', descending: true).limit(1).snapshots().listen((snapshot) {
      if (!_activityReady) {
        _activityReady = true;
        return;
      }
      for (final change in snapshot.docChanges) {
        if (change.type != DocumentChangeType.added || change.doc.data()?['actorId'] == Auth.admin?['id']) continue;
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('${change.doc.data()?['actorName']}: ${change.doc.data()?['action']} ${change.doc.data()?['subject']}'),
          ));
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
    ('Manage Members', Icons.people),
    ('Renewal', Icons.autorenew),
    ('Member Payments Tracker', Icons.receipt_long),
    ('Gross Income Tracker', Icons.trending_up),
    ('Expenses', Icons.money_off),
  ];

  Widget _page() => switch (index) {
        0 => const DashboardPage(),
        1 => const AddMemberPage(),
        2 => const ManageMembersPage(),
        3 => const RenewalPage(),
        4 => const PaymentsTrackerPage(),
        5 => const GrossIncomePage(),
        7 => AccountManagementPage(onLogout: _logout),
        _ => const ExpensesPage(),
      };

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
                translation: Offset(side * _slideDistance * (1 - animation.value), 0),
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
        context, MaterialPageRoute(builder: (_) => const LoginPage()), (_) => false);
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
              decoration: BoxDecoration(gradient: kTape, borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.fitness_center_rounded, color: Colors.white, size: 21),
            ),
          ),
        ),
        title: Text(index == 7 ? 'Edit Account' : items[index].$1),
        actions: [
          Builder(builder: (drawerContext) => IconButton(
            tooltip: _menuAnimation.isCompleted ? 'Close navigation menu' : 'Open navigation menu',
            icon: AnimatedIcon(icon: AnimatedIcons.menu_close, progress: _menuAnimation),
            onPressed: () => Scaffold.of(drawerContext).openDrawer(),
          )),
        ],
        bottom: const PreferredSize(preferredSize: Size.fromHeight(3), child: _Tape()),
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
        child: ListView(controller: _drawerScrollController, padding: EdgeInsets.zero, children: [
          DrawerHeader(
            margin: EdgeInsets.zero,
            decoration: const BoxDecoration(
              border: Border(),
              gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [kInkSoft, kInk]),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.end, children: [
              InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => _selectFromDrawer(0),
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(gradient: kTape, borderRadius: BorderRadius.circular(16)),
                  child: const Icon(Icons.fitness_center_rounded, size: 26, color: Colors.white),
                ),
              ),
              const SizedBox(height: 12),
              Text(Auth.admin?['fullName'] ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
              const SizedBox(height: 2),
              const Text('Administrator', style: TextStyle(color: kLilac, fontWeight: FontWeight.w600, fontSize: 12.5)),
            ]),
          ),
          const _Tape(),
          const SizedBox(height: 10),
          for (var i = 0; i < items.length; i++)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
              child: AnimatedContainer(
                key: _featureKeys[i],
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                decoration: BoxDecoration(
                  color: i == index ? kRed.withValues(alpha: .2) : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: i == index ? kRed.withValues(alpha: .48) : Colors.transparent),
                ),
                child: ListTile(
                  leading: Icon(items[i].$2),
                  title: Text(items[i].$1, style: const TextStyle(fontWeight: FontWeight.w700)),
                  selected: i == index,
                  selectedColor: Colors.white,
                  selectedTileColor: Colors.transparent,
                  iconColor: const Color(0xFF9B93C9),
                  textColor: const Color(0xFFD9D4F5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  onTap: () => _selectFromDrawer(i),
                ),
              ),
            ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 18, vertical: 8),
            child: Divider(color: Color(0x22FFFFFF), height: 1),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              decoration: BoxDecoration(
                color: index == 7 ? kRed.withValues(alpha: .2) : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: const Icon(Icons.manage_accounts_outlined),
                title: const Text('Edit Account', style: TextStyle(fontWeight: FontWeight.w700)),
                iconColor: index == 7 ? Colors.white : const Color(0xFF9B93C9),
                textColor: index == 7 ? Colors.white : const Color(0xFFD9D4F5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                onTap: () => _selectFromDrawer(7),
              ),
            ),
          ),
        ]),
      ),
      body: desktop
          ? Row(children: [
              NavigationRail(
                extended: MediaQuery.sizeOf(context).width >= 1200,
                selectedIndex: index < items.length ? index : null,
                onDestinationSelected: _navigateTo,
                destinations: [for (final item in items) NavigationRailDestination(icon: Icon(item.$2), label: Text(item.$1))],
              ),
              Expanded(child: _animatedPage()),
            ])
          : _animatedPage(),
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
    _email.text = profile['pendingEmail']?.toString() ?? profile['email']?.toString() ?? '';
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
    final changingEmail = requestedEmail != (Auth.admin?['email']?.toString().toLowerCase() ?? '');
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
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result)));
      return;
    }
    _currentPassword.clear();
    _newPassword.clear();
    _confirmPassword.clear();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(changingEmail
          ? 'Profile updated. Verify the link sent to your new email to finish changing it.'
          : 'Account details updated successfully.'),
    ));
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
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: kTape,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Row(children: [
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(color: Colors.white.withValues(alpha: .2), borderRadius: BorderRadius.circular(17)),
                    child: const Icon(Icons.manage_accounts_rounded, color: Colors.white, size: 30),
                  ),
                  const SizedBox(width: 14),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('Administrator account', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 3),
                    Text('Update your profile and sign-in details', style: TextStyle(color: Colors.white.withValues(alpha: .86))),
                  ])),
                ]),
              ),
              const SizedBox(height: 18),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('Profile', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 16),
                    TextFormField(controller: _name, textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(labelText: 'Full name', prefixIcon: Icon(Icons.person_outline)), validator: reqRule),
                    const SizedBox(height: 12),
                    TextFormField(controller: _username, textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(labelText: 'Username', prefixIcon: Icon(Icons.alternate_email)),
                      validator: (value) => (value == null || value.trim().length < 3) ? 'Use at least 3 characters' : null),
                    const SizedBox(height: 12),
                    TextFormField(controller: _email, keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(labelText: 'Email address', prefixIcon: Icon(Icons.email_outlined)), validator: emailRule),
                  ]),
                ),
              ),
              const SizedBox(height: 14),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('Security', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 4),
                    const Text('Confirm your current password to save account changes.', style: TextStyle(color: kMuted)),
                    const SizedBox(height: 14),
                    TextFormField(controller: _currentPassword, obscureText: true, autofillHints: const [AutofillHints.password],
                      decoration: const InputDecoration(labelText: 'Current password', prefixIcon: Icon(Icons.lock_outline)),
                      validator: (value) => (value == null || value.isEmpty) ? 'Enter your current password' : null),
                    const SizedBox(height: 12),
                    TextFormField(controller: _newPassword, obscureText: true,
                      decoration: const InputDecoration(labelText: 'New password (optional)', prefixIcon: Icon(Icons.lock_reset_outlined), helperText: 'Leave blank to keep your current password'),
                      validator: (value) => (value != null && value.isNotEmpty && value.length < 6) ? 'Use at least 6 characters' : null),
                    const SizedBox(height: 12),
                    TextFormField(controller: _confirmPassword, obscureText: true,
                      decoration: const InputDecoration(labelText: 'Confirm new password', prefixIcon: Icon(Icons.verified_user_outlined)),
                      validator: (value) => _newPassword.text.isEmpty
                          ? ((value?.isNotEmpty ?? false) ? 'Enter a new password above first' : null)
                          : value != _newPassword.text ? 'Passwords do not match' : null),
                  ]),
                ),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: _busy ? null : _save,
                icon: _busy
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.save_outlined),
                label: Text(_busy ? 'Saving…' : 'Save account changes'),
                style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 15)),
              ),
              const SizedBox(height: 20),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.logout_rounded, color: kError),
                  title: const Text('Log out', style: TextStyle(color: kError, fontWeight: FontWeight.w800)),
                  subtitle: const Text('Sign out of this administrator account'),
                  trailing: const Icon(Icons.chevron_right_rounded, color: kMuted),
                  onTap: _busy ? null : widget.onLogout,
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Nested live streams: any change to members/payments updates the cards instantly.
    return StreamBuilder<QuerySnapshot>(
      stream: db.collection('members').snapshots(),
      builder: (_, ms) => StreamBuilder<QuerySnapshot>(
        stream: db.collection('payments').snapshots(),
        builder: (_, ps) {
          if (!ms.hasData || !ps.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final members = ms.data!.docs.map((d) => d.data() as Map<String, dynamic>).toList();
          final cutoff = DateTime.now().subtract(const Duration(days: newMemberWindowDays));
          final revenue = ps.data!.docs
              .fold<double>(0, (s, d) => s + ((d.data() as Map)['amount'] as num).toDouble());
          final soon = members.where((m) => statusOf(m) == 'Expiring Soon').length;
          final expired = members.where((m) => statusOf(m) == 'Expired').length;
          final fresh = members.where((m) => dt(m['createdAt']).isAfter(cutoff)).length;
          final active = members.where((m) => statusOf(m) == 'Active').length;
          final adminName = (Auth.admin?['fullName'] ?? 'Admin').toString();

          return LayoutBuilder(builder: (context, constraints) {
            final maxWidth = constraints.maxWidth >= 900 ? 780.0 : double.infinity;
            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
              children: [
                Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: maxWidth),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      _Hero(name: adminName, total: members.length, active: active, fresh: fresh),
                      const SizedBox(height: 22),
                      const SectionTitle('The gym at one glance'),
                      IntrinsicHeight(
                        child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                          Expanded(child: _Stat('Expiring Soon', '$soon', Icons.hourglass_bottom, color: const Color(0xFFE88A00))),
                          const SizedBox(width: 10),
                          Expanded(child: _Stat('Expired Memberships', '$expired', Icons.event_busy, color: kError)),
                        ]),
                      ),
                      const SizedBox(height: 10),
                      _Stat('Total Revenue', money(revenue), Icons.payments, wide: true),
                    ]),
                  ),
                ),
              ],
            );
          });
        },
      ),
    );
  }
}

/// Dark "scoreboard" header: the one bold moment on the dashboard.
class _Hero extends StatelessWidget {
  final String name;
  final int total, active, fresh;
  const _Hero({required this.name, required this.total, required this.active, required this.fresh});

  @override
  Widget build(BuildContext context) {
    final pct = total == 0 ? 0.0 : active / total;
    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [kInk, kInkSoft]),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Stack(children: [
        Positioned(
          right: -22,
          top: -18,
          child: Transform.rotate(
            angle: .45,
            child: Icon(Icons.fitness_center_rounded, size: 170, color: Colors.white.withValues(alpha: .06)),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(DateFormat('EEEE, MMMM d').format(DateTime.now()),
                style: const TextStyle(color: kLilac, fontSize: 12.5, fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            Text('Welcome, $name',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800, letterSpacing: -.3)),
            const SizedBox(height: 24),
            Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Expanded(flex: 4, child: _HeroFigure('$total', 'Total Members', big: true)),
              Expanded(flex: 3, child: _HeroFigure('$active', 'Active')),
              Expanded(flex: 3, child: _HeroFigure('$fresh', 'New Members')),
            ]),
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
            Text('${(pct * 100).round()}% of members are active',
                style: const TextStyle(color: Color(0xFFB4ACDA), fontSize: 12, fontWeight: FontWeight.w600)),
          ]),
        ),
      ]),
    );
  }
}

class _HeroFigure extends StatelessWidget {
  final String value, label;
  final bool big;
  const _HeroFigure(this.value, this.label, {this.big = false});
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(value,
              style: TextStyle(color: Colors.white, fontSize: big ? 46 : 28, height: 1, fontWeight: FontWeight.w800, letterSpacing: -1)),
        ),
        const SizedBox(height: 6),
        Text(label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Color(0xFFB4ACDA), fontSize: 12, fontWeight: FontWeight.w600)),
      ]);
}

class _Stat extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;
  final bool wide;
  const _Stat(this.label, this.value, this.icon, {this.color = kRed, this.wide = false});

  @override
  Widget build(BuildContext context) {
    final badge = Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(color: color.withValues(alpha: .13), borderRadius: BorderRadius.circular(12)),
      child: Icon(icon, color: color, size: 21),
    );
    final number = FittedBox(
      alignment: wide ? Alignment.centerRight : Alignment.centerLeft,
      fit: BoxFit.scaleDown,
      child: Text(value,
          maxLines: 1,
          style: TextStyle(fontSize: wide ? 26 : 30, height: 1.05, fontWeight: FontWeight.w800, letterSpacing: -.5)),
    );
    final caption = Text(label,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(color: kMuted, fontSize: 12.5, fontWeight: FontWeight.w600, height: 1.15));
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5E2ED)),
      ),
      child: wide
          ? Row(children: [
              badge,
              const SizedBox(width: 12),
              Expanded(child: caption),
              const SizedBox(width: 8),
              Flexible(child: number),
            ])
          : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              badge,
              const SizedBox(height: 14),
              number,
              const SizedBox(height: 4),
              caption,
            ]),
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
      snack(context, 'Member saved. First payment of ${money(plans[type]!.price)} recorded.');
      for (final c in [nameC, contactC, emailC, addressC]) {
        c.clear();
      }
      setState(() => type = 'Daily');
    } catch (e) {
      if (mounted) snack(context, 'Failed to save member. Check your connection.');
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
              child: Column(children: [
                const _Tape(4),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: _form,
                    child: Column(children: [
                      TextFormField(controller: nameC, decoration: const InputDecoration(labelText: 'Full Name', prefixIcon: Icon(Icons.person_outline)), validator: reqRule),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: contactC,
                        keyboardType: TextInputType.phone,
                        maxLength: 10,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(10)],
                        decoration: const InputDecoration(labelText: 'Mobile Number', prefixIcon: Icon(Icons.phone_outlined), prefixText: '+63 ', counterText: ''),
                        validator: (v) => (v == null || !RegExp(r'^9\d{9}$').hasMatch(v.trim())) ? 'Enter 10 digits starting with 9' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                          controller: emailC,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.mail_outline)),
                          validator: emailRule),
                      const SizedBox(height: 12),
                      TextFormField(controller: addressC, decoration: const InputDecoration(labelText: 'Address', prefixIcon: Icon(Icons.location_on_outlined)), validator: reqRule),
                      const SizedBox(height: 20),
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text('Membership Type', style: TextStyle(fontWeight: FontWeight.w800)),
                      ),
                      const SizedBox(height: 10),
                      _PlanPicker(selected: type, onChanged: (v) => setState(() => type = v)),
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(color: kRed.withValues(alpha: .08), borderRadius: BorderRadius.circular(12)),
                        child: Row(children: [
                          const Icon(Icons.event_available_outlined, size: 18, color: kRed),
                          const SizedBox(width: 8),
                          Text(
                            'Expires: ${fmtDate(DateTime.now().add(Duration(days: plans[type]!.days)))}',
                            style: const TextStyle(color: kDarkRed, fontWeight: FontWeight.w700),
                          ),
                        ]),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                          onPressed: busy ? null : _save,
                          child: busy
                              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                              : const Text('Save Member')),
                    ]),
                  ),
                ),
              ]),
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

  Stream<QuerySnapshot> _make() =>
      db.collection('members').orderBy('memberId', descending: !asc).snapshots();

  Future<void> _edit(String id, Map<String, dynamic> m) async {
    final form = GlobalKey<FormState>();
    final n = TextEditingController(text: m['fullName']);
    final c = TextEditingController(text: (m['contact'] as String).replaceFirst(RegExp(r'^\+63'), ''));
    final e = TextEditingController(text: m['email']);
    final a = TextEditingController(text: m['address']);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Member'),
        content: SingleChildScrollView(
          child: Form(
            key: form,
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              TextFormField(controller: n, decoration: const InputDecoration(labelText: 'Full Name'), validator: reqRule),
              const SizedBox(height: 8),
              TextFormField(controller: c, keyboardType: TextInputType.phone, maxLength: 10,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(10)],
                decoration: const InputDecoration(labelText: 'Mobile Number', prefixText: '+63 ', counterText: ''),
                validator: (v) => (v == null || !RegExp(r'^9\d{9}$').hasMatch(v.trim())) ? 'Enter 10 digits starting with 9' : null),
              const SizedBox(height: 8),
              TextFormField(controller: e, decoration: const InputDecoration(labelText: 'Email'), validator: emailRule),
              const SizedBox(height: 8),
              TextFormField(controller: a, decoration: const InputDecoration(labelText: 'Address'), validator: reqRule),
            ]),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
              onPressed: () {
                if (form.currentState!.validate()) Navigator.pop(ctx, true);
              },
              child: const Text('Save')),
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
    if (!await confirm(context, 'Delete Member', 'Delete $name? This cannot be undone.')) return;
    await db.collection('members').doc(id).delete();
    await recordChange('Deleted member', subject: name);
    if (mounted) snack(context, 'Member deleted.');
  }

  Future<void> _toggleFreeze(String id, Map<String, dynamic> m) async {
    final frozen = m['status'] == 'Frozen';
    if (!await confirm(context, frozen ? 'Unfreeze' : 'Freeze',
        '${frozen ? 'Unfreeze' : 'Freeze'} ${m['fullName']}\'s membership?')) {
      return;
    }
    await db.collection('members').doc(id).update({'status': frozen ? 'Active' : 'Frozen'});
    await recordChange(frozen ? 'Unfroze membership' : 'Froze membership', subject: m['fullName']);
  }

  @override
  Widget build(BuildContext context) => Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
          child: Row(children: [
            Expanded(
              child: TextField(
                controller: searchC,
                decoration: const InputDecoration(labelText: 'Search by full name', prefixIcon: Icon(Icons.search), isDense: true),
                onChanged: (_) => setState(() {}),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              style: tonalIcon(),
              tooltip: asc ? 'Member ID ascending' : 'Member ID descending',
              icon: Icon(asc ? Icons.arrow_upward : Icons.arrow_downward),
              onPressed: () => setState(() { asc = !asc; stream = _make(); }),
            ),
            const SizedBox(width: 4),
            IconButton(
              style: tonalIcon(),
              tooltip: 'Reset',
              icon: const Icon(Icons.refresh),
              onPressed: () => setState(() { searchC.clear(); asc = true; stream = _make(); }),
            ),
          ]),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: stream,
            builder: (_, snap) {
              if (snap.hasError) return const EmptyState('Failed to load members.');
              if (!snap.hasData) return const Center(child: CircularProgressIndicator());
              final q = searchC.text.trim().toLowerCase();
              final docs = snap.data!.docs
                  .where((d) => (d['fullName'] as String).toLowerCase().contains(q))
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
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      _MemberHeader(m, st),
                      const SizedBox(height: 8),
                      _Info(Icons.phone_outlined, '${m['contact']}'),
                      _Info(Icons.mail_outline, '${m['email']}'),
                      _Info(Icons.location_on_outlined, '${m['address']}'),
                      const SizedBox(height: 12),
                      Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                        _ActionBtn(Icons.edit_outlined, kRed, 'Edit', () => _edit(id, m)),
                        const SizedBox(width: 8),
                        _ActionBtn(Icons.print_outlined, kMuted, 'Print', () => PdfService.memberRecord(m, st)),
                        const SizedBox(width: 8),
                        _ActionBtn(frozen ? Icons.play_circle_outline : Icons.ac_unit, const Color(0xFF2A9DF4),
                            frozen ? 'Unfreeze' : 'Freeze', () => _toggleFreeze(id, m)),
                        const SizedBox(width: 8),
                        _ActionBtn(Icons.delete_outline, kError, 'Delete', () => _delete(id, m['fullName'])),
                      ]),
                    ]),
                  );
                },
              );
            },
          ),
        ),
      ]);
}

// ───────── Renewal ─────────
class RenewalPage extends StatelessWidget {
  const RenewalPage({super.key});

  Future<void> _renew(BuildContext context, String id, Map<String, dynamic> m) async {
    if (m['status'] == 'Frozen') {
      snack(context, 'Unfreeze this member before renewing.');
      return;
    }
    String type = m['membershipType'];
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, set) => AlertDialog(
          title: Text('Renew ${m['fullName']}'),
          content: _PlanPicker(selected: type, onChanged: (v) => set(() => type = v)),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
            TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text('Pay ${money(plans[type]!.price)}')),
          ],
        ),
      ),
    );
    if (ok != true) return;
    await renewMember(id, m, type);
    if (context.mounted) snack(context, 'Membership renewed.');
  }

  @override
  Widget build(BuildContext context) => StreamBuilder<QuerySnapshot>(
        stream: db.collection('members').orderBy('memberId').snapshots(),
        builder: (_, snap) {
          if (snap.hasError) return const EmptyState('Failed to load members.');
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          final docs = snap.data!.docs;
          if (docs.isEmpty) return const EmptyState('No members to renew.');
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: docs.length,
            itemBuilder: (_, i) {
              final m = docs[i].data() as Map<String, dynamic>;
              final exp = dt(m['expirationDate']);
              final st = statusOf(m);
              final planDays = plans[m['membershipType']]?.days ?? 30;
              return MemberCard(
                stripe: statusColor(st),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  _MemberHeader(m, st),
                  const SizedBox(height: 12),
                  _ExpiryBar(exp: exp, planDays: planDays, color: statusColor(st)),
                  const SizedBox(height: 6),
                  _Info(Icons.phone_outlined, '${m['contact']}'),
                  _Info(Icons.mail_outline, '${m['email']}'),
                  _Info(Icons.history, 'Added ${fmtDateTime(dt(m['createdAt']))}'),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(minimumSize: const Size(140, 44)),
                      onPressed: () => _renew(context, docs[i].id, m),
                      icon: const Icon(Icons.autorenew),
                      label: const Text('Renew'),
                    ),
                  ),
                ]),
              );
            },
          );
        },
      );
}

// ═════════ finance ═════════

Widget _hscroll(Widget table) => Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE9E7F0)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: ConstrainedBox(constraints: const BoxConstraints(minWidth: 600), child: table),
      ),
    );

// ───────── Member Payments Tracker ─────────
class PaymentsTrackerPage extends StatefulWidget {
  const PaymentsTrackerPage({super.key});
  @override
  State<PaymentsTrackerPage> createState() => _PaymentsTrackerPageState();
}

class _PaymentsTrackerPageState extends State<PaymentsTrackerPage> {
  final nameC = TextEditingController();
  String? type, aType;
  int? month, aMonth, year, aYear;
  String aName = '';
  final stream = db.collection('payments').orderBy('paymentDate', descending: true).snapshots();

  Widget _dd<T>(String label, T? value, List<DropdownMenuItem<T>> items, ValueChanged<T?> cb) =>
      SizedBox(
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
    return Column(children: [
      Padding(
        padding: const EdgeInsets.all(12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: kCard,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE9E7F0)),
          ),
          child: Wrap(spacing: 8, runSpacing: 8, crossAxisAlignment: WrapCrossAlignment.center, children: [
          SizedBox(
            width: 180,
            child: TextField(controller: nameC, decoration: const InputDecoration(labelText: 'Member name', isDense: true)),
          ),
          _dd<String>('Type', type, [for (final t in plans.keys) DropdownMenuItem(value: t, child: Text(t))], (v) => setState(() => type = v)),
          _dd<int>('Month', month, [for (var m = 1; m <= 12; m++) DropdownMenuItem(value: m, child: Text(DateFormat.MMMM().format(DateTime(2000, m))))], (v) => setState(() => month = v)),
          _dd<int>('Year', year, [for (var y = yr; y >= yr - 5; y--) DropdownMenuItem(value: y, child: Text('$y'))], (v) => setState(() => year = v)),
          ElevatedButton(
            style: ElevatedButton.styleFrom(minimumSize: const Size(110, 44)),
            onPressed: () => setState(() {
              aName = nameC.text.trim().toLowerCase();
              aType = type; aMonth = month; aYear = year;
            }),
            child: const Text('Apply Filters'),
          ),
          OutlinedButton(
            onPressed: () => setState(() {
              nameC.clear();
              type = aType = null; month = aMonth = null; year = aYear = null; aName = '';
            }),
            child: const Text('Reset'),
          ),
        ])),
      ),
      Expanded(
        child: StreamBuilder<QuerySnapshot>(
          stream: stream,
          builder: (_, snap) {
            if (snap.hasError) return const EmptyState('Failed to load payments.');
            if (!snap.hasData) return const Center(child: CircularProgressIndicator());
            final rows = snap.data!.docs.map((d) => d.data() as Map<String, dynamic>).where((p) {
              final d = dt(p['paymentDate']);
              if (aName.isNotEmpty && !(p['memberName'] as String).toLowerCase().contains(aName)) return false;
              if (aType != null && p['type'] != aType) return false;
              if (aMonth != null && d.month != aMonth) return false;
              if (aYear != null && d.year != aYear) return false;
              return true;
            }).toList();
            if (rows.isEmpty) return const EmptyState('No payments match.');
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
              child: _hscroll(DataTable(
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
                  for (final p in rows)
                    DataRow(cells: [
                      DataCell(Text('${p['memberId']}')),
                      DataCell(Text(p['memberName'])),
                      DataCell(Text(p['type'])),
                      DataCell(Text(money(p['amount']))),
                      DataCell(Text(fmtDate(dt(p['paymentDate'])))),
                      DataCell(Text(fmtDate(dt(p['expirationDate'])))),
                      DataCell(StatusChip(dt(p['expirationDate']).isAfter(DateTime.now()) ? 'Active' : 'Expired')),
                    ]),
                ],
              )),
            );
          },
        ),
      ),
    ]);
  }
}

// ───────── Expenses ─────────
class ExpensesPage extends StatefulWidget {
  const ExpensesPage({super.key});
  @override
  State<ExpensesPage> createState() => _ExpensesPageState();
}

class _ExpensesPageState extends State<ExpensesPage> {
  static const types = ['Utilities', 'Maintenance', 'Salaries', 'Supplies', 'Other'];
  final _form = GlobalKey<FormState>();
  final amountC = TextEditingController();
  String type = types.first;
  bool busy = false;
  final stream = db.collection('expenses').orderBy('createdAt', descending: true).snapshots();

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
  Widget build(BuildContext context) => ListView(padding: const EdgeInsets.all(16), children: [
        Card(child: Padding(padding: const EdgeInsets.all(16), child: Form(
          key: _form,
          child: Column(children: [
            DropdownButtonFormField<String>(
              initialValue: type,
              decoration: const InputDecoration(labelText: 'Expense Type'),
              items: types.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
              onChanged: (v) => setState(() => type = v!),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: amountC,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Amount', prefixText: '₱ '),
              validator: (v) {
                final n = double.tryParse((v ?? '').trim());
                return (n == null || n <= 0) ? 'Enter an amount greater than 0' : null;
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton(
                onPressed: busy ? null : _save,
                child: busy
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Save Expense')),
          ]),
        ))),
        const SizedBox(height: 20),
        StreamBuilder<QuerySnapshot>(
          stream: stream,
          builder: (_, snap) {
            if (snap.hasError) return const EmptyState('Failed to load expenses.');
            if (!snap.hasData) return const Center(child: CircularProgressIndicator());
            final list = snap.data!.docs.map((d) => d.data() as Map<String, dynamic>).toList();
            final total = list.fold<double>(0, (s, e) => s + (e['amount'] as num));
            return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: kCard,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE9E7F0)),
                ),
                child: Row(children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(color: kError.withValues(alpha: .1), borderRadius: BorderRadius.circular(12)),
                    child: const Icon(Icons.money_off, color: kError, size: 21),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(child: Text('Total Expenses', style: TextStyle(color: kMuted, fontWeight: FontWeight.w700))),
                  Text(money(total), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, letterSpacing: -.3)),
                ]),
              ),
              const SizedBox(height: 16),
              const SectionTitle('Expense History'),
              if (list.isEmpty)
                const EmptyState('No expenses recorded.')
              else
                _hscroll(DataTable(
                  columns: const [
                    DataColumn(label: Text('ID')),
                    DataColumn(label: Text('Type')),
                    DataColumn(label: Text('Amount')),
                    DataColumn(label: Text('Date Recorded')),
                  ],
                  rows: [
                    for (final e in list)
                      DataRow(cells: [
                        DataCell(Text('${e['expenseId']}')),
                        DataCell(Text(e['type'])),
                        DataCell(Text(money(e['amount']))),
                        DataCell(Text(fmtDateTime(dt(e['createdAt'])))),
                      ]),
                  ],
                )),
            ]);
          },
        ),
      ]);
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
  final pStream = db.collection('payments').orderBy('paymentDate', descending: true).snapshots();
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
            if (ps.hasError || es.hasError) return const EmptyState('Failed to load data.');
            if (!ps.hasData || !es.hasData) return const Center(child: CircularProgressIndicator());
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

            return ListView(padding: const EdgeInsets.all(16), children: [
              Wrap(spacing: 8, runSpacing: 8, crossAxisAlignment: WrapCrossAlignment.center, children: [
                OutlinedButton.icon(onPressed: () => _pick(true), icon: const Icon(Icons.calendar_today, size: 16), label: Text('From: ${fmtDate(from)}')),
                OutlinedButton.icon(onPressed: () => _pick(false), icon: const Icon(Icons.calendar_today, size: 16), label: Text('To: ${fmtDate(to)}')),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(minimumSize: const Size(100, 44)),
                  onPressed: () {
                    if (to.isBefore(from)) {
                      snack(context, '"To" date must be on or after "From" date.');
                      return;
                    }
                    setState(() { aFrom = from; aTo = to; });
                  },
                  child: const Text('Filter'),
                ),
              ]),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [kInk, kInkSoft]),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Column(children: [
                  _row('Date Range', range),
                  _row('Total Income', money(income)),
                  _row('Total Expenses', money(expenses)),
                  const Divider(color: Color(0x33FFFFFF), height: 22),
                  _row('Net Income', money(net), color: net >= 0 ? const Color(0xFF5BE3A0) : const Color(0xFFFF8FA3), big: true),
                ]),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () => PdfService.incomeReport(
                  range: range,
                  income: income,
                  expenses: expenses,
                  rows: [for (final p in pays) [fmtDate(dt(p['paymentDate'])), p['memberName'], p['type'], 'PHP ${(p['amount'] as num).toStringAsFixed(2)}']],
                ),
                icon: const Icon(Icons.picture_as_pdf),
                label: const Text('Print Report'),
              ),
              const SizedBox(height: 16),
              const SectionTitle('Income Details'),
              if (pays.isEmpty)
                const EmptyState('No income in this date range.')
              else
                _hscroll(DataTable(
                  columns: const [
                    DataColumn(label: Text('Date')),
                    DataColumn(label: Text('Member')),
                    DataColumn(label: Text('Type')),
                    DataColumn(label: Text('Amount')),
                  ],
                  rows: [
                    for (final p in pays)
                      DataRow(cells: [
                        DataCell(Text(fmtDate(dt(p['paymentDate'])))),
                        DataCell(Text(p['memberName'])),
                        DataCell(Text(p['type'])),
                        DataCell(Text(money(p['amount']))),
                      ]),
                  ],
                )),
            ]);
          },
        ),
      );

  Widget _row(String l, String v, {Color? color, bool big = false}) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(l, style: const TextStyle(color: Color(0xFFB4ACDA), fontWeight: FontWeight.w600)),
          const SizedBox(width: 12),
          Flexible(
            child: Text(v,
                textAlign: TextAlign.right,
                style: TextStyle(color: color ?? Colors.white, fontSize: big ? 26 : 16, fontWeight: FontWeight.w800, letterSpacing: big ? -.4 : 0)),
          ),
        ]),
      );
}

// ═════════ pdf_service ═════════

/// Note: the default PDF font has no ₱ glyph, so PDFs use the "PHP" prefix.
class PdfService {
  static final PdfColor _brandViolet = PdfColor.fromInt(0xFF6857D9);

  static pw.Widget _line(String k, String v) => pw.Padding(
        padding: const pw.EdgeInsets.symmetric(vertical: 4),
        child: pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
          pw.SizedBox(width: 130, child: pw.Text(k, style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
          pw.Expanded(child: pw.Text(v)),
        ]),
      );

  static Future<void> memberRecord(Map<String, dynamic> m, String status) async {
    final doc = pw.Document();
    doc.addPage(pw.Page(
      build: (_) => pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
        pw.Text('FitCore', style: pw.TextStyle(fontSize: 26, fontWeight: pw.FontWeight.bold, color: _brandViolet)),
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
        pw.Text('Printed ${fmtDateTime(DateTime.now())}', style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
      ]),
    ));
    await Printing.layoutPdf(onLayout: (_) => doc.save(), name: 'member_${m['memberId']}.pdf');
  }

  static Future<void> incomeReport({
    required String range,
    required double income,
    required double expenses,
    required List<List<String>> rows,
  }) async {
    String php(double n) => 'PHP ${n.toStringAsFixed(2)}';
    final doc = pw.Document();
    doc.addPage(pw.MultiPage(
      build: (_) => [
        pw.Text('FitCore', style: pw.TextStyle(fontSize: 26, fontWeight: pw.FontWeight.bold, color: _brandViolet)),
        pw.Text('Gross Income Report'),
        pw.Divider(),
        _line('Date Range', range),
        _line('Total Income', php(income)),
        _line('Total Expenses', php(expenses)),
        _line('Net Income', php(income - expenses)),
        pw.SizedBox(height: 16),
        pw.Text('Income Details', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 6),
        if (rows.isEmpty)
          pw.Text('No income in this range.')
        else
          pw.TableHelper.fromTextArray(
            headers: ['Date', 'Member', 'Type', 'Amount'],
            data: rows,
            headerDecoration: pw.BoxDecoration(color: _brandViolet),
            headerStyle: pw.TextStyle(color: PdfColors.white, fontWeight: pw.FontWeight.bold),
            cellAlignment: pw.Alignment.centerLeft,
          ),
      ],
    ));
    await Printing.layoutPdf(onLayout: (_) => doc.save(), name: 'gross_income_report.pdf');
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
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
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
            return const _StartupScreen(message: 'Unable to connect. Please restart the app.');
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
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(gradient: kTape, borderRadius: BorderRadius.circular(22)),
              child: const Icon(Icons.fitness_center_rounded, size: 40, color: Colors.white),
            ),
            const SizedBox(height: 24),
            const SizedBox(width: 26, height: 26, child: CircularProgressIndicator(strokeWidth: 3, color: kLilac)),
            const SizedBox(height: 16),
            Text(message, style: const TextStyle(color: Color(0xFFB4ACDA), fontWeight: FontWeight.w600)),
          ]),
        ),
      );
}
