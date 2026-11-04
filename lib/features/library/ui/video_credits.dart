import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/tokens.dart';
import '../../../shared/widgets/sheet.dart';
import '../domain/exercise_videos.dart';

/// Who filmed each demo video and the licence it is shared under.
Future<void> showVideoCredits(BuildContext context, List<VideoClip> clips) {
  final one = clips.length == 1;
  return showNefaSheet<void>(
    context,
    title: one ? 'Video credit' : 'Video credits',
    subtitle: one
        ? clips.first.title
        : '${clips.length} demo videos from the wger.de community, shared under CC BY-SA 4.0.',
    icon: Icons.videocam_outlined,
    builder: (context) {
      final c = context.nefa;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final (i, clip) in clips.indexed) ...[
            if (i > 0) Divider(color: c.rule, height: 28),
            _Credit(clip: clip, showTitle: !one),
          ],
          const SizedBox(height: 18),
          Text(
            'Changes for the app: ${clips.first.changes} '
            'The adapted clips are shared under the same licence.',
            style: NefaType.style(12.5, 500, height: 1.45, color: c.muted),
          ),
          const SizedBox(height: 6),
          _Link(label: 'Licence', url: clips.first.licenseUrl),
        ],
      );
    },
  );
}

class _Credit extends StatelessWidget {
  const _Credit({required this.clip, required this.showTitle});
  final VideoClip clip;
  final bool showTitle;

  @override
  Widget build(BuildContext context) {
    final c = context.nefa;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showTitle) ...[
          Text(clip.title, style: NefaType.style(15, 800, color: c.ink)),
          const SizedBox(height: 4),
        ],
        Text(
          'Filmed by ${clip.author} · ${clip.license}',
          style: NefaType.style(13.5, 600, color: c.ink),
        ),
        const SizedBox(height: 6),
        _Link(label: 'Source', url: clip.source),
      ],
    );
  }
}

/// A link you can copy. Tap to copy it.
class _Link extends StatelessWidget {
  const _Link({required this.label, required this.url});
  final String label;
  final String url;

  @override
  Widget build(BuildContext context) {
    final c = context.nefa;
    return InkWell(
      borderRadius: BorderRadius.circular(6),
      onTap: () {
        Clipboard.setData(ClipboardData(text: url));
        HapticFeedback.selectionClick();
        ScaffoldMessenger.maybeOf(context)?.showSnackBar(
          SnackBar(content: Text('$label link copied'), duration: const Duration(seconds: 2)),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            SizedBox(
              width: 62,
              child: Text(label.toUpperCase(), style: NefaType.eyebrow(color: c.muted, size: 9.5)),
            ),
            Expanded(
              child: Text(
                url,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: NefaType.style(12.5, 600, color: c.accentInk),
              ),
            ),
            Icon(Icons.copy_rounded, size: 15, color: c.faint),
          ],
        ),
      ),
    );
  }
}
