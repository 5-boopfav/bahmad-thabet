import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
void main() {
  runApp(const ThabetApp());
}

// ======================================================
// الثيمات
// ======================================================

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

// ======================================================
// خلفيات التطبيق
// ======================================================

const List<Color> appBackgrounds = [
  Color(0xfff5f5f5),
  Color(0xffe8e8e8),
  Color(0xff171717),
  Color(0xff34271f),
  Color(0xffe8edf4),
];

// ======================================================
// التطبيق
// ======================================================

class ThabetApp extends StatefulWidget {
  const ThabetApp({super.key});

  @override
  State<ThabetApp> createState() => _ThabetAppState();
}

class _ThabetAppState extends State<ThabetApp> {
  int themeIndex = 0;
  int backgroundIndex = 0;

  bool soundEnabled = true;
  bool vibrationEnabled = true;

  BoardTheme get theme => boardThemes[themeIndex];

  Color get appBackground => appBackgrounds[backgroundIndex];

  void sound() {
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
        brightness: Brightness.light,
        useMaterial3: true,
        scaffoldBackgroundColor: appBackground,
        colorScheme: ColorScheme.fromSeed(
          seedColor: theme.accent,
          brightness: Brightness.light,
        ),
      ),
      home: HomePage(
        theme: theme,
        themeIndex: themeIndex,
        appBackground: appBackground,
        backgroundIndex: backgroundIndex,
        onThemeChanged: (v) => setState(() => themeIndex = v),
        onBackgroundChanged: (v) =>
            setState(() => backgroundIndex = v),
        soundEnabled: soundEnabled,
        vibrationEnabled: vibrationEnabled,
        onSoundChanged: (v) => setState(() => soundEnabled = v),
        onVibrationChanged: (v) =>
            setState(() => vibrationEnabled = v),
        sound: sound,
        vibrate: vibrate,
      ),
    );
  }
}

// ======================================================
// الشاشة الرئيسية
// ======================================================

class HomePage extends StatelessWidget {
  final BoardTheme theme;
  final int themeIndex;
  final Color appBackground;
  final int backgroundIndex;

  final ValueChanged<int> onThemeChanged;
  final ValueChanged<int> onBackgroundChanged;

  final bool soundEnabled;
  final bool vibrationEnabled;

  final ValueChanged<bool> onSoundChanged;
  final ValueChanged<bool> onVibrationChanged;

  final VoidCallback sound;
  final VoidCallback vibrate;

  const HomePage({
    super.key,
    required this.theme,
    required this.themeIndex,
    required this.appBackground,
    required this.backgroundIndex,
    required this.onThemeChanged,
    required this.onBackgroundChanged,
    required this.soundEnabled,
    required this.vibrationEnabled,
    required this.onSoundChanged,
    required this.onVibrationChanged,
    required this.sound,
    required this.vibrate,
  });

  bool get isDark =>
      ThemeData.estimateBrightnessForColor(appBackground) ==
      Brightness.dark;

