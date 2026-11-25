import 'dart:async';
import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
  } catch (_) {
    // Keeps offline mode working safely if Firebase config is not present
  }
  runApp(const ThabetApp());
}

class SoundEffects {
  static final AudioPlayer _player = AudioPlayer();

  static Future<void> play(String fileName, {required bool enabled}) async {
    if (!enabled) return;
    try {
      await _player.stop();
      await _player.play(AssetSource('sounds/$fileName'));
    } catch (_) {
      // Ignore audio errors if sound file is missing or device audio is busy
    }
  }
}

enum AppThemePreset { wood, emerald, obsidian }

enum AiDifficulty { medium, hard, extreme }

enum GameMode { vsAi, localTwoPlayers, onlineFriend }

enum GamePhase { placing, moving, gameOver }

enum TurnStage { selectOrPlace, removePiece }

class GameSnapshot {
  final List<int?> board;
  int currentPlayer; // 1 = Player 1 (بحمد), 2 = Player 2 / AI
  GamePhase phase;
  TurnStage stage;
  int p1RemainingToPlace;
  int p2RemainingToPlace;
  int p1PiecesOnBoard;
  int p2PiecesOnBoard;
  int? selectedIndex;
  String statusText;
  int? winner;
  Set<int> aiHighlightNodes;
  Set<int> activeLineNodes;

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
    required this.aiHighlightNodes,
    Set<int>? activeLineNodes,
  }) : activeLineNodes = activeLineNodes ?? <int>{};

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
        aiHighlightNodes: Set<int>.from(aiHighlightNodes),
        activeLineNodes: Set<int>.from(activeLineNodes),
      );

  Map<String, dynamic> toMap() => {
        'board': board.map((e) => e ?? 0).toList(),
        'currentPlayer': currentPlayer,
        'phase': phase.name,
        'stage': stage.name,
        'p1RemainingToPlace': p1RemainingToPlace,
        'p2RemainingToPlace': p2RemainingToPlace,
        'p1PiecesOnBoard': p1PiecesOnBoard,
        'p2PiecesOnBoard': p2PiecesOnBoard,
        'selectedIndex': selectedIndex ?? -1,
        'statusText': statusText,
        'winner': winner ?? 0,
        'aiHighlightNodes': aiHighlightNodes.toList(),
        'activeLineNodes': activeLineNodes.toList(),
      };

  static GameSnapshot fromMap(Map<dynamic, dynamic> raw) {
    final rawBoard = (raw['board'] as List<dynamic>? ?? List.filled(24, 0))
        .map((e) => (e as num).toInt() == 0 ? null : (e as num).toInt())
        .toList();
    while (rawBoard.length < 24) {
      rawBoard.add(null);
    }

    final phaseName = raw['phase']?.toString() ?? 'placing';
    final stageName = raw['stage']?.toString() ?? 'selectOrPlace';
    final selRaw = (raw['selectedIndex'] as num?)?.toInt() ?? -1;
    final winRaw = (raw['winner'] as num?)?.toInt() ?? 0;
    final highlights = ((raw['aiHighlightNodes'] as List<dynamic>?) ?? const [])
        .map((e) => (e as num).toInt())
        .toSet();
    final activeLines = ((raw['activeLineNodes'] as List<dynamic>?) ?? const [])
        .map((e) => (e as num).toInt())
        .toSet();

    final parsedPhase = phaseName == 'moving' || phaseName == 'flying'
        ? GamePhase.moving
        : (phaseName == 'gameOver' ? GamePhase.gameOver : GamePhase.placing);

    return GameSnapshot(
      board: rawBoard.take(24).toList(),
      currentPlayer: ((raw['currentPlayer'] as num?)?.toInt() ?? 1).clamp(1, 2),
      phase: parsedPhase,
      stage: TurnStage.values.firstWhere((s) => s.name == stageName, orElse: () => TurnStage.selectOrPlace),
      p1RemainingToPlace: (raw['p1RemainingToPlace'] as num?)?.toInt() ?? 9,
      p2RemainingToPlace: (raw['p2RemainingToPlace'] as num?)?.toInt() ?? 9,
      p1PiecesOnBoard: (raw['p1PiecesOnBoard'] as num?)?.toInt() ?? 0,
      p2PiecesOnBoard: (raw['p2PiecesOnBoard'] as num?)?.toInt() ?? 0,
      selectedIndex: selRaw >= 0 && selRaw < 24 ? selRaw : null,
      statusText: raw['statusText']?.toString() ?? 'دورك الآن',
      winner: winRaw == 1 || winRaw == 2 ? winRaw : null,
      aiHighlightNodes: highlights,
      activeLineNodes: activeLines,
    );
  }
}

class ThabetApp extends StatefulWidget {
  const ThabetApp({super.key});

  @override
  State<ThabetApp> createState() => _ThabetAppState();
}

class _ThabetAppState extends State<ThabetApp> {
  bool _soundEnabled = true;
  AppThemePreset _themePreset = AppThemePreset.wood;
  AiDifficulty _difficulty = AiDifficulty.extreme;

  int _totalGames = 0;
  int _wins = 0;
  int _losses = 0;
  int _draws = 0;

  @override
  void initState() {
    super.initState();
    _loadSavedData();
  }

  Future<void> _loadSavedData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _soundEnabled = prefs.getBool('sound_enabled') ?? true;
      final themeIdx = prefs.getInt('theme_preset') ?? AppThemePreset.wood.index;
      _themePreset = AppThemePreset.values[themeIdx.clamp(0, AppThemePreset.values.length - 1)];
      final diffIdx = prefs.getInt('ai_difficulty') ?? AiDifficulty.extreme.index;
      _difficulty = AiDifficulty.values[diffIdx.clamp(0, AiDifficulty.values.length - 1)];

