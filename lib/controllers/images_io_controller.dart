import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:image/image.dart' as img;
import 'package:messenger/controllers/account_controller.dart';
import 'package:messenger/controllers/encryption_controller.dart';
import 'package:messenger/services/account_image_metadata_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<String?> pickLocalImage() async {
  final result = await FilePicker.pickFile(type: FileType.image);

  if (result != null && result.path != null) {
    return result.path;
  }
  
  return null;
}

class ImagesIOController {
  final AccountController _accountController;
  final EncryptionController _encryptionController;
  final AccountImageMetadataService _accountImageMetadataService;
  final _supabase = Supabase.instance.client;   

  final kTempDir = '${Directory.systemTemp.path}/images';
  final kEncryptedDir = '${Directory.systemTemp.path}/encrypted_images';

  ImagesIOController(this._accountController, this._encryptionController, this._accountImageMetadataService) {
    Directory(kTempDir).createSync();
    Directory(kEncryptedDir).createSync();
  }

  List<int> readBytes(String filePath) {
    final baseFile = File(filePath);
    final bytes = baseFile.readAsBytesSync();   
    final originalImage = img.decodeImage(bytes);

    if (originalImage == null) throw Exception("Failed to decode image");  

    final resizedImage = img.copyResize(originalImage, width: 400, height: 400);
    final compressedBytes = img.encodeJpg(resizedImage, quality: 85);

    return compressedBytes;
  }

  Future<File?> saveImage(int accountId, int timestamp) async {
    final filePath = await pickLocalImage();
    if (filePath == null) return null;
    final bytes = readBytes(filePath);

    final dir = Directory('$kTempDir/$accountId');
    if (dir.existsSync()) {
      dir.deleteSync(recursive: true);
    }
    dir.createSync();

    final file = File('$kTempDir/$accountId/$timestamp.png');
    await file.writeAsBytes(bytes);    
    
    return file;
  } 

  Future<File> saveEncryptedImage(int accountId, int timestamp) async {
    final bytes = readBytes('$kTempDir/$accountId/$timestamp.png');
    final encryptedBytes = _encryptionController.encryptBytes(bytes);

    final dir = Directory('$kEncryptedDir/$accountId');
    if (dir.existsSync()) {
      dir.deleteSync(recursive: true);
    }
    dir.createSync();

    final encryptedFile = File('$kEncryptedDir/$accountId/$timestamp.png');
    await encryptedFile.writeAsBytes(encryptedBytes);  

    return encryptedFile;
  }

  Future<void> uploadAccountImage(int accountId, int timestamp) async {
    final inBucketDirPath = '$accountId';
    final inBucketFilePath = '$inBucketDirPath/$timestamp';

    final files = await _supabase.storage
      .from('images')
      .list(path: inBucketDirPath);

    if (files.isNotEmpty) {
      final filePaths = files.map((file) => '$inBucketDirPath/${file.name}').toList();

      await _supabase.storage
        .from('images')
        .remove(filePaths);   
    }

    await _supabase.storage
      .from('images') 
      .upload(inBucketFilePath, File('$kEncryptedDir/$accountId/$timestamp.png'));
    
    _accountImageMetadataService.update(accountId);
  }

  Future<File?> downloadImage(int accountId) async {
    final inBucketDirPath = accountId.toString();

    final files = await _supabase.storage
      .from('images') 
      .list(path: inBucketDirPath);
    
    if (files.isEmpty) return null;

    final inBucketFilePath = '$inBucketDirPath/${files.first.name}';

    final fileBytes = await _supabase.storage
      .from('images') 
      .download(inBucketFilePath);

    final decryptedBytes = _encryptionController.decryptBytes(fileBytes);

    final dir = Directory('$kTempDir/$inBucketDirPath');
    if (dir.existsSync()) {
      dir.deleteSync(recursive: true);
    }
    dir.createSync();

    final restoredFile = File('$kTempDir/$inBucketFilePath.png');
    await restoredFile.writeAsBytes(decryptedBytes);
    return restoredFile;
  }

  Future<File?> downloadCurrentAccountImage() async {
    return downloadImage(_accountController.account!.id);
  }

  String? getCurrentAccountImagePath() {
    return getAccountImagePath(_accountController.account!.id);
  }

  String? getAccountImagePath(int accountId) {
    final inBucketDirPath = accountId.toString();
    final dir = Directory('$kTempDir/$inBucketDirPath');
    if (!dir.existsSync()) return null;
    final filesInDir = dir.listSync();
    return filesInDir.isEmpty ? null : filesInDir.first.path;
  }
}