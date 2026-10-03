import 'package:flutter/material.dart';
import 'package:messenger/controllers/settings.dart';

PreferredSize createCustomAppBar(BuildContext context, {
  Widget? child
}) {
  final settings = Settings.instance;

  return PreferredSize(
    preferredSize: Size.fromHeight(50),
    child: Container(
      color: settings.outerColor,
      padding: .only(
        left: 20, 
        right: 20, 
        top: MediaQuery.of(context).padding.top,
        bottom: MediaQuery.of(context).padding.bottom
      ),
      child: child
    ),
  );
}