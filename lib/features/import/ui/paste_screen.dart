import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:paper_kit/paper_kit.dart';

import '../../../core/providers.dart';
import '../../../core/services/vision.dart';
import '../../../core/theme/tokens.dart';
import '../../../shared/widgets/controls.dart';
import '../../../shared/widgets/surfaces.dart';
import '../../routines/domain/routine_draft.dart';
import '../../settings/settings_controller.dart';
import '../domain/routine_parser.dart';
import 'review_screen.dart';

const _example = '''Monday — Push
Incline DB Press 3 × 10, rest 90 sec
Lateral Raises 3 × 15
Plank 3 × 45 sec
Push-ups 2 × failure''';

class PasteScreen extends ConsumerStatefulWidget {
  const PasteScreen({super.key});

  @override
  ConsumerState<PasteScreen> createState() => _PasteScreenState();
}

class _PasteScreenState extends ConsumerState<PasteScreen> {
  final _text = TextEditingController();
  bool _reading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _text.addListener(() => setState(() => _error = null));
  }

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  bool _scanning = false;

  /// Reads a photo, screenshot or PDF on-device and drops the text into the
  /// note so you can fix anything the scan got wrong before it is parsed.
  Future<void> _scan(Future<String?> Function() pickPath, {bool pdf = false}) async {
    const vision = VisionService();
    if (!vision.isSupported) {
      setState(
        () => _error = 'Photo and PDF import work on iPhone for now. Paste the text instead.',
      );
      return;
    }
    final path = await pickPath();
    if (path == null) return;
    setState(() => _scanning = true);
    try {
      final text = pdf ? await vision.textFromPdf(path) : await vision.textFromImage(path);
      if (!mounted) return;
      if (text.trim().isEmpty) {
        setState(
          () => _error =
              'No text found in that ${pdf ? 'PDF' : 'image'}. Try a sharper, straighter shot.',
        );
        return;
      }
      _text.text = text.trim();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Text read. Check it over, then tap Read routine.')),
      );
    } catch (e) {
      if (mounted) setState(() => _error = 'That file could not be read. ($e)');
    } finally {
      if (mounted) setState(() => _scanning = false);
    }
  }

  Future<String?> _pickImage(ImageSource source) async =>
      (await ImagePicker().pickImage(source: source, maxWidth: 2600))?.path;

  Future<String?> _pickPdf() async {
    final files = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['pdf'],
    );
    return files.isEmpty ? null : files.first.path;
  }

  Future<void> _pasteClipboard() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final t = data?.text?.trim();
    if (t == null || t.isEmpty) {
      setState(() => _error = 'Your clipboard is empty. Copy a routine first.');
      return;
    }
    _text.text = t;
  }

  Future<void> _read() async {
    final source = _text.text.trim();
    if (source.isEmpty) return;
    setState(() => _reading = true);
    try {
      final index = await ref.read(exerciseIndexProvider.future);
      final settings = ref.read(settingsProvider);
      final parsed = RoutineParser(
        index,
        defaultRestSeconds: settings.defaultRestSeconds,
        defaultUnit: settings.unit,
      ).parse(source);
      if (!mounted) return;
      if (parsed.isEmpty) {
        setState(
          () => _error =
              'No exercises found. Each line needs a name and a target, like “Squat 3 × 8” or “Plank 45 sec”.',
        );
        return;
      }
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) =>
              RoutineEditorScreen(draft: RoutineDraft.fromParsed(parsed, source), importing: true),
        ),
      );
    } finally {
      if (mounted) setState(() => _reading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.nefa;
    final bottom = MediaQuery.paddingOf(context).bottom;
    return PaperScaffold(
      body: Column(
        children: [
          const PageBar(closeIcon: true),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(NefaSpace.gutter, 4, NefaSpace.gutter, 24),
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              children: [
                const PageTitle(
                  'Paste your routine.',
                  subtitle:
                      'From Notes, WhatsApp, a doc or an AI chat. You’ll check everything before it’s saved.',
                ),
                const SizedBox(height: 26),
                PaperNote(
                  rotation: -.012,
                  tape: c.accent.withValues(alpha: .55),
                  padding: const EdgeInsets.fromLTRB(18, 26, 18, 14),
                  child: TextField(
                    controller: _text,
                    minLines: 10,
                    maxLines: 18,
                    keyboardType: TextInputType.multiline,
                    style: NefaType.style(15, 600, height: 1.6, color: c.ink),
                    cursorColor: c.accent,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      isDense: true,
                      hintText: _example,
                      hintStyle: NefaType.style(15, 500, height: 1.6, color: c.faint),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    Pill(
                      label: 'Paste from clipboard',
                      icon: Icons.content_paste_rounded,
                      onTap: _pasteClipboard,
                    ),
                    Pill(
                      label: _scanning ? 'Reading…' : 'Screenshot or photo',
                      icon: Icons.image_outlined,
                      onTap: _scanning ? null : () => _scan(() => _pickImage(ImageSource.gallery)),
                    ),
                    Pill(
                      label: 'Camera',
                      icon: Icons.photo_camera_outlined,
                      onTap: _scanning ? null : () => _scan(() => _pickImage(ImageSource.camera)),
                    ),
                    Pill(
                      label: 'PDF',
                      icon: Icons.picture_as_pdf_outlined,
                      onTap: _scanning ? null : () => _scan(_pickPdf, pdf: true),
                    ),
                    Pill(
                      label: 'Try the example',
                      icon: Icons.auto_awesome_outlined,
                      onTap: () => _text.text = _example,
                    ),
                    if (_text.text.isNotEmpty)
                      Pill(label: 'Clear', icon: Icons.backspace_outlined, onTap: _text.clear),
                  ],
                ),
                if (_error != null) ...[
                  const SizedBox(height: 18),
                  Notice(text: _error!, tone: NoticeTone.danger),
                ],
                const SizedBox(height: 24),
                Text('WHAT GETS READ', style: NefaType.eyebrow(color: c.muted)),
                const SizedBox(height: 10),
                for (final (a, b) in const [
                  ('Sets and reps', '3 × 10 · 4x8-12 · 3 sets of 8'),
                  ('Timed holds', '45 sec · 1:30 · 3 × 1 min'),
                  ('Load and rest', '@ 20kg · 135 lb · rest 90s'),
                  ('Days and supersets', 'Monday — Push · A1/A2 · Superset:'),
                ])
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(color: c.accent, shape: BoxShape.circle),
                        ),
                        const SizedBox(width: 10),
                        Text(a, style: NefaType.style(13.5, 700, color: c.ink)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            b,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: NefaType.style(13, 500, color: c.muted),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(NefaSpace.gutter, 12, NefaSpace.gutter, 12 + bottom),
            child: NefaButton(
              label: 'Read routine',
              icon: Icons.auto_fix_high_rounded,
              loading: _reading,
              onPressed: _text.text.trim().isEmpty ? null : _read,
            ),
          ),
        ],
      ),
    );
  }
}
