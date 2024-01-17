/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: public_member_api_docs
// ignore_for_file: implementation_imports

// ignore_for_file: no_leading_underscores_for_library_prefixes

class Message {
  Message({
    this.id,
    this.channel,
    required this.content,
    this.send_by,
    this.sent_at,
    this.isSent,
    this.seen_at,
    required this.seen_by,
    this.group,
    this.deleted,
    this.replayto,
  });

  factory Message.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return Message(
      id: jsonSerialization['id'],
      channel: jsonSerialization['channel'],
      content: jsonSerialization['content'],
      send_by: jsonSerialization['send_by'],
      sent_at:jsonSerialization['sent_at'],
      isSent: jsonSerialization['isSent'],
      seen_at: jsonSerialization['seen_at'],
      seen_by: jsonSerialization['seen_by'],
      group:jsonSerialization['group'],
      deleted:
        jsonSerialization['deleted'],
      replayto:jsonSerialization['replayto'],
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  String? channel;

  String content;

  String? send_by;

  DateTime? sent_at;

  String? isSent;

  DateTime? seen_at;

  List<String> seen_by;

  bool? group;

  bool? deleted;

  int? replayto;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'channel': channel,
      'content': content,
      'send_by': send_by,
      'sent_at': sent_at,
      'isSent': isSent,
      'seen_at': seen_at,
      'seen_by': seen_by,
      'group': group,
      'deleted': deleted,
      'replayto': replayto,
    };
  }
}
