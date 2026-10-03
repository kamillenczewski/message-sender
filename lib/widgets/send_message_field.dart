import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:messenger/controllers/settings.dart';

class SendMessageField extends StatefulWidget {
  final void Function(String) _onSubmitted;

  const SendMessageField({
    super.key,
    required this._onSubmitted,
  });

  @override
  State<SendMessageField> createState() => _SendMessageFieldState();
}

class _SendMessageFieldState extends State<SendMessageField> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final _settings = Settings.instance;

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 10,
      children: [
        Expanded(
          child: Container(
            padding: .only(right: 12, left: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(12)),
              border: BoxBorder.all(width: 1, color: _settings.innerColor),
            ),
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              onSubmitted: (value) {
                if (Platform.isAndroid) {
                  _controller.text += '\n';
                }
                else if (Platform.isWindows) {
                  if (HardwareKeyboard.instance.isShiftPressed) {
                    _controller.text += '\n';
                  }
                  else {
                    widget._onSubmitted(_controller.text);
                    _controller.clear();
                  }
                }
                _focusNode.requestFocus();
              },
              onTapOutside: (event) {
                _focusNode.unfocus();
              },
              keyboardType: TextInputType.multiline,
              maxLines: null,
              autofocus: true,
              textInputAction: TextInputAction.send,
              cursorColor: _settings.innerColor,
              style: TextStyle(
                overflow: .ellipsis,
                color: _settings.innerColor, 
              ),
              decoration: InputDecoration(
                hintText: '',
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
            ),
          ),
        ),
        GestureDetector(
          onTap: () {
            widget._onSubmitted(_controller.text);
            _controller.clear();
            _focusNode.requestFocus();
          },
          child: Icon(
            Icons.send, 
            color: _settings.innerColor, 
            size: 25
          ),
        )
      ],
    );
  }
}