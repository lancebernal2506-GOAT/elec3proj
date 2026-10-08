import 'dart:convert';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';

// ═════════ core ═════════

// ───────── Theme ─────────
const kRed = Color(0xFFD71920);
const kDarkRed = Color(0xFF8E0E13);
const kBlack = Color(0xFF0B0B0B);
const kCard = Color(0xFF1A1A1A);

ThemeData appTheme() => ThemeData(
      brightness: Brightness.dark,
      useMaterial3: true,
      scaffoldBackgroundColor: kBlack,
      colorScheme: const ColorScheme.dark(
          primary: kRed, secondary: kDarkRed, surface: kCard),
      appBarTheme: const AppBarTheme(
          backgroundColor: kDarkRed, foregroundColor: Colors.white),
      drawerTheme: const DrawerThemeData(backgroundColor: kBlack),
      inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(), filled: true, fillColor: kCard),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
            backgroundColor: kRed,
            foregroundColor: Colors.white,
            minimumSize: const Size.fromHeight(48)),
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
  const EmptyState(this.text, {super.key});
  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.inbox, size: 56, color: Colors.white38),
            const SizedBox(height: 8),
            Text(text, style: const TextStyle(color: Colors.white54)),
          ]),
        ),
      );
}

class StatusChip extends StatelessWidget {
  final String status;
  const StatusChip(this.status, {super.key});
  @override
  Widget build(BuildContext context) {
    final c = switch (status) {
      'Active' => Colors.green,
      'Expiring Soon' => Colors.orange,
      'Frozen' => Colors.lightBlue,
      _ => kRed,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
          color: c.withValues(alpha: .2),
          border: Border.all(color: c),
          borderRadius: BorderRadius.circular(12)),
      child: Text(status, style: TextStyle(color: c, fontSize: 12)),
    );
  }
}

// ───────── Firestore ─────────
final db = FirebaseFirestore.instance;

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
}

// ───────── Auth (admin accounts in Firestore, salted+iterated SHA-256) ─────────
class Auth {
  static Map<String, dynamic>? admin;

  static String _salt() {
    final r = Random.secure();
    return base64Url.encode(List.generate(16, (_) => r.nextInt(256)));
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
      if (id == null) return false;
      final d = await db.collection('admins').doc(id).get();
      if (!d.exists) return false;
      admin = {...d.data()!, 'id': d.id};
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
      final a = await db.collection('admins').where('usernameLower', isEqualTo: u).limit(1).get();
      if (a.docs.isNotEmpty) return 'Username is already taken.';
      final b = await db.collection('admins').where('emailLower', isEqualTo: e).limit(1).get();
      if (b.docs.isNotEmpty) return 'Email is already registered.';
      final salt = _salt();
      await db.collection('admins').add({
        'fullName': name.trim(),
        'email': email.trim(),
        'emailLower': e,
        'username': username.trim(),
        'usernameLower': u,
        'salt': salt,
        'passwordHash': _hash(pw, salt),
        'role': 'Administrator',
        'createdAt': Timestamp.now(),
      });
      return null;
    } catch (_) {
      return 'Something went wrong. Please try again.';
    }
  }

  static Future<String?> login(String id, String pw) async {
    const generic = 'Invalid username/email or password.';
    final k = id.trim().toLowerCase();
    try {
      var q = await db.collection('admins').where('usernameLower', isEqualTo: k).limit(1).get();
      if (q.docs.isEmpty) {
        q = await db.collection('admins').where('emailLower', isEqualTo: k).limit(1).get();
      }
      if (q.docs.isEmpty) return generic;
      final d = q.docs.first;
      final data = d.data();
      if (_hash(pw, data['salt']) != data['passwordHash']) return generic;
      admin = {...data, 'id': d.id};
      final p = await SharedPreferences.getInstance();
      await p.setString('adminId', d.id);
      return null;
    } catch (_) {
      return 'Something went wrong. Please try again.';
    }
  }

  static Future<void> logout() async {
    admin = null;
    final p = await SharedPreferences.getInstance();
    await p.remove('adminId');
  }
}

// ═════════ auth_pages ═════════

