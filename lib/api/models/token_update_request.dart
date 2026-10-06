import 'package:json_annotation/json_annotation.dart';

part 'token_update_request.g.dart';

@JsonSerializable()
class TokenUpdateRequest {
  final String id;
  final String name;
  final String issuer;

  TokenUpdateRequest({
    required this.id,
    required this.name,
    required this.issuer,
  });

  factory TokenUpdateRequest.fromJson(Map<String, dynamic> json) =>
      _$TokenUpdateRequestFromJson(json);

  Map<String, dynamic> toJson() => _$TokenUpdateRequestToJson(this);
}
