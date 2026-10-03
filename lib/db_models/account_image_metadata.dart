class AccountImageMetadata {
  int id;
  int accountId;
  int timestamp;

  static final kTable = 'account_images_metadata';
  static final kId = 'id';
  static final kAccountId = 'account_id';
  static final kTimestamp = 'timestamp';

  AccountImageMetadata(this.id, this.accountId, this.timestamp);

  Map<String, dynamic> toMap() {
    return {
      kId: id,
      kAccountId: accountId,
      kTimestamp: timestamp
    };
  }

  factory AccountImageMetadata.fromMap(Map<String, dynamic> map) {
    return AccountImageMetadata(
      map[kId],
      map[kAccountId],
      map[kTimestamp],
    );
  }
}