import 'dart:async';
import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ThabetApp());
}

class SoundEffects {
  static final AudioPlayer _player = AudioPlayer();

  static Future<void> play(String fileName, {required bool enabled}) async {
    if (!enabled) return;
    try {
      await _player.stop();
      await _player.play(AssetSource('sounds/$fileName'));
    } catch (_) {}
  }
}

enum BoardTheme { wood, emerald, obsidian }

enum AiLevel { easy, medium, hard }

enum GameMode { vsAi, twoPlayers }

enum GamePhase { placing, moving, gameOver }

enum TurnStage { selectOrPlace, removePiece }

class MoveRecord {
  final List<int?> boardBefore;
  final int player;
  final int? from;
  final int to;
  final int? removedIndex;
  final String description;

  MoveRecord({
    required this.boardBefore,
    required this.player,
    required this.from,
    required this.to,
    required this.removedIndex,
    required this.description,
  });
}

class GameSnapshot {
  final List<int?> board; // null = empty, 1 = white (أبيض), 2 = black (أسود)
  int currentPlayer;
  GamePhase phase;
  TurnStage stage;
  int p1RemainingToPlace;
  int p2RemainingToPlace;
  int p1PiecesOnBoard;
  int p2PiecesOnBoard;
  int? selectedIndex;
  String statusText;
  int? winner;
  String winReason;
  bool showThabetBadge;
  Set<int> highlightNodes;

  GameSnapshot({
    required this.board,
    required this.currentPlayer,
    required this.phase,
    required this.stage,
    required this.p1RemainingToPlace,
    required this.p2RemainingToPlace,
    required this.p1PiecesOnBoard,
    required this.p2PiecesOnBoard,
    required this.selectedIndex,
    required this.statusText,
    required this.winner,
    this.winReason = '',
    this.showThabetBadge = false,
    Set<int>? highlightNodes,
  }) : highlightNodes = highlightNodes ?? <int>{};

  GameSnapshot clone() => GameSnapshot(
        board: List<int?>.from(board),
        currentPlayer: currentPlayer,
        phase: phase,
        stage: stage,
        p1RemainingToPlace: p1RemainingToPlace,
        p2RemainingToPlace: p2RemainingToPlace,
        p1PiecesOnBoard: p1PiecesOnBoard,
        p2PiecesOnBoard: p2PiecesOnBoard,
        selectedIndex: selectedIndex,
        statusText: statusText,
        winner: winner,
        winReason: winReason,
        showThabetBadge: showThabetBadge,
        highlightNodes: Set<int>.from(highlightNodes),
      );
}

class ThabetApp extends StatefulWidget {
  const ThabetApp({super.key});

  @override
  State<ThabetApp> createState() => _ThabetAppState();
}

class _ThabetAppState extends State<ThabetApp> {
  bool _soundEnabled = true;
  bool _hintsEnabled = true;
  BoardTheme _boardTheme = BoardTheme.wood;
  AiLevel _aiLevel = AiLevel.medium;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _soundEnabled = prefs.getBool('sound_enabled') ?? true;
      _hintsEnabled = prefs.getBool('hints_enabled') ?? true;
      final tIdx = prefs.getInt('board_theme') ?? BoardTheme.wood.index;
      _boardTheme = BoardTheme.values[tIdx.clamp(0, BoardTheme.values.length - 1)];
      final lIdx = prefs.getInt('ai_level') ?? AiLevel.medium.index;
      _aiLevel = AiLevel.values[lIdx.clamp(0, AiLevel.values.length - 1)];
    });
  }

  Future<void> _savePrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('sound_enabled', _soundEnabled);
    await prefs.setBool('hints_enabled', _hintsEnabled);
    await prefs.setInt('board_theme', _boardTheme.index);
    await prefs.setInt('ai_level', _aiLevel.index);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ثبت',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF141414),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFD9A05B),
          brightness: Brightness.dark,
        ),
      ),
      home: Directionality(
        textDirection: TextDirection.rtl,
        child: MainMenuScreen(
          soundEnabled: _soundEnabled,
          hintsEnabled: _hintsEnabled,
          boardTheme: _boardTheme,
          aiLevel: _aiLevel,
          onToggleSound: (v) {
            setState(() => _soundEnabled = v);
            _savePrefs();
          },
          onToggleHints: (v) {
            setState(() => _hintsEnabled = v);
            _savePrefs();
          },
          onChangeTheme: (t) {
            setState(() => _boardTheme = t);
            _savePrefs();
          },
          onChangeAiLevel: (l) {
            setState(() => _aiLevel = l);
            _savePrefs();
          },
        ),
      ),
    );
  }
}