      _totalGames = prefs.getInt('stat_total') ?? 0;
      _wins = prefs.getInt('stat_wins') ?? 0;
      _losses = prefs.getInt('stat_losses') ?? 0;
      _draws = prefs.getInt('stat_draws') ?? 0;
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('sound_enabled', _soundEnabled);
    await prefs.setInt('theme_preset', _themePreset.index);
    await prefs.setInt('ai_difficulty', _difficulty.index);
  }

  Future<void> _recordMatchResult(int? winner) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _totalGames += 1;
      if (winner == 1) {
        _wins += 1;
      } else if (winner == 2) {
        _losses += 1;
      } else {
        _draws += 1;
      }
    });
    await prefs.setInt('stat_total', _totalGames);
    await prefs.setInt('stat_wins', _wins);
    await prefs.setInt('stat_losses', _losses);
    await prefs.setInt('stat_draws', _draws);
  }

  Future<void> _resetStats() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _totalGames = 0;
      _wins = 0;
      _losses = 0;
      _draws = 0;
    });
    await prefs.setInt('stat_total', 0);
    await prefs.setInt('stat_wins', 0);
    await prefs.setInt('stat_losses', 0);
    await prefs.setInt('stat_draws', 0);
  }

  ThemeData _buildTheme() {
    switch (_themePreset) {
      case AppThemePreset.emerald:
        return ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0F6B4E), brightness: Brightness.dark),
          scaffoldBackgroundColor: const Color(0xFF091E18),
        );
      case AppThemePreset.obsidian:
        return ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFD4AF37), brightness: Brightness.dark),
          scaffoldBackgroundColor: const Color(0xFF101114),
        );
      case AppThemePreset.wood:
        return ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFB4692B), brightness: Brightness.dark),
          scaffoldBackgroundColor: const Color(0xFF1D130C),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ثبت',
      debugShowCheckedModeBanner: false,
      theme: _buildTheme(),
      home: Directionality(
        textDirection: TextDirection.rtl,
        child: ThabetHomeScreen(
          brandTitle: 'BAHMAD THABET',
          aiName: 'الكمبيوتر',
          soundEnabled: _soundEnabled,
          themePreset: _themePreset,
          difficulty: _difficulty,
          totalGames: _totalGames,
          wins: _wins,
          losses: _losses,
          draws: _draws,
          onToggleSound: (val) {
            setState(() => _soundEnabled = val);
            _saveSettings();
          },
          onChangeTheme: (preset) {
            setState(() => _themePreset = preset);
            _saveSettings();
          },
          onChangeDifficulty: (diff) {
            setState(() => _difficulty = diff);
            _saveSettings();
          },
          onMatchFinished: _recordMatchResult,
          onResetStats: _resetStats,
        ),
      ),
    );
  }
}

class ThabetHomeScreen extends StatefulWidget {
  final String brandTitle;
  final String aiName;
  final bool soundEnabled;
  final AppThemePreset themePreset;
  final AiDifficulty difficulty;
  final int totalGames;
  final int wins;
  final int losses;
  final int draws;
  final ValueChanged<bool> onToggleSound;
  final ValueChanged<AppThemePreset> onChangeTheme;
  final ValueChanged<AiDifficulty> onChangeDifficulty;
  final ValueChanged<int?> onMatchFinished;
  final VoidCallback onResetStats;

  const ThabetHomeScreen({
    super.key,
    required this.brandTitle,
    required this.aiName,
    required this.soundEnabled,
    required this.themePreset,
    required this.difficulty,
    required this.totalGames,
    required this.wins,
    required this.losses,
    required this.draws,
    required this.onToggleSound,
    required this.onChangeTheme,
    required this.onChangeDifficulty,
    required this.onMatchFinished,
    required this.onResetStats,
  });

  @override
  State<ThabetHomeScreen> createState() => _ThabetHomeScreenState();
}

