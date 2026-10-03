import 'package:flutter/material.dart';
import 'package:messenger/controllers/settings.dart';
import 'package:messenger/widgets/operation_button.dart';

void showInformationDialog(
  BuildContext context,
  String text,
) {
  final settings = Settings.instance;

  showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        child: Container(
          width: 300,
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
                  color: settings.innerColor,
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                spacing: 5,
                children: [
                  OperationButton(
                    onTap: () => Navigator.of(context).pop(),
                    title: "Ok",
                  )
                ],
              )
            ],
          ),
        )
      );
    },
  );
}