  Color get textColor => isDark ? Colors.white : Colors.black87;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appBackground,
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
                      color: theme.accent.withOpacity(.3),
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
              const SizedBox(height: 20),
              Text(
                'ثبّت',
                style: TextStyle(
                  fontSize: 50,
                  fontWeight: FontWeight.bold,
                  color: theme.accent,
                ),
              ),
              Text(
                'BAHMAD THABET',
                style: TextStyle(
                  fontSize: 14,
                  letterSpacing: 4,
                  color: textColor.withOpacity(.7),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'لعبة الذكاء والتحدي',
                style: TextStyle(
                  fontSize: 16,
                  color: textColor.withOpacity(.7),
                ),
              ),
              const SizedBox(height: 45),
              _button(
                context,
                'العب ضد الكمبيوتر',
                Icons.smart_toy,
                () => _chooseDifficulty(context),
                main: true,
              ),
              const SizedBox(height: 13),
              _button(
                context,
                'لاعبان على نفس الجهاز',
                Icons.people_alt,
                () => _start(context, false, 1),
              ),
              const SizedBox(height: 13),
              _button(
                context,
                'قواعد اللعبة',
                Icons.menu_book,
                () => rules(context),
              ),
              const SizedBox(height: 13),
              _button(
                context,
                'مظهر الطاولة',
                Icons.palette,
                () => _themes(context),
              ),
              const SizedBox(height: 13),
              _button(
                context,
                'الإعدادات',
                Icons.settings,
                () => _settings(context),
              ),
              const SizedBox(height: 40),
              Text(
                'BAHMAD • 2026',
                style: TextStyle(
                  color: textColor.withOpacity(.35),
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _button(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback action, {
    bool main = false,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: main
          ? FilledButton.icon(
              onPressed: action,
              icon: Icon(icon),
              label: Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: theme.accent,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            )
          : OutlinedButton.icon(
              onPressed: action,
              icon: Icon(icon, color: theme.accent),
              label: Text(
                title,
                style: TextStyle(color: textColor),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                  color: theme.accent.withOpacity(.5),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
    );
  }

  void _start(
    BuildContext context,
    bool computer,
    int difficulty,
  ) {
    sound();
    vibrate();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GamePage(
          theme: theme,
          appBackground: appBackground,
          computerMode: computer,
          difficulty: difficulty,
          sound: sound,
          vibrate: vibrate,
        ),
      ),
    );
  }

  void _chooseDifficulty(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xff2b2018),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'اختر مستوى الكمبيوتر',
                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                  color: theme.lines,
                ),
              ),
              const SizedBox(height: 15),
              _difficultyTile(
                ctx,
                context,
                'سهل',
                'مناسب للمبتدئين',
                1,
              ),
              _difficultyTile(
                ctx,
                context,
                'متوسط',
                'تحدٍّ متوازن',
                2,
              ),
              _difficultyTile(
                ctx,
                context,
                'صعب',
                'خصم أكثر ذكاءً',
                3,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _difficultyTile(
    BuildContext sheetContext,
    BuildContext homeContext,
    String title,
    String subtitle,
    int level,
  ) {
    return ListTile(
      leading: Icon(Icons.smart_toy, color: theme.lines),
      title: Text(title),
      subtitle: Text(subtitle),
      onTap: () {
        Navigator.pop(sheetContext);
        _start(homeContext, true, level);
      },
    );
  }

  void _themes(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xff241a13),
      builder: (ctx) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            const Padding(
              padding: EdgeInsets.all(18),
              child: Text(
                'اختر مظهر الطاولة',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            for (int i = 0; i < boardThemes.length; i++)
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: boardThemes[i].wood,
                  child: Icon(
                    Icons.palette,
                    color: boardThemes[i].lines,
                  ),
                ),
                title: Text(boardThemes[i].name),
                trailing: themeIndex == i
                    ? Icon(
                        Icons.check_circle,
                        color: theme.lines,
                      )
                    : null,
                onTap: () {
                  onThemeChanged(i);
                  Navigator.pop(ctx);
                },
              ),
          ],
        ),
      ),
    );
  }

  void _settings(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xff241a13),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setSheet) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(18),
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
                const SizedBox(height: 8),
                SwitchListTile(
                  title: const Text('الأصوات'),
                  value: soundEnabled,
                  onChanged: (v) {
                    onSoundChanged(v);
                    setSheet(() {});
                  },
                ),
                SwitchListTile(
                  title: const Text('الاهتزاز'),
                  value: vibrationEnabled,
                  onChanged: (v) {
                    onVibrationChanged(v);
                    setSheet(() {});
                  },
                ),
                const Divider(),
                const Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    'خلفية التطبيق',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 12,
                  runSpacing: 12,
                  children: List.generate(
                    appBackgrounds.length,
                    (i) => GestureDetector(
                      onTap: () {
                        onBackgroundChanged(i);
                        setSheet(() {});
                      },
                      child: Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: appBackgrounds[i],
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: backgroundIndex == i
                                ? theme.accent
                                : Colors.grey,
                            width: backgroundIndex == i ? 3 : 1,
                          ),
                        ),
                        child: backgroundIndex == i
                            ? const Icon(
                                Icons.check,
                                color: Colors.green,
                              )
                            : null,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void rules(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xff2b2018),
        title: Text(
          'قواعد ثبّت',
          style: TextStyle(color: theme.lines),
        ),
        content: const SingleChildScrollView(
          child: Text(
            '• لكل لاعب 12 حجرًا.\n\n'
            '• يتناوب اللاعبان في وضع الأحجار.\n\n'
            '• لا توجد إزالة أثناء الرص.\n\n'
            '• بعد انتهاء الرص، يزيل كل لاعب حجرًا واحدًا حسب الأولوية.\n\n'
            '• بعد الإزالة الأولى لا نفحص الفوز بسبب انعدام الحركات.\n\n'
            '• بعد الإزالة الثانية نفحص حركات اللاعب الأول.\n\n'
            '• إذا لم يجد اللاعب الأول أي حركة، يفوز اللاعب الثاني.\n\n'
            '• الثبّت هو ثلاثة أحجار على خط أفقي أو عمودي.\n\n'
            '• الحركة إلى نقطة فارغة متصلة فقط.\n\n'
            '• عند تكوين ثبّت جديد، تزال قطعة من الخصم.\n\n'
            '• يمكن إزالة أي حجر من أحجار الخصم.\n\n'
            '• الفوز بإزالة جميع أحجار الخصم أو منعه من الحركة.',
            style: TextStyle(height: 1.6),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('إغلاق'),
          ),
        ],
      ),
    );
  }
}

// ======================================================
// شاشة اللعبة
// ======================================================

class GamePage extends StatefulWidget {
  final BoardTheme theme;
  final Color appBackground;
  final bool computerMode;
  final int difficulty;
  final VoidCallback sound;
  final VoidCallback vibrate;

  const GamePage({
    super.key,
    required this.theme,
    required this.appBackground,
    required this.computerMode,
    required this.difficulty,
    required this.sound,
    required this.vibrate,
  });

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  static int nextStarter = 1;

  final List<Offset> points = const [
    Offset(0, 0),
    Offset(.5, 0),
    Offset(1, 0),
    Offset(1, .5),
    Offset(1, 1),
    Offset(.5, 1),
    Offset(0, 1),
    Offset(0, .5),
    Offset(.17, .17),
    Offset(.5, .17),
    Offset(.83, .17),
    Offset(.83, .5),
    Offset(.83, .83),
    Offset(.5, .83),
    Offset(.17, .83),
    Offset(.17, .5),
    Offset(.34, .34),
    Offset(.5, .34),
    Offset(.66, .34),
    Offset(.66, .5),
    Offset(.66, .66),
    Offset(.5, .66),
    Offset(.34, .66),
    Offset(.34, .5),
  ];