class _ThabetHomeScreenState extends State<ThabetHomeScreen> {
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
    Offset(0.08, 0.08), Offset(0.50, 0.08), Offset(0.92, 0.08),
    Offset(0.22, 0.22), Offset(0.50, 0.22), Offset(0.78, 0.22),
    Offset(0.36, 0.36), Offset(0.50, 0.36), Offset(0.64, 0.36),
    Offset(0.08, 0.50), Offset(0.22, 0.50), Offset(0.36, 0.50),
    Offset(0.64, 0.50), Offset(0.78, 0.50), Offset(0.92, 0.50),
    Offset(0.36, 0.64), Offset(0.50, 0.64), Offset(0.64, 0.64),
    Offset(0.22, 0.78), Offset(0.50, 0.78), Offset(0.78, 0.78),
    Offset(0.08, 0.92), Offset(0.50, 0.92), Offset(0.92, 0.92),
  ];

  late GameSnapshot _state;
  final List<GameSnapshot> _history = [];
  GameMode _gameMode = GameMode.vsAi;
  bool _aiThinking = false;
  bool _resultRecorded = false;
  final Random _rng = Random();

  String? _roomCode;
  int _onlinePlayerId = 1;
  bool _friendJoined = false;
  StreamSubscription<DatabaseEvent>? _roomSub;

  @override
  void initState() {
    super.initState();
    _startNewGame(triggerAiIfNeeded: false);
  }

  @override
  void dispose() {
    _roomSub?.cancel();
    super.dispose();
  }

  String _generateRoomCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    return List.generate(5, (_) => chars[_rng.nextInt(chars.length)]).join();
  }

  DatabaseReference? _roomRef(String code) {
    try {
      if (Firebase.apps.isEmpty) return null;
      return FirebaseDatabase.instance.ref('thabet_rooms/$code');
    } catch (_) {
      return null;
    }
  }

  Future<void> _createOnlineRoom() async {
    final code = _generateRoomCode();
    final ref = _roomRef(code);
    if (ref == null) {
      _showOnlineMessage('الأونلاين يتطلب ربط ملف google-services.json وتفعيل Realtime Database في Firebase.');
      return;
    }

    _roomSub?.cancel();
    final initial = GameSnapshot(
      board: List<int?>.filled(24, null),
      currentPlayer: 1,
      phase: GamePhase.placing,
      stage: TurnStage.selectOrPlace,
      p1RemainingToPlace: 9,
      p2RemainingToPlace: 9,
      p1PiecesOnBoard: 0,
      p2PiecesOnBoard: 0,
      selectedIndex: null,
      statusText: 'غرفة ($code) جاهزة — شارك الكود مع صديقك للبدء',
      winner: null,
      aiHighlightNodes: {},
      activeLineNodes: {},
    );

    try {
      await ref.set({
        'hostJoined': true,
        'guestJoined': false,
        'updatedAt': ServerValue.timestamp,
        'game': initial.toMap(),
      });

      setState(() {
        _gameMode = GameMode.onlineFriend;
        _roomCode = code;
        _onlinePlayerId = 1;
        _friendJoined = false;
        _history.clear();
        _resultRecorded = false;
        _state = initial;
      });

      _listenToRoom(code);
    } catch (e) {
      _showOnlineMessage('تعذر إنشاء الغرفة: $e');
    }
  }

  Future<void> _joinOnlineRoom(String rawCode) async {
    final code = rawCode.trim().toUpperCase();
    if (code.isEmpty) return;

    final ref = _roomRef(code);
    if (ref == null) {
      _showOnlineMessage('الأونلاين يتطلب ربط ملف google-services.json وتفعيل Realtime Database في Firebase.');
      return;
    }

    try {
      final snap = await ref.get();
      if (!snap.exists || snap.value is! Map) {
        _showOnlineMessage('لا توجد غرفة بالكود ($code).');
        return;
      }

      _roomSub?.cancel();
      await ref.update({
        'guestJoined': true,
        'updatedAt': ServerValue.timestamp,
      });

      setState(() {
        _gameMode = GameMode.onlineFriend;
        _roomCode = code;
        _onlinePlayerId = 2;
        _friendJoined = true;
        _history.clear();
        _resultRecorded = false;
      });

      _listenToRoom(code);
    } catch (e) {
      _showOnlineMessage('تعذر الانضمام للغرفة: $e');
    }
  }

  void _listenToRoom(String code) {
    final ref = _roomRef(code);
    if (ref == null) return;

    _roomSub = ref.onValue.listen((event) {
      final data = event.snapshot.value;
      if (data is! Map) return;

      final guestJoined = data['guestJoined'] == true;
      final gameMap = data['game'];
      if (gameMap is Map) {
        final remoteSnap = GameSnapshot.fromMap(gameMap);
        setState(() {
          _friendJoined = guestJoined;
          _state = remoteSnap;
        });
        _checkGameOverNotification(_state);
      }
    });
  }

  Future<void> _syncRoomGameState(GameSnapshot snap) async {
    if (_gameMode != GameMode.onlineFriend || _roomCode == null) return;
    final ref = _roomRef(_roomCode!);
    if (ref == null) return;
    try {
      await ref.update({
        'game': snap.toMap(),
        'updatedAt': ServerValue.timestamp,
      });
    } catch (_) {}
  }

  void _showOnlineMessage(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  void _openOnlineLobbyDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('أونلاين مع صديق 🌐'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'أنشئ غرفة وأرسل الكود لصديقك، أو أدخل كود الغرفة للانضمام المباشر.',
              style: TextStyle(fontSize: 13.5),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: () {
                Navigator.pop(context);
                _createOnlineRoom();
              },
              icon: const Icon(Icons.add_circle_outline),
              label: const Text('إنشاء غرفة جديدة'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              textCapitalization: TextCapitalization.characters,
              decoration: const InputDecoration(
                labelText: 'أدخل كود الغرفة',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () {
                final code = controller.text;
                Navigator.pop(context);
                _joinOnlineRoom(code);
              },
              icon: const Icon(Icons.login),
              label: const Text('انضمام إلى الغرفة'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('إغلاق')),
        ],
      ),
    );
  }

  void _startNewGame({bool triggerAiIfNeeded = true}) {
    if (_gameMode == GameMode.onlineFriend) {
      final fresh = GameSnapshot(
        board: List<int?>.filled(24, null),
        currentPlayer: 1,
        phase: GamePhase.placing,
        stage: TurnStage.selectOrPlace,
        p1RemainingToPlace: 9,
        p2RemainingToPlace: 9,
        p1PiecesOnBoard: 0,
        p2PiecesOnBoard: 0,
        selectedIndex: null,
        statusText: 'بدأت جولة أونلاين جديدة — دور اللاعب 1',
        winner: null,
        aiHighlightNodes: {},
        activeLineNodes: {},
      );
      setState(() {
        _resultRecorded = false;
        _state = fresh;
      });
      _syncRoomGameState(fresh);
      return;
    }

    setState(() {
      _history.clear();
      _aiThinking = false;
      _resultRecorded = false;
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
        statusText: _gameMode == GameMode.vsAi
            ? 'مرحلة الوضع: ضع قطعة (9 قطع لكل لاعب)'
            : 'دور اللاعب 1 (أبيض): ضع قطعة',
        winner: null,
        aiHighlightNodes: {},
        activeLineNodes: {},
      );
    });
    if (triggerAiIfNeeded && _gameMode == GameMode.vsAi && _state.currentPlayer == 2) {
      _runAiTurn();
    }
  }

  Set<int> _completedLineNodesAt(List<int?> board, int pos, int player) {
    final nodes = <int>{};
    for (final line in thabetLines) {
      if (line.contains(pos) && line.every((idx) => board[idx] == player)) {
        nodes.addAll(line);
      }
    }
    return nodes;
  }

  bool _formsThabet(List<int?> board, int pos, int player) {
    for (final line in thabetLines) {
      if (line.contains(pos) && line.every((idx) => board[idx] == player)) {
        return true;
      }
    }
    return false;
  }

  bool _isProtectedByThabet(List<int?> board, int pos, int player) {
    return _formsThabet(board, pos, player);
  }

  bool _allOpponentProtected(List<int?> board, int opponent) {
    for (int i = 0; i < 24; i++) {
      if (board[i] == opponent && !_isProtectedByThabet(board, i, opponent)) {
        return false;
      }
    }
    return true;
  }

  // قواعد ثبت: لا يوجد طيران؛ التحريك يكون إلى نقطة مجاورة فارغة فقط
  bool _hasAnyLegalMove(List<int?> board, int player, GamePhase phase, int remainingToPlace) {
    if (remainingToPlace > 0) {
      return board.any((cell) => cell == null);
    }
    for (int i = 0; i < 24; i++) {
      if (board[i] == player) {
        for (final n in adjacent[i]!) {
          if (board[n] == null) return true;
        }
      }
    }
    return false;
  }

  void _syncCountsAndPhase(GameSnapshot snap) {
    snap.p1PiecesOnBoard = snap.board.where((c) => c == 1).length;
    snap.p2PiecesOnBoard = snap.board.where((c) => c == 2).length;

    if (snap.winner != null) {
      snap.phase = GamePhase.gameOver;
      return;
    }

    if (snap.p1RemainingToPlace > 0 || snap.p2RemainingToPlace > 0) {
      snap.phase = GamePhase.placing;
      return;
    }

    if (snap.p1PiecesOnBoard < 3) {
      snap.winner = 2;
      snap.phase = GamePhase.gameOver;
      snap.statusText = _gameMode == GameMode.vsAi ? 'فاز ${widget.aiName}🤖 (بحمد)!' : 'فاز اللاعب 2 (أحمر)!';
      return;
    }
    if (snap.p2PiecesOnBoard < 3) {
      snap.winner = 1;
      snap.phase = GamePhase.gameOver;
      snap.statusText = _gameMode == GameMode.vsAi ? 'مبروك! فزت بالجولة 👑' : 'فاز اللاعب 1 (أبيض)!';
      return;
    }

    snap.phase = GamePhase.moving;

    int rem = snap.currentPlayer == 1 ? snap.p1RemainingToPlace : snap.p2RemainingToPlace;
    if (!_hasAnyLegalMove(snap.board, snap.currentPlayer, snap.phase, rem)) {
      snap.winner = snap.currentPlayer == 1 ? 2 : 1;
      snap.phase = GamePhase.gameOver;
      snap.statusText = snap.winner == 1
          ? (_gameMode == GameMode.vsAi ? 'مبروك! فزت بالجولة 👑' : 'فاز اللاعب 1!')
          : (_gameMode == GameMode.vsAi ? 'فاز ${widget.aiName}🤖 (بحمد)!' : 'فاز اللاعب 2!');
    }
  }

  void _checkGameOverNotification(GameSnapshot snap) {
    if (snap.phase == GamePhase.gameOver && !_resultRecorded) {
      _resultRecorded = true;
      if (_gameMode == GameMode.onlineFriend) {
        widget.onMatchFinished(snap.winner == _onlinePlayerId ? 1 : 2);
      } else {
        widget.onMatchFinished(snap.winner);
      }
    }
  }

  String _nextTurnPrompt(int turnPlayer, GamePhase phase) {
    final phaseLabel = phase == GamePhase.placing ? 'ضع قطعة' : 'حرّك قطعة إلى نقطة مجاورة';
    if (_gameMode == GameMode.vsAi) {
      return turnPlayer == 2 ? 'يفكر ${widget.aiName}🤖 (بحمد)...' : 'دورك: $phaseLabel';
    }
    if (_gameMode == GameMode.onlineFriend) {
      return turnPlayer == _onlinePlayerId ? 'دورك: $phaseLabel' : 'بانتظار نقلة صديقك...';
    }
    return turnPlayer == 1 ? 'اللاعب 1 (أبيض): $phaseLabel' : 'اللاعب 2 (أحمر): $phaseLabel';
  }

  void _onNodeTap(int index) {
    if (_aiThinking || _state.phase == GamePhase.gameOver) return;
    if (_gameMode == GameMode.vsAi && _state.currentPlayer == 2) return;
    if (_gameMode == GameMode.onlineFriend && _state.currentPlayer != _onlinePlayerId) {
      setState(() => _state.statusText = 'انتظر دور صديقك...');
      return;
    }

    final next = _state.clone();
    final player = next.currentPlayer;
    final opponent = player == 1 ? 2 : 1;

    if (next.stage == TurnStage.removePiece) {
      if (next.board[index] != opponent) {
        setState(() => next.statusText = 'اختر قطعة للخصم لإزالتها');
        return;
      }
      if (!_allOpponentProtected(next.board, opponent) && _isProtectedByThabet(next.board, index, opponent)) {
        setState(() => next.statusText = 'لا يمكن إزالة قطعة محمية بـ «ثبت» مكتمل');
        return;
      }
      if (_gameMode != GameMode.onlineFriend) {
        _history.add(_state.clone());
      }
      next.board[index] = null;
      next.stage = TurnStage.selectOrPlace;
      next.selectedIndex = null;
      next.activeLineNodes = {};
      next.currentPlayer = opponent;
      _syncCountsAndPhase(next);
      if (next.phase != GamePhase.gameOver) {
        next.statusText = _nextTurnPrompt(next.currentPlayer, next.phase);
      }
      SoundEffects.play('remove.wav', enabled: widget.soundEnabled);
      setState(() => _state = next);
      _checkGameOverNotification(_state);
      _syncRoomGameState(next);
      if (_gameMode == GameMode.vsAi && _state.phase != GamePhase.gameOver && _state.currentPlayer == 2) {
        _runAiTurn();
      }
      return;
    }

    if (next.phase == GamePhase.placing) {
      if (next.board[index] != null) return;
      if (_gameMode != GameMode.onlineFriend) {
        _history.add(_state.clone());
      }
      next.board[index] = player;
      if (player == 1) {
        next.p1RemainingToPlace -= 1;
      } else {
        next.p2RemainingToPlace -= 1;
      }
      _syncCountsAndPhase(next);

      if (_formsThabet(next.board, index, player)) {
        next.stage = TurnStage.removePiece;
        next.activeLineNodes = _completedLineNodesAt(next.board, index, player);
        next.statusText = 'تم «ثبت»! اختر قطعة للخصم لإزالتها';
        SoundEffects.play('mill.wav', enabled: widget.soundEnabled);
        setState(() => _state = next);
        _syncRoomGameState(next);
      } else {
        next.activeLineNodes = {};
        next.currentPlayer = opponent;
        _syncCountsAndPhase(next);
        if (next.phase != GamePhase.gameOver) {
          next.statusText = _nextTurnPrompt(next.currentPlayer, next.phase);
        }
        SoundEffects.play('place.wav', enabled: widget.soundEnabled);
        setState(() => _state = next);
        _checkGameOverNotification(_state);
        _syncRoomGameState(next);
        if (_gameMode == GameMode.vsAi && _state.phase != GamePhase.gameOver && _state.currentPlayer == 2) {
          _runAiTurn();
        }
      }
      return;
    }

    if (next.board[index] == player) {
      setState(() {
        _state.selectedIndex = index;
        _state.statusText = 'تم تحديد القطعة — اختر نقطة مجاورة فارغة';
      });
      return;
    }

    if (next.selectedIndex != null && next.board[index] == null) {
      final from = next.selectedIndex!;
      bool validMove = adjacent[from]?.contains(index) ?? false;
      if (!validMove) {
        setState(() => _state.statusText = 'في ثبت: التحريك للنقطة المجاورة المتصلة فقط');
        return;
      }

      if (_gameMode != GameMode.onlineFriend) {
        _history.add(_state.clone());
      }
      next.board[from] = null;
      next.board[index] = player;
      next.selectedIndex = null;
      _syncCountsAndPhase(next);

      if (_formsThabet(next.board, index, player)) {
        next.stage = TurnStage.removePiece;
        next.activeLineNodes = _completedLineNodesAt(next.board, index, player);
        next.statusText = 'تم «ثبت»! اختر قطعة للخصم لإزالتها';
        SoundEffects.play('mill.wav', enabled: widget.soundEnabled);
        setState(() => _state = next);
        _syncRoomGameState(next);
      } else {
        next.activeLineNodes = {};
        next.currentPlayer = opponent;
        _syncCountsAndPhase(next);
        if (next.phase != GamePhase.gameOver) {
          next.statusText = _nextTurnPrompt(next.currentPlayer, next.phase);
        }
        SoundEffects.play('place.wav', enabled: widget.soundEnabled);
        setState(() => _state = next);
        _checkGameOverNotification(_state);
        _syncRoomGameState(next);
        if (_gameMode == GameMode.vsAi && _state.phase != GamePhase.gameOver && _state.currentPlayer == 2) {
          _runAiTurn();
        }
      }
    }
  }

  void _undoLastTurn() {
    if (_aiThinking || _history.isEmpty || _gameMode == GameMode.onlineFriend) return;
    while (_history.isNotEmpty) {
      final prev = _history.removeLast();
      if (_gameMode != GameMode.vsAi || prev.currentPlayer == 1) {
        setState(() {
          _state = prev;
          _resultRecorded = false;
        });
        return;
      }
    }
  }

  // ==================== AI ENGINE ====================
  Future<void> _runAiTurn() async {
    setState(() {
      _aiThinking = true;
      _state.statusText = 'يفكر ${widget.aiName}🤖 (بحمد) بعمق...';
    });

    await Future.delayed(const Duration(milliseconds: 220));

    final snap = _state.clone();
    final bestMove = _computeBestAiMove(snap);

    if (bestMove == null) {
      setState(() {
        _aiThinking = false;
        _state.winner = 1;
        _state.phase = GamePhase.gameOver;
        _state.statusText = 'مبروك! فزت بالجولة 👑';
      });
      _checkGameOverNotification(_state);
      return;
    }

    final next = _state.clone();
    final highlights = <int>{};
    if (bestMove.from != null) {
      next.board[bestMove.from!] = null;
      highlights.add(bestMove.from!);
    }
    next.board[bestMove.to] = 2;
    highlights.add(bestMove.to);
    if (next.p2RemainingToPlace > 0) {
      next.p2RemainingToPlace -= 1;
    }
    next.aiHighlightNodes = highlights;
    _syncCountsAndPhase(next);

    bool madeThabet = _formsThabet(next.board, bestMove.to, 2);
    if (madeThabet) {
      next.activeLineNodes = _completedLineNodesAt(next.board, bestMove.to, 2);
      final victim = _chooseBestRemovalTarget(next.board, 1);
      if (victim != null) {
        next.board[victim] = null;
        next.aiHighlightNodes.add(victim);
      }
    } else {
      next.activeLineNodes = {};
    }

    next.currentPlayer = 1;
    next.stage = TurnStage.selectOrPlace;
    next.selectedIndex = null;
    _syncCountsAndPhase(next);
    if (next.phase != GamePhase.gameOver) {
      next.statusText = _nextTurnPrompt(1, next.phase);
    }

    SoundEffects.play(madeThabet ? 'mill.wav' : 'place.wav', enabled: widget.soundEnabled);
    setState(() {
      _state = next;
      _aiThinking = false;
    });
    _checkGameOverNotification(_state);
  }

  _AiMove? _computeBestAiMove(GameSnapshot snap) {
    final moves = _generateMovesForPlayer(snap.board, 2, snap.p2RemainingToPlace);
    if (moves.isEmpty) return null;

    int depth;
    switch (widget.difficulty) {
      case AiDifficulty.medium:
        depth = 2;
        break;
      case AiDifficulty.hard:
        depth = 3;
        break;
      case AiDifficulty.extreme:
        depth = 4;
        break;
    }

    moves.sort((a, b) => _quickMovePriority(snap.board, b).compareTo(_quickMovePriority(snap.board, a)));

    int bestScore = -1000000;
    _AiMove? bestMove;
    int alpha = -1000000;
    const int beta = 1000000;

    for (final m in moves.take(widget.difficulty == AiDifficulty.extreme ? 28 : 18)) {
      final sim = _applyMoveSimulation(snap, m, 2);
      final score = _minimax(sim, depth - 1, alpha, beta, false);
      if (score > bestScore || (score == bestScore && _rng.nextBool())) {
        bestScore = score;
        bestMove = m;
      }
      if (score > alpha) alpha = score;
    }
    return bestMove ?? moves.first;
  }

  int _quickMovePriority(List<int?> board, _AiMove m) {
    int p = 0;
    final b = List<int?>.from(board);
    if (m.from != null) b[m.from!] = null;
    b[m.to] = 2;
    if (_formsThabet(b, m.to, 2)) p += 500;
    p += (adjacent[m.to]?.length ?? 0) * 15;
    return p;
  }

  List<_AiMove> _generateMovesForPlayer(List<int?> board, int player, int remainingToPlace) {
    final res = <_AiMove>[];
    if (remainingToPlace > 0) {
      for (int i = 0; i < 24; i++) {
        if (board[i] == null) {
          res.add(_AiMove(from: null, to: i));
        }
      }
      return res;
    }

    for (int i = 0; i < 24; i++) {
      if (board[i] == player) {
        for (final n in adjacent[i]!) {
          if (board[n] == null) res.add(_AiMove(from: i, to: n));
        }
      }
    }
    return res;
  }

  GameSnapshot _applyMoveSimulation(GameSnapshot origin, _AiMove m, int player) {
    final s = origin.clone();
    if (m.from != null) s.board[m.from!] = null;
    s.board[m.to] = player;
    if (player == 1 && s.p1RemainingToPlace > 0) s.p1RemainingToPlace -= 1;
    if (player == 2 && s.p2RemainingToPlace > 0) s.p2RemainingToPlace -= 1;

    if (_formsThabet(s.board, m.to, player)) {
      final opp = player == 1 ? 2 : 1;
      final victim = _chooseBestRemovalTarget(s.board, opp);
      if (victim != null) s.board[victim] = null;
    }

    s.currentPlayer = player == 1 ? 2 : 1;
    _syncCountsAndPhase(s);
    return s;
  }

  int? _chooseBestRemovalTarget(List<int?> board, int opponent) {
    int? bestIdx;
    int bestScore = -100000;
    bool allProtected = _allOpponentProtected(board, opponent);

    for (int i = 0; i < 24; i++) {
      if (board[i] != opponent) continue;
      if (!allProtected && _isProtectedByThabet(board, i, opponent)) continue;

      int score = 0;
      for (final line in thabetLines) {
        if (!line.contains(i)) continue;
        int oppCount = line.where((idx) => board[idx] == opponent).length;
        int emptyCount = line.where((idx) => board[idx] == null).length;
        if (oppCount == 2 && emptyCount == 1) score += 120;
        if (oppCount == 1 && emptyCount == 2) score += 25;
      }
      score += (adjacent[i]?.length ?? 0) * 10;
      if (score > bestScore) {
        bestScore = score;
        bestIdx = i;
      }
    }
    return bestIdx;
  }

  int _minimax(GameSnapshot s, int depth, int alpha, int beta, bool maximizingAi) {
    if (s.winner == 2) return 100000 + depth * 100;
    if (s.winner == 1) return -100000 - depth * 100;
    if (depth <= 0) return _evaluateBoard(s);

    final player = maximizingAi ? 2 : 1;
    final rem = player == 1 ? s.p1RemainingToPlace : s.p2RemainingToPlace;
    final moves = _generateMovesForPlayer(s.board, player, rem);
    if (moves.isEmpty) {
      return maximizingAi ? -90000 : 90000;
    }

    if (maximizingAi) {
      int value = -1000000;
      for (final m in moves.take(16)) {
        final child = _applyMoveSimulation(s, m, 2);
        value = max(value, _minimax(child, depth - 1, alpha, beta, false));
        alpha = max(alpha, value);
        if (alpha >= beta) break;
      }
      return value;
    } else {
      int value = 1000000;
      for (final m in moves.take(16)) {
        final child = _applyMoveSimulation(s, m, 1);
        value = min(value, _minimax(child, depth - 1, alpha, beta, true));
        beta = min(beta, value);
        if (alpha >= beta) break;
      }
      return value;
    }
  }

  int _evaluateBoard(GameSnapshot s) {
    int score = 0;
    int aiPieces = s.board.where((c) => c == 2).length + s.p2RemainingToPlace;
    int p1Pieces = s.board.where((c) => c == 1).length + s.p1RemainingToPlace;
    score += (aiPieces - p1Pieces) * 260;

    int aiOpenTwo = 0;
    int p1OpenTwo = 0;

    for (final line in thabetLines) {
      int c2 = line.where((idx) => s.board[idx] == 2).length;
      int c1 = line.where((idx) => s.board[idx] == 1).length;
      int emp = line.where((idx) => s.board[idx] == null).length;

      if (c2 == 3) score += 180;
      if (c1 == 3) score -= 190;
      if (c2 == 2 && emp == 1) aiOpenTwo += 1;
      if (c1 == 2 && emp == 1) p1OpenTwo += 1;
    }

    score += aiOpenTwo * 130;
    score -= p1OpenTwo * 155;
    if (aiOpenTwo >= 2) score += 320;

    int aiMobility = 0;
    int p1Mobility = 0;
    for (int i = 0; i < 24; i++) {
      if (s.board[i] == 2) {
        aiMobility += (adjacent[i] ?? []).where((n) => s.board[n] == null).length;
      } else if (s.board[i] == 1) {
        p1Mobility += (adjacent[i] ?? []).where((n) => s.board[n] == null).length;
      }
    }
    score += (aiMobility - p1Mobility) * 18;
    return score;
  }

  String _difficultyLabel(AiDifficulty d) {
    switch (d) {
      case AiDifficulty.medium:
        return 'متوسط';
      case AiDifficulty.hard:
        return 'صعب';
      case AiDifficulty.extreme:
        return 'صعب جداً 🔥';
    }
  }

  String _themeLabel(AppThemePreset t) {
    switch (t) {
      case AppThemePreset.wood:
        return 'خشبي ملكي';
      case AppThemePreset.emerald:
        return 'زمردي';
      case AppThemePreset.obsidian:
        return 'ليلي ذهبي';
    }
  }

  void _openRulesDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('قوانين لعبة «ثبت»'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ruleSection('1. مرحلة الوضع', 'يضع كل لاعب 9 قطع بالتناوب على نقاط التقاطع الفارغة.'),
              const SizedBox(height: 10),
              _ruleSection('2. تحقيق «ثبت»', 'صف 3 قطع من لونك على خط مستقيم لتحقيق «ثبت» وإزالة قطعة للخصم (لا تُزال قطعة محمية بـ «ثبت» مكتمل إلا إذا كانت كل قطع الخصم محمية).'),
              const SizedBox(height: 10),
              _ruleSection('3. التحريك المتصل', 'في ثبت يُحرّك اللاعب قطعته إلى نقطة مجاورة فارغة متصلة بالخط، ولا يوجد طيران.'),
              const SizedBox(height: 10),
              _ruleSection('4. الفوز والأنماط', 'تفوز إذا قلت قطع الخصم عن 3 أو حُصرت حركاته، ويمكن اللعب ضد ${widget.aiName}🤖 (بحمد) أو أونلاين مع صديق.'),
            ],
          ),
        ),
        actions: [
          FilledButton(onPressed: () => Navigator.pop(context), child: const Text('فهمت')),
        ],
      ),
    );
  }

  Widget _ruleSection(String title, String body) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        const SizedBox(height: 3),
        Text(body, style: const TextStyle(fontSize: 13.5, height: 1.45)),
      ],
    );
  }

  void _openSettingsSheet() {
    showModalBottomSheet(
      context: context,
      builder: (_) => Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('الإعدادات (محفوظة تلقائياً)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            SwitchListTile(
              title: const Text('المؤثرات الصوتية'),
              value: widget.soundEnabled,
              onChanged: (v) {
                widget.onToggleSound(v);
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 8),
            Text('مستوى صعوبة ${widget.aiName}🤖 (بحمد):'),
            const SizedBox(height: 6),
            SegmentedButton<AiDifficulty>(
              segments: AiDifficulty.values
                  .map((d) => ButtonSegment<AiDifficulty>(value: d, label: Text(_difficultyLabel(d))))
                  .toList(),
              selected: {widget.difficulty},
              onSelectionChanged: (set) {
                widget.onChangeDifficulty(set.first);
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 12),
            const Text('ثيم اللوحة:'),
            const SizedBox(height: 6),
            SegmentedButton<AppThemePreset>(
              segments: AppThemePreset.values
                  .map((t) => ButtonSegment<AppThemePreset>(value: t, label: Text(_themeLabel(t))))
                  .toList(),
              selected: {widget.themePreset},
              onSelectionChanged: (set) {
                widget.onChangeTheme(set.first);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _openStatsDialog() {
    final winRate = widget.totalGames == 0 ? 0 : ((widget.wins / widget.totalGames) * 100).round();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('سجل إحصائيات اللاعب'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _statRow('إجمالي المباريات', '${widget.totalGames}'),
            _statRow('مرات الفوز', '${widget.wins}'),
            _statRow('مرات الخسارة', '${widget.losses}'),
            _statRow('التعادلات', '${widget.draws}'),
            _statRow('نسبة الفوز', '$winRate%'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              widget.onResetStats();
              Navigator.pop(context);
            },
            child: const Text('تصفير السجل'),
          ),
          FilledButton(onPressed: () => Navigator.pop(context), child: const Text('إغلاق')),
        ],
      ),
    );
  }

  Widget _statRow(String label, String val) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [Text(label), Text(val, style: const TextStyle(fontWeight: FontWeight.bold))],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final effectiveAiName = '${widget.aiName}🤖 (بحمد)';
    final lineColor = switch (widget.themePreset) {
      AppThemePreset.wood => const Color(0xFFD9A066),
      AppThemePreset.emerald => const Color(0xFF6EE7B7),
      AppThemePreset.obsidian => const Color(0xFFE5C158),
    };

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.brandTitle),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.help_outline), tooltip: 'قوانين اللعبة', onPressed: _openRulesDialog),
          IconButton(icon: const Icon(Icons.bar_chart), tooltip: 'الإحصائيات', onPressed: _openStatsDialog),
          IconButton(icon: const Icon(Icons.settings), tooltip: 'الإعدادات', onPressed: _openSettingsSheet),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          child: Column(
            children: [
              // شريط أنماط اللعب في صف نظيف بدون إطارات مزعجة
              Row(
                children: [
                  Expanded(
                    child: ChoiceChip(
                      label: Text('ضد $effectiveAiName', overflow: TextOverflow.ellipsis),
                      selected: _gameMode == GameMode.vsAi,
                      onSelected: (_) {
                        _roomSub?.cancel();
                        setState(() {
                          _gameMode = GameMode.vsAi;
                          _roomCode = null;
                        });
                        _startNewGame();
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text('أونلاين 🌐'),
                    selected: _gameMode == GameMode.onlineFriend,
                    onSelected: (_) => _openOnlineLobbyDialog(),
                  ),
                  const SizedBox(width: 4),
                  IconButton(
                    onPressed: _history.isNotEmpty && !_aiThinking && _gameMode != GameMode.onlineFriend
                        ? _undoLastTurn
                        : null,
                    tooltip: 'تراجع',
                    icon: const Icon(Icons.undo),
                  ),
                ],
              ),
              if (_gameMode == GameMode.onlineFriend && _roomCode != null) ...[
                const SizedBox(height: 6),
                Text(
                  'غرفة: $_roomCode • أنت: اللاعب $_onlinePlayerId • ${_friendJoined ? "الصديق متصل" : "بانتظار الصديق"}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
              ],
              const SizedBox(height: 8),
              Text(
                _state.statusText,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              // اللوحة بدون إطار صندوقي محيط
              Expanded(
                child: AspectRatio(
                  aspectRatio: 1,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final w = constraints.maxWidth;
                      final h = constraints.maxHeight;
                      return Stack(
                        children: [
                          CustomPaint(
                            size: Size(w, h),
                            painter: _ThabetBoardPainter(lineColor: lineColor, coords: nodeCoords),
                          ),
                          for (int i = 0; i < 24; i++)
                            Positioned(
                              left: nodeCoords[i].dx * w - 23,
                              top: nodeCoords[i].dy * h - 23,
                              child: GestureDetector(
                                onTap: () => _onNodeTap(i),
                                child: _buildFloatingOrbWidget(i, lineColor),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // صف عداد القطع بدون إطار
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text(
                    'أنت (أبيض): ${_state.p1PiecesOnBoard + _state.p1RemainingToPlace}',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    '$effectiveAiName (أحمر): ${_state.p2PiecesOnBoard + _state.p2RemainingToPlace}',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () => _startNewGame(),
                  icon: const Icon(Icons.refresh),
                  label: const Text('جولة جديدة'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // كرات عائمة بدون إطار صندوقي مزعج
  Widget _buildFloatingOrbWidget(int idx, Color lineColor) {
    final occupant = _state.board[idx];
    final isSelected = _state.selectedIndex == idx;
    final isAiLast = _state.aiHighlightNodes.contains(idx);
    final isCompletedLine = _state.activeLineNodes.contains(idx);

    if (occupant == null) {
      return SizedBox(
        width: 46,
        height: 46,
        child: Center(
          child: Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: lineColor.withValues(alpha: 0.42),
            ),
          ),
        ),
      );
    }

    final List<Color> gradientColors = occupant == 1
        ? const [Color(0xFFFFFFFF), Color(0xFFCBD5E1)]
        : const [Color(0xFFFF7A7A), Color(0xFFDC2626)];

    final glowColor = isSelected
        ? Colors.cyanAccent
        : (isCompletedLine
            ? Colors.limeAccent
            : (isAiLast ? Colors.orangeAccent : Colors.black.withValues(alpha: 0.45)));

    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          center: const Alignment(-0.32, -0.35),
          radius: 0.75,
          colors: gradientColors,
        ),
        boxShadow: [
          BoxShadow(
            color: glowColor,
            blurRadius: (isSelected || isCompletedLine || isAiLast) ? 14 : 8,
            spreadRadius: (isSelected || isCompletedLine || isAiLast) ? 2 : 0.5,
            offset: const Offset(0, 3),
          ),
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

class _ThabetBoardPainter extends CustomPainter {
  final Color lineColor;
  final List<Offset> coords;

  _ThabetBoardPainter({required this.lineColor, required this.coords});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = 2.8
      ..style = PaintingStyle.stroke;

    void connect(int a, int b) {
      canvas.drawLine(
        Offset(coords[a].dx * size.width, coords[a].dy * size.height),
        Offset(coords[b].dx * size.width, coords[b].dy * size.height),
        paint,
      );
    }

    connect(0, 1); connect(1, 2); connect(2, 14); connect(14, 23);
    connect(23, 22); connect(22, 21); connect(21, 9); connect(9, 0);

    connect(3, 4); connect(4, 5); connect(5, 13); connect(13, 20);
    connect(20, 19); connect(19, 18); connect(18, 10); connect(10, 3);

    connect(6, 7); connect(7, 8); connect(8, 12); connect(12, 17);
    connect(17, 16); connect(16, 15); connect(15, 11); connect(11, 6);

    connect(1, 4); connect(4, 7);
    connect(9, 10); connect(10, 11);
    connect(12, 13); connect(13, 14);
    connect(16, 19); connect(19, 22);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
