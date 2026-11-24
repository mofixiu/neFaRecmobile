import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/providers.dart';
import '../../core/services/vision.dart';
import '../../core/theme/tokens.dart';
import '../../shared/widgets/controls.dart';
import '../../shared/widgets/motion.dart';
import '../../shared/widgets/surfaces.dart';
import '../app/navigation.dart';
import '../library/domain/library_data.dart';
import 'equipment_guide.dart';

final equipmentGuideProvider = FutureProvider<EquipmentGuide>(
  (_) async => EquipmentGuide.parse(await rootBundle.loadString('assets/equipment/equipment.json')),
);

/// The scanner needs the on-device model, which ships for iPhone and Android.
bool get equipmentScanSupported => Platform.isIOS || Platform.isAndroid;

void openEquipmentScanner(BuildContext context) => push(context, const EquipmentScanScreen());

void openEquipment(BuildContext context, String id) =>
    push(context, EquipmentDetailScreen(equipmentId: id));

String _percent(double p) => '${(p * 100).round()}% sure';

/// "What's this machine?": a photo in, the likely equipment out, with the
/// whole guide underneath to browse. Runs on the phone; the photo is not kept.
class EquipmentScanScreen extends ConsumerStatefulWidget {
  const EquipmentScanScreen({super.key});

  @override
  ConsumerState<EquipmentScanScreen> createState() => _EquipmentScanScreenState();
}

class _EquipmentScanScreenState extends ConsumerState<EquipmentScanScreen> {
  String? _photo;
  EquipmentScan? _scan;
  bool _working = false;
  String? _error;

  Future<void> _pick(ImageSource source) async {
    XFile? file;
    try {
      file = await ImagePicker().pickImage(source: source, maxWidth: 1600, imageQuality: 90);
    } on PlatformException {
      if (mounted) {
        setState(
          () => _error = source == ImageSource.camera
              ? 'The camera isn’t available here. Choose a photo instead.'
              : 'Photos aren’t available. Allow access in Settings and try again.',
        );
      }
      return;
    }
    if (file == null) return;
    setState(() {
      _photo = file!.path;
      _scan = null;
      _error = null;
      _working = true;
    });
    try {
      const vision = VisionService();
      final guide = await ref.read(equipmentGuideProvider.future);
      final (model, text) = await (
        vision.equipmentFromImage(file.path),
        vision.textFromImage(file.path).catchError((Object _) => ''),
      ).wait;
      if (!mounted) return;
      final scan = rankEquipment(model, text, guide);
      if (scan.confident) HapticFeedback.lightImpact();
      setState(() => _scan = scan);
    } on PlatformException catch (e) {
      if (mounted) setState(() => _error = e.message ?? 'That photo couldn’t be read on this device.');
    } catch (e) {
      if (mounted) setState(() => _error = 'That photo couldn’t be read on this device. ($e)');
    } finally {
      if (mounted) setState(() => _working = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.nefa;
    final guide = ref.watch(equipmentGuideProvider).valueOrNull;
    final scan = _scan;
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
              children: [
                Row(
                  children: [
                    const Eyebrow('What’s this?'),
                    const SizedBox(width: 8),
                    Pill(label: 'Beta', background: c.accentWash, foreground: c.accentInk),
                  ],
                ),
                const SizedBox(height: 8),
                Text('Point at any machine', style: Theme.of(context).textTheme.displaySmall),
                const SizedBox(height: 14),
                Text(
                  'Take a photo of the whole machine, from the side if you can. neFaRec tells you '
                  'what it is, how to set it up and what to do on it.',
                  style: NefaType.style(14.5, 500, height: 1.5, color: c.muted),
                ),
                const SizedBox(height: 14),
                const Notice(text: 'Processed on this phone. The photo isn’t uploaded or saved.'),
                const SizedBox(height: 20),
                NefaButton(
                  label: 'Take a photo',
                  icon: Icons.photo_camera_rounded,
                  loading: _working,
                  onPressed: _working ? null : () => _pick(ImageSource.camera),
                ),
                const SizedBox(height: 10),
                NefaButton(
                  label: 'Choose a photo',
                  icon: Icons.photo_library_outlined,
                  tone: ButtonTone.ghost,
                  onPressed: _working ? null : () => _pick(ImageSource.gallery),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 18),
                  Notice(text: _error!, tone: NoticeTone.danger),
                ],
                if (_photo != null) ...[
                  const SizedBox(height: 24),
                  _Result(photo: _photo!, scan: scan, working: _working),
                ],
                if (guide != null) ...[
                  const SizedBox(height: 32),
                  SectionHeader(
                    scan == null ? 'Or browse the guide' : 'All equipment',
                    eyebrow: '${guide.items.length} kinds',
                  ),
                  const SizedBox(height: 6),
                  _GuideList(guide: guide),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Result extends StatelessWidget {
  const _Result({required this.photo, required this.scan, required this.working});
  final String photo;
  final EquipmentScan? scan;
  final bool working;

  @override
  Widget build(BuildContext context) {
    final c = context.nefa;
    final s = scan;
    final image = ClipRRect(
      borderRadius: BorderRadius.circular(NefaRadii.md),
      child: Image.file(File(photo), width: 92, height: 92, fit: BoxFit.cover, cacheWidth: 276),
    );
    if (working || s == null) {
      return Row(
        children: [
          image,
          const SizedBox(width: 16),
          Expanded(
            child: Text('Looking at it…', style: NefaType.style(14, 600, color: c.muted)),
          ),
        ],
      );
    }
    if (s.unsure) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          image,
          const SizedBox(height: 14),
          const Notice(
            tone: NoticeTone.warn,
            text:
                'Couldn’t tell what this is. Get the whole machine in the frame, in good light, '
                'or find it in the guide below.',
          ),
        ],
      );
    }
    final best = s.best!;
    final others = s.guesses.skip(1).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Rise(
          index: 0,
          child: BoardCard(
            onTap: () => openEquipment(context, best.equipment.id),
            child: Row(
              children: [
                image,
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        (s.confident ? 'Looks like' : 'Maybe').toUpperCase(),
                        style: NefaType.eyebrow(color: c.boardMuted),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        best.equipment.name,
                        style: NefaType.style(24, 900, tracking: -.6, height: 1.1, color: c.onBoard),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        best.readLabel != null
                            ? 'Read “${best.readLabel}” on it'
                            : _percent(best.confidence),
                        style: NefaType.style(12.5, 600, color: c.boardMuted),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: c.boardMuted),
              ],
            ),
          ),
        ),
        if (!s.confident)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text(
              'Not sure about this one. Open it and check the description matches what you see.',
              style: NefaType.style(13, 600, color: c.muted),
            ),
          ),
        if (others.isNotEmpty) ...[
          const SizedBox(height: 18),
          const Eyebrow('Not it? It could be'),
          const SizedBox(height: 4),
          for (final (i, g) in others.indexed)
            Rise(
              index: i + 1,
              child: _EquipmentRow(
                equipment: g.equipment,
                trailing: g.confidence >= .05 ? _percent(g.confidence) : null,
              ),
            ),
        ],
      ],
    );
  }
}

