class GroupAccountLink {
  int id;
  int accountId;
  int groupId;

  static final kTable = 'group_account_links';
  static final kId = 'id';
  static final kAccountId = 'account_id';
  static final kGroupId = 'group_id';

  GroupAccountLink(this.id, this.accountId, this.groupId);

  Map<String, dynamic> toMap() {
    return {
      kId: id,
      kAccountId: accountId,
      kGroupId: groupId,
    };
  }

  factory GroupAccountLink.fromMap(Map<String, dynamic> map) {
    return GroupAccountLink(
      map[kId],
      map[kAccountId],
      map[kGroupId],
    );
  }
}