class _AuthFrame extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _AuthFrame({required this.title, required this.children});
  @override
  Widget build(BuildContext context) => Scaffold(
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(children: [
                const Icon(Icons.fitness_center, size: 64, color: kRed),
                const Text('ActiveSync',
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(title, style: const TextStyle(color: Colors.white70)),
                const SizedBox(height: 24),
                ...children,
              ]),
            ),
          ),
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
  String? error;

  Future<void> _login() async {
    if (!_form.currentState!.validate()) return;
    setState(() { busy = true; error = null; });
    final err = await Auth.login(idC.text, pwC.text);
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
              decoration: const InputDecoration(labelText: 'Username or Email', prefixIcon: Icon(Icons.person)),
              validator: reqRule,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: pwC,
              obscureText: hide,
              decoration: InputDecoration(
                labelText: 'Password',
                prefixIcon: const Icon(Icons.lock),
                suffixIcon: IconButton(
                    icon: Icon(hide ? Icons.visibility : Icons.visibility_off),
                    onPressed: () => setState(() => hide = !hide)),
              ),
              validator: reqRule,
              onFieldSubmitted: (_) => _login(),
            ),
            if (error != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(error!, style: const TextStyle(color: kRed)),
              ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: busy ? null : _login,
              child: busy
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Login'),
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
    snack(context, 'Account created. Please log in.');
    Navigator.pushAndRemoveUntil(
        context, MaterialPageRoute(builder: (_) => const LoginPage()), (_) => false);
  }

  @override
  Widget build(BuildContext context) => _AuthFrame(title: 'Create Admin Account', children: [
        Form(
          key: _form,
          child: Column(children: [
            TextFormField(controller: nameC, decoration: const InputDecoration(labelText: 'Full Name'), validator: reqRule),
            const SizedBox(height: 12),
            TextFormField(
                controller: emailC,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: emailRule),
            const SizedBox(height: 12),
            TextFormField(
              controller: userC,
              decoration: const InputDecoration(labelText: 'Username'),
              validator: (v) => (v == null || v.trim().length < 3) ? 'At least 3 characters' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: pwC,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password'),
              validator: (v) => (v == null || v.length < 6) ? 'At least 6 characters' : null,
            ),
            if (error != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(error!, style: const TextStyle(color: kRed)),
              ),
            const SizedBox(height: 20),
            ElevatedButton(
                onPressed: busy ? null : _register,
                child: busy
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
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

class _HomeShellState extends State<HomeShell> {
  int index = 0;

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
        _ => const ExpensesPage(),
      };

  Future<void> _logout() async {
    Navigator.pop(context); // close drawer
    if (!await confirm(context, 'Logout', 'Do you want to log out?')) return;
    await Auth.logout();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
        context, MaterialPageRoute(builder: (_) => const LoginPage()), (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(items[index].$1)),
      drawer: Drawer(
        child: ListView(children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: kDarkRed),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.end, children: [
              const Icon(Icons.fitness_center, size: 40),
              const SizedBox(height: 8),
              Text(Auth.admin?['fullName'] ?? '', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const Text('Administrator'),
            ]),
          ),
          for (var i = 0; i < items.length; i++)
            ListTile(
              leading: Icon(items[i].$2, color: i == index ? kRed : Colors.white70),
              title: Text(items[i].$1),
              selected: i == index,
              selectedColor: kRed,
              onTap: () {
                Navigator.pop(context);
                setState(() => index = i);
              },
            ),
          const Divider(),
          ListTile(leading: const Icon(Icons.logout), title: const Text('Logout'), onTap: _logout),
        ]),
      ),
      body: _page(),
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

          final cards = [
            _Stat('Total Members', '${members.length}', Icons.groups),
            _Stat('Expiring Soon', '$soon', Icons.hourglass_bottom),
            _Stat('Total Revenue', money(revenue), Icons.payments),
            _Stat('New Members', '$fresh', Icons.person_add_alt_1),
            _Stat('Expired Memberships', '$expired', Icons.event_busy),
          ];

          return ListView(padding: const EdgeInsets.all(16), children: [
            Text('Welcome, ${Auth.admin?['fullName'] ?? ''}',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const Text('Administrator', style: TextStyle(color: kRed)),
            const SizedBox(height: 16),
            LayoutBuilder(builder: (_, c) {
              final cols = c.maxWidth > 700 ? 3 : 2;
              return GridView.count(
                crossAxisCount: cols,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.4,
                children: cards,
              );
            }),
          ]);
        },
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label, value;
  final IconData icon;
  const _Stat(this.label, this.value, this.icon);
  @override
  Widget build(BuildContext context) => Card(
        color: kCard,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: kDarkRed)),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Icon(icon, color: kRed),
            FittedBox(child: Text(value, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold))),
            Text(label, style: const TextStyle(color: Colors.white70)),
          ]),
        ),
      );
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
        contact: contactC.text.trim(),
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
        child: Form(
          key: _form,
          child: Column(children: [
            TextFormField(controller: nameC, decoration: const InputDecoration(labelText: 'Full Name'), validator: reqRule),
            const SizedBox(height: 12),
            TextFormField(
              controller: contactC,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: 'Contact Number'),
              validator: (v) => (v == null || v.trim().length < 7) ? 'Enter a valid contact number' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
                controller: emailC,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: emailRule),
            const SizedBox(height: 12),
            TextFormField(controller: addressC, decoration: const InputDecoration(labelText: 'Address'), validator: reqRule),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: type,
              decoration: const InputDecoration(labelText: 'Membership Type'),
              items: plans.keys.map((t) => DropdownMenuItem(value: t, child: Text(planLabel(t)))).toList(),
              onChanged: (v) => setState(() => type = v!),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Expires: ${fmtDate(DateTime.now().add(Duration(days: plans[type]!.days)))}',
                style: const TextStyle(color: Colors.white60),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
                onPressed: busy ? null : _save,
                child: busy
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Save Member')),
          ]),
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
    final c = TextEditingController(text: m['contact']);
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
              TextFormField(controller: c, decoration: const InputDecoration(labelText: 'Contact'), validator: reqRule),
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
      'contact': c.text.trim(),
      'email': e.text.trim(),
      'address': a.text.trim(),
    });
    if (mounted) snack(context, 'Member updated.');
  }

  Future<void> _delete(String id, String name) async {
    if (!await confirm(context, 'Delete Member', 'Delete $name? This cannot be undone.')) return;
    await db.collection('members').doc(id).delete();
    if (mounted) snack(context, 'Member deleted.');
  }

  Future<void> _toggleFreeze(String id, Map<String, dynamic> m) async {
    final frozen = m['status'] == 'Frozen';
    if (!await confirm(context, frozen ? 'Unfreeze' : 'Freeze',
        '${frozen ? 'Unfreeze' : 'Freeze'} ${m['fullName']}\'s membership?')) {
      return;
    }
    await db.collection('members').doc(id).update({'status': frozen ? 'Active' : 'Frozen'});
  }

  @override
  Widget build(BuildContext context) => Column(children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(children: [
            Expanded(
              child: TextField(
                controller: searchC,
                decoration: const InputDecoration(labelText: 'Search by full name', prefixIcon: Icon(Icons.search), isDense: true),
                onChanged: (_) => setState(() {}),
              ),
            ),
            IconButton(
              tooltip: asc ? 'Member ID ascending' : 'Member ID descending',
              icon: Icon(asc ? Icons.arrow_upward : Icons.arrow_downward),
              onPressed: () => setState(() { asc = !asc; stream = _make(); }),
            ),
            IconButton(
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
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: docs.length,
                itemBuilder: (_, i) {
                  final m = docs[i].data() as Map<String, dynamic>;
                  final id = docs[i].id;
                  final st = statusOf(m);
                  return Card(
                    color: kCard,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Row(children: [
                          Text('#${m['memberId']}', style: const TextStyle(color: kRed, fontWeight: FontWeight.bold)),
                          const SizedBox(width: 8),
                          Expanded(child: Text(m['fullName'], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
                          StatusChip(st),
                        ]),
                        const SizedBox(height: 6),
                        Text('📞 ${m['contact']}'),
                        Text('✉ ${m['email']}'),
                        Text('📍 ${m['address']}'),
                        Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                          IconButton(tooltip: 'Edit', icon: const Icon(Icons.edit), onPressed: () => _edit(id, m)),
                          IconButton(tooltip: 'Delete', icon: const Icon(Icons.delete, color: kRed), onPressed: () => _delete(id, m['fullName'])),
                          IconButton(tooltip: 'Print', icon: const Icon(Icons.print), onPressed: () => PdfService.memberRecord(m, st)),
                          IconButton(
                            tooltip: m['status'] == 'Frozen' ? 'Unfreeze' : 'Freeze',
                            icon: Icon(m['status'] == 'Frozen' ? Icons.play_circle : Icons.ac_unit, color: Colors.lightBlue),
                            onPressed: () => _toggleFreeze(id, m),
                          ),
                        ]),
                      ]),
                    ),
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
          content: DropdownButtonFormField<String>(
            initialValue: type,
            decoration: const InputDecoration(labelText: 'Membership Type'),
            items: plans.keys.map((t) => DropdownMenuItem(value: t, child: Text(planLabel(t)))).toList(),
            onChanged: (v) => set(() => type = v!),
          ),
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
              return Card(
                color: kCard,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      Text('#${m['memberId']}', style: const TextStyle(color: kRed, fontWeight: FontWeight.bold)),
                      const SizedBox(width: 8),
                      Expanded(child: Text(m['fullName'], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
                      StatusChip(statusOf(m)),
                    ]),
                    const SizedBox(height: 6),
                    Text('${m['contact']}  •  ${m['email']}'),
                    Text('Type: ${m['membershipType']}'),
                    Text('Expires: ${fmtDate(exp)}  (${daysLeft(exp)} days remaining)'),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: SizedBox(
                        width: 130,
                        child: ElevatedButton.icon(
                          onPressed: () => _renew(context, docs[i].id, m),
                          icon: const Icon(Icons.autorenew),
                          label: const Text('Renew'),
                        ),
                      ),
                    ),
                  ]),
                ),
              );
            },
          );
        },
      );
}