  late final List<List<int>> edges;
  late final List<List<int>> near;
  late final List<List<int>> mills;

  List<int> board = List.filled(24, 0);
  List<List<int>> history = [];

  late int starter;
  late int turn;

  int whitePlaced = 0;
  int blackPlaced = 0;
  int phase = 0;

  int? selected;
  int? pendingRemoval;
  int? winner;
  int? firstMill;
  int? initialFirstRemover;
  int? hintDestination;

  bool initialRemovalPhase = false;
  bool firstInitialRemovalDone = false;
  bool paused = false;
  bool showHint = false;
  bool replayMode = false;

  bool millCelebration = false;
  List<int> highlightedMill = [];
  Timer? millTimer;

  int replayIndex = 0;
  int seconds = 0;

  Timer? clock;
  Timer? aiTimer;

  String status = '';

  int get playerCount =>
      board.where((v) => v == 1).length;

  int get computerCount =>
      board.where((v) => v == 2).length;

  String playerName(int p) =>
      p == 1 ? 'الأبيض' : 'الأسود';

  @override
  void initState() {
    super.initState();

    starter = nextStarter;
    turn = starter;

    status = 'دور ${playerName(turn)}: ضع حجرًا';

    edges = [];

    for (int r = 0; r < 3; r++) {
      final b = r * 8;
      for (int i = 0; i < 8; i++) {
        edges.add([b + i, b + (i + 1) % 8]);
      }
    }

    for (final i in [1, 3, 5, 7]) {
      edges.add([i, 8 + i]);
      edges.add([8 + i, 16 + i]);
    }

    near = List.generate(24, (_) => []);

    for (final e in edges) {
      near[e[0]].add(e[1]);
      near[e[1]].add(e[0]);
    }

    mills = _createMills();

    clock = Timer.periodic(
      const Duration(seconds: 1),
      (_) {
        if (mounted &&
            !paused &&
            winner == null &&
            !replayMode) {
          setState(() => seconds++);
        }
      },
    );

    _scheduleComputer();
  }

  List<List<int>> _createMills() {
    final result = <List<int>>[];

    for (int r = 0; r < 3; r++) {
      final b = r * 8;
      result.addAll([
        [b, b + 1, b + 2],
        [b + 2, b + 3, b + 4],
        [b + 4, b + 5, b + 6],
        [b + 6, b + 7, b],
      ]);
    }

    for (final i in [1, 3, 5, 7]) {
      result.add([i, 8 + i, 16 + i]);
    }

    return result;
  }

  bool hasMill(int index, int p) {
    return mills.any(
      (m) => m.contains(index) &&
          m.every((i) => board[i] == p),
    );
  }

  bool formsMill(int index, int p) {
    return hasMill(index, p);
  }

  List<int>? _getMill(int index, int p) {
    for (final m in mills) {
      if (m.contains(index) &&
          m.every((i) => board[i] == p)) {
        return m;
      }
    }
    return null;
  }

  void _celebrateMill(int index, int player) {
    final formed = _getMill(index, player);
    if (formed == null) return;

    millTimer?.cancel();

    setState(() {
      highlightedMill = List<int>.from(formed);
      millCelebration = true;
    });

    widget.sound();
    widget.vibrate();

    millTimer = Timer(
      const Duration(milliseconds: 1200),
      () {
        if (!mounted) return;
        setState(() {
          millCelebration = false;
          highlightedMill.clear();
        });
      },
    );
  }

  bool hasMove(int p) {
    for (int i = 0; i < 24; i++) {
      if (board[i] == p &&
          near[i].any((n) => board[n] == 0)) {
        return true;
      }
    }
    return false;
  }

  List<int> legalDestinations(int from) {
    return near[from]
        .where((i) => board[i] == 0)
        .toList();
  }

  void _saveHistory() {
    history.add(List<int>.from(board));
  }

  void _scheduleComputer() {
    aiTimer?.cancel();

    if (!widget.computerMode ||
        turn != 2 ||
        winner != null ||
        paused ||
        replayMode) {
      return;
    }

    aiTimer = Timer(
      const Duration(milliseconds: 650),
      () {
        if (!mounted ||
            paused ||
            turn != 2 ||
            winner != null) {
          return;
        }
        _computerMove();
      },
    );
  }

  void _computerMove() {
    if (pendingRemoval == 2) {
      _computerRemove();
      return;
    }

    if (pendingRemoval == 1 || winner != null) return;

    if (phase == 0) {
      _computerPlace();
    } else if (phase == 1) {
      _computerMoveStone();
    }
  }

  void _computerPlace() {
    final options = <int>[];

    for (int i = 0; i < 24; i++) {
      if (board[i] == 0) options.add(i);
    }

    if (options.isEmpty) return;

    options.shuffle();

    int chosen = options.first;

    if (widget.difficulty >= 2) {
      for (final i in options) {
        board[i] = 2;
        final makes = formsMill(i, 2);
        board[i] = 0;

        if (makes) {
          chosen = i;
          break;
        }
      }

      if (widget.difficulty == 3) {
        for (final i in options) {
          board[i] = 1;
          final blocks = formsMill(i, 1);
          board[i] = 0;

          if (blocks) {
            chosen = i;
            break;
          }
        }
      }
    }

    setState(() {
      board[chosen] = 2;
      blackPlaced++;

      if (hasMill(chosen, 2)) {
        if (firstMill == null) firstMill = 2;
        _celebrateMill(chosen, 2);
      }

      _saveHistory();
      _afterPlacement();
    });
  }

