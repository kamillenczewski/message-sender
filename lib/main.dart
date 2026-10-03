
import 'package:flutter/material.dart';
import 'package:flutter_soloud/flutter_soloud.dart';
import 'package:get_it/get_it.dart';
import 'package:messenger/controllers/secrets_controller.dart';
import 'package:messenger/pages/choose_users_to_group_page.dart';
import 'package:messenger/pages/first_page.dart';
import 'package:messenger/pages/groups_page/main_page.dart';
import 'package:messenger/pages/login_page.dart';
import 'package:messenger/pages/register_page.dart';
import 'package:messenger/register_services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> initDatabase() async {
  final getIt = GetIt.instance;
  final secrets = getIt<SecretsController>();

  await Supabase.initialize(
    url: await secrets.dbUrl,
    publishableKey: await secrets.dbKey,
  );
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SoLoud.instance.init();
  await registerSecretsController();
  await initDatabase();
  // await registerNotifications();
  registerServices();
  initServices();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Messenger',
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _nestedNavigatorKey = GlobalKey<NavigatorState>();

  final _pages = {
    LoginPage.route: LoginPage(),
    RegisterPage.route: RegisterPage(),
    MainPage.route: MainPage(),
    ChooseUsersToGroupPage.route: ChooseUsersToGroupPage(),
  };

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: _nestedNavigatorKey,
      onGenerateRoute: (routeSettings) {
        final page = _pages[routeSettings.name] ?? FirstPage();

        return PageRouteBuilder(
          pageBuilder: (_, _, _) => page,
        );
      },
    );
  }
}