class MainMenuScreen extends StatelessWidget {
  final bool soundEnabled;
  final bool hintsEnabled;
  final BoardTheme boardTheme;
  final AiLevel aiLevel;
  final ValueChanged<bool> onToggleSound;
  final ValueChanged<bool> onToggleHints;
  final ValueChanged<BoardTheme> onChangeTheme;
  final ValueChanged<AiLevel> onChangeAiLevel;

  const MainMenuScreen({
    super.key,
    required this.soundEnabled,
    required this.hintsEnabled,
    required this.boardTheme,
    required this.aiLevel,
    required this.onToggleSound,
    required this.onToggleHints,
    required this.onChangeTheme,
    required this.onChangeAiLevel,
  });

  void _openAiLevelSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1D1B18),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'اختر مستوى الكمبيوتر',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _levelOption(
              ctx,
              title: 'سهل',
              subtitle: 'مناسب للمبتدئين',
              level: AiLevel.easy,
            ),
            const SizedBox(height: 10),
            _levelOption(
              ctx,
              title: 'متوسط',
              subtitle: 'تحدٍ متوازن',
              level: AiLevel.medium,
            ),
            const SizedBox(height: 10),
            _levelOption(
              ctx,
              title: 'صعب',
              subtitle: 'خصم أكثر ذكاءً',
              level: AiLevel.hard,
            ),
          ],
        ),
      ),
    );
  }

  Widget _levelOption(
    BuildContext ctx, {
    required String title,
    required String subtitle,
    required AiLevel level,
  }) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          backgroundColor: const Color(0xFF28241F),
          side: const BorderSide(color: Color(0xFF3E372E)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        onPressed: () {
          onChangeAiLevel(level);
          Navigator.pop(ctx);
          Navigator.push(
            ctx,
            MaterialPageRoute(
              builder: (_) => Directionality(
                textDirection: TextDirection.rtl,
                child: GameBoardScreen(
                  mode: GameMode.vsAi,
                  aiLevel: level,
                  boardTheme: boardTheme,
                  soundEnabled: soundEnabled,
                  hintsEnabled: hintsEnabled,
                ),
              ),
            ),
          );
        },
        child: Row(
          children: [
            const Text('🤖', style: TextStyle(fontSize: 26)),
            const SizedBox(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white)),
                Text(subtitle, style: const TextStyle(fontSize: 13, color: Colors.white70)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _openRulesDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1E1C19),
        title: const Text('قوانين اللعبة'),
        content: const SingleChildScrollView(
          child: Text(
            '• يضع كل لاعب 9 حجارة بالتناوب على نقاط التقاطع الفارغة.\n'
            '• عند صف 3 حجارة من نفس اللون على خط مستقيم يتحقق «ثبت» وتتم إزالة حجر للخصم غير محمي بصف مكتمل.\n'
            '• بعد اكتمال وضع الحجارة، يتم تحريك الحجر إلى نقطة مجاورة فارغة متصلة بالخط.\n'
            '• يفوز اللاعب إذا قلت حجارة الخصم عن 3 أو لم يعد لديه حركة متاحة.',
            style: TextStyle(fontSize: 14.5, height: 1.6),
          ),
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('حسناً'),
          ),
        ],
      ),
    );
  }

  void _openThemeSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1D1B18),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('مظهر الطاولة', style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
            const SizedBox(height: 16),
            _themeTile(ctx, 'خشبي كلاسيكي', BoardTheme.wood, const Color(0xFFD69E5E)),
            _themeTile(ctx, 'زمردي فاخر', BoardTheme.emerald, const Color(0xFF2E8B6B)),
            _themeTile(ctx, 'ليلي داكن', BoardTheme.obsidian, const Color(0xFF3A3D45)),
          ],
        ),
      ),
    );
  }

  Widget _themeTile(BuildContext ctx, String label, BoardTheme t, Color swatch) {
    final selected = boardTheme == t;
    return ListTile(
      leading: CircleAvatar(backgroundColor: swatch, radius: 14),
      title: Text(label),
      trailing: selected ? const Icon(Icons.check_circle, color: Color(0xFFD9A05B)) : null,
      onTap: () {
        onChangeTheme(t);
        Navigator.pop(ctx);
      },
    );
  }

  void _openSettingsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1D1B18),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('الإعدادات', style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            SwitchListTile(
              title: const Text('الأصوات والمؤثرات'),
              value: soundEnabled,
              onChanged: onToggleSound,
            ),
            SwitchListTile(
              title: const Text('إظهار التلميحات'),
              value: hintsEnabled,
              onChanged: onToggleHints,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF141414),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
          child: Column(
            children: [
              const Spacer(),
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: const Color(0xFFD89E5A),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: const [
                    BoxShadow(color: Colors.black54, blurRadius: 12, offset: Offset(0, 5)),
                  ],
                ),
                child: const Center(
                  child: Text(
                    '#',
                    style: TextStyle(
                      fontSize: 54,
                      fontWeight: FontWeight.w300,
                      color: Color(0xFF2B1A0B),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'ثبت',
                style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Color(0xFFE5B373)),
              ),
              const SizedBox(height: 4),
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('بحمـد', style: TextStyle(fontSize: 17, color: Colors.white70)),
                  SizedBox(width: 6),
                  Text('👑', style: TextStyle(fontSize: 17)),
                ],
              ),
              const SizedBox(height: 6),
              const Text(
                'لعبة الذكاء والتحدي',
                style: TextStyle(fontSize: 14.5, color: Colors.white54),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFD89E5A),
                    foregroundColor: const Color(0xFF1B1208),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: () => _openAiLevelSheet(context),
                  icon: const Icon(Icons.smart_toy),
                  label: const Text('العب ضد الكمبيوتر', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 12),
              _menuSecondaryButton(
                context,
                icon: Icons.group,
                label: 'لاعبان على نفس الجهاز',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => Directionality(
                      textDirection: TextDirection.rtl,
                      child: GameBoardScreen(
                        mode: GameMode.twoPlayers,
                        aiLevel: aiLevel,
                        boardTheme: boardTheme,
                        soundEnabled: soundEnabled,
                        hintsEnabled: hintsEnabled,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _menuSecondaryButton(
                context,
                icon: Icons.menu_book,
                label: 'قواعد اللعبة',
                onTap: () => _openRulesDialog(context),
              ),
              const SizedBox(height: 12),
              _menuSecondaryButton(
                context,
                icon: Icons.palette,
                label: 'مظهر الطاولة',
                onTap: () => _openThemeSheet(context),
              ),
              const SizedBox(height: 12),
              _menuSecondaryButton(
                context,
                icon: Icons.settings,
                label: 'الإعدادات',
                onTap: () => _openSettingsSheet(context),
              ),
              const Spacer(),
              const Text(
                'BAHMAD • 2026',
                style: TextStyle(fontSize: 12, letterSpacing: 1.5, color: Colors.white38),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _menuSecondaryButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        style: OutlinedButton.styleFrom(
          backgroundColor: const Color(0xFF1F1F1F),
          foregroundColor: Colors.white,
          side: const BorderSide(color: Color(0xFF333333)),
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        onPressed: onTap,
        icon: Icon(icon, size: 20, color: const Color(0xFFD89E5A)),
        label: Text(label, style: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w600)),
      ),
    );
  }
}

class GameBoardScreen extends StatefulWidget {
  final GameMode mode;
  final AiLevel aiLevel;
  final BoardTheme boardTheme;
  final bool soundEnabled;
  final bool hintsEnabled;

  const GameBoardScreen({
    super.key,
    required this.mode,
    required this.aiLevel,
    required this.boardTheme,
    required this.soundEnabled,
    required this.hintsEnabled,
  });

  @override
  State<GameBoardScreen> createState() => _GameBoardScreenState();
}

class _GameBoardScreenState extends State<GameBoardScreen> {
  static const List<List<int>> thabetLines = [
    [0, 1, 2], [3, 4, 5], [6, 7, 8],
    [9, 10, 11], [12, 13, 14], [15, 16, 17],
    [18, 19, 20], [21, 22, 23],
    [0, 9, 21], [3, 10, 18], [6, 11, 15],
    [1, 4, 7], [16, 19, 22],
    [8, 12, 17], [5, 13, 20], [2, 14, 23],
  ];

  static const Map<int, List<int>> adjacent = {
    0: [1, 9], 1: [0, 2, 4], 2: [1, 14],
    3: [4, 10], 4: [1, 3, 5, 7], 5: [4, 13],
    6: [7, 11], 7: [4, 6, 8], 8: [7, 12],
    9: [0, 10, 21], 10: [3, 9, 11, 18], 11: [6, 10, 15],
    12: [8, 13, 17], 13: [5, 12, 14, 20], 14: [2, 13, 23],
    15: [11, 16], 16: [15, 17, 19, 22], 17: [12, 16],
    18: [10, 19], 19: [16, 18, 20, 22], 20: [13, 19],
    21: [9, 22], 22: [16, 19, 21, 23], 23: [14, 22],
  };

  static const List<Offset> nodeCoords = [
    Offset(0.09, 0.09), Offset(0.50, 0.09), Offset(0.91, 0.09),
    Offset(0.23, 0.23), Offset(0.50, 0.23), Offset(0.77, 0.23),
    Offset(0.36, 0.36), Offset(0.50, 0.36), Offset(0.64, 0.36),
    Offset(0.09, 0.50), Offset(0.23, 0.50), Offset(0.36, 0.50),
    Offset(0.64, 0.50), Offset(0.77, 0.50), Offset(0.91, 0.50),
    Offset(0.36, 0.64), Offset(0.50, 0.64), Offset(0.64, 0.64),
    Offset(0.23, 0.77), Offset(0.50, 0.77), Offset(0.77, 0.77),
    Offset(0.09, 0.91), Offset(0.50, 0.91), Offset(0.91, 0.91),
  ];

  late GameSnapshot _state;
  final List<MoveRecord> _moves = [];
  bool _isPaused = false;
  bool _aiThinking = false;
  int _elapsedSeconds = 0;
  Timer? _clockTimer;
  final Random _rng = Random();

  @override
  void initState() {
    super.initState();
    _newMatch();
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!_isPaused && _state.phase != GamePhase.gameOver && mounted) {
        setState(() => _elapsedSeconds += 1);
      }
    });
  }

  @override
  void dispose() {
    _clockTimer?.cancel();
    super.dispose();
  }

  String _formatClock(int sec) {
    final m = (sec ~/ 60).toString();
    final s = (sec % 60).toString().padLeft(2, '0');
    return '$m : $s';
  }

  String _formatElapsed(int sec) {
    final m = (sec ~/ 60).toString().padLeft(2, '0');
    final s = (sec % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  void _newMatch() {
    setState(() {
      _moves.clear();
      _isPaused = false;
      _aiThinking = false;
      _elapsedSeconds = 0;
      _state = GameSnapshot(
        board: List<int?>.filled(24, null),
        currentPlayer: 1,
        phase: GamePhase.placing,
        stage: TurnStage.selectOrPlace,
        p1RemainingToPlace: 9,
        p2RemainingToPlace: 9,
        p1PiecesOnBoard: 0,
        p2PiecesOnBoard: 0,
        selectedIndex: null,
        statusText: 'دور الأبيض: ضع حجراً',
        winner: null,
        winReason: '',
        showThabetBadge: false,
        highlightNodes: {},
      );
    });
  }

  bool _formsThabet(List<int?> board, int pos, int player) {
    for (final line in thabetLines) {
      if (line.contains(pos) && line.every((idx) => board[idx] == player)) {
        return true;
      }
    }
    return false;
  }

  bool _isProtected(List<int?> board, int pos, int player) => _formsThabet(board, pos, player);

  bool _allProtected(List<int?> board, int opponent) {
    for (int i = 0; i < 24; i++) {
      if (board[i] == opponent && !_isProtected(board, i, opponent)) {
        return false;
      }
    }
    return true;
  }

  bool _hasLegalMove(List<int?> board, int player, int remainingToPlace) {
    if (remainingToPlace > 0) return board.any((c) => c == null);
    for (int i = 0; i < 24; i++) {
      if (board[i] == player) {
        for (final n in adjacent[i]!) {
          if (board[n] == null) return true;
        }
      }
    }
    return false;
  }

  void _syncCountsAndWin(GameSnapshot s) {
    s.p1PiecesOnBoard = s.board.where((c) => c == 1).length;
    s.p2PiecesOnBoard = s.board.where((c) => c == 2).length;

    if (s.winner != null) {
      s.phase = GamePhase.gameOver;
      return;
    }

    if (s.p1RemainingToPlace > 0 || s.p2RemainingToPlace > 0) {
      s.phase = GamePhase.placing;
      return;
    }

    if (s.p1PiecesOnBoard < 3) {
      s.winner = 2;
      s.phase = GamePhase.gameOver;
      s.winReason = 'اللاعب الأول يمتلك أقل من 3 حجارة';
      s.statusText = 'فاز الأسود • ${s.winReason}';
      return;
    }
    if (s.p2PiecesOnBoard < 3) {
      s.winner = 1;
      s.phase = GamePhase.gameOver;
      s.winReason = 'اللاعب الثاني يمتلك أقل من 3 حجارة';
      s.statusText = 'فاز الأبيض • ${s.winReason}';
      return;
    }

    s.phase = GamePhase.moving;
    final rem = s.currentPlayer == 1 ? s.p1RemainingToPlace : s.p2RemainingToPlace;
    if (!_hasLegalMove(s.board, s.currentPlayer, rem)) {
      s.winner = s.currentPlayer == 1 ? 2 : 1;
      s.phase = GamePhase.gameOver;
      s.winReason = s.currentPlayer == 1 ? 'اللاعب الأول لا يملك حركة متاحة' : 'اللاعب الثاني لا يملك حركة متاحة';
      s.statusText = s.winner == 1 ? 'فاز الأبيض • ${s.winReason}' : 'فاز الأسود • ${s.winReason}';
    }
  }

  String _turnText(int player, GamePhase phase) {
    final colorName = player == 1 ? 'الأبيض' : 'الأسود';
    final act = phase == GamePhase.placing ? 'ضع حجراً' : 'حرّك حجراً';
    return 'دور $colorName: $act';
  }

  void _onNodeTap(int idx) {
    if (_isPaused || _aiThinking || _state.phase == GamePhase.gameOver) return;
    if (widget.mode == GameMode.vsAi && _state.currentPlayer == 2) return;

    final next = _state.clone();
    final player = next.currentPlayer;
    final opponent = player == 1 ? 2 : 1;

    if (next.stage == TurnStage.removePiece) {
      if (next.board[idx] != opponent) {
        setState(() => _state.statusText = player == 1 ? 'الأبيض يجب أن يزيل حجراً من الخصم' : 'الأسود يجب أن يزيل حجراً من الخصم');
        return;
      }
      if (!_allProtected(next.board, opponent) && _isProtected(next.board, idx, opponent)) {
        setState(() => _state.statusText = 'لا يمكن إزالة حجر محمي بـ «ثبت»');
        return;
      }

      final boardBefore = List<int?>.from(_state.board);
      next.board[idx] = null;
      next.stage = TurnStage.selectOrPlace;
      next.selectedIndex = null;
      next.showThabetBadge = false;
      next.highlightNodes = {idx};
      next.currentPlayer = opponent;
      _syncCountsAndWin(next);
      if (next.phase != GamePhase.gameOver) {
        next.statusText = _turnText(next.currentPlayer, next.phase);
      }

      _moves.add(MoveRecord(
        boardBefore: boardBefore,
        player: player,
        from: null,
        to: idx,
        removedIndex: idx,
        description: '${player == 1 ? "الأبيض" : "الأسود"} أزال حجراً',
      ));

      SoundEffects.play('remove.wav', enabled: widget.soundEnabled);
      setState(() => _state = next);
      if (widget.mode == GameMode.vsAi && _state.phase != GamePhase.gameOver && _state.currentPlayer == 2) {
        _runAiTurn();
      }
      return;
    }

    if (next.phase == GamePhase.placing) {
      if (next.board[idx] != null) return;
      final boardBefore = List<int?>.from(_state.board);
      next.board[idx] = player;
      if (player == 1) {
        next.p1RemainingToPlace -= 1;
      } else {
        next.p2RemainingToPlace -= 1;
      }
      next.highlightNodes = {idx};
      _syncCountsAndWin(next);

      if (_formsThabet(next.board, idx, player)) {
        next.stage = TurnStage.removePiece;
        next.showThabetBadge = true;
        next.statusText = player == 1 ? 'الأبيض يجب أن يزيل حجراً من الخصم' : 'الأسود يجب أن يزيل حجراً من الخصم';
        SoundEffects.play('mill.wav', enabled: widget.soundEnabled);
        setState(() => _state = next);
      } else {
        next.showThabetBadge = false;
        next.currentPlayer = opponent;
        _syncCountsAndWin(next);
        if (next.phase != GamePhase.gameOver) {
          next.statusText = _turnText(next.currentPlayer, next.phase);
        }
        _moves.add(MoveRecord(
          boardBefore: boardBefore,
          player: player,
          from: null,
          to: idx,
          removedIndex: null,
          description: '${player == 1 ? "الأبيض" : "الأسود"} وضع حجراً',
        ));
        SoundEffects.play('place.wav', enabled: widget.soundEnabled);
        setState(() => _state = next);
        if (widget.mode == GameMode.vsAi && _state.phase != GamePhase.gameOver && _state.currentPlayer == 2) {
          _runAiTurn();
        }
      }
      return;
    }

    if (next.board[idx] == player) {
      setState(() {
        _state.selectedIndex = idx;
        _state.statusText = 'تم تحديد الحجر — اختر نقطة مجاورة فارغة';
      });
      return;
    }

    if (next.selectedIndex != null && next.board[idx] == null) {
      final from = next.selectedIndex!;
      if (!(adjacent[from]?.contains(idx) ?? false)) {
        setState(() => _state.statusText = 'النقطة غير متجاورة مع الحجر المحدد');
        return;
      }

      final boardBefore = List<int?>.from(_state.board);
      next.board[from] = null;
      next.board[idx] = player;
      next.selectedIndex = null;
      next.highlightNodes = {from, idx};
      _syncCountsAndWin(next);

      if (_formsThabet(next.board, idx, player)) {
        next.stage = TurnStage.removePiece;
        next.showThabetBadge = true;
        next.statusText = player == 1 ? 'الأبيض يجب أن يزيل حجراً من الخصم' : 'الأسود يجب أن يزيل حجراً من الخصم';
        SoundEffects.play('mill.wav', enabled: widget.soundEnabled);
        setState(() => _state = next);
      } else {
        next.showThabetBadge = false;
        next.currentPlayer = opponent;
        _syncCountsAndWin(next);
        if (next.phase != GamePhase.gameOver) {
          next.statusText = _turnText(next.currentPlayer, next.phase);
        }
        _moves.add(MoveRecord(
          boardBefore: boardBefore,
          player: player,
          from: from,
          to: idx,
          removedIndex: null,
          description: '${player == 1 ? "الأبيض" : "الأسود"} حرّك حجراً',
        ));
        SoundEffects.play('place.wav', enabled: widget.soundEnabled);
        setState(() => _state = next);
        if (widget.mode == GameMode.vsAi && _state.phase != GamePhase.gameOver && _state.currentPlayer == 2) {
          _runAiTurn();
        }
      }
    }
  }

  Future<void> _runAiTurn() async {
    setState(() {
      _aiThinking = true;
      _state.statusText = 'دور الأسود: يفكر الكمبيوتر...';
    });

    await Future.delayed(const Duration(milliseconds: 350));
    if (!mounted) return;

    final moves = _generateMoves(_state.board, 2, _state.p2RemainingToPlace);
    if (moves.isEmpty) {
      setState(() {
        _aiThinking = false;
        _state.winner = 1;
        _state.phase = GamePhase.gameOver;
        _state.winReason = 'اللاعب الثاني لا يملك حركة متاحة';
        _state.statusText = 'فاز الأبيض • ${_state.winReason}';
      });
      return;
    }

    _AiMove chosen;
    if (widget.aiLevel == AiLevel.easy) {
      chosen = moves[_rng.nextInt(moves.length)];
    } else {
      moves.sort((a, b) => _scoreMove(_state, b).compareTo(_scoreMove(_state, a)));
      chosen = moves.first;
    }

    final boardBefore = List<int?>.from(_state.board);
    final next = _state.clone();
    final highlights = <int>{};
    if (chosen.from != null) {
      next.board[chosen.from!] = null;
      highlights.add(chosen.from!);
    }
    next.board[chosen.to] = 2;
    highlights.add(chosen.to);
    if (next.p2RemainingToPlace > 0) next.p2RemainingToPlace -= 1;

    int? removed;
    final madeThabet = _formsThabet(next.board, chosen.to, 2);
    if (madeThabet) {
      next.showThabetBadge = true;
      removed = _pickVictim(next.board, 1);
      if (removed != null) {
        next.board[removed] = null;
        highlights.add(removed);
      }
    } else {
      next.showThabetBadge = false;
    }

    next.highlightNodes = highlights;
    next.currentPlayer = 1;
    next.stage = TurnStage.selectOrPlace;
    next.selectedIndex = null;
    _syncCountsAndWin(next);
    if (next.phase != GamePhase.gameOver) {
      next.statusText = _turnText(1, next.phase);
    }

    _moves.add(MoveRecord(
      boardBefore: boardBefore,
      player: 2,
      from: chosen.from,
      to: chosen.to,
      removedIndex: removed,
      description: 'الأسود لعب',
    ));

    SoundEffects.play(madeThabet ? 'mill.wav' : 'place.wav', enabled: widget.soundEnabled);
    setState(() {
      _state = next;
      _aiThinking = false;
    });
  }

  List<_AiMove> _generateMoves(List<int?> board, int player, int rem) {
    final out = <_AiMove>[];
    if (rem > 0) {
      for (int i = 0; i < 24; i++) {
        if (board[i] == null) out.add(_AiMove(from: null, to: i));
      }
      return out;
    }
    for (int i = 0; i < 24; i++) {
      if (board[i] == player) {
        for (final n in adjacent[i]!) {
          if (board[n] == null) out.add(_AiMove(from: i, to: n));
        }
      }
    }
    return out;
  }

  int _scoreMove(GameSnapshot s, _AiMove m) {
    final b = List<int?>.from(s.board);
    if (m.from != null) b[m.from!] = null;
    b[m.to] = 2;
    int score = 0;
    if (_formsThabet(b, m.to, 2)) score += 300;
    for (final line in thabetLines) {
      if (!line.contains(m.to)) continue;
      final c1 = line.where((i) => b[i] == 1).length;
      final emp = line.where((i) => b[i] == null).length;
      if (c1 == 2 && emp == 1) score += 140;
    }
    score += (adjacent[m.to]?.length ?? 0) * 12 + _rng.nextInt(15);
    return score;
  }

  int? _pickVictim(List<int?> board, int opp) {
    final allProt = _allProtected(board, opp);
    for (int i = 0; i < 24; i++) {
      if (board[i] == opp && (allProt || !_isProtected(board, i, opp))) {
        return i;
      }
    }
    return null;
  }

  void _showHint() {
    if (!widget.hintsEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('التلميحات متوقفة من الإعدادات')),
      );
      return;
    }
    final p = _state.currentPlayer;
    final rem = p == 1 ? _state.p1RemainingToPlace : _state.p2RemainingToPlace;
    final moves = _generateMoves(_state.board, p, rem);
    if (moves.isNotEmpty) {
      setState(() {
        _state.highlightNodes = {moves.first.to};
        _state.statusText = 'تلميح: النقطة المضيئة خيار مناسب';
      });
    }
  }

  void _replayMoves() {
    if (_moves.isEmpty) return;
    final firstBoard = List<int?>.from(_moves.first.boardBefore);
    setState(() {
      _state.board
        ..clear()
        ..addAll(firstBoard);
      _state.phase = GamePhase.gameOver;
      _state.statusText = 'إعادة عرض بداية المباراة (${_moves.length} نقلة)';
    });
  }

  Color get _boardSurfaceColor => switch (widget.boardTheme) {
        BoardTheme.wood => const Color(0xFFD59D5D),
        BoardTheme.emerald => const Color(0xFF2B7A5E),
        BoardTheme.obsidian => const Color(0xFF34373F),
      };

  Color get _lineStrokeColor => switch (widget.boardTheme) {
        BoardTheme.wood => const Color(0xFF4B3219),
        BoardTheme.emerald => const Color(0xFFD8F3DC),
        BoardTheme.obsidian => const Color(0xFFD9A05B),
      };

  @override
  Widget build(BuildContext context) {
    final p1Total = _state.p1PiecesOnBoard + _state.p1RemainingToPlace;
    final p2Total = _state.p2PiecesOnBoard + _state.p2RemainingToPlace;

    return Scaffold(
      backgroundColor: const Color(0xFF141414),
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Expanded(
                        child: Text(
                          'الكمبيوتر 🤖 (بحمد)',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                      IconButton(
                        icon: Icon(_isPaused ? Icons.play_arrow : Icons.pause),
                        onPressed: () => setState(() => _isPaused = !_isPaused),
                      ),
                      IconButton(
                        icon: const Icon(Icons.refresh),
                        onPressed: _newMatch,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatClock(_elapsedSeconds),
                    style: const TextStyle(fontSize: 14, color: Colors.white70),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF222222),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      _isPaused ? 'اللعبة متوقفة مؤقتاً' : _state.statusText,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      _formatElapsed(_elapsedSeconds),
                      style: const TextStyle(fontSize: 13, color: Colors.white54),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Expanded(
                    child: Center(
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: Container(
                          decoration: BoxDecoration(
                            color: _boardSurfaceColor,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: const [
                              BoxShadow(color: Colors.black54, blurRadius: 16, offset: Offset(0, 6)),
                            ],
                          ),
                          child: LayoutBuilder(
                            builder: (ctx, c) {
                              final w = c.maxWidth;
                              final h = c.maxHeight;
                              return Stack(
                                children: [
                                  CustomPaint(
                                    size: Size(w, h),
                                    painter: _BoardLinesPainter(lineColor: _lineStrokeColor, coords: nodeCoords),
                                  ),
                                  for (int i = 0; i < 24; i++)
                                    Positioned(
                                      left: nodeCoords[i].dx * w - 21,
                                      top: nodeCoords[i].dy * h - 21,
                                      child: GestureDetector(
                                        onTap: () => _onNodeTap(i),
                                        child: _buildStone(i),
                                      ),
                                    ),
                                  if (_state.showThabetBadge)
                                    Center(
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFE5B373),
                                          borderRadius: BorderRadius.circular(12),
                                          boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 8)],
                                        ),
                                        child: const Text(
                                          'إثبت',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF1E140A),
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  _buildPoolRow(count: p2Total, isWhite: false),
                  const SizedBox(height: 6),
                  _buildPoolRow(count: p1Total, isWhite: true),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _bottomActionButton(
                          icon: Icons.refresh,
                          label: 'مباراة جديدة',
                          onTap: _newMatch,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _bottomActionButton(
                          icon: Icons.replay,
                          label: 'إعادة العرض',
                          onTap: _replayMoves,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _bottomActionButton(
                          icon: Icons.lightbulb_outline,
                          label: 'تلميح',
                          onTap: _showHint,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        backgroundColor: const Color(0xFF1F1F1F),
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Color(0xFF333333)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.home, size: 18),
                      label: const Text('الرئيسية'),
                    ),
                  ),
                ],
              ),
            ),
            if (_state.phase == GamePhase.gameOver && _state.winner != null)
              Container(
                color: Colors.black54,
                child: Center(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 28),
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: const Color(0xFF23201C),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFF473E33)),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('🏆', style: TextStyle(fontSize: 38)),
                        const SizedBox(height: 8),
                        Text(
                          _state.winner == 1 ? 'فاز الأبيض' : 'فاز الأسود',
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFFE5B373)),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'السبب: ${_state.winReason}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 13.5, color: Colors.white70),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'الوقت المستغرق: ${_formatElapsed(_elapsedSeconds)}',
                          style: const TextStyle(fontSize: 13.5, color: Colors.white70),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: _replayMoves,
                            child: const Text('إعادة العرض'),
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('الرئيسية'),
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            style: FilledButton.styleFrom(
                              backgroundColor: const Color(0xFFD89E5A),
                              foregroundColor: const Color(0xFF1A1107),
                            ),
                            onPressed: _newMatch,
                            child: const Text('مباراة جديدة', style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPoolRow({required int count, required bool isWhite}) {
    final safeCount = count.clamp(0, 9);
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 6,
      children: List.generate(
        safeCount,
        (_) => Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isWhite ? const Color(0xFFF5F5F5) : const Color(0xFF191919),
            border: Border.all(
              color: isWhite ? const Color(0xFF8C8C8C) : const Color(0xFF5A5A5A),
              width: 1.5,
            ),
            boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 3, offset: Offset(0, 1.5))],
          ),
        ),
      ),
    );
  }

  Widget _buildStone(int idx) {
    final v = _state.board[idx];
    final selected = _state.selectedIndex == idx;
    final highlighted = _state.highlightNodes.contains(idx);

    if (v == null) {
      return SizedBox(
        width: 42,
        height: 42,
        child: Center(
          child: Container(
            width: highlighted ? 18 : 13,
            height: highlighted ? 18 : 13,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: highlighted ? Colors.amberAccent : const Color(0xFFF6F2EC),
              border: Border.all(color: const Color(0xFF4B3219), width: 2),
            ),
          ),
        ),
      );
    }

    final isWhite = v == 1;
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isWhite ? const Color(0xFFF7F7F7) : const Color(0xFF171717),
        border: Border.all(
          color: selected
              ? Colors.cyanAccent
              : (highlighted ? Colors.amberAccent : (isWhite ? const Color(0xFF7A7A7A) : const Color(0xFF525252))),
          width: (selected || highlighted) ? 3 : 2,
        ),
        boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 5, offset: Offset(0, 2.5))],
      ),
    );
  }

  Widget _bottomActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        backgroundColor: const Color(0xFF1F1F1F),
        foregroundColor: Colors.white,
        side: const BorderSide(color: Color(0xFF333333)),
        padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onPressed: onTap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: const Color(0xFFD89E5A)),
          const SizedBox(width: 4),
          Flexible(child: Text(label, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12.5))),
        ],
      ),
    );
  }
}

