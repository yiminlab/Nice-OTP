import 'package:json_annotation/json_annotation.dart';

part 'sync_response.g.dart';

@JsonSerializable()
class SyncResponse {
  final bool success;
  @JsonKey(name: 'syncTime')
  final DateTime syncTime;
  @JsonKey(name: 'error', defaultValue: "")
  final String error;

  SyncResponse({
    required this.success,
    required this.syncTime,
    required this.error,
  });

  factory SyncResponse.fromJson(Map<String, dynamic> json) =>
      _$SyncResponseFromJson(json);
  Map<String, dynamic> toJson() => _$SyncResponseToJson(this);
}
