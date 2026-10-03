import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:messenger/controllers/account_controller.dart';
import 'package:messenger/db_models/account.dart';
import 'package:messenger/db_models/account_activity.dart';
import 'package:messenger/pages/widgets/account_image.dart';
import 'package:messenger/pages/widgets/clickable_account_image.dart';
import 'package:messenger/services/account_activities_table_service.dart';
import 'package:messenger/controllers/settings.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final getIt = GetIt.instance;

class ActivityBar extends HookWidget {
  ActivityBar({super.key});

  final _accountActivitiesTableService = getIt<AccountActivitiesTableService>();
  final _accountController = getIt<AccountController>();
  final _settings = Settings.instance;
  final _supabase = Supabase.instance.client;

  final kAvatarRadius = 40.0;
  final kActivityCircleRadius = 10.0;

  @override
  Widget build(BuildContext context) {
    useMemoized(() {});
    final isLoading = useState(true);
    final activeAccounts = useState<List<Account>>([]);

    void fetchData() async {
      activeAccounts.value = await _accountActivitiesTableService.getActiveAccounts(_accountController.account!);
    }

    useEffect(() {
      isLoading.value = true;

      fetchData();

      final channel = _supabase
        .channel('public:${AccountActivity.kTable}')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: AccountActivity.kTable,
          callback: (payload) => fetchData(),
        )
        .subscribe();
      
      isLoading.value = false;

      return () => _supabase.removeChannel(channel);
    }, const []);

    if (isLoading.value) {
      return Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 100, maxHeight: 100),
          child: CircularProgressIndicator()
        ),
      );
    }

    if (activeAccounts.value.isEmpty) {
      return SizedBox.shrink();
    }

    return Container(
      padding: .only(right: 20, left: 20),
      child: SizedBox(
        height: kAvatarRadius*2,
        child: ListView.builder(
          scrollDirection: .horizontal,
          itemCount: activeAccounts.value.length,
          itemBuilder: (context, index) {
            return Row(
              children: [
                Stack(
                  children: [
                    ClickableAccountImage(
                      accountId: activeAccounts.value[index].id,
                      widget: AccountImage(
                        accountId: activeAccounts.value[index].id, 
                        accountName: activeAccounts.value[index].name
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: kActivityCircleRadius*2,
                        height: kActivityCircleRadius*2,
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: .circular(kActivityCircleRadius),
                          border: .all(color: _settings.outerColor, width: 3),
                        ),
                      ),
                    )
                  ],
                ),
                SizedBox(width: 8)
              ],
            );
          }
        ),
      ),
    );
  }
}