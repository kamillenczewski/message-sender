class ConversationMessage {
  int id;
  int userId;
  int conversationId;
  String content;
  int datetime;

  static final kTable = 'conversation_messages';
  static final kId = 'id';
  static final kUserId = 'user_id';
  static final kConversationId = 'conversation_id';
  static final kContent = 'content';
  static final kDatetime = 'datetime';

  ConversationMessage(this.id, this.userId, this.content, this.datetime, this.conversationId);

  Map<String, dynamic> toMap() {
    return {
      kId: id,
      kUserId: userId,
      kContent: content,
      kDatetime: datetime,
      kConversationId: conversationId,
    };
  }

  factory ConversationMessage.fromMap(Map<String, dynamic> map) {
    return ConversationMessage(
      map[kId],
      map[kUserId],
      map[kContent],
      map[kDatetime],
      map[kConversationId],
    );
  }
}