import 'package:flutter/material.dart';

void main() => runApp(const ThabetApp());

class ThabetApp extends StatelessWidget {
  const ThabetApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ثبّت',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xffd6a84f),
          brightness: Brightness.dark,
        ),
      ),
      home: const GamePage(),
    );
  }
}

class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  final points = <Offset>[
    const Offset(0, 0), const Offset(.5, 0),
    const Offset(1, 0), const Offset(1, .5),
    const Offset(1, 1), const Offset(.5, 1),
    const Offset(0, 1), const Offset(0, .5),
    const Offset(.17, .17), const Offset(.5, .17),
    const Offset(.83, .17), const Offset(.83, .5),
    const Offset(.83, .83), const Offset(.5, .83),
    const Offset(.17, .83), const Offset(.17, .5),
    const Offset(.34, .34), const Offset(.5, .34),
    const Offset(.66, .34), const Offset(.66, .5),
    const Offset(.66, .66), const Offset(.5, .66),
    const Offset(.34, .66), const Offset(.34, .5),
  ];

  late final List<List<int>> edges;
  late final List<List<int>> near;

  List<int> board = List.filled(24, 0);

  int turn = 1;
  int starter = 1;
  int redPlaced = 0;
  int whitePlaced = 0;
  int phase = 0;

  int? selected;
  int? pendingRemoval;
  int? firstMill;
  int? winner;

  String status = 'دور اللاعب الأحمر: ضع حجرًا';

  @override
  void initState() {
    super.initState();

    edges = [];

    for (int r = 0; r < 3; r++) {
      int b = r * 8;
      for (int i = 0; i < 8; i++) {
        edges.add([b + i, b + (i + 1) % 8]);
      }
    }

    for (int i = 0; i < 8; i++) {
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

  bool hasMill(int i, int p) =>
      mills.any((m) => m.contains(i) && m.every((n) => board[n] == p));

  String name(int p) => p == 1 ? 'الأحمر' : 'الأبيض';

  bool hasMove(int p) => List.generate(24, (i) => i).any(
        (i) => board[i] == p && near[i].any((n) => board[n] == 0),
      );

  void tapNode(int i) {
    if (phase == 2) return;

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
          pendingRemoval = firstMill ?? starter;

          status = firstMill == null
              ? 'انتهى الرص. أولوية الإزالة للاعب البادئ (${name(starter)}).'
              : 'انتهى الرص. أولوية الإزالة للاعب ${name(firstMill!)}.';
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
            status = 'ثبّت! اختر حجرًا من اللاعب ${name(3 - turn)} لإزالته.';
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

    if (count(3 - remover) == 0) {
      winner = remover;
      phase = 2;
      status = 'فاز اللاعب ${name(remover)}!';
      return;
    }

    turn = remover;
    _endTurn(changeTurn: false);
  }

  void _endTurn({bool changeTurn = true}) {
    if (changeTurn) turn = 3 - turn;

    selected = null;
    final opp = 3 - turn;

    if (count(opp) == 0) {
      winner = turn;
      phase = 2;
      status = 'فاز اللاعب ${name(turn)}!';
      return;
    }

    if (!hasMove(opp)) {
      winner = turn;
      phase = 2;
      status = 'فاز اللاعب ${name(turn)}! الخصم لا يملك حركة متاحة.';
      return;
    }

    status = 'دور اللاعب ${name(turn)}: حرّك حجرًا';
  }

  void restart() {
    setState(() {
      starter = 3 - starter;
      turn = starter;
      board = List.filled(24, 0);
      redPlaced = 0;
      whitePlaced = 0;
      phase = 0;
      selected = null;
      pendingRemoval = null;
      firstMill = null;
      winner = null;
      status = 'مباراة جديدة. يبدأ اللاعب ${name(turn)}.';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff101827),
      appBar: AppBar(
        title: const Text(
          'ثبّت • BAHMAD THABET',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xff17243a),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _player('الأحمر', count(1), 1),
                _player('الأبيض', count(2), 2),
              ],
            ),
            Container(
              margin: const EdgeInsets.all(14),
              padding: const EdgeInsets.all(12),
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xff24334a),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xffd6a84f)),
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

                          if (dist < s * .085) tapNode(best);
                        },
                        child: Stack(
                          children: [
                            CustomPaint(
                              size: Size(s, s),
                              painter: _BoardPainter(points, edges),
                            ),
                            for (int i = 0; i < 24; i++)
                              Positioned(
                                left: points[i].dx * s - s * .028,
                                top: points[i].dy * s - s * .028,
                                child: Container(
                                  width: s * .056,
                                  height: s * .056,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: board[i] == 1
                                        ? const Color(0xffe53935)
                                        : board[i] == 2
                                            ? Colors.white
                                            : const Color(0xffd6a84f),
                                    border: Border.all(
                                      color: selected == i
                                          ? Colors.cyan
                                          : const Color(0xff17243a),
                                      width: selected == i ? 4 : 2,
                                    ),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Colors.black54,
                                        blurRadius: 5,
                                        offset: Offset(1, 2),
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
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 14),
              child: Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: restart,
                      icon: const Icon(Icons.refresh),
                      label: const Text('مباراة جديدة'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text('قواعد ثبّت'),
                          content: const Text(
                            'ضع 12 حجرًا لكل لاعب. لا إزالة أثناء الرص. '
                            'الثبّت ثلاثة أحجار على خط أفقي أو عمودي. '
                            'تحرّك إلى نقطة فارغة متصلة فقط. '
                            'الفوز بإزالة جميع أحجار الخصم أو بمنعه من الحركة.',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('إغلاق'),
                            ),
                          ],
                        ),
                      ),
                      icon: const Icon(Icons.info_outline),
                      label: const Text('القواعد'),
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
    return Container(
      width: 145,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xff1c2a40),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: p == 1 ? const Color(0xffe53935) : Colors.white70,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: p == 1 ? const Color(0xffe53935) : Colors.white,
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text('الأحجار: $n'),
            ],
          ),
        ],
      ),
    );
  }
}

class _BoardPainter extends CustomPainter {
  final List<Offset> p;
  final List<List<int>> e;

  _BoardPainter(this.p, this.e);

  @override
  void paint(Canvas c, Size s) {
    final r = Offset.zero & s;

    c.drawRRect(
      RRect.fromRectAndRadius(
        r.deflate(3),
        const Radius.circular(22),
      ),
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xff264b42), Color(0xff17352f)],
        ).createShader(r),
    );

    final line = Paint()
      ..color = const Color(0xffe0bd73)
      ..strokeWidth = s.width * .012
      ..strokeCap = StrokeCap.round;

    for (final x in e) {
      c.drawLine(
        Offset(p[x[0]].dx * s.width, p[x[0]].dy * s.height),
        Offset(p[x[1]].dx * s.width, p[x[1]].dy * s.height),
        line,
      );
    }

    c.drawRRect(
      RRect.fromRectAndRadius(
        r.deflate(3),
        const Radius.circular(22),
      ),
      Paint()
        ..color = const Color(0xffa87b38)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4,
    );
  }

  @override
  bool shouldRepaint(covariant _BoardPainter old) => false;
}
