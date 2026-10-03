// import 'package:flutter_soloud/flutter_soloud.dart';
// import 'package:get_it/get_it.dart';
// import 'package:messenger/controllers/audio_controller.dart';
// import 'package:messenger/db_models/group_message.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';

// final getIt = GetIt.instance;

// class NotificationSoundService {
//   final AudioController _audioController;
//   final SupabaseClient _supabase = Supabase.instance.client;
//   RealtimeChannel? _channel;

//   NotificationSoundService(this._audioController) {
//     _channel = _supabase
//       .channel('public:${GroupMessage.kTable}:$hashCode')
//       .onPostgresChanges(
//         event: PostgresChangeEvent.all,
//         schema: 'public',
//         table: GroupMessage.kTable,
//         callback: (payload) {
//           payload.newRecord.
//           if (payload.eventType == PostgresChangeEvent.insert) {
//             _playNotificationSound();
//           }
//         },
//       )
//       .subscribe();
//   }

//   void _playNotificationSound() async {
//     SoLoud.instance.play(_audioController.kNotification!, volume: 0.05);
//   }
// }