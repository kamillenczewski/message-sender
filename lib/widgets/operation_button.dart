import 'dart:async';

import 'package:flutter/material.dart';
import 'package:messenger/controllers/settings.dart';

class OperationButton extends StatefulWidget {
  final String _title;
  final bool _reversedColors;
  final double _width;
  final void Function() _onTap;

  const OperationButton({
    super.key,
    required this._title, 
    required this._onTap,
    this._reversedColors = true,
    this._width = 250,
  });

  @override
  State<OperationButton> createState() => _OperationButtonState();
}

class _OperationButtonState extends State<OperationButton> {
  final settings = Settings.instance;
  
  bool _isClicked = false;
  Timer? _timer;

  Color getContainerColor() {
    Color color = widget._reversedColors ? settings.innerColor : settings.outerColor;

    if (_isClicked) {
      color = color.withAlpha(127);
    }
    
    return color;
  }

  @override
  void dispose() {
    super.dispose();
    _timer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget._width,
      child: Row(
        mainAxisSize: .max,
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {                
                if (!_isClicked) {
                  widget._onTap();
                }      

                setState(() {
                  _isClicked = true;
                });

                _timer = Timer(
                  const Duration(seconds: 2), 
                  () {
                    setState(() {
                      _isClicked = false; 
                    });
                  }
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  color: getContainerColor(),
                  borderRadius: .circular(8),
                  border: .all(color: widget._reversedColors ? settings.outerColor : settings.innerColor)
                ),
                padding: .all(8),
                child: Row(
                  mainAxisAlignment: .center,
                  children: [
                    Text(
                      widget._title,
                      textAlign: .center,
                      style: TextStyle(
                        color: widget._reversedColors ? settings.outerColor : settings.innerColor, 
                        fontFamily: settings.fontFamily,
                        fontSize: 15
                      )
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}