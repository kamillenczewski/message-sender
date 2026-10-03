import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:messenger/controllers/settings.dart';
import 'package:messenger/widgets/operation_button.dart';
import 'package:messenger/widgets/text_field_with_counter.dart';

final getIt = GetIt.instance;

void showChangeGroupNameForm(BuildContext context, {
  required String defaultText,
  required void Function(String) onSubmitted,
}) {
  final title = 'New group name';
  final label = 'Name';
  final textController = TextEditingController(text: defaultText);
  final settings = Settings.instance;

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        child: SizedBox(
          width: 300,
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
              children: <Widget>[
                Text(
                  title, 
                  textAlign: .center,
                  style: TextStyle(
                    fontFamily: settings.fontFamily, 
                    fontSize: 25, 
                    color: settings.innerColor
                  ),
                ),
                Container(
                  padding: .only(right: 8, left: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                    border: BoxBorder.all(width: 1, color: settings.innerColor),
                  ),
                  child: TextFieldWithCounter(
                    maxLength: 20,
                    defaultText: defaultText,
                    label: label, 
                    controller: textController
                  )
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  spacing: 5,
                  children: [
                    OperationButton(
                      onTap: () => Navigator.of(context).pop(), 
                      title: "Cancel",
                      reversedColors: false,
                      width: 100
                    ),
                    OperationButton(
                      onTap: () {
                        onSubmitted(textController.text);
                        Navigator.of(context).pop();
                      },
                      title: "Submit",
                      width: 100
                    ),
                  ],
                )
              ]
            ),
          ),
        )
      );
    },
  );
}