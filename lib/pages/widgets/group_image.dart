import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:get_it/get_it.dart';
import 'package:messenger/db_models/account.dart';
import 'package:messenger/pages/widgets/account_image.dart';

final getIt = GetIt.instance;

class GroupImage extends HookWidget {
  final List<Account> _accounts;
  final String _groupName;
  final double _size;

  double get _innerSize => _size*0.72;
  double get _innerRadius => _innerSize / 2;

  final kBorderWidth = 3.0;

  const GroupImage({
    super.key, 
    required this._accounts,
    required this._groupName,
    required this._size,
  });

  @override
  Widget build(BuildContext context) {
    useMemoized(() {});

    return Tooltip(
      message: _groupName,
      child: 
      _accounts.length >= 2 && _groupName.isNotEmpty
      ?
      SizedBox(
        width: _size,
        height: _size,
        child: Stack(
          children: [
            Positioned(
              top: 0,
              right: 0,
              child: AccountImage(
                accountId: _accounts.reversed.first.id, 
                accountName: _accounts.reversed.first.name,
                radius: _innerRadius - kBorderWidth,
                isTooltipVisible: false,
              )
            ),
            Positioned(
              bottom: 0,
              left: 0,
              child: AccountImage(
                accountId: _accounts.reversed.elementAt(1).id, 
                accountName: _accounts.reversed.elementAt(1).name,
                radius: _innerRadius,
                isTooltipVisible: false,
                borderWidth: kBorderWidth,
              )
            ),
          ],
        ),
      )
      :
      SizedBox(width: _size, height: _size)
    );
  }
}