  void _computerMoveStone() {
    final moves = <List<int>>[];

    for (int i = 0; i < 24; i++) {
      if (board[i] == 2) {
        for (final n in near[i]) {
          if (board[n] == 0) moves.add([i, n]);
        }
      }
    }

    if (moves.isEmpty) {
      setState(() {
        winner = 1;
        phase = 2;
        status = 'فاز الأبيض! الكمبيوتر لا يملك حركة.';
      });
      return;
    }

    moves.shuffle();

    List<int> chosen = moves.first;

    for (final move in moves) {
      board[move[0]] = 0;
      board[move[1]] = 2;
      final makes = hasMill(move[1], 2);
      board[move[0]] = 2;
      board[move[1]] = 0;

      if (makes) {
        chosen = move;
        break;
      }
    }

    if (widget.difficulty == 3) {
      for (final move in moves) {
        board[move[0]] = 0;
        board[move[1]] = 2;
        final blocks = hasMill(move[1], 1);
        board[move[0]] = 2;
        board[move[1]] = 0;

        if (blocks) {
          chosen = move;
          break;
        }
      }
    }

    setState(() {
      board[chosen[0]] = 0;
      board[chosen[1]] = 2;
      _saveHistory();

      if (hasMill(chosen[1], 2)) {
        pendingRemoval = 2;
        status = 'الكمبيوتر كوّن ثبّت!';
        _celebrateMill(chosen[1], 2);
      } else {
        _endTurn();
      }
    });

    _scheduleComputer();
  }

  void _computerRemove() {
    final targets = <int>[];

    for (int i = 0; i < 24; i++) {
      if (board[i] == 1) targets.add(i);
    }

    if (targets.isEmpty) {
      setState(() => _endTurn());
      return;
    }

    int target = targets.first;

    if (widget.difficulty >= 2) {
      target = targets.firstWhere(
        (i) => !hasMill(i, 1),
        orElse: () => targets.first,
      );
    }

    setState(() {
      board[target] = 0;
      pendingRemoval = null;
      _saveHistory();
      _afterRemoval(2);
    });
  }

  void _afterPlacement() {
    if (whitePlaced == 12 && blackPlaced == 12) {
      phase = 1;
      initialRemovalPhase = true;
      firstInitialRemovalDone = false;

      initialFirstRemover = firstMill ?? starter;
      pendingRemoval = initialFirstRemover;
      turn = initialFirstRemover!;

      status =
          'انتهى الرص. ${playerName(turn)} يزيل حجرًا من الخصم.';
      _scheduleComputer();
    } else {
      turn = 3 - turn;
      status = 'دور ${playerName(turn)}: ضع حجرًا';
      _scheduleComputer();
    }
  }

  // ======================================================
  // قاعدة الإزالتين الأولى والثانية
  // ======================================================

  void _afterRemoval(int remover) {
    if (initialRemovalPhase) {
      if (!firstInitialRemovalDone) {
        firstInitialRemovalDone = true;

        final next = 3 - remover;
        turn = next;
        pendingRemoval = next;

        status =
            '${playerName(next)} يجب أن يزيل حجرًا من الخصم.';
        _scheduleComputer();
        return;
      }

      initialRemovalPhase = false;
      firstInitialRemovalDone = false;
      pendingRemoval = null;

      turn = initialFirstRemover!;

      if (board.every((v) => v != turn) ||
          !hasMove(turn)) {
        winner = 3 - turn;
        phase = 2;
        status =
            'فاز ${playerName(winner!)}! اللاعب الأول لا يملك حركة متاحة.';
        return;
      }

      status =
          'اكتملت الإزالتان. دور ${playerName(turn)} للتحريك.';
      _scheduleComputer();
      return;
    }

    if (board.every((v) => v != 3 - remover)) {
      winner = remover;
      phase = 2;
      status = 'فاز ${playerName(remover)}!';
      return;
    }

    turn = 3 - remover;
    _checkNextTurn();
    _scheduleComputer();
  }

  void _removeStone(int index) {
    if (pendingRemoval == null) return;
    if (board[index] != 3 - pendingRemoval!) return;

    final remover = pendingRemoval!;

    setState(() {
      board[index] = 0;
      pendingRemoval = null;
      _saveHistory();
      _afterRemoval(remover);
    });

    widget.sound();
    widget.vibrate();
  }

  void _endTurn() {
    turn = 3 - turn;
    selected = null;
    showHint = false;
    hintDestination = null;
    _checkNextTurn();
    _scheduleComputer();
  }

  void _checkNextTurn() {
    selected = null;

    if (board.every((v) => v != turn)) {
      winner = 3 - turn;
      phase = 2;
      status = 'فاز ${playerName(winner!)}!';
      return;
    }

    if (!hasMove(turn)) {
      winner = 3 - turn;
      phase = 2;
      status =
          'فاز ${playerName(winner!)}! لا توجد حركات متاحة.';
      return;
    }

    status = 'دور ${playerName(turn)}: اسحب حجرًا';
  }

