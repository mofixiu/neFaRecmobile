import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';

import '../../../core/providers.dart';
import '../../../core/services/media_cache.dart';
import '../../../core/theme/tokens.dart';
import '../../../shared/widgets/sheet.dart';
import '../domain/exercise_videos.dart';
import '../domain/library_data.dart';
import 'video_credits.dart';

/// A looping, silent video of the movement when one is bundled; otherwise the
/// start and end photos, flipping like a two-page flipbook printed onto the
/// paper. Falls back to a cue card when a movement has no media.
class ExerciseDemo extends ConsumerStatefulWidget {
  const ExerciseDemo({
    super.key,
    required this.exerciseId,
    required this.name,
    this.height = 210,
    this.active = true,
  });
  final String? exerciseId;
  final String name;
  final double height;

  /// False while this demo is off screen (a neighbouring workout page), so
  /// its video stays paused.
  final bool active;

  @override
  ConsumerState<ExerciseDemo> createState() => _ExerciseDemoState();
}

class _ExerciseDemoState extends ConsumerState<ExerciseDemo> {
  int _frame = 0;
  Timer? _flip;
  List<ImageProvider> _remote = const [];
  String? _loadedFor;
  bool _photos = false;
  bool _showingVideo = false;

  /// Movements without bundled photos: download once, then cached offline.
  Future<void> _loadRemote(LibraryRecord record) async {
    final files = await Future.wait(record.images.take(2).map(MediaCache.instance.fetch));
    if (!mounted || _loadedFor != record.id) return;
    setState(() => _remote = [for (final f in files.whereType<File>()) FileImage(f)]);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _flip?.cancel();
    if (!MediaQuery.disableAnimationsOf(context)) {
      _flip = Timer.periodic(const Duration(milliseconds: 1300), (_) {
        if (mounted && !_showingVideo) setState(() => _frame = 1 - _frame);
      });
    }
  }

