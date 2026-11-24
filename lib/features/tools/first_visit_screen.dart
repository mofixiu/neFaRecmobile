import 'package:flutter/material.dart';

import '../../core/theme/tokens.dart';
import '../../shared/widgets/controls.dart';
import '../../shared/widgets/motion.dart';
import '../../shared/widgets/surfaces.dart';
import '../app/navigation.dart';
import '../equipment/equipment_screens.dart';
import '../plans/starter_plan_screen.dart';
import 'plate_calculator.dart';

void openFirstVisit(BuildContext context) => push(context, const FirstVisitScreen());

class _Section {
  const _Section(this.icon, this.title, this.points, {this.say = const []});
  final IconData icon;
  final String title;
  final List<String> points;

  /// Things you can actually say, shown as speech bubbles.
  final List<String> say;
}

const _sections = [
  _Section(Icons.backpack_outlined, 'Before you go', [
    'Wear trainers with flat, firm soles and clothes you can move in.',
    'Bring water, a small towel, and a padlock if there are lockers.',
    'Eat something light an hour or two before.',
    'Know what you’ll do before you walk in: open your routine, or get a starter plan.',
  ]),
  _Section(Icons.door_front_door_outlined, 'When you get there', [
    'Ask the front desk for a quick tour. Most gyms are happy to show you round.',
    'Find the wipes or spray, the water, and where the weights live.',
    'Warm up for five minutes on a bike or treadmill.',
  ]),
  _Section(Icons.handshake_outlined, 'Gym manners', [
    'Wipe the seat or bench after you use it.',
    'Put weights back where they came from, and take the plates off a bar when you’re done.',
    'Don’t sit on a machine scrolling between sets. If it’s busy, step off while you rest.',
    'Leave space in front of the dumbbell rack and the mirror so people can get to the weights.',
    'Keep your music in your headphones.',
  ]),
  _Section(
    Icons.swap_horiz_rounded,
    'Sharing equipment',
    [
      'A towel or bottle on a bench means someone is using it. Ask first.',
      '“Working in” means taking turns between sets. When you swap, put the pin back to their weight.',
      'If someone asks you, saying yes is normal. If a machine stays busy, tap “Machine taken?” in your workout for a swap.',
    ],
    say: ['Are you using this?', 'Can I work in with you?', 'How many sets have you got left?'],
  ),
  _Section(Icons.trending_up_rounded, 'Your first few weeks', [
    'Start lighter than you think. Tell neFaRec how each set felt and it moves the weight for you.',
    'Three to five exercises in about 45 minutes is plenty.',
    'Rest one to two minutes between sets.',
    'Sore muscles the next day are normal. Sharp or joint pain isn’t: stop that exercise.',
    'Nobody is watching you as much as you think. Everyone there started somewhere.',
  ]),
  _Section(
    Icons.support_agent_outlined,
    'Ask for help',
    ['Trainers on the floor will show you how a machine adjusts. That’s part of their job.'],
    say: ['Can you show me how this adjusts?'],
  ),
];

/// Short gym etiquette and first-day tips for people who've never been.
class FirstVisitScreen extends StatelessWidget {
  const FirstVisitScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.nefa;
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
                const Eyebrow('First visit'),
                const SizedBox(height: 8),
                Text('Your first time at the gym', style: Theme.of(context).textTheme.displaySmall),
                const SizedBox(height: 12),
                Text(
                  'What to bring, how gyms work, and what to say. Two minutes to read.',
                  style: NefaType.style(14.5, 500, height: 1.5, color: c.muted),
                ),
                const SizedBox(height: 22),
                for (final (i, s) in _sections.indexed) ...[
                  Rise(
                    index: i,
                    child: _SectionCard(section: s),
                  ),
                  const SizedBox(height: 12),
                ],
                const SizedBox(height: 14),
                Text('When you’re there', style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 12),
                if (equipmentScanSupported) ...[
                  NefaButton(
                    label: 'What’s this machine?',
                    icon: Icons.center_focus_strong_rounded,
                    onPressed: () => openEquipmentScanner(context),
                  ),
                  const SizedBox(height: 10),
                ],
                NefaButton(
                  label: 'What to put on the bar',
                  icon: Icons.fitness_center_rounded,
                  tone: ButtonTone.ghost,
                  onPressed: () => showPlateCalculator(context),
                ),
                const SizedBox(height: 10),
                NefaButton(
                  label: 'Get a starter plan',
                  icon: Icons.auto_awesome_outlined,
                  tone: ButtonTone.ghost,
                  onPressed: () => openStarterPlan(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.section});
  final _Section section;

  @override
  Widget build(BuildContext context) {
    final c = context.nefa;
    return SheetCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: c.accentWash,
                  borderRadius: BorderRadius.circular(NefaRadii.md - 6),
                ),
                child: Icon(section.icon, size: 20, color: c.accentInk),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  section.title,
                  style: NefaType.style(18, 800, tracking: -.3, color: c.ink),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          for (final p in section.points)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 8, right: 10),
                    child: Container(
                      width: 5,
                      height: 5,
                      decoration: BoxDecoration(color: c.accent, shape: BoxShape.circle),
                    ),
                  ),
                  Expanded(
                    child: Text(p, style: NefaType.style(14.5, 500, height: 1.5, color: c.ink)),
                  ),
                ],
              ),
            ),
          if (section.say.isNotEmpty) ...[
            const SizedBox(height: 4),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final line in section.say)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: c.board,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(14),
                        topRight: Radius.circular(14),
                        bottomRight: Radius.circular(14),
                        bottomLeft: Radius.circular(4),
                      ),
                    ),
                    child: Text('“$line”', style: NefaType.style(13.5, 700, color: c.onBoard)),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