class _AiMove {
  final int? from;
  final int to;
  _AiMove({required this.from, required this.to});
}

class _BoardLinesPainter extends CustomPainter {
  final Color lineColor;
  final List<Offset> coords;

  _BoardLinesPainter({required this.lineColor, required this.coords});

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = lineColor
      ..strokeWidth = 3.2
      ..style = PaintingStyle.stroke;

    void seg(int a, int b) {
      canvas.drawLine(
        Offset(coords[a].dx * size.width, coords[a].dy * size.height),
        Offset(coords[b].dx * size.width, coords[b].dy * size.height),
        p,
      );
    }

    seg(0, 1); seg(1, 2); seg(2, 14); seg(14, 23);
    seg(23, 22); seg(22, 21); seg(21, 9); seg(9, 0);

    seg(3, 4); seg(4, 5); seg(5, 13); seg(13, 20);
    seg(20, 19); seg(19, 18); seg(18, 10); seg(10, 3);

    seg(6, 7); seg(7, 8); seg(8, 12); seg(12, 17);
    seg(17, 16); seg(16, 15); seg(15, 11); seg(11, 6);

    seg(1, 4); seg(4, 7);
    seg(9, 10); seg(10, 11);
    seg(12, 13); seg(13, 14);
    seg(16, 19); seg(19, 22);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