  @override
  void dispose() {
    _flip?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.nefa;
    final id = widget.exerciseId;
    final record = id == null ? null : ref.watch(libraryByIdProvider).valueOrNull?[id];
    final clip = id == null ? null : ref.watch(videoByExerciseProvider).valueOrNull?[id];
    final bundled = record == null
        ? const <String>[]
        : [
            for (var i = 0; i < record.images.length && i < 2; i++)
              bundledDemoAsset(record.id, i, curated: record.curated),
          ].whereType<String>().toList();
    final List<ImageProvider> frames = bundled.isNotEmpty
        ? [for (final a in bundled) AssetImage(a)]
        : _remote;
    if (bundled.isEmpty && record != null && record.images.isNotEmpty && _loadedFor != record.id) {
      _loadedFor = record.id;
      _loadRemote(record);
    }
    _showingVideo = clip != null && !_photos;

    final Widget body;
    if (_showingVideo) {
      body = _VideoDemo(
        key: ValueKey(clip!.file),
        clip: clip,
        name: widget.name,
        active: widget.active,
        poster: frames.firstOrNull,
      );
    } else if (frames.isEmpty) {
      body = _CueCard(record: record, name: widget.name);
    } else {
      body = GestureDetector(
        onTap: () => setState(() => _frame = 1 - _frame),
        child: Stack(
          fit: StackFit.expand,
          children: [
            for (final (i, image) in frames.indexed)
              AnimatedOpacity(
                opacity: (_frame % frames.length) == i ? 1 : 0,
                duration: const Duration(milliseconds: 260),
                child: ColorFiltered(
                  // Multiply onto the sheet so the photo's white reads as paper.
                  colorFilter: ColorFilter.mode(
                    c.isDark ? const Color(0xFFF1E9DA) : c.sheet,
                    BlendMode.multiply,
                  ),
                  child: Image(
                    image: image,
                    fit: BoxFit.cover,
                    gaplessPlayback: true,
                    semanticLabel: '${widget.name}, ${i == 0 ? 'start' : 'end'} position',
                  ),
                ),
              ),
            Positioned(
              left: 12,
              bottom: 12,
              child: _Tag(
                children: [
                  for (var i = 0; i < frames.length; i++)
                    Container(
                      width: 6,
                      height: 6,
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: i == _frame % frames.length ? c.accent : c.boardMuted,
                      ),
                    ),
                  const SizedBox(width: 6),
                  Text(
                    _frame % frames.length == 0 ? 'START' : 'FINISH',
                    style: NefaType.eyebrow(color: c.onBoard, size: 9),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      height: widget.height,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: c.isDark ? const Color(0xFFF1E9DA) : c.sheet,
        borderRadius: BorderRadius.circular(NefaRadii.lg),
        border: Border.all(color: c.rule),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          AnimatedSwitcher(duration: NefaMotion.small, child: body),
          if (clip != null && frames.isNotEmpty)
            Positioned(
              top: 10,
              right: 10,
              child: _ModeSwitch(
                video: !_photos,
                onChanged: (video) => setState(() => _photos = !video),
              ),
            ),
        ],
      ),
    );
  }
}

/// Plays muted on a loop while on screen, mixing with your music. Tap to
/// pause. With reduce motion on it waits for a tap.
class _VideoDemo extends StatefulWidget {
  const _VideoDemo({
    super.key,
    required this.clip,
    required this.name,
    required this.active,
    this.poster,
  });
  final VideoClip clip;
  final String name;
  final bool active;
  final ImageProvider? poster;

  @override
  State<_VideoDemo> createState() => _VideoDemoState();
}

class _VideoDemoState extends State<_VideoDemo> {
  late final _video = VideoPlayerController.asset(
    widget.clip.asset,
    videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
  );
  bool _ready = false;
  bool _still = false;
  bool _onTop = true;

  /// What the user chose by tapping; null means follow reduce motion.
  bool? _wantsPlay;

  @override
  void initState() {
    super.initState();
    _video
      ..setLooping(true)
      ..setVolume(0);
    _video.initialize().then((_) {
      if (!mounted) return;
      setState(() => _ready = true);
      _sync();
    }, onError: (Object _) {});
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _still = MediaQuery.disableAnimationsOf(context);
    // Pauses under a sheet or a pushed screen.
    _onTop = ModalRoute.isCurrentOf(context) ?? true;
    _sync();
  }

  @override
  void didUpdateWidget(_VideoDemo old) {
    super.didUpdateWidget(old);
    if (old.active != widget.active) _sync();
  }

  void _sync() {
    if (!_ready) return;
    final play = widget.active && _onTop && (_wantsPlay ?? !_still);
    play ? _video.play() : _video.pause();
  }

  void _toggle() {
    _wantsPlay = !_video.value.isPlaying;
    _sync();
  }

  @override
  void dispose() {
    _video.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.nefa;
    return ValueListenableBuilder<VideoPlayerValue>(
      valueListenable: _video,
      builder: (context, value, _) => Semantics(
        button: true,
        label: '${widget.name} demo video, ${value.isPlaying ? 'playing' : 'paused'}',
        hint: value.isPlaying ? 'Pause' : 'Play',
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _ready ? _toggle : null,
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (widget.poster != null)
                ColorFiltered(
                  colorFilter: ColorFilter.mode(c.sheet, BlendMode.multiply),
                  child: Image(image: widget.poster!, fit: BoxFit.cover),
                )
              else
                ColoredBox(color: c.board),
              AnimatedOpacity(
                opacity: _ready ? 1 : 0,
                duration: const Duration(milliseconds: 360),
                child: _ready
                    ? FittedBox(
                        fit: BoxFit.cover,
                        clipBehavior: Clip.hardEdge,
                        child: SizedBox(
                          width: value.size.width,
                          height: value.size.height,
                          child: VideoPlayer(_video),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
              Center(
                child: AnimatedScale(
                  scale: _ready && !value.isPlaying ? 1 : .6,
                  duration: NefaMotion.small,
                  curve: Curves.easeOutBack,
                  child: AnimatedOpacity(
                    opacity: _ready && !value.isPlaying ? 1 : 0,
                    duration: NefaMotion.small,
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: c.board.withValues(alpha: .82),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.play_arrow_rounded, color: c.onBoard, size: 32),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 12,
                bottom: 12,
                child: _Tag(
                  children: [
                    _Dot(live: value.isPlaying),
                    const SizedBox(width: 6),
                    Text('VIDEO', style: NefaType.eyebrow(color: c.onBoard, size: 9)),
                  ],
                ),
              ),
              Positioned(
                right: 12,
                bottom: 12,
                child: GestureDetector(
                  onTap: () => showVideoCredits(context, [widget.clip]),
                  child: _Tag(
                    children: [
                      Text(
                        widget.clip.credit,
                        style: NefaType.style(9.5, 700, color: c.onBoard.withValues(alpha: .8)),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The recording light: breathes while the video plays.
class _Dot extends StatefulWidget {
  const _Dot({required this.live});
  final bool live;

  @override
  State<_Dot> createState() => _DotState();
}

class _DotState extends State<_Dot> with SingleTickerProviderStateMixin {
  late final _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400));

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _run();
  }

  @override
  void didUpdateWidget(_Dot old) {
    super.didUpdateWidget(old);
    _run();
  }

  void _run() {
    if (widget.live && !MediaQuery.disableAnimationsOf(context)) {
      if (!_c.isAnimating) _c.repeat(reverse: true);
    } else {
      _c.value = 1;
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.nefa;
    return FadeTransition(
      opacity: Tween(begin: .35, end: 1.0).animate(_c),
      child: Container(
        width: 7,
        height: 7,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: widget.live ? c.accent : c.boardMuted,
        ),
      ),
    );
  }
}

/// A small dark label printed over a demo.
class _Tag extends StatelessWidget {
  const _Tag({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: context.nefa.board.withValues(alpha: .82),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: children),
    );
  }
}

/// Video or photos, for movements that have both.
class _ModeSwitch extends StatelessWidget {
  const _ModeSwitch({required this.video, required this.onChanged});
  final bool video;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final c = context.nefa;
    Widget option(bool isVideo, IconData icon, String label) {
      final on = video == isVideo;
      return Semantics(
        button: true,
        selected: on,
        label: label,
        child: GestureDetector(
          onTap: () => onChanged(isVideo),
          child: AnimatedContainer(
            duration: NefaMotion.small,
            width: 34,
            height: 28,
            decoration: BoxDecoration(
              color: on ? c.accent : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, size: 16, color: on ? c.onAccent : c.onBoard),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: c.board.withValues(alpha: .82),
        borderRadius: BorderRadius.circular(9),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          option(true, Icons.videocam_rounded, 'Show video'),
          option(false, Icons.photo_outlined, 'Show photos'),
        ],
      ),
    );
  }
}

class _CueCard extends StatelessWidget {
  const _CueCard({required this.record, required this.name});
  final LibraryRecord? record;
  final String name;

  @override
  Widget build(BuildContext context) {
    const ink = Color(0xFF211E19);
    final c = context.nefa;
    final first = record?.instructions.firstOrNull;
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('NO DEMO YET', style: NefaType.eyebrow(color: c.accentInk)),
          const Spacer(),
          Text(
            name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: NefaType.style(26, 900, height: 1, tracking: -1, color: ink),
          ),
          if (first != null) ...[
            const SizedBox(height: 10),
            Text(
              first,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: NefaType.style(13.5, 500, height: 1.45, color: ink.withValues(alpha: .7)),
            ),
          ],
        ],
      ),
    );
  }
}

/// Step-by-step technique, muscles and equipment.
Future<void> showCues(BuildContext context, LibraryRecord record) {
  final c = context.nefa;
  return showNefaSheet<void>(
    context,
    title: record.name,
    subtitle: [
      if (record.equipment != null) record.equipment!,
      if (record.primaryMuscles.isNotEmpty) record.primaryMuscles.join(', '),
    ].join(' · '),
    icon: Icons.menu_book_rounded,
    builder: (context) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final (i, step) in record.instructions.indexed)
          Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 26,
                  height: 26,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(color: c.board, shape: BoxShape.circle),
                  child: Text('${i + 1}', style: NefaType.style(12, 900, color: c.onBoard)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(step, style: NefaType.style(14.5, 500, height: 1.5, color: c.ink)),
                ),
              ],
            ),
          ),
        if (record.instructions.isEmpty)
          Text(
            'No written steps for this one yet.',
            style: NefaType.style(14, 500, color: c.muted),
          ),
        const SizedBox(height: 8),
        Text(
          'These are general cues, not a single correct form for every body. Move within a range that feels controlled.',
          style: NefaType.style(12.5, 500, height: 1.45, color: c.muted),
        ),
      ],
    ),
  );
}
