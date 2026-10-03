class GroupMessage {
  int id;
  int userId;
  int groupId;
  String content;
  int datetime;

  static final kTable = 'group_messages';
  static final kId = 'id';
  static final kUserId = 'user_id';
  static final kGroupId = 'group_id';
  static final kContent = 'content';
  static final kDatetime = 'datetime';

  GroupMessage(this.id, this.userId, this.content, this.datetime, this.groupId);

  Map<String, dynamic> toMap() {
    return {
      kId: id,
      kUserId: userId,
      kContent: content,
      kDatetime: datetime,
      kGroupId: groupId,
    };
  }

  factory GroupMessage.fromMap(Map<String, dynamic> map) {
    return GroupMessage(
      map[kId],
      map[kUserId],
      map[kContent],
      map[kDatetime],
      map[kGroupId],
    );
  }
}