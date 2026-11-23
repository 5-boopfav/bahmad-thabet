import 'dart:async';
import 'dart:math' as math;
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

void main() {
  runApp(const ThabetApp());
}

class SoundFX {
  static final AudioPlayer _player = AudioPlayer();

  static Future<void> _playAsset(String assetPath, SystemSoundType fallback) async {
    try {
      await _player.stop();
      await _player.play(AssetSource(assetPath));
    } catch (_) {
      SystemSound.play(fallback);
    }
  }

  static Future<void> playPlace(bool enabled) async {
    if (!enabled) return;
    await _playAsset('sounds/place.wav', SystemSoundType.click);
  }

  static Future<void> playMill(bool enabled) async {
    if (!enabled) return;
    await _playAsset('sounds/mill.wav', SystemSoundType.alert);
  }

  static Future<void> playRemove(bool enabled) async {
    if (!enabled) return;
    await _playAsset('sounds/remove.wav', SystemSoundType.click);
  }
}

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
    name: 'الخشبي الكلاسيكي',
    background: Color(0xff2c2d2e),
    wood: Color(0xffdca463),
    lines: Color(0xff5a371c),
    points: Color(0xfffdf6e7),
    accent: Color(0xffe5a95c),
  ),
  BoardTheme(
    name: 'الخشبي الملكي',
    background: Color(0xff1e1b18),
    wood: Color(0xffc99252),
    lines: Color(0xff4a2c16),
    points: Color(0xfffff2d6),
    accent: Color(0xffd6a84f),
  ),
  BoardTheme(
    name: 'المحيط',
    background: Color(0xff1c2229),
    wood: Color(0xff6da5b8),
    lines: Color(0xff1d3c4a),
    points: Color(0xffe6f9ff),
    accent: Color(0xff52b8d4),
  ),
  BoardTheme(
    name: 'الليلي',
    background: Color(0xff201d28),
    wood: Color(0xff8c76a8),
    lines: Color(0xff352647),
    points: Color(0xfff5ecff),
    accent: Color(0xffb592e0),
  ),
  BoardTheme(
    name: 'الرخامي',
    background: Color(0xff25282c),
    wood: Color(0xffb5bcc2),
    lines: Color(0xff3c424a),
    points: Color(0xffffffff),
    accent: Color(0xff9aa6b2),
  ),
];

