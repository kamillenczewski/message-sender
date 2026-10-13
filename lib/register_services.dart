import 'package:get_it/get_it.dart';
import 'package:messenger/controllers/account_controller.dart';
import 'package:messenger/controllers/audio_controller.dart';
import 'package:messenger/controllers/encryption_controller.dart';
import 'package:messenger/controllers/images_controller.dart';
import 'package:messenger/controllers/images_io_controller.dart';
// import 'package:messenger/controllers/notifications_controller.dart';
import 'package:messenger/controllers/secrets_controller.dart';
import 'package:messenger/controllers/session_controller.dart';
import 'package:messenger/model_encryptors/account_activity_encryptor.dart';
import 'package:messenger/model_encryptors/account_encryptor.dart';
import 'package:messenger/model_encryptors/account_image_metadata_encryptor.dart';
import 'package:messenger/model_encryptors/encryptor.dart';
import 'package:messenger/model_encryptors/group_encryptor.dart';
import 'package:messenger/model_encryptors/group_message_encryptor.dart';
import 'package:messenger/services/account_activities_table_service.dart';
import 'package:messenger/services/account_image_metadata_service.dart';
import 'package:messenger/services/accounts_in_group_service.dart';
import 'package:messenger/services/accounts_not_in_conversation_service.dart';
import 'package:messenger/services/accounts_not_in_group_service.dart';
import 'package:messenger/services/accounts_with_conversations_view_service.dart';
import 'package:messenger/services/add_accounts_to_group_servicre.dart';
import 'package:messenger/services/edit_group_name_service.dart';
import 'package:messenger/services/get_conversation_service.dart';
import 'package:messenger/services/group_account_links_table_service.dart';
import 'package:messenger/services/group_name_service.dart';
import 'package:messenger/services/groups_latest_messages_service.dart';
import 'package:messenger/services/groups_table_service.dart';
import 'package:messenger/services/is_group_active_service.dart';
import 'package:messenger/services/messages_table_service.dart';
import 'package:messenger/services/group_messages_view_service.dart';
import 'package:messenger/services/remove_users_from_group_service.dart';
import 'package:messenger/services/seconds_since_last_activity_service.dart';
import 'package:messenger/services/users_table_service.dart';

final getIt = GetIt.instance;

Future<void> registerSecretsController() async {
  getIt.registerSingleton(SecretsController());
  await getIt<SecretsController>().init();
}

// Future<void> registerNotifications() async {
//   getIt.registerSingleton(NotificationsController());
//   await getIt<NotificationsController>().init();
// }

void registerServices() {
  final getIt = GetIt.instance;

  getIt.registerSingleton(RemoveUsersFromGroupService());
  getIt.registerSingleton(AddAccountsToGroupServicre());
  getIt.registerSingleton(GroupAccountLinksTableService());
  getIt.registerSingleton(EncryptionController(getIt<SecretsController>()));
  getIt.registerSingleton(Encryptor(getIt<EncryptionController>()));
  getIt.registerSingleton(AccountEncryptor(getIt<Encryptor>()));
  getIt.registerSingleton(AccountActivityEncryptor(getIt<Encryptor>()));
  getIt.registerSingleton(GroupEncryptor(getIt<Encryptor>()));
  getIt.registerSingleton(EditGroupNameService(getIt<GroupEncryptor>()));
  getIt.registerSingleton(GroupMessageEncryptor(getIt<Encryptor>()));
  getIt.registerSingleton(
    GroupMessagesViewService(
      getIt<EncryptionController>(),
      getIt<GroupMessageEncryptor>(),
    ),
  );
  getIt.registerSingleton(AccountsNotInGroupService(getIt<AccountEncryptor>()));
  getIt.registerSingleton(AccountsInGroupService(getIt<AccountEncryptor>()));
  getIt.registerSingleton(
    AccountActivitiesTableService(
      getIt<AccountActivityEncryptor>(),
      getIt<AccountEncryptor>(),
    ),
  );
  getIt.registerSingleton(AudioController());
  getIt.registerSingleton(
    UsersTableService(getIt<EncryptionController>(), getIt<AccountEncryptor>()),
  );
  getIt.registerSingleton(MessagesTableService(getIt<GroupMessageEncryptor>()));
  getIt.registerSingleton(
    AccountController(
      getIt<UsersTableService>(),
      getIt<AccountActivitiesTableService>(),
    ),
  );
  getIt.registerSingleton(
    AccountsNotInConversationService(
      getIt<AccountEncryptor>(),
      getIt<AccountController>(),
    ),
  );
  getIt.registerSingleton(
    GroupsLatestMessagesService(
      getIt<EncryptionController>(),
      getIt<AccountController>(),
    ),
  );
  getIt.registerSingleton(GroupsTableService(getIt<GroupEncryptor>()));
  getIt.registerSingleton(
    GetConversationService(getIt<GroupEncryptor>(), getIt<AccountController>()),
  );
  getIt.registerSingleton(
    GroupNameService(
      getIt<AccountController>(),
      getIt<EncryptionController>(),
      getIt<GroupEncryptor>(),
    ),
  );
  getIt.registerSingleton(
    AccountsWithConversationsViewService(
      getIt<EncryptionController>(),
      getIt<AccountController>(),
      getIt<AccountEncryptor>(),
    ),
  );
  getIt.registerSingleton(AccountImageMetadataEncryptor(getIt<Encryptor>()));
  getIt.registerSingleton(
    AccountImageMetadataService(getIt<AccountImageMetadataEncryptor>()),
  );
  getIt.registerSingleton(
    ImagesIOController(
      getIt<AccountController>(),
      getIt<EncryptionController>(),
      getIt<AccountImageMetadataService>(),
    ),
  );
  getIt.registerSingleton(ImagesController(getIt<ImagesIOController>()));
  getIt.registerSingleton(IsGroupActiveService(getIt<EncryptionController>()));
  getIt.registerSingleton(
    SecondsSinceLastActivityService(getIt<AccountActivityEncryptor>()),
  );
  getIt.registerSingleton(
    SessionController(getIt<AccountEncryptor>(), getIt<AccountController>()),
  );
}

Future<void> initServices() async {
  final getIt = GetIt.instance;
  await getIt<EncryptionController>().init();
}
