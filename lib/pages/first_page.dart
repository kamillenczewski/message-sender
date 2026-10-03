import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:get_it/get_it.dart';
import 'package:messenger/controllers/session_controller.dart';
import 'package:messenger/pages/groups_page/main_page.dart';
import 'package:messenger/pages/login_or_register_page.dart';
import 'package:messenger/pages/widgets/custom_app_bar.dart';

final getIt = GetIt.instance;

class FirstPage extends HookWidget {
  const FirstPage({super.key});

  @override
  Widget build(BuildContext context) {
    final initPage = useState<Widget>(Container());

    Future<void> fetchSession() async {
      if (await GetIt.instance<SessionController>().tryLoadSession()) {
        initPage.value = MainPage();
      }
      else {
        initPage.value = LoginOrRegisterPage();
      }

      await Navigator.of(context).push(
        PageRouteBuilder(
          pageBuilder: (_, _, _) => initPage.value,
        )
      );
    }

    useEffect(() {
      fetchSession();
      return null;
    }, []);
    
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: createCustomAppBar(context),
    );
  }
}