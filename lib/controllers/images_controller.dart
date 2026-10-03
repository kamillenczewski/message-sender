import 'dart:io';
import 'package:flutter/material.dart';
import 'package:messenger/controllers/images_io_controller.dart';
import 'package:messenger/db_models/account_image_metadata.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ImagesController extends ChangeNotifier {
  final Map<int, File?> _idsAndFiles = {};
  final ImagesIOController _imagesIOController;
  final _supabase = Supabase.instance.client;

  RealtimeChannel? _channel;

  ImagesController(this._imagesIOController) {
    _channel = _supabase
      .channel('public:${AccountImageMetadata.kTable}')
      .onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: AccountImageMetadata.kTable,
        callback: (payload) async {
          if (payload.eventType == PostgresChangeEvent.insert || payload.eventType == PostgresChangeEvent.update) {
            await _fetchData(payload.newRecord[AccountImageMetadata.kAccountId]);
          }
        }
      )
      .subscribe();
  }

  Future<void> _fetchData(int accountId) async {
    _idsAndFiles[accountId] = await _imagesIOController.downloadImage(accountId);
    notifyListeners();
  }

  @override
  void dispose() {
    if (_channel != null) _supabase.removeChannel(_channel!);
    super.dispose();
  }

  Future<void> _addId(int accountId) async {
    if (_idsAndFiles.containsKey(accountId)) return;
    _idsAndFiles[accountId] = await _imagesIOController.downloadImage(accountId);
  }

  Future<void> addId(int accountId) async {
    _addId(accountId);
    notifyListeners();
  }

  void setFile(int accountId, File file) {
    _idsAndFiles[accountId] = file;
    notifyListeners();
  }

  Future<File?> getFile(int accountId) async {
    if (!_idsAndFiles.containsKey(accountId)) await _addId(accountId);
    return _idsAndFiles[accountId];
  } 
}