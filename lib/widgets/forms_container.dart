import 'package:flutter/material.dart';
import 'package:messenger/controllers/settings.dart';

class FormsContainer extends StatefulWidget {
  final String _title;
  final List<Widget> _textFields;

  const FormsContainer({
    super.key,
    required this._title,
    required this._textFields,
  });

  @override
  State<FormsContainer> createState() => _FormsContainerState();
}

class _FormsContainerState extends State<FormsContainer> {
  final settings = Settings.instance;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: 12,
      children: <Widget>[
        Text(
          widget._title, 
          style: TextStyle(
            fontFamily: settings.fontFamily, 
            fontSize: 25, 
            color: settings.innerColor
          ),
        )
      ] + 
      List<SizedBox>.generate(
        widget._textFields.length, (index) =>
          SizedBox(
            width: 300,
            child: widget._textFields[index]
          )
      )
    );
  }
}