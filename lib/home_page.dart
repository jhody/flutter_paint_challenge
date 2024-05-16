import 'package:flutter/material.dart';

import 'custom_paint/color_selector_paint.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Offset _offset = const Offset(0, radius);

  final GlobalKey _painterKey = GlobalKey();

  void _handlePanUpdate(DragUpdateDetails details) {
    final offset = Helper.selectorOffset(details.localPosition);

    setState(() {
      if (Helper.canPerformSelectorMotion(offset.dx, offset.dy, 0, 0)) {
        _offset = offset;
      } else {}
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SizedBox(
          width: 300,
          height: 300,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onPanUpdate: _handlePanUpdate,
            child: Center(
              child: CustomPaint(
                key: _painterKey,
                painter: ColorSelectorPaint(
                  currentOffset: _offset,
                  currentlySelectedColor: Helper.offsetColor(colors, _offset),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
