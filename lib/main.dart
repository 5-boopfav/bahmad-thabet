import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const ThabetApp());
}

// ==========================================
// الثيمات
// ==========================================

class BoardTheme {
  final String name;
  final Color background;
  final Color wood;
  final Color lines;
  final Color points;
  final Color accent;

  const BoardTheme({
    required this.name,
    required this.background,
    required this.wood,
    required this.lines,
    required this.points,
    required this.accent,
  });
}

const List<BoardTheme> boardThemes = [
  BoardTheme(
    name: 'الخشبي الملكي',
    background: Color(0xff17100c),
    wood: Color(0xff59351f),
    lines: Color(0xffe3bd79),
    points: Color(0xffffd27a),
    accent: Color(0xffd6a84f),
  ),
  BoardTheme(
    name: 'المحيط',
    background: Color(0xff101c2c),
    wood: Color(0xff183b55),
    lines: Color(0xff70d6e8),
    points: Color(0xffa2f0ff),
    accent: Color(0xff36b9d4),
  ),
  BoardTheme(
    name: 'الليلي',
    background: Color(0xff171323),
    wood: Color(0xff30233f),
    lines: Color(0xffbd8cff),
    points: Color(0xffdfbdff),
    accent: Color(0xffa66be8),
  ),
  BoardTheme(
    name: 'الناري',
    background: Color(0xff24100e),
    wood: Color(0xff54221c),
    lines: Color(0xffffa45e),
    points: Color(0xffffca77),
    accent: Color(0xffe86a37),
  ),
  BoardTheme(
    name: 'الرخامي',
    background: Color(0xff171b22),
    wood: Color(0xff414954),
    lines: Color(0xffd9e1e8),
    points: Color(0xffffffff),
    accent: Color(0xffaebdce),
  ),
];

// ==========================================
// التطبيق
// ==========================================

class ThabetApp extends StatefulWidget {
  const ThabetApp({super.key});

  @override
  State<ThabetApp> createState() => _ThabetAppState();
}

class _ThabetAppState extends State<ThabetApp> {
  int themeIndex = 0;
  bool soundEnabled = true;
  bool vibrationEnabled = true;

  BoardTheme get currentTheme => boardThemes[themeIndex];

  void changeTheme(int index) {
    setState(() => themeIndex = index);
  }

  void playSound() {
    if (soundEnabled) {
      SystemSound.play(SystemSoundType.click);
    }
  }

  void vibrate() {
    if (vibrationEnabled) {
      HapticFeedback.selectionClick();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ثبّت',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xff17100c),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xffd6a84f),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: HomePage(
        theme: currentTheme,
        themeIndex: themeIndex,
        onThemeChanged: changeTheme,
        soundEnabled: soundEnabled,
        vibrationEnabled: vibrationEnabled,
        onSoundChanged: (v) => setState(() => soundEnabled = v),
        onVibrationChanged: (v) =>
            setState(() => vibrationEnabled = v),
        playSound: playSound,
        vibrate: vibrate,
      ),
    );
  }
}

// ==========================================
// الشاشة الرئيسية
// ==========================================

class HomePage extends StatelessWidget {
  final BoardTheme theme;
  final int themeIndex;
  final Function(int) onThemeChanged;

  final bool soundEnabled;
  final bool vibrationEnabled;
  final Function(bool) onSoundChanged;
  final Function(bool) onVibrationChanged;

  final VoidCallback playSound;
  final VoidCallback vibrate;

