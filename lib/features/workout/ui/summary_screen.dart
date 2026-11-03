import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:paper_kit/paper_kit.dart';

import '../../../core/providers.dart';
import '../../../core/theme/tokens.dart';
import '../../../shared/widgets/controls.dart';
import '../../../shared/widgets/surfaces.dart';
import '../../settings/settings_controller.dart';
import '../domain/session_models.dart';
import 'receipt_view.dart';

final recordsProvider = FutureProvider.family<List<PersonalRecord>, int>((ref, sessionId) async {
  final detail = await ref.watch(sessionProvider(sessionId).future);
  if (detail == null) return const [];
  return ref.read(sessionRepositoryProvider).recordsFor(detail);
});

/// Shown when a workout is finished: the receipt prints and gets stamped.
class SummaryScreen extends ConsumerStatefulWidget {
  const SummaryScreen({super.key, required this.sessionId, this.fresh = false});
  final int sessionId;
  final bool fresh;

  @override
  ConsumerState<SummaryScreen> createState() => _SummaryScreenState();
}

class _SummaryScreenState extends ConsumerState<SummaryScreen> with TickerProviderStateMixin {
  late final _print = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
  late final _stamp = AnimationController(vsync: this, duration: const Duration(milliseconds: 420));

  @override
  void initState() {
    super.initState();
    if (widget.fresh) {
      _print.forward().then((_) async {
        await Future<void>.delayed(const Duration(milliseconds: 150));
        if (!mounted) return;
        PaperHaptics.stamp();
        await _stamp.forward();
      });
    } else {
      _print.value = 1;
      _stamp.value = 1;
    }
  }

  @override
  void dispose() {
    _print.dispose();
    _stamp.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.nefa;
    final detail = ref.watch(sessionProvider(widget.sessionId)).valueOrNull;
    final records = ref.watch(recordsProvider(widget.sessionId)).valueOrNull ?? const [];
    final unit = ref.watch(settingsProvider).unit;
    final bottom = MediaQuery.paddingOf(context).bottom;
    final reduce = MediaQuery.disableAnimationsOf(context);

    return PaperScaffold(
      body: Column(
        children: [
          PageBar(closeIcon: true, onBack: () => Navigator.of(context).popUntil((r) => r.isFirst)),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(NefaSpace.gutter, 0, NefaSpace.gutter, 24),
              children: [
                if (detail != null) ...[
                  Text(
                    records.isEmpty ? 'Logged.' : 'New record${records.length == 1 ? '' : 's'}.',
                    style: Theme.of(context).textTheme.displayMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    records.isEmpty
                        ? 'Every set is saved to your history. Next time you’ll see these numbers beside each set.'
                        : 'You beat your previous best on ${records.map((r) => r.exerciseName).toSet().join(', ')}.',
                    style: NefaType.style(14.5, 500, height: 1.5, color: c.muted),
                  ),
                  const SizedBox(height: 24),
                  AnimatedBuilder(
                    animation: Listenable.merge([_print, _stamp]),
                    builder: (context, _) {
                      final t = reduce ? 1.0 : Curves.easeOutCubic.transform(_print.value);
                      return ClipRect(
                        child: Align(
                          alignment: Alignment.topCenter,
                          heightFactor: t,
                          child: Transform.translate(
                            offset: Offset(0, -40 * (1 - t)),
                            child: ReceiptView(
                              detail: detail,
                              records: records,
                              unit: unit,
                              stamp: reduce ? 1 : _stamp.value,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(NefaSpace.gutter, 8, NefaSpace.gutter, 12 + bottom),
            child: NefaButton(
              label: 'Done',
              icon: Icons.check_rounded,
              tone: ButtonTone.ink,
              onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst),
            ),
          ),
        ],
      ),
    );
  }
}
