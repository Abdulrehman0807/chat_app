// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class RequestModel {
  String? senderName;
  String? senderId;
  String? recevieName;
  String? recevieId;
  String? reqId;
  String? status;
  RequestModel({
    this.senderName,
    this.senderId,
    this.recevieName,
    this.recevieId,
    this.reqId,
    this.status,
  });

  RequestModel copyWith({
    String? senderName,
    String? senderId,
    String? recevieName,
    String? recevieId,
    String? reqId,
    String? status,
  }) {
    return RequestModel(
      senderName: senderName ?? this.senderName,
      senderId: senderId ?? this.senderId,
      recevieName: recevieName ?? this.recevieName,
      recevieId: recevieId ?? this.recevieId,
      reqId: reqId ?? this.reqId,
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'senderName': senderName,
      'senderId': senderId,
      'recevieName': recevieName,
      'recevieId': recevieId,
      'reqId': reqId,
      'status': status,
    };
  }

  factory RequestModel.fromMap(Map<String, dynamic> map) {
    return RequestModel(
      senderName:
          map['senderName'] != null ? map['senderName'] as String : null,
      senderId: map['senderId'] != null ? map['senderId'] as String : null,
      recevieName:
          map['recevieName'] != null ? map['recevieName'] as String : null,
      recevieId: map['recevieId'] != null ? map['recevieId'] as String : null,
      reqId: map['reqId'] != null ? map['reqId'] as String : null,
      status: map['status'] != null ? map['status'] as String : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory RequestModel.fromJson(String source) =>
      RequestModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'RequestModel(senderName: $senderName, senderId: $senderId, recevieName: $recevieName, recevieId: $recevieId, reqId: $reqId, status: $status)';
  }

  @override
  bool operator ==(covariant RequestModel other) {
    if (identical(this, other)) return true;

    return other.senderName == senderName &&
        other.senderId == senderId &&
        other.recevieName == recevieName &&
        other.recevieId == recevieId &&
        other.reqId == reqId &&
        other.status == status;
  }

  @override
  int get hashCode {
    return senderName.hashCode ^
        senderId.hashCode ^
        recevieName.hashCode ^
        recevieId.hashCode ^
        reqId.hashCode ^
        status.hashCode;
  }
}