  const HomePage({
    super.key,
    required this.theme,
    required this.themeIndex,
    required this.onThemeChanged,
    required this.soundEnabled,
    required this.vibrationEnabled,
    required this.onSoundChanged,
    required this.onVibrationChanged,
    required this.playSound,
    required this.vibrate,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: theme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(22),
          child: Column(
            children: [
              const SizedBox(height: 35),

              Container(
                width: 115,
                height: 115,
                decoration: BoxDecoration(
                  color: theme.wood,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: theme.lines,
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: theme.accent.withOpacity(.25),
                      blurRadius: 25,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.grid_4x4_rounded,
                  size: 65,
                  color: theme.lines,
                ),
              ),

              const SizedBox(height: 22),

              Text(
                'ثبّت',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: theme.lines,
                ),
              ),

              const SizedBox(height: 5),

              Text(
                'BAHMAD THABET',
                style: TextStyle(
                  fontSize: 15,
                  letterSpacing: 4,
                  color: theme.lines.withOpacity(.8),
                ),
              ),

              const SizedBox(height: 12),

              Text(
                'لعبة الذكاء والتحدي',
                style: TextStyle(
                  color: Colors.white.withOpacity(.7),
                  fontSize: 16,
                ),
              ),

              const SizedBox(height: 55),

              _mainButton(
                context,
                title: 'ابدأ اللعب',
                icon: Icons.play_arrow_rounded,
                onPressed: () {
                  playSound();
                  vibrate();

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => GamePage(
                        theme: theme,
                        playSound: playSound,
                        vibrate: vibrate,
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 14),

              _secondaryButton(
                title: 'قواعد اللعبة',
                icon: Icons.menu_book_rounded,
                onPressed: () {
                  playSound();
                  showRules(context, theme);
                },
              ),

              const SizedBox(height: 14),

              _secondaryButton(
                title: 'مظهر الطاولة',
                icon: Icons.palette_outlined,
                onPressed: () {
                  playSound();
                  showThemes(context);
                },
              ),

              const SizedBox(height: 14),

              _secondaryButton(
                title: 'الإعدادات',
                icon: Icons.settings_outlined,
                onPressed: () {
                  playSound();
                  showSettings(context);
                },
              ),

              const SizedBox(height: 50),

              Text(
                'BAHMAD • 2026',
                style: TextStyle(
                  color: Colors.white.withOpacity(.35),
                  letterSpacing: 2,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _mainButton(
    BuildContext context, {
    required String title,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 58,
      child: FilledButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        style: FilledButton.styleFrom(
          backgroundColor: theme.accent,
          foregroundColor: const Color(0xff20160d),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  Widget _secondaryButton({
    required String title,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, color: theme.lines),
        label: Text(
          title,
          style: TextStyle(
            color: theme.lines,
            fontWeight: FontWeight.bold,
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: BorderSide(
            color: theme.lines.withOpacity(.5),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  void showThemes(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xff241a13),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'اختر مظهر الطاولة',
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 18),

                ...List.generate(boardThemes.length, (i) {
                  final t = boardThemes[i];

                  return ListTile(
                    leading: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: t.wood,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: t.lines),
                      ),
                    ),
                    title: Text(t.name),
                    trailing: themeIndex == i
                        ? Icon(Icons.check_circle, color: t.lines)
                        : null,
                    onTap: () {
                      onThemeChanged(i);
                      Navigator.pop(ctx);
                    },
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  void showSettings(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xff241a13),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'إعدادات اللعبة',
                      style: TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    SwitchListTile(
                      title: const Text('الأصوات'),
                      secondary: const Icon(Icons.volume_up),
                      value: soundEnabled,
                      onChanged: (v) {
                        onSoundChanged(v);
                        setSheetState(() {});
                      },
                    ),

                    SwitchListTile(
                      title: const Text('الاهتزاز'),
                      secondary: const Icon(Icons.vibration),
                      value: vibrationEnabled,
                      onChanged: (v) {
                        onVibrationChanged(v);
                        setSheetState(() {});
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

// ==========================================
// قواعد اللعبة
// ==========================================

void showRules(BuildContext context, BoardTheme theme) {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      backgroundColor: const Color(0xff2b2018),
      title: Text(
        'قواعد ثبّت',
        style: TextStyle(color: theme.lines),
      ),
      content: const SingleChildScrollView(
        child: Text(
          '1. لكل لاعب 12 حجرًا.\n\n'
          '2. يتناوب اللاعبان في وضع الأحجار.\n\n'
          '3. لا توجد إزالة أثناء الرص.\n\n'
          '4. بعد انتهاء الرص، يزيل كل لاعب حجرًا واحدًا حسب الأولوية.\n\n'
          '5. الثبّت هو ثلاثة أحجار على خط أفقي أو عمودي.\n\n'
          '6. الحركة تكون إلى نقطة فارغة متصلة فقط.\n\n'
          '7. عند تكوين ثبّت جديد أثناء التحريك، تزال قطعة من الخصم.\n\n'
          '8. الفوز بإزالة جميع أحجار الخصم أو منعه من الحركة.',
          style: TextStyle(height: 1.6),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('إغلاق'),
        ),
      ],
    ),
  );
}

// ==========================================
// شاشة اللعب
// ==========================================

class GamePage extends StatefulWidget {
  final BoardTheme theme;
  final VoidCallback playSound;
  final VoidCallback vibrate;

  const GamePage({
    super.key,
    required this.theme,
    required this.playSound,
    required this.vibrate,
  });

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  static int nextStarter = 1;

  final points = <Offset>[
    const Offset(0, 0),
    const Offset(.5, 0),
    const Offset(1, 0),
    const Offset(1, .5),
    const Offset(1, 1),
    const Offset(.5, 1),
    const Offset(0, 1),
    const Offset(0, .5),

    const Offset(.17, .17),
    const Offset(.5, .17),
    const Offset(.83, .17),
    const Offset(.83, .5),
    const Offset(.83, .83),
    const Offset(.5, .83),
    const Offset(.17, .83),
    const Offset(.17, .5),

    const Offset(.34, .34),
    const Offset(.5, .34),
    const Offset(.66, .34),
    const Offset(.66, .5),
    const Offset(.66, .66),
    const Offset(.5, .66),
    const Offset(.34, .66),
    const Offset(.34, .5),
  ];

  late final List<List<int>> edges;
  late final List<List<int>> near;

  late int turn;
  late int starter;

  List<int> board = List.filled(24, 0);

  int redPlaced = 0;
  int whitePlaced = 0;
  int phase = 0;

  int? selected;
  int? pendingRemoval;
  int? firstMill;
  int? winner;

  bool initialRemovalPhase = false;
  bool firstInitialRemovalDone = false;
  int? initialFirstRemover;

  String status = '';

  @override
  void initState() {
    super.initState();

    starter = nextStarter;
    turn = starter;

    status = 'دور اللاعب ${name(turn)}: ضع حجرًا';

    edges = [];

    for (int r = 0; r < 3; r++) {
      int b = r * 8;

      for (int i = 0; i < 8; i++) {
        edges.add([b + i, b + (i + 1) % 8]);
      }
    }

    for (int i in [1, 3, 5, 7]) {
      edges.add([i, 8 + i]);
      edges.add([8 + i, 16 + i]);
    }

    near = List.generate(24, (_) => []);

    for (final e in edges) {
      near[e[0]].add(e[1]);
      near[e[1]].add(e[0]);
    }
  }

  List<List<int>> get mills {
    final m = <List<int>>[];

    for (int r = 0; r < 3; r++) {
      int b = r * 8;

      m.addAll([
        [b, b + 1, b + 2],
        [b + 2, b + 3, b + 4],
        [b + 4, b + 5, b + 6],
        [b + 6, b + 7, b],
      ]);
    }

    for (final i in [1, 3, 5, 7]) {
      m.add([i, 8 + i, 16 + i]);
    }

    return m;
  }

  int count(int p) => board.where((v) => v == p).length;

  bool hasMill(int i, int p) {
    return mills.any(
      (m) => m.contains(i) && m.every((n) => board[n] == p),
    );
  }

  String name(int p) => p == 1 ? 'الأحمر' : 'الأبيض';

  bool hasMove(int p) {
    return List.generate(24, (i) => i).any(
      (i) => board[i] == p && near[i].any((n) => board[n] == 0),
    );
  }

  void tapNode(int i) {
    if (phase == 2) return;

    widget.playSound();
    widget.vibrate();

    if (pendingRemoval != null) {
      if (board[i] == 3 - pendingRemoval!) {
        setState(() => _remove(i));
      }
      return;
    }

    setState(() {
      if (phase == 0) {
        if (board[i] != 0) return;

        board[i] = turn;

        if (turn == 1) {
          redPlaced++;
        } else {
          whitePlaced++;
        }

        if (hasMill(i, turn) && firstMill == null) {
          firstMill = turn;
        }

        if (redPlaced == 12 && whitePlaced == 12) {
          phase = 1;
          initialRemovalPhase = true;
          firstInitialRemovalDone = false;

          initialFirstRemover = firstMill ?? starter;
          pendingRemoval = initialFirstRemover;
          turn = initialFirstRemover!;

          status =
              'انتهى الرص. اللاعب ${name(turn)} له الأولوية. اختر حجرًا من الخصم لإزالته.';
        } else {
          turn = 3 - turn;
          status = 'دور اللاعب ${name(turn)}: ضع حجرًا';
        }
      } else {
        if (selected == null) {
          if (board[i] == turn) {
            selected = i;
            status = 'اختر نقطة فارغة متصلة لتحريك الحجر.';
          }
        } else if (board[i] == turn) {
          selected = i;
        } else if (board[i] == 0 && near[selected!].contains(i)) {
          board[selected!] = 0;
          board[i] = turn;
          selected = null;

          if (hasMill(i, turn)) {
            pendingRemoval = turn;
            status =
                'ثبّت! اختر حجرًا من اللاعب ${name(3 - turn)} لإزالته.';
          } else {
            _endTurn();
          }
        } else {
          selected = null;
          status = 'اختر نقطة فارغة متصلة بخط.';
        }
      }
    });
  }

  void _remove(int i) {
    final remover = pendingRemoval!;

    board[i] = 0;
    pendingRemoval = null;

    if (initialRemovalPhase) {
      if (!firstInitialRemovalDone) {
        firstInitialRemovalDone = true;

        final secondRemover = 3 - remover;
        turn = secondRemover;
        pendingRemoval = secondRemover;

        status =
            'تمت الإزالة الأولى. الآن اللاعب ${name(secondRemover)} يجب أن يزيل حجرًا من الخصم.';

        return;
      }

      initialRemovalPhase = false;
      firstInitialRemovalDone = false;
      pendingRemoval = null;

      turn = initialFirstRemover!;
      selected = null;

      status =
          'اكتملت الإزالتان! الآن دور اللاعب ${name(turn)} لتحريك حجر.';

      return;
    }

    if (count(3 - remover) == 0) {
      winner = remover;
      phase = 2;
      status = 'فاز اللاعب ${name(remover)}!';
      return;
    }

    turn = 3 - remover;
    _checkNextTurn();
  }

  void _endTurn() {
    turn = 3 - turn;
    _checkNextTurn();
  }

  void _checkNextTurn() {
    selected = null;

    if (count(turn) == 0) {
      winner = 3 - turn;
      phase = 2;
      status = 'فاز اللاعب ${name(winner!)}!';
      return;
    }

    if (!hasMove(turn)) {
      winner = 3 - turn;
      phase = 2;
      status =
          'فاز اللاعب ${name(winner!)}! اللاعب ${name(turn)} لا يملك حركة متاحة.';
      return;
    }

    status = 'دور اللاعب ${name(turn)}: حرّك حجرًا';
  }

  void restart() {
    setState(() {
      starter = 3 - starter;
      nextStarter = starter;

      turn = starter;
      board = List.filled(24, 0);

      redPlaced = 0;
      whitePlaced = 0;
      phase = 0;

      selected = null;
      pendingRemoval = null;
      firstMill = null;
      winner = null;

      initialRemovalPhase = false;
      firstInitialRemovalDone = false;
      initialFirstRemover = null;

      status = 'مباراة جديدة. يبدأ اللاعب ${name(turn)}.';
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;

    return Scaffold(
      backgroundColor: theme.background,
      appBar: AppBar(
        backgroundColor: theme.wood,
        foregroundColor: theme.lines,
        centerTitle: true,
        title: const Text(
          'ثبّت • BAHMAD THABET',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            tooltip: 'القواعد',
            icon: const Icon(Icons.info_outline),
            onPressed: () => showRules(context, theme),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 12),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _player('الأحمر', count(1), 1),
                _player('الأبيض', count(2), 2),
              ],
            ),

            Container(
              margin: const EdgeInsets.all(14),
              padding: const EdgeInsets.all(14),
              width: double.infinity,
              decoration: BoxDecoration(
                color: theme.wood,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: theme.lines),
                boxShadow: [
                  BoxShadow(
                    color: theme.accent.withOpacity(.15),
                    blurRadius: 12,
                  ),
                ],
              ),
              child: Text(
                status,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            Expanded(
              child: Center(
                child: AspectRatio(
                  aspectRatio: 1,
                  child: LayoutBuilder(
                    builder: (c, box) {
                      final s = box.maxWidth;

                      return GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTapDown: (d) {
                          final pos = d.localPosition;

                          int best = 0;
                          double dist = 9999;

                          for (int i = 0; i < 24; i++) {
                            final q = Offset(
                              points[i].dx * s,
                              points[i].dy * s,
                            );

                            final x = (q - pos).distance;

                            if (x < dist) {
                              dist = x;
                              best = i;
                            }
                          }

                          if (dist < s * .085) {
                            tapNode(best);
                          }
                        },
                        child: Stack(
                          children: [
                            CustomPaint(
                              size: Size(s, s),
                              painter: _BoardPainter(
                                points,
                                edges,
                                theme,
                              ),
                            ),

                            for (int i = 0; i < 24; i++)
                              Positioned(
                                left: points[i].dx * s - s * .029,
                                top: points[i].dy * s - s * .029,
                                child: AnimatedContainer(
                                  duration: const Duration(
                                    milliseconds: 180,
                                  ),
                                  width: s * .058,
                                  height: s * .058,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: board[i] == 1
                                        ? const Color(0xffe53935)
                                        : board[i] == 2
                                            ? Colors.white
                                            : theme.points,
                                    border: Border.all(
                                      color: selected == i
                                          ? Colors.cyanAccent
                                          : theme.lines,
                                      width: selected == i ? 4 : 2,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: selected == i
                                            ? Colors.cyanAccent
                                                .withOpacity(.8)
                                            : theme.accent.withOpacity(.25),
                                        blurRadius: selected == i ? 15 : 5,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(14, 5, 14, 14),
              child: Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: restart,
                      icon: const Icon(Icons.refresh),
                      label: const Text('مباراة جديدة'),
                      style: FilledButton.styleFrom(
                        backgroundColor: theme.accent,
                        foregroundColor: Colors.black,
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.home_outlined),
                      label: const Text('الرئيسية'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: theme.lines,
                        side: BorderSide(color: theme.lines),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _player(String label, int n, int p) {
    final theme = widget.theme;

    return Container(
      width: 145,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: theme.wood,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: p == 1
              ? const Color(0xffe53935)
              : Colors.white70,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: p == 1
                  ? const Color(0xffe53935)
                  : Colors.white,
            ),
          ),

          const SizedBox(width: 8),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text('الأحجار: $n'),
            ],
          ),
        ],
      ),
    );
  }
}

// ==========================================
// رسم الطاولة الخشبية
// ==========================================

class _BoardPainter extends CustomPainter {
  final List<Offset> p;
  final List<List<int>> e;
  final BoardTheme theme;

  _BoardPainter(this.p, this.e, this.theme);

  @override
  void paint(Canvas c, Size s) {
    final r = Offset.zero & s;

    final woodPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          theme.wood,
          theme.wood.withOpacity(.75),
          theme.background,
          theme.wood,
        ],
      ).createShader(r);

    c.drawRRect(
      RRect.fromRectAndRadius(
        r.deflate(3),
        const Radius.circular(22),
      ),
      woodPaint,
    );

    // خطوط زخرفية تعطي إحساس الخشب
    final grain = Paint()
      ..color = theme.lines.withOpacity(.07)
      ..strokeWidth = 1;

    for (int i = 1; i < 12; i++) {
      final y = s.height * i / 12;

      c.drawLine(
        Offset(s.width * .04, y),
        Offset(s.width * .96, y),
        grain,
      );
    }

    final line = Paint()
      ..color = theme.lines
      ..strokeWidth = s.width * .012
      ..strokeCap = StrokeCap.round;

    for (final x in e) {
      c.drawLine(
        Offset(
          p[x[0]].dx * s.width,
          p[x[0]].dy * s.height,
        ),
        Offset(
          p[x[1]].dx * s.width,
          p[x[1]].dy * s.height,
        ),
        line,
      );
    }

    c.drawRRect(
      RRect.fromRectAndRadius(
        r.deflate(3),
        const Radius.circular(22),
      ),
      Paint()
        ..color = theme.accent
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5,
    );

    c.drawRRect(
      RRect.fromRectAndRadius(
        r.deflate(10),
        const Radius.circular(17),
      ),
      Paint()
        ..color = theme.lines.withOpacity(.25)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
  }

  @override
  bool shouldRepaint(covariant _BoardPainter old) {
    return old.theme != theme;
  }
}
