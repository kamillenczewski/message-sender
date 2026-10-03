class Group {
  int id;
  String name;
  int typeId;

  static final kTable = 'groups';
  static final kId = 'id';
  static final kName = 'name';
  static final kTypeId = 'type_id';

  static final kNoNameTag = '__NO_NAME__';

  Group(this.id, this.name, this.typeId);

  Map<String, dynamic> toMap() {
    return {
      kId: id,
      kName: name,
      kTypeId: typeId
    };
  }

  factory Group.fromMap(Map<String, dynamic> map) {
    return Group(
      map[kId],
      map[kName],
      map[kTypeId],
    );
  }
}