class _GuideList extends StatelessWidget {
  const _GuideList({required this.guide});
  final EquipmentGuide guide;

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];
    for (final kind in equipmentKinds) {
      final items = guide.items.where((e) => e.kind == kind).toList()
        ..sort((a, b) => a.name.compareTo(b.name));
      if (items.isEmpty) continue;
      children
        ..add(
          Padding(
            padding: const EdgeInsets.only(top: 18, bottom: 2),
            child: Eyebrow(kindTitle(kind)),
          ),
        )
        ..addAll([for (final e in items) _EquipmentRow(equipment: e)]);
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: children);
  }
}

class _EquipmentRow extends StatelessWidget {
  const _EquipmentRow({required this.equipment, this.trailing});
  final Equipment equipment;
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    final c = context.nefa;
    return Pressable(
      onTap: () => openEquipment(context, equipment.id),
      semanticLabel: equipment.name,
      scale: .985,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: c.rule.withValues(alpha: .6))),
        ),
        child: Row(
          children: [
            EquipmentPhoto(equipment: equipment, width: 54, height: 54, radius: NefaRadii.md - 4),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(equipment.name, style: NefaType.style(15, 700, color: c.ink)),
                  if (equipment.trains.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(
                      equipment.trains.take(3).join(' · '),
                      style: NefaType.style(12.5, 500, color: c.muted),
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null)
              Padding(
                padding: const EdgeInsets.only(right: 4),
                child: Text(trailing!, style: NefaType.style(12.5, 700, color: c.muted)),
              ),
            Icon(Icons.chevron_right_rounded, color: c.faint),
          ],
        ),
      ),
    );
  }
}

