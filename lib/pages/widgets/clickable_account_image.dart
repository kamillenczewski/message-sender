import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:get_it/get_it.dart';
import 'package:messenger/controllers/account_controller.dart';
import 'package:messenger/pages/messages_page/messages_page.dart';
import 'package:messenger/services/get_conversation_service.dart';

final getIt = GetIt.instance;

class ClickableAccountImage extends HookWidget {
  final int _accountId;
  final Widget _widget;

  final _accountController = getIt<AccountController>();
  final _getConversationService = getIt<GetConversationService>();
  

  ClickableAccountImage({
    super.key,
    required this._accountId,
    required this._widget,
  });

  @override
  Widget build(BuildContext context) {
    useMemoized(() {});
    final isClicked = useState<bool>(false);
    final timer = useState<Timer?>(null);

    useEffect(() {
      return () {
        if (timer.value == null) return;
        timer.value!.cancel();
      };
    }, []);

    return GestureDetector(
      onTap: () async {
        if (_accountId == _accountController.account!.id || isClicked.value) return;

        isClicked.value = true;

        final group = await _getConversationService.get(_accountId);

        await Navigator.of(context).push(
          PageRouteBuilder(
            pageBuilder: (_, _, _) => MessagesPage(group: group),
          )
        );

        timer.value = Timer(
          Duration(seconds: 2),
          () => isClicked.value = false
        );
      },
      child: _widget
    );
  }
}