const List<Color> appBackgrounds = [
  Color(0xff2b2c2d),
  Color(0xff383a3c),
  Color(0xff1b1c1d),
  Color(0xff34271f),
  Color(0xffe8edf4),
];

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
      SoundFX.playPlace(true);
    }
  }

  void playPlaceSound() {
    SoundFX.playPlace(soundEnabled);
  }

  void playMillSound() {
    SoundFX.playMill(soundEnabled);
  }

  void playRemoveSound() {
    SoundFX.playRemove(soundEnabled);
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
        brightness: ThemeData.estimateBrightnessForColor(appBackground),
        useMaterial3: true,
        scaffoldBackgroundColor: appBackground,
        colorScheme: ColorScheme.fromSeed(
          seedColor: theme.accent,
          brightness: ThemeData.estimateBrightnessForColor(appBackground),
        ),
      ),
      home: HomePage(
        theme: theme,
        themeIndex: themeIndex,
        appBackground: appBackground,
        backgroundIndex: backgroundIndex,
        onThemeChanged: (v) => setState(() => themeIndex = v),
        onBackgroundChanged: (v) => setState(() => backgroundIndex = v),
        soundEnabled: soundEnabled,
        vibrationEnabled: vibrationEnabled,
        onSoundChanged: (v) => setState(() => soundEnabled = v),
        onVibrationChanged: (v) => setState(() => vibrationEnabled = v),
        sound: sound,
        playPlaceSound: playPlaceSound,
        playMillSound: playMillSound,
        playRemoveSound: playRemoveSound,
        vibrate: vibrate,
      ),
    );
  }
}

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
  final VoidCallback playPlaceSound;
  final VoidCallback playMillSound;
  final VoidCallback playRemoveSound;
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
    required this.playPlaceSound,
    required this.playMillSound,
    required this.playRemoveSound,
    required this.vibrate,
  });

  bool get isDark =>
      ThemeData.estimateBrightnessForColor(appBackground) == Brightness.dark;

  Color get textColor => isDark ? Colors.white : Colors.black87;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appBackground,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [
                    appBackground.withOpacity(0.95),
                    const Color(0xff161718),
                  ]
                : [
                    appBackground,
                    appBackground.withOpacity(0.85),
                  ],
          ),
        ),
        child: SafeArea(
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
                    border: Border.all(color: theme.lines, width: 2.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(.45),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
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
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: theme.accent,
                foregroundColor: Colors.black87,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            )
          : OutlinedButton.icon(
              onPressed: action,
              icon: Icon(icon, color: theme.accent),
              label: Text(title, style: TextStyle(color: textColor)),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: theme.accent.withOpacity(.5)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
    );
  }

  void _start(BuildContext context, bool computer, int difficulty) {
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
          playPlaceSound: playPlaceSound,
          playMillSound: playMillSound,
          playRemoveSound: playRemoveSound,
          vibrate: vibrate,
        ),
      ),
    );
  }

  void _chooseDifficulty(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xff2b2c2e),
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
                  color: theme.accent,
                ),
              ),
              const SizedBox(height: 15),
              _difficultyTile(ctx, context, 'سهل', 'مناسب للمبتدئين', 1),
              _difficultyTile(ctx, context, 'متوسط', 'تحدٍّ متوازن', 2),
              _difficultyTile(ctx, context, 'صعب', 'خصم أكثر ذكاءً', 3),
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
      leading: Icon(Icons.smart_toy, color: theme.accent),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      subtitle:
          Text(subtitle, style: const TextStyle(color: Colors.white70)),
      onTap: () {
        Navigator.pop(sheetContext);
        _start(homeContext, true, level);
      },
    );
  }

  void _themes(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xff2b2c2e),
      builder: (ctx) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            Padding(
              padding: const EdgeInsets.all(18),
              child: Text(
                'اختر مظهر الطاولة',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                  color: theme.accent,
                ),
              ),
            ),
            for (int i = 0; i < boardThemes.length; i++)
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: boardThemes[i].wood,
                  child: Icon(Icons.palette, color: boardThemes[i].lines),
                ),
                title: Text(
                  boardThemes[i].name,
                  style: const TextStyle(color: Colors.white),
                ),
                trailing: themeIndex == i
                    ? Icon(Icons.check_circle, color: theme.accent)
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
      backgroundColor: const Color(0xff2b2c2e),
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
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                SwitchListTile(
                  title: const Text(
                    'الأصوات',
                    style: TextStyle(color: Colors.white),
                  ),
                  value: soundEnabled,
                  onChanged: (v) {
                    onSoundChanged(v);
                    setSheet(() {});
                  },
                ),
                SwitchListTile(
                  title: const Text(
                    'الاهتزاز',
                    style: TextStyle(color: Colors.white),
                  ),
                  value: vibrationEnabled,
                  onChanged: (v) {
                    onVibrationChanged(v);
                    setSheet(() {});
                  },
                ),
                const Divider(color: Colors.white24),
                const Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    'خلفية التطبيق',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
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
                            ? const Icon(Icons.check, color: Colors.green)
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
        backgroundColor: const Color(0xff2b2c2e),
        title: Text('قواعد ثبّت', style: TextStyle(color: theme.accent)),
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
            style: TextStyle(height: 1.6, color: Colors.white),
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

class _FlyingStone {
  final int player;
  final Offset startOffset;
  final Offset endOffset;

  const _FlyingStone({
    required this.player,
    required this.startOffset,
    required this.endOffset,
  });
}

