class AccountActivity {
  int id;
  int accountId;
  int timestamp;

  static final kTable = 'account_activities';
  static final kId = 'id';
  static final kAccountId = 'account_id';
  static final kTimestamp = 'time_stamp';

  static final kMaxDelayInMiliseconds = 40*1000;
  static final kMaxDelayInSeconds = 40;

  AccountActivity(this.id, this.accountId, this.timestamp);

  Map<String, dynamic> toMap() {
    return {
      kId: id,
      kAccountId: accountId,
      kTimestamp: timestamp
    };
  }

  factory AccountActivity.fromMap(Map<String, dynamic> map) {
    return AccountActivity(
      map[kId],
      map[kAccountId],
      map[kTimestamp],
    );
  }
}