  void _placeStone(int index) {
    if (board[index] != 0) return;

    setState(() {
      board[index] = turn;

      if (turn == 1) {
        whitePlaced++;
      } else {
        blackPlaced++;
      }

      if (hasMill(index, turn)) {
        if (firstMill == null) firstMill = turn;
        _celebrateMill(index, turn);
      }

      _saveHistory();
      _afterPlacement();
    });

    widget.sound();
    widget.vibrate();
  }

  void _moveStone(int from, int to) {
    if (board[from] != turn || board[to] != 0) return;
    if (!near[from].contains(to)) return;

    setState(() {
      board[from] = 0;
      board[to] = turn;
      selected = null;
      showHint = false;
      hintDestination = null;

      _saveHistory();

      if (hasMill(to, turn)) {
        pendingRemoval = turn;
        status =
            'ثبّت! اختر حجرًا من ${playerName(3 - turn)} لإزالته.';
        _celebrateMill(to, turn);
      } else {
        _endTurn();
      }
    });

    widget.sound();
    widget.vibrate();
  }

  void _tapNode(int index) {
    if (paused || winner != null || replayMode) return;
    if (widget.computerMode && turn == 2) return;

    if (pendingRemoval != null) {
      widget.sound();
      widget.vibrate();
      _removeStone(index);
      return;
    }

    if (phase == 0) {
      widget.sound();
      widget.vibrate();

      if (board[index] == 0) {
        _placeStone(index);
      }
    }

    // في مرحلة التحريك: السحب فقط.
  }

  void _dragMove(int from, int to) {
    if (paused || winner != null || replayMode) return;
    if (widget.computerMode && turn == 2) return;
    if (pendingRemoval != null) return;
    if (phase != 1) return;
    if (board[from] != turn) return;
    if (board[to] != 0) return;
    if (!near[from].contains(to)) return;

    _moveStone(from, to);
  }

  void _restart() {
    aiTimer?.cancel();
    millTimer?.cancel();

    setState(() {
      starter = 3 - starter;
      nextStarter = starter;
      turn = starter;

      board = List.filled(24, 0);
      history.clear();

      whitePlaced = 0;
      blackPlaced = 0;
      phase = 0;

      selected = null;
      pendingRemoval = null;
      winner = null;
      firstMill = null;
      initialFirstRemover = null;

      initialRemovalPhase = false;
      firstInitialRemovalDone = false;

      showHint = false;
      hintDestination = null;
      replayMode = false;
      replayIndex = 0;
      seconds = 0;

      millCelebration = false;
      highlightedMill.clear();

      status = 'مباراة جديدة. يبدأ ${playerName(turn)}.';
    });

    _scheduleComputer();
  }

  void _hint() {
    if (!widget.computerMode) return;
    if (winner != null || turn != 1 || paused) return;
    if (pendingRemoval != null) return;

    int? best;
    int? fromBest;

    if (phase == 0) {
      for (int i = 0; i < 24; i++) {
        if (board[i] != 0) continue;

        board[i] = 1;
        final makes = hasMill(i, 1);
        board[i] = 0;

        if (makes) {
          best = i;
          break;
        }
      }

      if (best == null) {
        for (int i = 0; i < 24; i++) {
          if (board[i] == 0) {
            best = i;
            break;
          }
        }
      }
    } else if (phase == 1) {
      for (int i = 0; i < 24; i++) {
        if (board[i] != 1) continue;

        for (final n in near[i]) {
          if (board[n] != 0) continue;

          board[i] = 0;
          board[n] = 1;
          final makes = hasMill(n, 1);
          board[i] = 1;
          board[n] = 0;

          if (makes) {
            best = n;
            fromBest = i;
            break;
          }
        }

        if (best != null) break;
      }

      if (best == null) {
        for (int i = 0; i < 24; i++) {
          if (board[i] != 1) continue;

          final destinations = legalDestinations(i);

          if (destinations.isNotEmpty) {
            best = destinations.first;
            fromBest = i;
            break;
          }
        }
      }
    }

    setState(() {
      selected = fromBest;
      hintDestination = best;
      showHint = best != null;

      if (best != null) {
        status = phase == 0
            ? 'التلميح: النقطة المضيئة اقتراح لمكان الحجر.'
            : 'التلميح: اسحب الحجر إلى النقطة المضيئة.';
      } else {
        status = 'لا توجد حركة مقترحة.';
      }
    });
  }

  void _pause() {
    if (winner != null || replayMode) return;

    setState(() {
      paused = !paused;
      status = paused
          ? 'اللعبة متوقفة مؤقتًا'
          : 'تم استئناف اللعب';
    });

    aiTimer?.cancel();

    if (!paused) {
      _scheduleComputer();
    }
  }

  void _replay() {
    if (history.isEmpty) return;

    aiTimer?.cancel();

    setState(() {
      replayMode = true;
      replayIndex = 0;
      board = List<int>.from(history.first);
      status = 'إعادة عرض المباراة';
    });
  }

  void _replayStep(int step) {
    if (history.isEmpty) return;

    final next =
        (replayIndex + step).clamp(0, history.length - 1);

    setState(() {
      replayIndex = next;
      board = List<int>.from(history[next]);
      status =
          'الحركة ${replayIndex + 1} من ${history.length}';
    });
  }

