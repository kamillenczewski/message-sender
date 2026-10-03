import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:messenger/db_models/group.dart';
import 'package:messenger/db_models/group_message.dart';
import 'package:messenger/pages/widgets/account_image.dart';
import 'package:messenger/services/group_messages_view_service.dart';
import 'package:messenger/controllers/settings.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

final getIt = GetIt.instance;

class MessagesWidget extends HookWidget {
  final _settings = Settings.instance;
  final _messagesViewService = getIt<GroupMessagesViewService>();
  
  final ScrollController _scrollController;
  final Group _group;

  final kAvatarRadius = 25.0; 

  MessagesWidget({
    super.key,
    required this._scrollController,
    required this._group
  });

  Widget createMessageBox({required String text}) {
    return Text(
      text,
      softWrap: true,
      style: TextStyle(
        fontFamily: _settings.fontFamily,
        color: _settings.innerColor,
        fontSize: 15
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final supabase = Supabase.instance.client;
    
    useMemoized(() {});
    final viewData = useState<List<(List<GroupMessage>, String, int)>>([]);
    final isLoading = useState(true);
    final messageIndexForVisibleDate = useState(-1);
    final blockIndexForVisibleDate = useState(-1);

    void fetchView() async {
      viewData.value = await _messagesViewService.getMessagesByGroup_NEW(_group.id);
    }

    useEffect(() {
      isLoading.value = true;
      
      fetchView();

      final channel = supabase
        .channel('public:${GroupMessage.kTable}')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: GroupMessage.kTable,
          callback: (payload) => fetchView(),
        )
        .subscribe();
      
      isLoading.value = false;

      return () => supabase.removeChannel(channel);
    }, const []);

    final messages = viewData.value;
    
    if (isLoading.value) {
      return Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 100, maxHeight: 100),
          child: CircularProgressIndicator()
        ),
      );
    }

    return StatefulBuilder(
      builder: (context, setState) {
        return ScrollConfiguration(
          behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
          child: Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: messages.length,
              reverse: true,
              itemBuilder: (context, blockIndex) {
                final messagesBlock = messages[blockIndex].$1;
                final accountName = messages[blockIndex].$2;
                final accountId = messages[blockIndex].$3;
              
                return Column(
                  children: [
                    Row(
                      crossAxisAlignment: .start,
                      spacing: 12,
                      children: [
                        Column(
                          children: [
                            AccountImage(
                              accountId: accountId, 
                              accountName: accountName,
                              radius: kAvatarRadius,
                              isTooltipVisible: false,
                            ),
                          ],
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: .start,
                            children: <Widget>[
                              Text(
                                accountName,
                                textAlign: .left, 
                                style: TextStyle(
                                  color: _settings.innerColor, 
                                  fontFamily: _settings.fontFamily, 
                                  fontSize: 20,
                                  fontWeight: .bold
                                )
                              ),
                            ] + List.generate(
                              messagesBlock.length,
                              (index) {
                                return Column(
                                  children: [
                                    messageIndexForVisibleDate.value == index && 
                                    blockIndexForVisibleDate.value == blockIndex
                                    ? 
                                    Text(
                                      DateFormat("yyyy-MM-dd HH:mm")
                                        .format(DateTime.fromMillisecondsSinceEpoch(messagesBlock[index].datetime)),
                                      textAlign: .center,
                                      style: TextStyle(
                                        fontFamily: _settings.fontFamily,
                                        color: _settings.middleColor,
                                      ),
                                    )
                                    : 
                                    SizedBox.shrink(),
                                    Row(
                                      spacing: 8,
                                      children: [
                                        Expanded(
                                          child: GestureDetector(
                                            child: createMessageBox(text: messagesBlock[index].content),
                                            onTap: () {
                                              int newBlockIndex = -1;
                                              int newMessageIndex = -1;
                                                                      
                                              if (blockIndex != blockIndexForVisibleDate.value || index != messageIndexForVisibleDate.value) {
                                                newBlockIndex = blockIndex;
                                                newMessageIndex = index;
                                              }
                                                                      
                                              setState(() {
                                                blockIndexForVisibleDate.value = newBlockIndex;
                                                messageIndexForVisibleDate.value = newMessageIndex;
                                              });
                                            },
                                          ),
                                        ),
                                        
                                      ],
                                    ),
                                  ],
                                );
                              }
                            )
                          ),
                        )
                      ],
                    ),
                    SizedBox(height: 16)
                  ],
                );
              }
            ),
          ),
        );
      }
    );
  }
}