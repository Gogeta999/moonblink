import 'dart:ui';

import 'package:flutter/material.dart';
import 'dart:math';

import 'package:random_string/random_string.dart';

class MBCaptcha extends StatefulWidget {
  MBCaptcha({@required this.something});
  final int something;
  @override
  _MBCaptchaState createState() => _MBCaptchaState();
}

class _MBCaptchaState extends State<MBCaptcha> {
  //For RandomOutPut
  var elementList = [
    '0',
    '1',
    '2',
    '3',
    '4',
    '5',
    '6',
    '7',
    '8',
    '9',
    'a',
    'b',
    'c',
    'd',
    'e',
    'f',
    'g',
    'h',
    'i',
    'j',
    'k',
    'l',
    'm',
    'n',
    'o',
    'p',
    'q',
    'r',
    's',
    't',
    'u',
    'v',
    'w',
    'x',
    'y',
    'z',
    'A',
    'B',
    'C',
    'D',
    'E',
    'F',
    'G',
    'H',
    'I',
    'J',
    'K',
    'L',
    'M',
    'N',
    'O',
    'P',
    'Q',
    'R',
    'S',
    'T',
    'U',
    'V',
    'W',
    'X',
    'Y',
    'Z'
  ];
  final _random = Random();
  var _randomValueList = [];
  //For Random Paint
  int _textLength;
  double _width;
  double _height;
  List<Offset> _lineOffsets = <Offset>[];
  Color _randomColor = RandomColorTheme.randomColor();
  @override
  void initState() {
    captchOutPut();
    super.initState();
  }

  void generateRandomValue() {
    _randomValueList = new List.generate(
        4, (_) => elementList[_random.nextInt(elementList.length)]);
  }

  void captchOutPut() {
    generateRandomValue();
    _textLength = 4;
    _width = _textLength.toDouble() * 32;
    _height = 50;
    _randLines();
  }

  //Rotate substring in List Effect
  Container _subBox(index) {
    return Container(
      padding: EdgeInsets.only(
          left: 2, right: 2, top: randomBetween(0, 14).toDouble()),
      child: Transform.rotate(
        angle: pi / randomBetween(3, 30) * randomBetween(0, 1),
        child: Text(_randomValueList[index],
            style: TextStyle(
                fontSize: randomBetween(16, 18).toDouble(),
                color: RandomColorTheme.randomColor())),
      ),
    );
  }

  //Draw Random Line
  void _randLines() {
    _lineOffsets.clear();
    //I here control how many line
    for (var i = 0; i < 78; i++) {
      double fromYend = _height + 3;
      double fromX = randomBetween(10, 20).toDouble();
      double fromY = randomBetween(3, fromYend.toInt()).toDouble();
      Offset from = Offset(fromX, fromY);
      _lineOffsets.add(from);
      double endYend = _height + 3;
      double endX = randomBetween(60, _width.toInt() - 10).toDouble();
      double endY = randomBetween(3, endYend.toInt()).toDouble();
      Offset end = Offset(endX, endY);
      _lineOffsets.add(end);
    }
    _randomColor = RandomColorTheme.randomColor();
  }

  Container _annoyLine() {
    return Container(
      width: _width,
      height: _height,
      child: CustomPaint(
        painter: CodePaint(_lineOffsets, _randomColor, _randomValueList.join()),
        foregroundPainter:
            CodePaint(_lineOffsets, _randomColor, _randomValueList.join()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          captchOutPut();
        });
      },
      child: Container(
        color: Colors.grey[200],
        width: _width,
        height: _height,
        child: Stack(
          alignment: Alignment.center,
          children: [
            _annoyLine(),
            _annoyLine(),
            // _annoyLine(),
            // _annoyLine(),
            Container(
              width: _width,
              height: _height,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_randomValueList.length, (int index) {
                  return _subBox(index);
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RandomColorTheme {
  static Color randomColor() {
    return Color.fromARGB(255, Random().nextInt(256) + 0,
        Random().nextInt(256) + 0, Random().nextInt(256) + 0);
  }
}

class CodePaint extends CustomPainter {
  // PassData To Paint
  final List<Offset> lineOffsets;
  final Color ranColor;
  final String captchaCode;

  CodePaint(this.lineOffsets, this.ranColor, this.captchaCode);

  @override
  void paint(Canvas canvas, Size size) {
    debugPrint(canvas.runtimeType.toString());
    canvas.save();
    Paint _paint = Paint()
      ..color = ranColor
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true
      ..blendMode = BlendMode.exclusion
      ..style = PaintingStyle.fill
      ..colorFilter = ColorFilter.mode(ranColor, BlendMode.exclusion)
      ..maskFilter = MaskFilter.blur(BlurStyle.inner, 1.0)
      ..filterQuality = FilterQuality.high
      ..strokeWidth = 1;

    final pointMode = PointMode.lines;
    canvas.drawPoints(pointMode, lineOffsets, _paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(CodePaint oldDelegate) {
    return oldDelegate.captchaCode != this.captchaCode;
  }
}
