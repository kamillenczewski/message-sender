import 'package:flutter/material.dart';
import 'package:messenger/controllers/settings.dart';

class TextFieldWithCounter extends StatefulWidget {
  final int _maxLength;
  final String _defaultText;
  final String _label;
  final TextEditingController _controller;

  const TextFieldWithCounter({
    super.key,
    required this._maxLength,
    required this._defaultText,
    required this._label,
    required this._controller,
  });

  @override
  State<TextFieldWithCounter> createState() => _TextFieldWithCounterState();
}

class _TextFieldWithCounterState extends State<TextFieldWithCounter> {
  final _settings = Settings.instance;
  int _currentLength = 0;

  @override
  void initState() {
    super.initState();

    widget._controller.addListener(() {
      setState(() {
        _currentLength = widget._controller.text.length;
      });
    });
  
    widget._controller.text = widget._defaultText;
    _currentLength = widget._defaultText.length;
  }

  @override
  void dispose() {
    widget._controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      maxLength: widget._maxLength,
      buildCounter: (context, {required currentLength, required maxLength, required isFocused}) => null,
      cursorColor: _settings.innerColor,
      keyboardType: TextInputType.multiline,
      maxLines: null,
      controller: widget._controller,
      style: TextStyle(
        color: _settings.innerColor, 
        fontFamily: _settings.fontFamily,
        fontSize: 17
      ),
      decoration: InputDecoration(
        suffix: Column(
          mainAxisAlignment: .center,
          children: [
            Text(
              '$_currentLength/${widget._maxLength}',
              style: TextStyle(
                fontFamily: _settings.fontFamily,
                color: _settings.middleColor,
                fontSize: 14
              ),
            ),
          ],
        ),
        suffixText: null,
        hintText: widget._label,
        hintStyle: TextStyle(
          fontFamily: _settings.fontFamily, 
          color: _settings.middleColor,
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.transparent),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.transparent),
        ),
        floatingLabelBehavior: .never,
        floatingLabelStyle: TextStyle(fontSize: 0)
      ),
    );
  }
}