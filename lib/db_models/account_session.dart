class AccountSession {
  int id;
  int accountId;
  String hashcode;
  String deviceId;

  static final kTable = 'sessions';
  static final kId = 'id';
  static final kAccountId = 'account_id';
  static final kHashcode = 'hashcode';
  static final kDeviceId = 'device_id';

  AccountSession(this.id, this.accountId, this.hashcode, this.deviceId);

  Map<String, dynamic> toMap() {
    return {
      kId: id,
      kAccountId: accountId,
      kHashcode: hashcode,
      kDeviceId: deviceId
    };
  }

  factory AccountSession.fromMap(Map<String, dynamic> map) {
    return AccountSession(
      map[kId],
      map[kAccountId],
      map[kHashcode],
      map[kDeviceId],
    );
  }
}