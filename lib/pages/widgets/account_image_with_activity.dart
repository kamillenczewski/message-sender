import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:get_it/get_it.dart';
import 'package:messenger/controllers/settings.dart';
import 'package:messenger/db_models/account.dart';
import 'package:messenger/db_models/account_activity.dart';
import 'package:messenger/pages/widgets/account_image.dart';
import 'package:messenger/services/seconds_since_last_activity_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final getIt = GetIt.instance;

class AccountImageWithActivity extends HookWidget {
  final Account _account;
  final double _radius;

  final _secondsSinceLastActivityService = getIt<SecondsSinceLastActivityService>();
  final _supabase = Supabase.instance.client;
  final _settings = Settings.instance;

  final kActivityCircleRadiusWhenActive = 10.0;
  final kActivityCircleRadiusWhenMinutes = 12.0;

  AccountImageWithActivity({
    required this._account,
    required this._radius,
    super.key,
  });

  Widget createActivityBox(BuildContext context, int seconds) {
    if (seconds >= 60 && seconds < 60*60) {
      return Positioned(
        bottom: -2,
        right: -2,
        child: Container(
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 0, 70, 1),
            borderRadius: .circular(kActivityCircleRadiusWhenMinutes),
            border: .all(color: Theme.of(context).primaryColor, width: 3),
          ),
          padding: .all(2),
          child: FittedBox(
            child: Text(
              '${(seconds / 60).round()}m', 
              textAlign: .center,
              style: TextStyle(
                color: const Color.fromARGB(255, 1, 255, 9),
                fontFamily: _settings.fontFamily,
                fontSize: 7
              ),
            ),
          ),
        ),
      );
    }
    else if (seconds < 60) {
      return Positioned(
        bottom: 0,
        right: 0,
        child: Container(
          width: kActivityCircleRadiusWhenActive*2,
          height: kActivityCircleRadiusWhenActive*2,
          decoration: BoxDecoration(
            color: Colors.green,
            borderRadius: .circular(kActivityCircleRadiusWhenActive),
            border: .all(color: Theme.of(context).primaryColor, width: 3),
          ),
        ),
      );
    }
    else {
      return SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    final secondsSinceLastActivity = useState(AccountActivity.kMaxDelayInSeconds + 1);

    Future<void> fetchData() async {
      secondsSinceLastActivity.value = await _secondsSinceLastActivityService.get(_account.id);
    }

    useEffect(() {
      fetchData();

      final channel = _supabase
        .channel('public:${AccountActivity.kTable}:$hashCode')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: AccountActivity.kTable,
          callback: (payload) {
            if (
              (payload.eventType == .insert || payload.eventType == .update) && 
              payload.newRecord[AccountActivity.kAccountId] == _account.id
            ) {
              fetchData();
            }
          },
        )
        .subscribe();

        return () => _supabase.removeChannel(channel);
    }, []);

    return Stack(
      children: [
        AccountImage(
          accountId: _account.id,
          accountName: _account.name,
          radius: _radius,
        ),
        createActivityBox(context, secondsSinceLastActivity.value)
      ],
    );
  }
}