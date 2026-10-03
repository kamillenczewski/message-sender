import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:get_it/get_it.dart';
import 'package:messenger/controllers/images_controller.dart';
import 'package:messenger/controllers/settings.dart';

final getIt = GetIt.instance;

class AccountImage extends HookWidget {
  final int _accountId;
  final String _accountName;
  final double _radius;
  final bool _isTooltipVisible;
  final double _borderWidth;

  final _settings = Settings.instance;
  final _imagesController = getIt<ImagesController>();

  AccountImage({
    super.key, 
    required this._accountId,
    required this._accountName,
    this._radius = 32.0,
    this._isTooltipVisible = true,
    this._borderWidth = 0.0
  });

  @override
  Widget build(BuildContext context) {
    final file = useState<File?>(null);

    Future<void> fetchData() async {
      file.value = await _imagesController.getFile(_accountId);
    }

    Future<void> onImagesControllerChange() async {
      await fetchData();
    }

    useEffect(() {
      fetchData();
      _imagesController.addListener(onImagesControllerChange);
      return () => _imagesController.removeListener(onImagesControllerChange);
    }, [_accountId]);

    final widget = file.value == null
    ?
    Container(
      width: _radius*2,
      height: _radius*2,
      alignment: .center,
      decoration: BoxDecoration(
        color: Colors.blue,
        borderRadius: .circular(_radius),
        border: .all(width: _borderWidth, color: Theme.of(context).primaryColor)
      ),
      child: Text(
        _accountName[0], 
        style: TextStyle(
          color: _settings.innerColor,
          fontFamily: _settings.fontFamily,
          fontSize: _radius / 1.3,
        )
      ),
    )
    :
    CircleAvatar(
      radius: _radius,
      backgroundColor: Theme.of(context).primaryColor,
      child: CircleAvatar(
        radius: _radius - _borderWidth,
        backgroundImage: FileImage(file.value!),
      ),
    );

    if (_isTooltipVisible) {
      return Tooltip(
        message: _accountName,
        child: widget
      );
    }
    else {
      return widget;
    }   
  }
}