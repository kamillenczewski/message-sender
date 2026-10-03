import 'package:flutter_soloud/flutter_soloud.dart';

class AudioController {
  AudioController() {
    init();
  }

  AudioSource? kNotification;

  void init() async {
    kNotification = await SoLoud.instance.loadAsset('assets/notification_sound.wav');
  }
}