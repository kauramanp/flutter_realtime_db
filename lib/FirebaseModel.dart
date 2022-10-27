class FirebaseModel {
  FirebaseModel({
    this.name,
    this.firebaseModelClass,
    this.rollno,
    this.referenceId,
  });

  String? name;
  String? firebaseModelClass;
  int? rollno;
  String? referenceId;

  factory FirebaseModel.fromJson(Map<String, dynamic> json) => FirebaseModel(
        name: json["name"] == null ? null : json["name"],
        firebaseModelClass: json["class"] == null ? null : json["class"],
        rollno: json["rollno"] == null ? null : json["rollno"],
        referenceId: json["referenceId"] == null ? null : json["referenceId"],
      );

  Map<String, dynamic> toJson() => {
        "name": name == null ? null : name,
        "class": firebaseModelClass == null ? null : firebaseModelClass,
        "rollno": rollno == null ? null : rollno,
        "referenceId": referenceId == null ? null : referenceId,
      };
}