  String _formatTime() {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  void dispose() {
    clock?.cancel();
    aiTimer?.cancel();
    millTimer?.cancel();
    super.dispose();
  }

  // ======================================================
  // واجهة اللعب
  // ======================================================

  @override
  Widget build(BuildContext context) {
    final t = widget.theme;

    return Scaffold(
      backgroundColor: widget.appBackground,
      appBar: AppBar(
        backgroundColor: t.wood,
        foregroundColor: t.lines,
        centerTitle: true,
        title: const Text(
          'ثبّت • BAHMAD THABET',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            tooltip: 'إيقاف مؤقت',
            icon: Icon(
              paused ? Icons.play_arrow : Icons.pause,
            ),
            onPressed: _pause,
          ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final availableWidth =
                math.max(0.0, constraints.maxWidth - 32);

            final availableHeight =
                math.max(0.0, constraints.maxHeight);

            final boardSize = math.min(
              availableWidth,
              availableHeight * .66,
            ).clamp(
              0.0,
              600.0,
            );

            return Column(
              children: [
                const SizedBox(height: 8),

                _playerPanel(
                  label: widget.computerMode
                      ? 'الكمبيوتر'
                      : 'الأسود',
                  count: computerCount,
                  placed: blackPlaced,
                  player: 2,
                  active: turn == 2,
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 7,
                  ),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 9,
                    ),
                    decoration: BoxDecoration(
                      color: t.wood,
                      borderRadius: BorderRadius.circular(13),
                      border: Border.all(
                        color: t.lines.withOpacity(.65),
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          status,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'الوقت: ${_formatTime()}',
                          style: TextStyle(
                            color: t.lines.withOpacity(.8),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                Expanded(
                  child: Center(
                    child: SizedBox(
                      width: boardSize,
                      height: boardSize,
                      child: _boardWidget(boardSize),
                    ),
                  ),
                ),

                _playerPanel(
                  label: 'الأبيض',
                  count: playerCount,
                  placed: whitePlaced,
                  player: 1,
                  active: turn == 1,
                ),

                if (replayMode)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: () => _replayStep(-1),
                        icon: const Icon(Icons.skip_previous),
                      ),
                      Text(
                        '${replayIndex + 1} / ${history.length}',
                        style: TextStyle(
                          color: ThemeData.estimateBrightnessForColor(
                            widget.appBackground,
                          ) ==
                                  Brightness.dark
                              ? Colors.white
                              : Colors.black,
                        ),
                      ),
                      IconButton(
                        onPressed: () => _replayStep(1),
                        icon: const Icon(Icons.skip_next),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            replayMode = false;
                            status = 'تم إغلاق إعادة العرض';
                          });
                        },
                        child: const Text('إغلاق'),
                      ),
                    ],
                  ),

                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 5, 8, 9),
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 6,
                    runSpacing: 3,
                    children: [
                      if (widget.computerMode && !replayMode)
                        _actionButton(
                          'تلميح',
                          Icons.lightbulb_outline,
                          _hint,
                        ),
                      _actionButton(
                        'إعادة العرض',
                        Icons.replay,
                        _replay,
                      ),
                      _actionButton(
                        'مباراة جديدة',
                        Icons.refresh,
                        _restart,
                      ),
                      _actionButton(
                        'الرئيسية',
                        Icons.home,
                        () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // ======================================================
  // لوحة اللعب
  // ======================================================

  Widget _boardWidget(double size) {
    final t = widget.theme;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (details) {
            final index =
                _nearestPoint(details.localPosition, size);

            if (index != null) {
              _tapNode(index);
            }
          },
          child: CustomPaint(
            size: Size(size, size),
            painter: BoardPainter(
              points: points,
              edges: edges,
              theme: t,
              highlightedMill: highlightedMill,
              millCelebration: millCelebration,
            ),
          ),
        ),

        for (int i = 0; i < 24; i++)
          _stoneWidget(i, size),

        if (millCelebration)
          Positioned(
            top: 8,
            left: 0,
            right: 0,
            child: IgnorePointer(
              child: Center(
                child: AnimatedOpacity(
                  opacity: millCelebration ? 1 : 0,
                  duration: const Duration(milliseconds: 250),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xff321b0b)
                          .withOpacity(.88),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: const Color(0xffffd36b)
                            .withOpacity(.75),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xffffcf54)
                              .withOpacity(.18),
                          blurRadius: 12,
                        ),
                      ],
                    ),
                    child: const Text(
                      'ثبّت!',
                      style: TextStyle(
                        color: Color(0xffffdc83),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  // ======================================================
  // الأحجار
  // ======================================================

  Widget _stoneWidget(int i, double size) {
    final t = widget.theme;
    final value = board[i];

    final isHint = showHint && hintDestination == i;
    final isMill = highlightedMill.contains(i);

    final isLegal = selected != null &&
        legalDestinations(selected!).contains(i) &&
        phase == 1 &&
        pendingRemoval == null;

    final canDrag = !paused &&
        !replayMode &&
        winner == null &&
        pendingRemoval == null &&
        phase == 1 &&
        board[i] == turn &&
        !(widget.computerMode && turn == 2);

    final stoneSize = size * .064;

    final stone = AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      width: stoneSize,
      height: stoneSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: value == 1
            ? const RadialGradient(
                center: Alignment(-.35, -.4),
                radius: .95,
                colors: [
                  Color(0xffffffff),
                  Color(0xfff4f0e8),
                  Color(0xffc6c6c6),
                  Color(0xff777777),
                ],
                stops: [0, .3, .72, 1],
              )
            : value == 2
                ? const RadialGradient(
                    center: Alignment(-.35, -.4),
                    radius: .95,
                    colors: [
                      Color(0xffa0a0a0),
                      Color(0xff454545),
                      Color(0xff171717),
                      Color(0xff030303),
                    ],
                    stops: [0, .22, .65, 1],
                  )
                : null,
        color: value == 0
            ? (isLegal || isHint
                ? t.accent.withOpacity(.8)
                : const Color(0xff3c2418))
            : null,
        border: Border.all(
          color: isMill
              ? const Color(0xffffe27a)
              : isHint
                  ? Colors.greenAccent
                  : value == 0
                      ? const Color(0xff9b6745)
                      : value == 1
                          ? const Color(0xffeeeeee)
                          : const Color(0xff555555),
          width: isMill || isHint ? 2.5 : 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: isMill
                ? const Color(0xffffd34e).withOpacity(.45)
                : isHint
                    ? Colors.greenAccent.withOpacity(.7)
                    : Colors.black.withOpacity(.4),
            blurRadius: isMill || isHint ? 11 : 7,
            spreadRadius: isMill || isHint ? 2 : 1,
            offset: const Offset(1, 3),
          ),
        ],
      ),
      child: value == 0
          ? null
          : Align(
              alignment: const Alignment(-.35, -.4),
              child: Container(
                width: stoneSize * .22,
                height: stoneSize * .16,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(
                    value == 1 ? .9 : .35,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withOpacity(.25),
                      blurRadius: 5,
                    ),
                  ],
                ),
              ),
            ),
    );

    return Positioned(
      left: points[i].dx * size - stoneSize / 2,
      top: points[i].dy * size - stoneSize / 2,
      child: DragTarget<int>(
        onWillAcceptWithDetails: (details) {
          final from = details.data;

          return !paused &&
              !replayMode &&
              winner == null &&
              pendingRemoval == null &&
              phase == 1 &&
              from != i &&
              from >= 0 &&
              from < 24 &&
              board[from] == turn &&
              board[i] == 0 &&
              near[from].contains(i) &&
              !(widget.computerMode && turn == 2);
        },
        onAcceptWithDetails: (details) {
          _dragMove(details.data, i);
        },
        builder: (context, candidates, rejected) {
          return Draggable<int>(
            data: i,
            maxSimultaneousDrags: canDrag ? 1 : 0,
            feedback: Material(
              color: Colors.transparent,
              child: SizedBox(
                width: stoneSize,
                height: stoneSize,
                child: stone,
              ),
            ),
            childWhenDragging: Opacity(
              opacity: .2,
              child: stone,
            ),
            child: GestureDetector(
              onTap: () {
                if (pendingRemoval != null) {
                  _tapNode(i);
                } else if (phase == 0) {
                  _tapNode(i);
                }
              },
              child: stone,
            ),
          );
        },
      ),
    );
  }

