import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/training.dart';
import '../../core/theme/tokens.dart';
import '../../shared/widgets/controls.dart';
import '../../shared/widgets/sheet.dart';
import '../../shared/widgets/surfaces.dart';
import '../settings/settings_controller.dart';
import 'plates.dart';

/// "What do I put on the bar?" Type a weight, see the plates for each side.
Future<void> showPlateCalculator(
  BuildContext context, {
  double? weight,
  double? bar,
  WeightUnit? unit,
}) {
  return showNefaSheet<void>(
    context,
    title: 'Plate calculator',
    subtitle: 'What to load on each side',
    icon: Icons.fitness_center_rounded,
    builder: (_) => PlateCalculator(weight: weight, bar: bar, unit: unit),
  );
}

class PlateCalculator extends ConsumerStatefulWidget {
  const PlateCalculator({super.key, this.weight, this.bar, this.unit});
  final double? weight;
  final double? bar;
  final WeightUnit? unit;

  @override
  ConsumerState<PlateCalculator> createState() => _PlateCalculatorState();
}

class _PlateCalculatorState extends ConsumerState<PlateCalculator> {
  late WeightUnit _unit = widget.unit ?? ref.read(settingsProvider).unit;
  late double _bar = widget.bar ?? barsFor(_unit).first;
  late double _weight = widget.weight ?? (_unit == WeightUnit.kg ? 60 : 135);
  late final _field = TextEditingController(text: _fmt(_weight));

  @override
  void dispose() {
    _field.dispose();
    super.dispose();
  }

  static String _fmt(double v) => v == v.roundToDouble()
      ? v.toStringAsFixed(0)
      : v.toStringAsFixed(2).replaceAll(RegExp(r'0$'), '');

  double get _step => _unit == WeightUnit.kg ? 2.5 : 5;

  void _set(double v) {
    final next = v.clamp(0, 999).toDouble();
    setState(() => _weight = next);
    _field.text = _fmt(next);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.nefa;
    final load = loadBar(_weight, bar: _bar, unit: _unit);
    final u = _unit.name;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          height: 64,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: c.recessed,
            borderRadius: BorderRadius.circular(NefaRadii.md),
            border: Border.all(color: c.rule),
          ),
          child: Row(
            children: [
              RoundIconButton(
                icon: Icons.remove_rounded,
                label: 'Less',
                size: 44,
                filled: true,
                onPressed: _weight - _step < 0
                    ? null
                    : () {
                        HapticFeedback.selectionClick();
                        _set(_weight - _step);
                      },
              ),
              Expanded(
                child: TextField(
                  controller: _field,
                  textAlign: TextAlign.center,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))],
                  style: NefaType.value(30, color: c.ink),
                  cursorColor: c.accent,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    suffixText: u,
                    suffixStyle: NefaType.style(16, 700, color: c.muted),
                  ),
                  onChanged: (t) {
                    final v = double.tryParse(t.replaceAll(',', '.'));
                    if (v != null) setState(() => _weight = v);
                  },
                ),
              ),
              RoundIconButton(
                icon: Icons.add_rounded,
                label: 'More',
                size: 44,
                filled: true,
                onPressed: () {
                  HapticFeedback.selectionClick();
                  _set(_weight + _step);
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Segmented<double>(
          values: barsFor(_unit),
          value: _bar,
          labelOf: (b) => b == 0 ? 'Plates only' : '${_fmt(b)} $u bar',
          onChanged: (b) => setState(() => _bar = b),
        ),
        const SizedBox(height: 22),
        if (load.belowBar)
          Notice(
            tone: NoticeTone.warn,
            text:
                'That’s lighter than the bar (${_fmt(_bar)} $u). Pick a lighter bar, or use dumbbells.',
          )
        else ...[
          Text('EACH SIDE', style: NefaType.eyebrow(color: c.muted)),
          const SizedBox(height: 10),
          SizedBox(
            height: 150,
            child: BarSide(plates: load.perSide, unit: _unit),
          ),
          const SizedBox(height: 14),
          Text(
            load.perSide.isEmpty ? 'Just the bar.' : load.perSide.map(plateLabel).join('  +  '),
            style: NefaType.style(22, 900, tracking: -.5, color: c.ink, tabular: true),
          ),
          const SizedBox(height: 4),
          Text(
            _bar == 0
                ? '${_fmt(load.side)} $u each side = ${_fmt(load.total)} $u of plates'
                : '${_fmt(_bar)} bar + ${_fmt(load.side)} each side = ${_fmt(load.total)} $u',
            style: NefaType.style(13.5, 600, color: c.muted, tabular: true),
          ),
          if (!load.exact && load.above != null) ...[
            const SizedBox(height: 14),
            Notice(
              tone: NoticeTone.warn,
              text:
                  '${_fmt(_weight)} $u can’t be made with standard plates. '
                  'Closest: ${_fmt(load.total)} or ${_fmt(load.above!.total)} $u.',
              action: 'Use ${_fmt(load.above!.total)}',
              onAction: () => _set(load.above!.total),
            ),
          ],
          const SizedBox(height: 14),
          Text(
            'Load the heaviest plate first, the same on both sides, and put a collar on each end.',
            style: NefaType.style(13, 500, height: 1.45, color: c.muted),
          ),
        ],
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton(
            onPressed: () {
              // Same kind of bar in the other unit, and a sensible weight.
              final barIndex = barsFor(_unit).indexOf(_bar);
              setState(() {
                _unit = _unit == WeightUnit.kg ? WeightUnit.lb : WeightUnit.kg;
                _bar = barsFor(_unit)[barIndex < 0 ? 0 : barIndex];
              });
              _set(_unit == WeightUnit.kg ? 60 : 135);
            },
            child: Text(
              'Plates in ${_unit == WeightUnit.kg ? 'pounds' : 'kilos'}?',
              style: NefaType.style(13.5, 700, color: c.accentInk),
            ),
          ),
        ),
      ],
    );
  }
}

