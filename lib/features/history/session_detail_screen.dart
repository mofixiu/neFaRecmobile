import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../../core/theme/tokens.dart';
import '../../shared/widgets/controls.dart';
import '../../shared/widgets/surfaces.dart';
import '../routines/domain/routine_text.dart';
import '../settings/settings_controller.dart';
import '../workout/domain/session_models.dart';
import '../workout/ui/receipt_view.dart';
import '../workout/ui/summary_screen.dart';
import '../../shared/widgets/dialog.dart';

class SessionDetailScreen extends ConsumerWidget {
  const SessionDetailScreen({super.key, required this.sessionId});
  final int sessionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detail = ref.watch(sessionProvider(sessionId)).valueOrNull;
    final records = ref.watch(recordsProvider(sessionId)).valueOrNull ?? const [];
    final unit = ref.watch(settingsProvider).unit;
    return PaperScaffold(
      body: Column(
        children: [
          PageBar(
            actions: [
              RoundIconButton(
                icon: Icons.ios_share_rounded,
                label: 'Share with a coach',
                onPressed: detail == null ? null : () => _share(context, detail),
              ),
              RoundIconButton(
                icon: Icons.delete_outline_rounded,
                label: 'Delete session',
                onPressed: detail == null
                    ? null
                    : () async {
                        final ok = await showConfirm(
                          context,
                          title: 'Delete this session?',
                          body:
                              'Its sets leave your history, records and comparisons. '
                              'This can’t be undone.',
                          confirm: 'Delete session',
                          cancel: 'Keep it',
                          destructive: true,
                        );
                        if (ok) {
                          await ref.read(sessionRepositoryProvider).deleteSession(sessionId);
                          if (context.mounted) Navigator.of(context).pop();
                        }
                      },
              ),
            ],
          ),
          Expanded(
            child: detail == null
                ? const SizedBox()
                : ListView(
                    padding: EdgeInsets.fromLTRB(
                      NefaSpace.gutter,
                      0,
                      NefaSpace.gutter,
                      MediaQuery.paddingOf(context).bottom + 24,
                    ),
                    children: [ReceiptView(detail: detail, records: records, unit: unit)],
                  ),
          ),
        ],
      ),
    );
  }
}

/// Sends the session as readable text plus a CSV of every set.
Future<void> _share(BuildContext context, SessionDetail detail) async {
  final dir = await getTemporaryDirectory();
  final d = detail.session.startedAt;
  final file = File(
    '${dir.path}/nefarec-${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}.csv',
  )..writeAsStringSync(sessionToCsv(detail));
  await SharePlus.instance.share(
    ShareParams(
      text: sessionToText(detail),
      subject: detail.session.title,
      files: [XFile(file.path, mimeType: 'text/csv')],
    ),
  );
}
