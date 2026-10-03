import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:messenger/controllers/account_controller.dart';
import 'package:messenger/db_models/account.dart';
import 'package:messenger/db_models/group.dart';
import 'package:messenger/pages/widgets/account_image_with_activity.dart';
import 'package:messenger/pages/widgets/group_image_with_activity.dart';
import 'package:messenger/pages/widgets/highlighted_widget.dart';
import 'package:messenger/pages/messages_page/messages_page.dart';
import 'package:messenger/controllers/settings.dart';

final getIt = GetIt.instance;

class GroupBox extends StatefulWidget {
  final Group _group;
  final String _accountName;
  final String _content;
  final int _datetime;
  final List<Account>? _accounts;

  const GroupBox({
    super.key, 
    required this._group,
    required this._accountName,
    required this._content,
    required this._datetime,
    this._accounts,
  });

  @override
  State<GroupBox> createState() => _GroupBoxState();
}

class _GroupBoxState extends State<GroupBox> {
  final kAvatarRadius = 26.0; 

  final _settings = Settings.instance;
  final _accountController = getIt<AccountController>();

  String getMessageDate(int milliseconds) {
    final dateTime = DateTime.fromMillisecondsSinceEpoch(milliseconds);
    final now = DateTime.now();

    var format = '';
    
    if (milliseconds == 0) {
      return '';
    }
    else if (dateTime.day == now.day) {
      format = 'hh:mm aaa';
    }
    else if (DateFormat('w').format(dateTime) == DateFormat('w').format(now)) {
      format = 'EEE';
    }
    else if (dateTime.year == now.year) {
      format = 'MMM d';
    }
    else {
      format = 'MMM d, y';
    }
    return DateFormat(format).format(dateTime);
  }

  String getGroupName() {
    if (widget._group.typeId == 0) {
      return widget._group.name;
    }
    
    return widget._accounts!
      .where((e) => e.id != _accountController.account!.id)
      .map((e) => e.name)
      .join(', ');
  }


  @override
  Widget build(BuildContext context) {
    return HighlightedWidget(
      onTap: () {
        Navigator.of(context).push(
          PageRouteBuilder(
            pageBuilder: (_, _, _) => MessagesPage(group: widget._group),
          )
        );
      },
      child: Container(
        padding: .only(top: 8, bottom: 8),
        child: Row(
          mainAxisAlignment: .spaceBetween,
          children: [
            Expanded(
              child: Row(
                spacing: 8,
                children: [
                  widget._group.typeId == 0
                  ?
                  GroupImageWithActivity(
                    accounts: widget._accounts!, 
                    group: widget._group,
                    size: kAvatarRadius*2,
                  )
                  :
                  AccountImageWithActivity(
                    account: widget._accounts!.where((e) => e.id != _accountController.account!.id).first,
                    radius: kAvatarRadius,
                  ),
                  // AccountImage(
                  //   accountId: widget._accounts!.where((e) => e.id != _accountController.account!.id).first.id, 
                  //   accountName: widget._accounts!.where((e) => e.id != _accountController.account!.id).first.name,
                    
                  // ),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: .center,
                      crossAxisAlignment: .start,
                      children: [
                        Text(
                          getGroupName(),
                          maxLines: 1,
                          overflow: .ellipsis,
                          style: TextStyle(
                            color: _settings.innerColor, 
                            fontFamily: _settings.fontFamily,
                            fontSize: 19,
                          )
                        ),
                        Text(
                          widget._accountName == '' || widget._content == ''
                          ? ''
                          : '${widget._accountName}: ${widget._content}', 
                          maxLines: 1,
                          overflow: .ellipsis,
                          style: TextStyle(
                            color: _settings.middleColor, 
                            fontFamily: _settings.fontFamily,
                            fontSize: 15,
                          )
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Text(
              getMessageDate(widget._datetime),
              style: TextStyle(
                color: _settings.middleColor, 
                fontFamily: _settings.fontFamily,
                fontSize: 14,
              )
            )
          ],
        ),
      )
    );
  }
}