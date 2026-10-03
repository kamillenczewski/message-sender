class Account {
  int id;
  String name;
  String password;

  static final kTable = 'accounts';
  static final kId = 'id';
  static final kName = 'name';
  static final kPassword = 'password';

  Account(this.id, this.name, this.password);

  Map<String, dynamic> toMap() {
    return {
      kId: id,
      kName: name,
      kPassword: password
    };
  }

  factory Account.fromMap(Map<String, dynamic> map) {
    return Account(
      map[kId],
      map[kName],
      map[kPassword],
    );
  }
}