/// One side of a loaded bar: sleeve, collar and plates, heaviest nearest the
/// middle, each sized roughly like the real thing.
class BarSide extends StatelessWidget {
  const BarSide({super.key, required this.plates, required this.unit});
  final List<double> plates;
  final WeightUnit unit;

  @override
  Widget build(BuildContext context) {
    final c = context.nefa;
    return Semantics(
      label: plates.isEmpty
          ? 'Empty bar'
          : 'Each side: ${plates.map(plateLabel).join(', ')} ${unit.name}',
      child: CustomPaint(
        painter: _BarPainter(
          plates: plates,
          heaviest: platesFor(unit).first,
          plate: c.board,
          plateEdge: c.isDark ? c.boardEdge : c.board,
          label: c.onBoard,
          bar: c.muted,
          collar: c.accent,
        ),
      ),
    );
  }
}

class _BarPainter extends CustomPainter {
  _BarPainter({
    required this.plates,
    required this.heaviest,
    required this.plate,
    required this.plateEdge,
    required this.label,
    required this.bar,
    required this.collar,
  });

  final List<double> plates;
  final double heaviest;
  final Color plate, plateEdge, label, bar, collar;

  // Relative height and thickness of each plate, by its share of the
  // heaviest one.
  double _h(double p) => .34 + .66 * (p / heaviest).clamp(0, 1);
  double _w(double p) => 10 + 16 * (p / heaviest).clamp(0, 1);

  @override
  void paint(Canvas canvas, Size size) {
    final mid = size.height / 2;
    const gap = 3.0;
    final need = plates.fold(0.0, (s, p) => s + _w(p) + gap) + 60;
    final scale = need > size.width ? size.width / need : 1.0;
    canvas.save();
    canvas.scale(scale, 1);
    final rr = Radius.circular(4);
    // The bar runs from the left edge (the middle of the bar) to the sleeve end.
    final barPaint = Paint()..color = bar;
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(0, mid - 4, 26, 8), rr), barPaint);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(22, mid - 16, 8, 32), rr), barPaint);
    var x = 34.0;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(x, mid - 6, (size.width / scale) - x - 4, 12),
        const Radius.circular(6),
      ),
      barPaint,
    );
    final tp = TextPainter(textDirection: TextDirection.ltr);
    for (final p in plates) {
      final w = _w(p);
      final h = size.height * _h(p);
      final r = Rect.fromLTWH(x, mid - h / 2, w, h);
      canvas.drawRRect(
        RRect.fromRectAndRadius(r, const Radius.circular(5)),
        Paint()..color = plate,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(r, const Radius.circular(5)),
        Paint()
          ..color = plateEdge
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1,
      );
      // Weight printed along the plate, like the real thing.
      tp.text = TextSpan(
        text: plateLabel(p),
        style: NefaType.style(w >= 18 ? 11 : 9, 900, color: label),
      );
      tp.layout();
      canvas.save();
      canvas.translate(x + w / 2, mid);
      canvas.rotate(-1.5708);
      tp.paint(canvas, Offset(-tp.width / 2, -tp.height / 2));
      canvas.restore();
      x += w + gap;
    }
    // Collar.
    if (plates.isNotEmpty) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(x + 2, mid - 12, 10, 24), const Radius.circular(3)),
        Paint()..color = collar,
      );
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_BarPainter old) =>
      old.plates.join(',') != plates.join(',') || old.plate != plate || old.heaviest != heaviest;
}