class GamePage extends StatefulWidget {
  final BoardTheme theme;
  final Color appBackground;
  final bool computerMode;
  final int difficulty;
  final VoidCallback sound;
  final VoidCallback playPlaceSound;
  final VoidCallback playMillSound;
  final VoidCallback playRemoveSound;
  final VoidCallback vibrate;

  const GamePage({
    super.key,
    required this.theme,
    required this.appBackground,
    required this.computerMode,
    required this.difficulty,
    required this.sound,
    required this.playPlaceSound,
    required this.playMillSound,
    required this.playRemoveSound,
    required this.vibrate,
  });

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage>
    with SingleTickerProviderStateMixin {
  static int nextStarter = 1;

  final List<Offset> points = const [
    Offset(65 / 600, 65 / 600),
    Offset(300 / 600, 65 / 600),
    Offset(535 / 600, 65 / 600),
    Offset(535 / 600, 300 / 600),
    Offset(535 / 600, 535 / 600),
    Offset(300 / 600, 535 / 600),
    Offset(65 / 600, 535 / 600),
    Offset(65 / 600, 300 / 600),
    Offset(145 / 600, 145 / 600),
    Offset(300 / 600, 145 / 600),
    Offset(455 / 600, 145 / 600),
    Offset(455 / 600, 300 / 600),
    Offset(455 / 600, 455 / 600),
    Offset(300 / 600, 455 / 600),
    Offset(145 / 600, 455 / 600),
    Offset(145 / 600, 300 / 600),
    Offset(225 / 600, 225 / 600),
    Offset(300 / 600, 225 / 600),
    Offset(375 / 600, 225 / 600),
    Offset(375 / 600, 300 / 600),
    Offset(375 / 600, 375 / 600),
    Offset(300 / 600, 375 / 600),
    Offset(225 / 600, 375 / 600),
    Offset(225 / 600, 300 / 600),
  ];

  late final List<List<int>> edges;
  late final List<List<int>> near;
  late final List<List<int>> mills;

  late final AnimationController _flyController;
  _FlyingStone? _flyingStone;
  double _currentBoardSize = 320;

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

  int get playerCount => board.where((v) => v == 1).length;
  int get computerCount => board.where((v) => v == 2).length;

  String playerName(int p) => p == 1 ? 'الأبيض' : 'الأسود';

  @override
  void initState() {
    super.initState();
    starter = nextStarter;
    turn = starter;
    status = 'دور ${playerName(turn)}: ضع حجرًا';

    _flyController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    )..addStatusListener((statusAnim) {
        if (statusAnim == AnimationStatus.completed && mounted) {
          setState(() => _flyingStone = null);
          widget.playPlaceSound();
          widget.vibrate();
        }
      });

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

    clock = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted && !paused && winner == null && !replayMode) {
        setState(() => seconds++);
      }
    });

    _scheduleComputer();
  }

  void _launchStoneFromCenter(int player, int targetIndex) {
    final size = _currentBoardSize;
    final startOffset = Offset(size * 0.5, size * (player == 1 ? 1.12 : -0.12));
    final endOffset = Offset(
      points[targetIndex].dx * size,
      points[targetIndex].dy * size,
    );

    _flyingStone = _FlyingStone(
      player: player,
      startOffset: startOffset,
      endOffset: endOffset,
    );
    _flyController.forward(from: 0.0);
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
      (m) => m.contains(index) && m.every((i) => board[i] == p),
    );
  }

  bool formsMill(int index, int p) => hasMill(index, p);

  List<int>? _getMill(int index, int p) {
    for (final m in mills) {
      if (m.contains(index) && m.every((i) => board[i] == p)) {
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

    widget.playMillSound();
    widget.vibrate();

    millTimer = Timer(const Duration(milliseconds: 1200), () {
      if (!mounted) return;
      setState(() {
        millCelebration = false;
        highlightedMill.clear();
      });
    });
  }

  bool hasMove(int p) {
    for (int i = 0; i < 24; i++) {
      if (board[i] == p && near[i].any((n) => board[n] == 0)) {
        return true;
      }
    }
    return false;
  }

  List<int> legalDestinations(int from) {
    return near[from].where((i) => board[i] == 0).toList();
  }

  void _saveHistory() {
    history.add(List.from(board));
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

    aiTimer = Timer(const Duration(milliseconds: 650), () {
      if (!mounted || paused || turn != 2 || winner != null) return;
      _computerMove();
    });
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
      _launchStoneFromCenter(2, chosen);

      if (hasMill(chosen, 2)) {
        if (firstMill == null) firstMill = 2;
        _celebrateMill(chosen, 2);
      } else {
        widget.playPlaceSound();
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
        widget.playPlaceSound();
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
      widget.playRemoveSound();
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

      status = 'انتهى الرص. ${playerName(turn)} يزيل حجرًا من الخصم.';
      _scheduleComputer();
    } else {
      turn = 3 - turn;
      status = 'دور ${playerName(turn)}: ضع حجرًا';
      _scheduleComputer();
    }
  }

  void _afterRemoval(int remover) {
    if (initialRemovalPhase) {
      if (!firstInitialRemovalDone) {
        firstInitialRemovalDone = true;
        final next = 3 - remover;
        turn = next;
        pendingRemoval = next;

        status = '${playerName(next)} يجب أن يزيل حجرًا من الخصم.';
        _scheduleComputer();
        return;
      }

      initialRemovalPhase = false;
      firstInitialRemovalDone = false;
      pendingRemoval = null;

      turn = initialFirstRemover!;

      if (board.every((v) => v != turn) || !hasMove(turn)) {
        winner = 3 - turn;
        phase = 2;
        status = 'فاز ${playerName(winner!)}! اللاعب الأول لا يملك حركة متاحة.';
        return;
      }

      status = 'اكتملت الإزالتان. دور ${playerName(turn)} للتحريك.';
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

    widget.playRemoveSound();
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
      status = 'فاز ${playerName(winner!)}! لا توجد حركات متاحة.';
      return;
    }

    status = 'دور ${playerName(turn)}: اسحب حجرًا';
  }

  void _placeStone(int index) {
    if (board[index] != 0) return;
    final currentPlayer = turn;
    setState(() {
      board[index] = currentPlayer;

      if (currentPlayer == 1) {
        whitePlaced++;
      } else {
        blackPlaced++;
      }

      _launchStoneFromCenter(currentPlayer, index);

      if (hasMill(index, currentPlayer)) {
        if (firstMill == null) firstMill = currentPlayer;
        _celebrateMill(index, currentPlayer);
      } else {
        widget.playPlaceSound();
      }

      _saveHistory();
      _afterPlacement();
    });

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
        status = 'ثبّت! اختر حجرًا من ${playerName(3 - turn)} لإزالته.';
        _celebrateMill(to, turn);
      } else {
        widget.playPlaceSound();
        _endTurn();
      }
    });

    widget.vibrate();
  }

  void _tapNode(int index) {
    if (paused || winner != null || replayMode) return;
    if (widget.computerMode && turn == 2) return;
    if (pendingRemoval != null) {
      widget.vibrate();
      _removeStone(index);
      return;
    }

    if (phase == 0) {
      widget.vibrate();

      if (board[index] == 0) {
        _placeStone(index);
      }
    } else if (phase == 1) {
      if (board[index] == turn) {
        setState(() {
          selected = selected == index ? null : index;
          showHint = false;
          hintDestination = null;
        });
        widget.playPlaceSound();
        widget.vibrate();
      } else if (selected != null &&
          board[index] == 0 &&
          near[selected!].contains(index)) {
        _moveStone(selected!, index);
      }
    }
  }

  void _dragMove(int from, int to) {
    if (paused || winner != null || replayMode) return;
    if (widget.computerMode && turn == 2) return;
    if (pendingRemoval != null || phase != 1) return;
    if (board[from] != turn || board[to] != 0) return;
    if (!near[from].contains(to)) return;
    _moveStone(from, to);
  }

  void _restart() {
    aiTimer?.cancel();
    millTimer?.cancel();
    _flyController.stop();
    setState(() {
      _flyingStone = null;
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
      paused = false;

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
      status = paused ? 'اللعبة متوقفة مؤقتًا' : 'تم استئناف اللعب';
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
    final next = (replayIndex + step).clamp(0, history.length - 1);
    setState(() {
      replayIndex = next;
      board = List<int>.from(history[next]);
      status = 'الحركة ${replayIndex + 1} من ${history.length}';
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
    _flyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkBg =
        ThemeData.estimateBrightnessForColor(widget.appBackground) ==
            Brightness.dark;

    return Scaffold(
      backgroundColor: widget.appBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: isDarkBg ? Colors.white : Colors.black87,
        centerTitle: true,
        title: Text(
          widget.computerMode ? 'الكمبيوتر' : 'ثبّت • BAHMAD THABET',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        actions: [
          IconButton(
            tooltip: 'إيقاف مؤقت',
            icon: Icon(paused ? Icons.play_arrow : Icons.pause),
            onPressed: _pause,
          ),
          IconButton(
            tooltip: 'مباراة جديدة',
            icon: const Icon(Icons.refresh),
            onPressed: _restart,
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDarkBg
                ? [
                    widget.appBackground,
                    const Color(0xff171819),
                  ]
                : [
                    widget.appBackground,
                    widget.appBackground.withOpacity(0.88),
                  ],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final availableWidth = math.max(0.0, constraints.maxWidth - 28);
              final availableHeight = math.max(0.0, constraints.maxHeight);

              final boardSize = math.min(
                availableWidth,
                availableHeight * .55,
              ).clamp(0.0, 540.0);
              _currentBoardSize = boardSize;

              return Column(
                children: [
                  SizedBox(
                    height: 54,
                    child: _stoneQueueRow(
                      player: 2,
                      placed: blackPlaced,
                      active: turn == 2,
                      isTop: true,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 4,
                    ),
                    child: Container(
                      width: double.infinity,
                      height: 46,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isDarkBg
                            ? Colors.white.withOpacity(.05)
                            : Colors.black.withOpacity(.04),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isDarkBg
                              ? Colors.white.withOpacity(.08)
                              : Colors.black.withOpacity(.06),
                        ),
                      ),
                      child: Row(
                        children: [
                          Text(
                            _formatTime(),
                            style: TextStyle(
                              color: isDarkBg
                                  ? Colors.white60
                                  : Colors.black54,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 220),
                              switchInCurve: Curves.easeOutCubic,
                              switchOutCurve: Curves.easeInCubic,
                              child: Text(
                                status,
                                key: ValueKey(status),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12.5,
                                  color: isDarkBg
                                      ? Colors.white
                                      : Colors.black87,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '$computerCount : $playerCount',
                            style: TextStyle(
                              color: isDarkBg
                                  ? Colors.white70
                                  : Colors.black87,
                              fontSize: 11.5,
                              fontWeight: FontWeight.bold,
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
                  SizedBox(
                    height: 54,
                    child: _stoneQueueRow(
                      player: 1,
                      placed: whitePlaced,
                      active: turn == 1,
                      isTop: false,
                    ),
                  ),
                  if (replayMode)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          onPressed: () => _replayStep(-1),
                          icon: Icon(
                            Icons.skip_previous,
                            color: isDarkBg ? Colors.white : Colors.black87,
                          ),
                        ),
                        Text(
                          '${replayIndex + 1} / ${history.length}',
                          style: TextStyle(
                            color: isDarkBg ? Colors.white : Colors.black87,
                          ),
                        ),
                        IconButton(
                          onPressed: () => _replayStep(1),
                          icon: Icon(
                            Icons.skip_next,
                            color: isDarkBg ? Colors.white : Colors.black87,
                          ),
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
                    padding: const EdgeInsets.fromLTRB(8, 2, 8, 8),
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 6,
                      runSpacing: 2,
                      children: [
                        if (widget.computerMode && !replayMode)
                          _actionButton(
                            'تلميح',
                            Icons.lightbulb_outline,
                            _hint,
                          ),
                        _actionButton('إعادة العرض', Icons.replay, _replay),
                        _actionButton('مباراة جديدة', Icons.refresh, _restart),
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
      ),
    );
  }

  Widget _stoneQueueRow({
    required int player,
    required int placed,
    required bool active,
    required bool isTop,
  }) {
    final remaining = (12 - placed).clamp(0, 12);
    final showReadyCenterBall = active && phase == 0 && remaining > 0;
    final queueCount = showReadyCenterBall ? remaining - 1 : remaining;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                queueCount,
                (index) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2.5),
                  child: _playerBall(player, 18),
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          SizedBox(
            height: 26,
            child: Center(
              child: showReadyCenterBall
                  ? _playerBall(player, 24, floating: true)
                  : const SizedBox.shrink(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _boardWidget(double size) {
    final t = widget.theme;
    final stoneSize = size * .082;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (details) {
            final index = _nearestPoint(details.localPosition, size);
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
        for (int i = 0; i < 24; i++) _stoneWidget(i, size),
        if (_flyingStone != null)
          AnimatedBuilder(
            animation: _flyController,
            builder: (context, child) {
              final curved = CurvedAnimation(
                parent: _flyController,
                curve: Curves.easeOutCubic,
              ).value;
              final pos = Offset.lerp(
                _flyingStone!.startOffset,
                _flyingStone!.endOffset,
                curved,
              )!;
              final floatLift = math.sin(curved * math.pi) * 6.0;
              return Positioned(
                left: pos.dx - (stoneSize * 1.14) / 2,
                top: pos.dy - (stoneSize * 1.14) / 2 - floatLift,
                child: IgnorePointer(
                  child: _playerBall(
                    _flyingStone!.player,
                    stoneSize * 1.14,
                    floating: true,
                  ),
                ),
              );
            },
          ),
        if (millCelebration)
          Positioned(
            top: 10,
            left: 0,
            right: 0,
            child: IgnorePointer(
              child: Center(
                child: AnimatedOpacity(
                  opacity: millCelebration ? 1 : 0,
                  duration: const Duration(milliseconds: 250),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xff232425).withOpacity(.92),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: Colors.white.withOpacity(.65),
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white.withOpacity(.25),
                          blurRadius: 14,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: const Text(
                      'ثبّت!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
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

  Widget _stoneWidget(int i, double size) {
    final t = widget.theme;
    final value = board[i];
    final isSelected = selected == i && value == turn;
    final isHint = showHint && hintDestination == i;
    final isMill = highlightedMill.contains(i);

    final isLegal = selected != null &&
        legalDestinations(selected!).contains(i) &&
        phase == 1 &&
        pendingRemoval == null;

    final canRemovable = pendingRemoval != null && value == 3 - pendingRemoval!;

    final canDrag = !paused &&
        !replayMode &&
        winner == null &&
        pendingRemoval == null &&
        phase == 1 &&
        value == turn &&
        !(widget.computerMode && turn == 2);

    final stoneSize = size * .082;

    final stone = AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      width: stoneSize,
      height: stoneSize,
      transform: Matrix4.identity()
        ..scale(isSelected ? 1.12 : (isMill ? 1.06 : 1.0)),
      transformAlignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: value == 1
            ? const RadialGradient(
                center: Alignment(-.3, -.35),
                radius: .9,
                colors: [
                  Color(0xffffffff),
                  Color(0xfff5f5f5),
                  Color(0xffdedede),
                  Color(0xffbdbdbd),
                ],
                stops: [0, .35, .75, 1],
              )
            : value == 2
                ? const RadialGradient(
                    center: Alignment(-.3, -.35),
                    radius: .9,
                    colors: [
                      Color(0xff5c5d5f),
                      Color(0xff2c2d2f),
                      Color(0xff161718),
                      Color(0xff0b0b0c),
                    ],
                    stops: [0, .25, .65, 1],
                  )
                : null,
        color: value == 0
            ? (isLegal || isHint
                ? Colors.white.withOpacity(.85)
                : Colors.transparent)
            : null,
        border: Border.all(
          color: isMill
              ? Colors.white
              : isSelected
                  ? Colors.white
                  : isHint
                      ? Colors.white
                      : isLegal
                          ? Colors.white
                          : canRemovable
                              ? Colors.redAccent.withOpacity(.85)
                              : value == 1
                                  ? const Color(0xffe0e0e0)
                                  : value == 2
                                      ? const Color(0xff3c3d3f)
                                      : Colors.transparent,
          width: isMill || isSelected || isHint || isLegal
              ? 2.4
              : canRemovable
                  ? 2.0
                  : 1.0,
        ),
        boxShadow: value == 0 && !(isLegal || isHint)
            ? []
            : [
                BoxShadow(
                  color: isMill || isSelected || isHint || isLegal
                      ? Colors.white.withOpacity(.55)
                      : Colors.black.withOpacity(.45),
                  blurRadius: isMill || isSelected || isHint || isLegal
                      ? 12
                      : 6,
                  spreadRadius: isMill || isSelected || isHint || isLegal
                      ? 2
                      : 0.5,
                  offset: const Offset(0, 3),
                ),
              ],
      ),
      child: value == 0
          ? (isLegal || isHint
              ? Center(
                  child: Container(
                    width: stoneSize * .28,
                    height: stoneSize * .28,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: t.lines.withOpacity(.75),
                    ),
                  ),
                )
              : null)
          : Align(
              alignment: const Alignment(-.3, -.35),
              child: Container(
                width: stoneSize * .22,
                height: stoneSize * .15,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(value == 1 ? .85 : .25),
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
    );

    final floatingStone = _playerBall(
      value,
      stoneSize * 1.18,
      floating: true,
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
          final isHoverTarget = candidates.isNotEmpty;
          final displayStone = isHoverTarget
              ? Container(
                  width: stoneSize * 1.12,
                  height: stoneSize * 1.12,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(.45),
                    border: Border.all(color: Colors.white, width: 2.2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withOpacity(.65),
                        blurRadius: 12,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                )
              : stone;

          return Draggable<int>(
            data: i,
            maxSimultaneousDrags: canDrag ? 1 : 0,
            feedback: Material(
              color: Colors.transparent,
              child: Transform.translate(
                offset: const Offset(0, -8),
                child: floatingStone,
              ),
            ),
            childWhenDragging: Opacity(
              opacity: .22,
              child: stone,
            ),
            child: GestureDetector(
              onTap: () {
                if (pendingRemoval != null || phase == 0 || phase == 1) {
                  _tapNode(i);
                }
              },
              child: displayStone,
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
      final target = Offset(points[i].dx * size, points[i].dy * size);
      final d = (target - pos).distance;

      if (d < distance) {
        distance = d;
        best = i;
      }
    }

    return distance < size * .095 ? best : null;
  }

  Widget _playerBall(int player, double size, {bool floating = false}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: player == 1
            ? const RadialGradient(
                center: Alignment(-.3, -.35),
                colors: [
                  Colors.white,
                  Color(0xffececec),
                  Color(0xffbdbdbd),
                ],
              )
            : const RadialGradient(
                center: Alignment(-.3, -.35),
                colors: [
                  Color(0xff5c5d5f),
                  Color(0xff262729),
                  Color(0xff0b0b0c),
                ],
              ),
        border: Border.all(
          color: player == 1
              ? const Color(0xffe0e0e0)
              : const Color(0xff3c3d3f),
          width: floating ? 1.2 : 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(floating ? .6 : .45),
            blurRadius: size * (floating ? .42 : .22),
            spreadRadius: floating ? 1.5 : 0,
            offset: Offset(0, size * (floating ? .26 : .12)),
          ),
        ],
      ),
    );
  }

  Widget _actionButton(String title, IconData icon, VoidCallback action) {
    final isDarkBg =
        ThemeData.estimateBrightnessForColor(widget.appBackground) ==
            Brightness.dark;
    return OutlinedButton.icon(
      onPressed: action,
      icon: Icon(icon, size: 17),
      label: Text(title, style: const TextStyle(fontSize: 12)),
      style: OutlinedButton.styleFrom(
        foregroundColor: isDarkBg ? Colors.white : Colors.black87,
        backgroundColor: isDarkBg
            ? Colors.white.withOpacity(.04)
            : Colors.black.withOpacity(.03),
        side: BorderSide(
          color: isDarkBg
              ? Colors.white.withOpacity(.22)
              : Colors.black.withOpacity(.2),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
        minimumSize: const Size(0, 34),
      ),
    );
  }
}

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

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        rect.deflate(2),
        const Radius.circular(20),
      ),
      Paint()
        ..color = Colors.black.withOpacity(.55)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 16),
    );

    final boardRect = rect.deflate(4);

    final woodPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          theme.wood.withOpacity(.96),
          theme.wood,
          Color.lerp(theme.wood, Colors.black, 0.08)!,
        ],
      ).createShader(boardRect);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        boardRect,
        const Radius.circular(18),
      ),
      woodPaint,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        boardRect,
        const Radius.circular(18),
      ),
      Paint()
        ..color = Colors.white.withOpacity(.28)
        ..style = PaintingStyle.stroke
        ..strokeWidth = size.width * .006,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        boardRect.deflate(size.width * .006),
        const Radius.circular(17),
      ),
      Paint()
        ..color = theme.lines.withOpacity(.35)
        ..style = PaintingStyle.stroke
        ..strokeWidth = size.width * .005,
    );

    final boardLines = Paint()
      ..color = theme.lines
      ..strokeWidth = size.width * .011
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

      canvas.drawLine(a, b, boardLines);
    }

    for (final point in points) {
      final center = Offset(
        point.dx * size.width,
        point.dy * size.height,
      );

      final radius = size.width * (12 / 600);

      canvas.drawCircle(
        center,
        radius,
        Paint()..color = theme.points,
      );

      canvas.drawCircle(
        center,
        radius,
        Paint()
          ..color = theme.lines
          ..style = PaintingStyle.stroke
          ..strokeWidth = size.width * .005,
      );
    }

    if (millCelebration && highlightedMill.length == 3) {
      final a = Offset(
        points[highlightedMill.first].dx * size.width,
        points[highlightedMill.first].dy * size.height,
      );

      final b = Offset(
        points[highlightedMill.last].dx * size.width,
        points[highlightedMill.last].dy * size.height,
      );

      canvas.drawLine(
        a,
        b,
        Paint()
          ..color = Colors.white.withOpacity(.55)
          ..strokeWidth = size.width * .036
          ..strokeCap = StrokeCap.round
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
      );

      canvas.drawLine(
        a,
        b,
        Paint()
          ..color = Colors.white.withOpacity(.9)
          ..strokeWidth = size.width * .008
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(covariant BoardPainter oldDelegate) {
    return oldDelegate.theme != theme ||
        oldDelegate.millCelebration != millCelebration ||
        !listEquals(oldDelegate.highlightedMill, highlightedMill);
  }
}
