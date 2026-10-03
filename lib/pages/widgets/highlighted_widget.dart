import 'package:flutter/material.dart';
import 'package:messenger/controllers/settings.dart';

class HighlightedWidget extends StatefulWidget {
  final Widget _child;
  final void Function()? _onTap;
  final double _borderRadius;

  const HighlightedWidget({
    super.key, 
    this._onTap,
    this._borderRadius = 0,
    required this._child,
  });

  @override
  State<HighlightedWidget> createState() => _HighlightedWidgetState();
}

class _HighlightedWidgetState extends State<HighlightedWidget> {
  bool _isHovered = false;
  bool _isPressed = false;

  final kActiveGroupColor = Color.fromARGB(255, 69, 68, 68);

  final _settings = Settings.instance;

  @override
  Widget build(BuildContext context) {
    Color currentColor = _settings.outerColor;

    if (_isPressed) {
      currentColor = kActiveGroupColor;
    } else if (_isHovered) {
      currentColor = kActiveGroupColor;
    }

    return Theme(
      data: ThemeData(
        primaryColor: currentColor
      ),
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() {
          _isHovered = false;
          _isPressed = false;
        }),
        child: GestureDetector(
          onTapDown: (_) => setState(() => _isPressed = true),
          onTapUp: (_) => setState(() => _isPressed = false),
          onTapCancel: () => setState(() => _isPressed = false),
          onTap: widget._onTap,
          child: AnimatedContainer(
            decoration: BoxDecoration(
              borderRadius: .circular(widget._borderRadius),
              color: currentColor,
            ),
            duration: Duration(milliseconds: 200),
            padding: .only(left: 20, right: 20),
            alignment: Alignment.center,
            child: widget._child
          ),
        ),
      ),
    );
  }
}