/// One piece of equipment: what it's for, how to set it up, and what to do
/// on it, linked to the library.
class EquipmentDetailScreen extends ConsumerWidget {
  const EquipmentDetailScreen({super.key, required this.equipmentId});
  final String equipmentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.nefa;
    final e = ref.watch(equipmentGuideProvider).valueOrNull?.byId(equipmentId);
    final byId = ref.watch(libraryByIdProvider).valueOrNull ?? const <String, LibraryRecord>{};
    final videos = ref.watch(videoByExerciseProvider).valueOrNull ?? const {};
    if (e == null) return const PaperScaffold(body: PageBar());
    final exercises = [for (final id in e.exercises) ?byId[id]];
    final title = Theme.of(context).textTheme.headlineMedium;
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
              children: [
                EquipmentPhoto(
                  equipment: e,
                  width: double.infinity,
                  height: 230,
                  radius: NefaRadii.lg,
                  cacheWidth: 1120,
                ),
                const SizedBox(height: 6),
                Text(
                  'Photo: free-exercise-db (public domain)',
                  style: NefaType.style(11, 500, color: c.faint),
                ),
                const SizedBox(height: 16),
                Eyebrow(kindTitle(e.kind).replaceFirst(RegExp(r's$'), '')),
                const SizedBox(height: 8),
                Text(e.name, style: Theme.of(context).textTheme.displaySmall),
                if (e.also.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    'Also called ${e.also.join(', ')}',
                    style: NefaType.style(13.5, 600, color: c.muted),
                  ),
                ],
                if (e.trains.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final (i, m) in e.trains.indexed)
                        Pill(label: m, selected: i == 0, background: c.sheet),
                    ],
                  ),
                ],
                const SizedBox(height: 16),
                Text(e.what, style: NefaType.style(15.5, 500, height: 1.55, color: c.ink)),
                const SizedBox(height: 26),
                Text('Set it up', style: title),
                const SizedBox(height: 14),
                for (final (i, step) in e.setup.indexed)
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
                          child: Text(
                            step,
                            style: NefaType.style(14.5, 500, height: 1.55, color: c.ink),
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 4),
                _Callout(label: 'Beginner tip', text: e.tip, color: c.accentWash, ink: c.accentInk),
                const SizedBox(height: 10),
                _Callout(label: 'Watch out', text: e.mistake, color: c.warnWash, ink: c.warn),
                if (exercises.isNotEmpty) ...[
                  const SizedBox(height: 28),
                  Text('What to do on it', style: title),
                  const SizedBox(height: 4),
                  for (final r in exercises)
                    Pressable(
                      onTap: () => openExercise(context, r.id),
                      semanticLabel: r.name,
                      scale: .985,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          border: Border(bottom: BorderSide(color: c.rule.withValues(alpha: .6))),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(r.name, style: NefaType.style(15, 700, color: c.ink)),
                                  const SizedBox(height: 3),
                                  Text(
                                    [
                                      if (r.primaryMuscles.isNotEmpty) r.primaryMuscles.first,
                                      if (r.level != null) r.level!,
                                    ].join(' · '),
                                    style: NefaType.style(12.5, 500, color: c.muted),
                                  ),
                                ],
                              ),
                            ),
                            if (videos.containsKey(r.id))
                              Padding(
                                padding: const EdgeInsets.only(right: 6),
                                child: Icon(Icons.play_circle_fill_rounded, size: 20, color: c.accent),
                              ),
                            Icon(Icons.chevron_right_rounded, color: c.faint),
                          ],
                        ),
                      ),
                    ),
                ],
                const SizedBox(height: 18),
                const Notice(
                  text:
                      'Machines differ between brands. If a sticker on the machine says something '
                      'different, follow the sticker. Stop if something hurts.',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// A photo of someone using the equipment, blended into the paper like the
/// library's exercise thumbnails.
class EquipmentPhoto extends StatelessWidget {
  const EquipmentPhoto({
    super.key,
    required this.equipment,
    required this.width,
    required this.height,
    required this.radius,
    this.cacheWidth = 168,
  });
  final Equipment equipment;
  final double width;
  final double height;
  final double radius;
  final int cacheWidth;

  @override
  Widget build(BuildContext context) {
    final c = context.nefa;
    final paper = c.isDark ? const Color(0xFFF1E9DA) : c.sheet;
    return Semantics(
      image: true,
      label: 'Someone using a ${equipment.name.toLowerCase()}',
      child: Container(
        width: width,
        height: height,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: paper,
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(color: c.rule),
        ),
        child: ColorFiltered(
          colorFilter: ColorFilter.mode(paper, BlendMode.multiply),
          child: Image.asset(equipment.image, fit: BoxFit.cover, cacheWidth: cacheWidth),
        ),
      ),
    );
  }
}

class _Callout extends StatelessWidget {
  const _Callout({required this.label, required this.text, required this.color, required this.ink});
  final String label;
  final String text;
  final Color color;
  final Color ink;

  @override
  Widget build(BuildContext context) {
    final c = context.nefa;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(NefaRadii.md),
        border: Border.all(color: ink.withValues(alpha: .25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label.toUpperCase(), style: NefaType.eyebrow(color: ink)),
          const SizedBox(height: 6),
          Text(text, style: NefaType.style(14, 600, height: 1.45, color: c.ink)),
        ],
      ),
    );
  }
}