  int? _nearestPoint(Offset pos, double size) {
    int best = 0;
    double distance = double.infinity;

    for (int i = 0; i < 24; i++) {
      final target = Offset(
        points[i].dx * size,
        points[i].dy * size,
      );

      final d = (target - pos).distance;

      if (d < distance) {
        distance = d;
        best = i;
      }
    }

    return distance < size * .09 ? best : null;
  }

  // ======================================================
  // بطاقة اللاعب
  // ======================================================

  Widget _playerPanel({
    required String label,
    required int count,
    required int placed,
    required int player,
    required bool active,
  }) {
    final t = widget.theme;

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 3,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: t.wood,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(
          color: active ? t.accent : t.lines.withOpacity(.35),
          width: active ? 2 : 1,
        ),
        boxShadow: active
            ? [
                BoxShadow(
                  color: t.accent.withOpacity(.18),
                  blurRadius: 12,
                ),
              ]
            : [],
      ),
      child: Row(
        children: [
          _playerBall(player, 22),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: active ? t.accent : Colors.white,
                  ),
                ),
                Text(
                  'الأحجار المتبقية: ${12 - placed}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '$count',
            style: TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.bold,
              color: t.lines,
            ),
          ),
          const SizedBox(width: 4),
          const Text(
            'حجر',
            style: TextStyle(
              fontSize: 11,
              color: Colors.white70,
            ),
          ),
          if (active) ...[
            const SizedBox(width: 7),
            Icon(Icons.circle, color: t.accent, size: 9),
          ],
        ],
      ),
    );
  }

  Widget _playerBall(int player, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: player == 1
            ? const RadialGradient(
                center: Alignment(-.35, -.4),
                colors: [
                  Colors.white,
                  Color(0xffdedede),
                  Color(0xff777777),
                ],
              )
            : const RadialGradient(
                center: Alignment(-.35, -.4),
                colors: [
                  Color(0xff888888),
                  Color(0xff333333),
                  Colors.black,
                ],
              ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black54,
            blurRadius: 5,
            offset: Offset(1, 2),
          ),
        ],
      ),
    );
  }

  Widget _actionButton(
    String title,
    IconData icon,
    VoidCallback action,
  ) {
    return OutlinedButton.icon(
      onPressed: action,
      icon: Icon(icon, size: 17),
      label: Text(
        title,
        style: const TextStyle(fontSize: 12),
      ),
      style: OutlinedButton.styleFrom(
        foregroundColor: widget.theme.accent,
        side: BorderSide(
          color: widget.theme.accent.withOpacity(.6),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 9,
          vertical: 7,
        ),
        minimumSize: const Size(0, 34),
      ),
    );
  }
}

