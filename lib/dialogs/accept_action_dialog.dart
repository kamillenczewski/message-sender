import 'package:flutter/material.dart';
import 'package:messenger/controllers/settings.dart';
import 'package:messenger/widgets/operation_button.dart';

enum ButtonsDirection {vertical, horizontal}

void showAcceptActionDialog(BuildContext context, {
  required void Function() onAccept,
  required String text,
  double buttonWidth = 250.0,
  ButtonsDirection direction = .vertical
}) {
  final settings = Settings.instance;

  List<Widget> getChildren(BuildContext context) {
    return [
      OperationButton(
        title: "Accept",
        onTap: () {
          onAccept();
          // Navigator.of(context).pop();
        }, 
        width: buttonWidth,
      ),
      OperationButton(
        title: "Cancel",
        onTap: () => Navigator.of(context).pop(), 
        reversedColors: false,
        width: buttonWidth,
      ),
    ];
  }

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.0),
            color: settings.outerColor,
            border: BoxBorder.all(color: settings.innerColor)
          ),
          padding: const EdgeInsets.all(15.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: 12,
            children: [
              Text(
                text, 
                textAlign: .center,
                style: TextStyle(
                  fontFamily: settings.fontFamily, 
                  fontSize: 20, 
                  color: settings.innerColor
                ),
              ),
              direction == .vertical
              ? Column(
                mainAxisSize: MainAxisSize.min,
                spacing: 5,
                children: getChildren(context)
              )
              : Row(
                mainAxisSize: MainAxisSize.min,
                spacing: 5,
                children: getChildren(context).reversed.toList()
              )
            ],
          ),
        )
      );
    },
  );
}