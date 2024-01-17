
import '../controllers/db_controller.dart';
import '../helpers/http_get.dart';

class User  {
  User({
    this.id,
    this.uid,
    required this.name,
    this.email,
    this.photoUrl,
    this.status,
  });

  factory User.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return User(
      id: jsonSerialization['id'],
      uid: jsonSerialization['uid'],
      name: jsonSerialization['name'],
      email:
        jsonSerialization['email'],
      photoUrl: jsonSerialization['photoUrl'],
      status: jsonSerialization['status'],
    );
  }

  int? id;

  String? uid;

  String name;

  String? email;

  String? photoUrl;

  String? status;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'uid': uid,
      'name': name,
      'email': email,
      'photoUrl': photoUrl,
      'status': status,
    };
  }
 static Future<User> fetchUser(String id) async =>
      await httpGetRequest(id).then((value) {
        value['uid'] = value['id'].toString();
        value['id'] = null;
        value['status'] = value['status'].toString();
        var user = User.fromJson(value);
        DBProvider.db.addUser(user, false);
        return user;
      });
}
