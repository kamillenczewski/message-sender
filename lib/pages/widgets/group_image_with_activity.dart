import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:get_it/get_it.dart';
import 'package:messenger/db_models/account.dart';
import 'package:messenger/db_models/account_activity.dart';
import 'package:messenger/db_models/group.dart';
import 'package:messenger/pages/widgets/group_image.dart';
import 'package:messenger/services/is_group_active_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final getIt = GetIt.instance;

class GroupImageWithActivity extends HookWidget {
  final List<Account> _accounts;
  final Group _group;
  final double _size;

  final kActivityCircleRadius = 10.0;

  final _isGroupActiveService = getIt<IsGroupActiveService>();
  final _supabase = Supabase.instance.client;

  GroupImageWithActivity({
    required this._accounts,
    required this._group,
    required this._size,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = useState(false);

    Future<void> fetchData() async {
      isActive.value = await _isGroupActiveService.execute(_group.id);
    }

    useEffect(() {
      fetchData();

      final channel = _supabase
        .channel('public:${AccountActivity.kTable}:$hashCode')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: AccountActivity.kTable,
          callback: (payload) => fetchData(),
        )
        .subscribe();

        return () => _supabase.removeChannel(channel);
    }, []);

    return Stack(
      children: [
        GroupImage(
          accounts: _accounts,
          groupName: _group.name,
          size: _size,
        ),
        isActive.value
        ?
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            width: kActivityCircleRadius*2,
            height: kActivityCircleRadius*2,
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: .circular(kActivityCircleRadius),
              border: .all(color: Theme.of(context).primaryColor, width: 3),
            ),
          ),
        )
        :
        SizedBox.shrink()
      ],
    );
  }
}