// ═════════ finance ═════════

Widget _hscroll(Widget table) => SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: ConstrainedBox(constraints: const BoxConstraints(minWidth: 600), child: table),
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
        ]),
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
        Form(
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
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Save Expense')),
          ]),
        ),
        const SizedBox(height: 20),
        StreamBuilder<QuerySnapshot>(
          stream: stream,
          builder: (_, snap) {
            if (snap.hasError) return const EmptyState('Failed to load expenses.');
            if (!snap.hasData) return const Center(child: CircularProgressIndicator());
            final list = snap.data!.docs.map((d) => d.data() as Map<String, dynamic>).toList();
            final total = list.fold<double>(0, (s, e) => s + (e['amount'] as num));
            return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Card(
                color: kCard,
                child: ListTile(
                  leading: const Icon(Icons.money_off, color: kRed),
                  title: const Text('Total Expenses'),
                  trailing: Text(money(total), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 8),
              const Text('Expense History', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
              Card(
                color: kCard,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: kDarkRed)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(children: [
                    _row('Date Range', range),
                    _row('Total Income', money(income)),
                    _row('Total Expenses', money(expenses)),
                    const Divider(),
                    _row('Net Income', money(net), color: net >= 0 ? Colors.green : kRed, big: true),
                  ]),
                ),
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
              const Text('Income Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
          Text(l, style: const TextStyle(color: Colors.white70)),
          Flexible(child: Text(v, textAlign: TextAlign.right, style: TextStyle(color: color, fontSize: big ? 22 : 16, fontWeight: FontWeight.bold))),
        ]),
      );
}

// ═════════ pdf_service ═════════

/// Note: the default PDF font has no ₱ glyph, so PDFs use the "PHP" prefix.
class PdfService {
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
        pw.Text('ActiveSync', style: pw.TextStyle(fontSize: 26, fontWeight: pw.FontWeight.bold, color: PdfColors.red800)),
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
        pw.Text('ActiveSync', style: pw.TextStyle(fontSize: 26, fontWeight: pw.FontWeight.bold, color: PdfColors.red800)),
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
            headerDecoration: const pw.BoxDecoration(color: PdfColors.red800),
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
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  final loggedIn = await Auth.restore();
  runApp(MyApp(loggedIn: loggedIn));
}

class MyApp extends StatelessWidget {
  final bool loggedIn;
  const MyApp({super.key, required this.loggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ActiveSync',
      debugShowCheckedModeBanner: false,
      theme: appTheme(),
      home: loggedIn ? const HomeShell() : const LoginPage(),
    );
  }
}