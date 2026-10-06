import 'package:json_annotation/json_annotation.dart';

part 'api_response.g.dart';

@JsonSerializable(genericArgumentFactories: true)
class ApiResponse<T> {
  final bool success;
  final String? error;
  final T? data;

  ApiResponse({
    required this.success,
    this.error,
    this.data,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) =>
      _$ApiResponseFromJson(json, fromJsonT);

  Map<String, dynamic> toJson(Object? Function(T value) toJsonT) =>
      _$ApiResponseToJson(this, toJsonT);
}

@JsonSerializable()
class ToggleSyncResponse {
  @JsonKey(name: 'sync_enabled', defaultValue: false)
  final bool syncEnabled;

  ToggleSyncResponse({
    required this.syncEnabled,
  });

  factory ToggleSyncResponse.fromJson(Map<String, dynamic> json) =>
      _$ToggleSyncResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ToggleSyncResponseToJson(this);
}
