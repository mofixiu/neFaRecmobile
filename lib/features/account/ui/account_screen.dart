import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/api_client.dart';
import '../../../core/theme/tokens.dart';
import '../../../shared/widgets/controls.dart';
import '../../../shared/widgets/sheet.dart';
import '../../../shared/widgets/surfaces.dart';
import '../../settings/settings_controller.dart';
import '../../workout/domain/session_models.dart';
import '../domain/profile.dart';
import '../state/account_controller.dart';
import '../../../shared/widgets/dialog.dart';

/// Your profile, account and cloud backups.
class AccountScreen extends ConsumerStatefulWidget {
  const AccountScreen({super.key});

  @override
  ConsumerState<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends ConsumerState<AccountScreen> {
  Profile? _draft;
  late final _name = TextEditingController();
  Future<List<BackupInfo>>? _backups;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  void _reloadBackups() {
    final signedIn = ref.read(accountProvider).signedIn;
    setState(() => _backups = signedIn ? ref.read(accountProvider.notifier).listBackups() : null);
  }

  Future<void> _run(Future<void> Function() work, {String? done}) async {
    setState(() => _error = null);
    try {
      await work();
      if (done != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(done)));
      }
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } on StateError catch (e) {
      if (mounted) setState(() => _error = e.message);
    }
  }

  Future<bool> _confirm(String title, String body, String action, {bool destructive = false}) =>
      showConfirm(
        context,
        title: title,
        body: body,
        confirm: action,
        destructive: destructive,
        icon: Icons.cloud_download_outlined,
      );

  @override
  Widget build(BuildContext context) {
    final c = context.nefa;
    final account = ref.watch(accountProvider);
    final unit = ref.watch(settingsProvider).unit;
    final ctrl = ref.read(accountProvider.notifier);
    final p = _draft ?? account.profile;
    if (_draft == null && _name.text != account.profile.displayName) {
      _name.text = account.profile.displayName;
    }
    if (account.signedIn && _backups == null) _backups = ctrl.listBackups();
    final dirty = _draft != null && _draft != account.profile;

    return PaperScaffold(
      body: Column(
        children: [
          const PageBar(),
          Expanded(
            child: ListView(
              padding: EdgeInsets.fromLTRB(
                NefaSpace.gutter,
                0,
                NefaSpace.gutter,
                MediaQuery.paddingOf(context).bottom + 24,
              ),
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              children: [
                BoardCard(
                  child: Row(
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(color: c.accent, shape: BoxShape.circle),
                        child: p.displayName.trim().isEmpty
                            ? Icon(Icons.person_outline_rounded, size: 30, color: c.onAccent)
                            : Text(p.initial, style: NefaType.style(28, 900, color: c.onAccent)),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              p.displayName.isEmpty ? 'Your profile' : p.displayName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: NefaType.style(24, 900, tracking: -.8, color: c.onBoard),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${p.goal.label} · ${p.weeklyTarget}× a week',
                              style: NefaType.style(13, 600, color: c.boardMuted),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              account.email ?? 'Not signed in · saved on this phone',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: NefaType.style(12, 600, color: c.boardMuted),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 14),
                  Notice(text: _error!, tone: NoticeTone.danger),
                ],
                const SizedBox(height: NefaSpace.section),
                Text('Profile', style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 14),
                const Eyebrow('Name'),
                TextField(
                  controller: _name,
                  textCapitalization: TextCapitalization.words,
                  style: NefaType.style(18, 700, color: c.ink),
                  cursorColor: c.accent,
                  onChanged: (v) => setState(() => _draft = p.copyWith(displayName: v)),
                  decoration: InputDecoration(
                    hintText: 'What should neFaRec call you?',
                    hintStyle: NefaType.style(16, 500, color: c.faint),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: c.rule, width: 1.2),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: c.accent, width: 1.6),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Eyebrow('Main goal'),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final g in Goal.values)
                      Pill(
                        label: g.label,
                        selected: p.goal == g,
                        onTap: () => setState(() => _draft = p.copyWith(goal: g)),
                      ),
                  ],
                ),
                const SizedBox(height: 20),
                const Eyebrow('Experience'),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final x in Experience.values)
                      Pill(
                        label: x.label,
                        selected: p.experience == x,
                        onTap: () => setState(() => _draft = p.copyWith(experience: x)),
                      ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Eyebrow('Bodyweight (${unit.name})'),
                          RuledNumberField(
                            value: p.bodyweightKg == null
                                ? null
                                : double.parse(fromKg(p.bodyweightKg!, unit).toStringAsFixed(1)),
                            decimal: true,
                            width: double.infinity,
                            hint: '—',
                            semanticLabel: 'Bodyweight',
                            onCommitted: (v) => setState(
                              () => _draft = v == null
                                  ? p.copyWith(clearBodyweight: true)
                                  : p.copyWith(bodyweightKg: toKg(v.toDouble(), unit)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Eyebrow('Height (cm)'),
                          RuledNumberField(
                            value: p.heightCm,
                            width: double.infinity,
                            hint: '—',
                            semanticLabel: 'Height',
                            onCommitted: (v) => setState(
                              () => _draft = v == null
                                  ? p.copyWith(clearHeight: true)
                                  : p.copyWith(heightCm: v.toDouble()),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                NefaStepper(
                  label: 'Sessions a week',
                  value: p.weeklyTarget,
                  min: 1,
                  max: 14,
                  format: (v) => '$v',
                  onChanged: (v) => setState(() => _draft = p.copyWith(weeklyTarget: v.toInt())),
                ),
                const SizedBox(height: 8),
                Text(
                  'Optional and private. Today uses your name and weekly target. '
                  'Bodyweight and height are kept for your own records.',
                  style: NefaType.style(12.5, 500, color: c.muted, height: 1.4),
                ),
                const SizedBox(height: 16),
                NefaButton(
                  label: dirty ? 'Save profile' : 'Saved',
                  icon: Icons.check_rounded,
                  loading: account.busy && dirty,
                  onPressed: dirty
                      ? () => _run(() async {
                          FocusScope.of(context).unfocus();
                          await Future<void>.delayed(Duration.zero);
                          await ctrl.saveProfile(_draft!.copyWith(displayName: _name.text.trim()));
                          if (mounted) setState(() => _draft = null);
                        }, done: 'Profile saved.')
                      : null,
                ),
                const SizedBox(height: NefaSpace.section),
                Text('Account & backup', style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 14),
                if (!account.signedIn)
                  SheetCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Keep your training safe',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'With a free account your profile follows you, and neFaRec backs up your routines and '
                          'history after every workout so you can restore them on a new phone.',
                          style: NefaType.style(13.5, 500, height: 1.5, color: c.muted),
                        ),
                        const SizedBox(height: 16),
                        NefaButton(
                          label: 'Create account',
                          icon: Icons.person_add_alt_1_rounded,
                          onPressed: () async {
                            await _showAuth(context, create: true);
                            _reloadBackups();
                          },
                        ),
                        const SizedBox(height: 10),
                        NefaButton(
                          label: 'Sign in',
                          tone: ButtonTone.ghost,
                          onPressed: () async {
                            await _showAuth(context, create: false);
                            _reloadBackups();
                          },
                        ),
                      ],
                    ),
                  )
                else ...[
                  SheetCard(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Back up after each workout',
                                style: NefaType.style(15, 700, color: c.ink),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                account.lastBackupAt == null
                                    ? 'No backup yet.'
                                    : 'Last backup ${_when(account.lastBackupAt!)}.',
                                style: NefaType.style(12.5, 500, color: c.muted),
                              ),
                            ],
                          ),
                        ),
                        Switch.adaptive(
                          value: account.autoBackup,
                          onChanged: ctrl.setAutoBackup,
                          activeTrackColor: c.accent,
                          activeThumbColor: Colors.white,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  NefaButton(
                    label: 'Back up now',
                    icon: Icons.cloud_upload_outlined,
                    loading: account.busy,
                    onPressed: account.busy
                        ? null
                        : () => _run(() async {
                            await ctrl.backupNow();
                            _reloadBackups();
                          }, done: 'Backed up.'),
                  ),
                  const SizedBox(height: 18),
                  const Eyebrow('Backups (latest 10 are kept)'),
                  const SizedBox(height: 8),
                  FutureBuilder<List<BackupInfo>>(
                    future: _backups,
                    builder: (context, snap) {
                      if (snap.hasError) {
                        return Notice(
                          text: '${snap.error}',
                          tone: NoticeTone.warn,
                          action: 'Retry',
                          onAction: _reloadBackups,
                        );
                      }
                      final list = snap.data;
                      if (list == null) {
                        return Text('Loading…', style: NefaType.style(13, 500, color: c.muted));
                      }
                      if (list.isEmpty) {
                        return Text(
                          'No backups yet. Tap Back up now, or finish a workout.',
                          style: NefaType.style(13, 500, color: c.muted),
                        );
                      }
                      return Column(
                        children: [
                          for (final b in list)
                            Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(color: c.rule.withValues(alpha: .6)),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.cloud_done_outlined, color: c.muted, size: 20),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _when(b.createdAt),
                                          style: NefaType.style(14, 700, color: c.ink),
                                        ),
                                        Text(
                                          '${b.summary['routines']} routines · ${b.summary['sessions']} sessions · '
                                          '${(b.sizeBytes / 1024).toStringAsFixed(0)} KB',
                                          style: NefaType.style(
                                            12,
                                            500,
                                            color: c.muted,
                                            tabular: true,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Pill(
                                    label: 'Restore',
                                    onTap: () async {
                                      final ok = await _confirm(
                                        'Restore this backup?',
                                        'Routines and history on this phone are replaced with the backup from '
                                            '${_when(b.createdAt)}. Anything newer that isn’t backed up is lost.',
                                        'Restore',
                                      );
                                      if (ok) {
                                        await _run(() => ctrl.restore(b.id), done: 'Restored.');
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 22),
                  NefaButton(
                    label: 'Sign out',
                    tone: ButtonTone.ghost,
                    onPressed: () => _run(() async {
                      await ctrl.signOut();
                      setState(() => _backups = null);
                    }),
                  ),
                  const SizedBox(height: 10),
                  Center(
                    child: TextButton(
                      onPressed: () async {
                        final ok = await _confirm(
                          'Delete your account?',
                          'Your account, profile and every cloud backup are deleted from the server. '
                              'Workouts on this phone stay. This can’t be undone.',
                          'Delete account',
                          destructive: true,
                        );
                        if (ok) {
                          await _run(() async {
                            await ctrl.deleteAccount();
                            setState(() => _backups = null);
                          }, done: 'Account deleted.');
                        }
                      },
                      child: Text(
                        'Delete account',
                        style: NefaType.style(14, 800, color: c.danger),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 14),
                Text(
                  'Server: $apiBaseUrl. Passwords are hashed; sign-in tokens are kept in the iOS Keychain.',
                  textAlign: TextAlign.center,
                  style: NefaType.style(11.5, 500, color: c.faint, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

String _when(DateTime d) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  final hh = d.hour.toString().padLeft(2, '0');
  final mm = d.minute.toString().padLeft(2, '0');
  return '${d.day} ${months[d.month - 1]}, $hh:$mm';
}

Future<void> _showAuth(BuildContext context, {required bool create}) {
  return showNefaSheet<void>(
    context,
    title: create ? 'Create your account' : 'Sign in',
    subtitle: create ? 'Free. Your profile and backups, on any phone.' : 'Welcome back.',
    icon: Icons.person_outline_rounded,
    builder: (_) => _AuthForm(create: create),
  );
}

class _AuthForm extends ConsumerStatefulWidget {
  const _AuthForm({required this.create});
  final bool create;

  @override
  ConsumerState<_AuthForm> createState() => _AuthFormState();
}

class _AuthFormState extends ConsumerState<_AuthForm> {
  late bool _create = widget.create;
  final _email = TextEditingController();
  final _password = TextEditingController();
  late final _name = TextEditingController(text: ref.read(accountProvider).profile.displayName);
  bool _hide = true;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _name.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _error = null);
    final email = _email.text.trim();
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
      setState(() => _error = 'Enter a valid email, like you@example.com.');
      return;
    }
    if (_create && _password.text.length < 8) {
      setState(() => _error = 'Use at least 8 characters for your password.');
      return;
    }
    try {
      final ctrl = ref.read(accountProvider.notifier);
      if (_create) {
        await ctrl.signUp(email: email, password: _password.text, name: _name.text);
      } else {
        await ctrl.signIn(email: email, password: _password.text);
      }
      if (mounted) Navigator.pop(context);
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.nefa;
    final busy = ref.watch(accountProvider).busy;
    InputDecoration deco(String label, {Widget? suffix}) => InputDecoration(
      labelText: label,
      labelStyle: NefaType.style(14, 600, color: c.muted),
      filled: true,
      fillColor: c.recessed,
      suffixIcon: suffix,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(NefaRadii.md),
        borderSide: BorderSide(color: c.rule),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(NefaRadii.md),
        borderSide: BorderSide(color: c.rule),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(NefaRadii.md),
        borderSide: BorderSide(color: c.accent, width: 1.5),
      ),
    );
    final text = NefaType.style(16, 600, color: c.ink);
    return AutofillGroup(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_create) ...[
            TextField(
              controller: _name,
              style: text,
              textCapitalization: TextCapitalization.words,
              autofillHints: const [AutofillHints.givenName],
              decoration: deco('Name'),
            ),
            const SizedBox(height: 12),
          ],
          TextField(
            controller: _email,
            style: text,
            keyboardType: TextInputType.emailAddress,
            autocorrect: false,
            autofillHints: const [AutofillHints.email],
            decoration: deco('Email'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _password,
            style: text,
            obscureText: _hide,
            autofillHints: [_create ? AutofillHints.newPassword : AutofillHints.password],
            onSubmitted: (_) => _submit(),
            decoration: deco(
              _create ? 'Password (8+ characters)' : 'Password',
              suffix: IconButton(
                tooltip: _hide ? 'Show password' : 'Hide password',
                icon: Icon(
                  _hide ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                  color: c.muted,
                ),
                onPressed: () => setState(() => _hide = !_hide),
              ),
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Notice(text: _error!, tone: NoticeTone.danger),
          ],
          const SizedBox(height: 16),
          NefaButton(
            label: _create ? 'Create account' : 'Sign in',
            loading: busy,
            onPressed: busy ? null : _submit,
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => setState(() {
              _create = !_create;
              _error = null;
            }),
            child: Text(
              _create ? 'Have an account? Sign in' : 'New here? Create an account',
              style: NefaType.style(14, 700, color: c.accentInk),
            ),
          ),
        ],
      ),
    );
  }
}
