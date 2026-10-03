class Conversation {
  int id;
  int accountId1;
  int accountId2;

  static final kTable = 'conversations';
  static final kId = 'id';
  static final kAccountId1 = 'account_id_1';
  static final kAccountId2 = 'account_id_2';

  Conversation(this.id, this.accountId1, this.accountId2);

  Map<String, dynamic> toMap() {
    return {
      kId: id,
      kAccountId1: kAccountId1,
      kAccountId2: kAccountId2
    };
  }

  factory Conversation.fromMap(Map<String, dynamic> map) {
    return Conversation(
      map[kId],
      map[kAccountId1],
      map[kAccountId2],
    );
  }
}