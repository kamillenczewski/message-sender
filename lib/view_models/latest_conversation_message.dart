class LatestConversationMessage {
  int conversationId;
  String accountName1;
  String accountName2;
  String messageSender;
  String content;
  int datetime;

  static final kView = 'latest_conversation_messages_view';
  static final kAccountIdArg = 'current_account_id';

  static final kConversationId = 'conversation_id';
  static final kAccountName1 = 'account_name_1';
  static final kAccountName2 = 'account_name_2';
  static final kMessageSender = 'message_sender';
  static final kContent = 'content';
  static final kDatetime = 'datetime';

  LatestConversationMessage(this.conversationId, this.accountName1, this.accountName2, this.messageSender, this.content, this.datetime);

  Map<String, dynamic> toMap() {
    return {
      kConversationId: conversationId,
      kAccountName1: accountName1,
      kAccountName2: accountName2,
      kMessageSender: messageSender,
      kContent: content,
      kDatetime: datetime,
    };
  }

  factory LatestConversationMessage.fromMap(Map<String, dynamic> map) {
    return LatestConversationMessage(
      map[kConversationId],
      map[kAccountName1],
      map[kAccountName2],
      map[kMessageSender],
      map[kContent],
      map[kDatetime],
    );
  }
}