// ======================================================
// رسم اللوحة الخشبية
// ======================================================

class BoardPainter extends CustomPainter {
  final List<Offset> points;
  final List<List<int>> edges;
  final BoardTheme theme;
  final List<int> highlightedMill;
  final bool millCelebration;

  BoardPainter({
    required this.points,
    required this.edges,
    required this.theme,
    required this.highlightedMill,
    required this.millCelebration,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    // ظل اللوحة الخارجي
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        rect.deflate(2),
        const Radius.circular(12),
      ),
      Paint()
        ..color = Colors.black.withOpacity(.35)
        ..maskFilter = const MaskFilter.blur(
          BlurStyle.normal,
          12,
        ),
    );

    // الخشب الفاتح
    final wood = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xffd5b17c),
          Color(0xffbd9360),
          Color(0xffd9b987),
          Color(0xffb88a57),
        ],
      ).createShader(rect);

    final boardRect = rect.deflate(5);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        boardRect,
        const Radius.circular(10),
      ),
      wood,
    );

    // عروق الخشب الأفقية
    final grain = Paint()
      ..color = const Color(0xff76502e).withOpacity(.17)
      ..strokeWidth = 1;

    for (int i = 1; i < 24; i++) {
      final y = size.height * i / 24;

      canvas.drawLine(
        Offset(size.width * .025, y),
        Offset(size.width * .975, y),
        grain,
      );
    }

    // خطوط خشبية دقيقة
    final fineGrain = Paint()
      ..color = const Color(0xffffe2b0).withOpacity(.18)
      ..strokeWidth = .7;

    for (int i = 0; i < 18; i++) {
      final y = size.height * (i + .5) / 18;

      canvas.drawLine(
        Offset(size.width * .08, y),
        Offset(
          size.width * .92,
          y + size.height * .003,
        ),
        fineGrain,
      );
    }

    // إطار اللوحة الداكن
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        rect.deflate(4),
        const Radius.circular(10),
      ),
      Paint()
        ..color = const Color(0xff21160f)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4,
    );

    // خطوط المربعات العنابية
    final lineGlow = Paint()
      ..color = const Color(0xff682c31).withOpacity(.18)
      ..strokeWidth = size.width * .025
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(
        BlurStyle.normal,
        4,
      );

    final boardLines = Paint()
      ..color = const Color(0xff742f35)
      ..strokeWidth = size.width * .012
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    for (final edge in edges) {
      final a = Offset(
        points[edge[0]].dx * size.width,
        points[edge[0]].dy * size.height,
      );

      final b = Offset(
        points[edge[1]].dx * size.width,
        points[edge[1]].dy * size.height,
      );

      canvas.drawLine(a, b, lineGlow);
      canvas.drawLine(a, b, boardLines);
    }

    // حفر نقاط اللعب
    for (final point in points) {
      final center = Offset(
        point.dx * size.width,
        point.dy * size.height,
      );

      final radius = size.width * .025;

      canvas.drawCircle(
        center,
        radius,
        Paint()
          ..shader = const RadialGradient(
            colors: [
              Color(0xff24150d),
              Color(0xff57351f),
              Color(0xff8b6745),
            ],
          ).createShader(
            Rect.fromCircle(
              center: center,
              radius: radius,
            ),
          ),
      );

      canvas.drawCircle(
        center.translate(0, -radius * .15),
        radius * .7,
        Paint()
          ..color = const Color(0xff170e09)
              .withOpacity(.45),
      );

      canvas.drawCircle(
        center,
        radius,
        Paint()
          ..color = const Color(0xffe3c69b)
              .withOpacity(.5)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1,
      );
    }

    // إضاءة خط الثبّت
    if (millCelebration && highlightedMill.length == 3) {
      final a = Offset(
        points[highlightedMill[0]].dx * size.width,
        points[highlightedMill[0]].dy * size.height,
      );

      final b = Offset(
        points[highlightedMill[2]].dx * size.width,
        points[highlightedMill[2]].dy * size.height,
      );

      final glow = Paint()
        ..color = const Color(0xffffd54f).withOpacity(.35)
        ..strokeWidth = size.width * .018
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(
          BlurStyle.normal,
          7,
        );

      canvas.drawLine(a, b, glow);

      final bright = Paint()
        ..color = const Color(0xffffed9b).withOpacity(.8)
        ..strokeWidth = size.width * .004
        ..strokeCap = StrokeCap.round;

      canvas.drawLine(a, b, bright);
    }

    // الإطار الداخلي
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        rect.deflate(11),
        const Radius.circular(7),
      ),
      Paint()
        ..color = const Color(0xff6b4428).withOpacity(.35)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
  }

  @override
  bool shouldRepaint(covariant BoardPainter oldDelegate) {
    return oldDelegate.theme != theme ||
        oldDelegate.millCelebration != millCelebration ||
        !listEquals(
          oldDelegate.highlightedMill,
          highlightedMill,
        );
  }
}
