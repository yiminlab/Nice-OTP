import 'package:dio/dio.dart';
import '../dio_client.dart';
import '../models/otp_token.dart';
import '../models/token_list_response.dart';
import '../models/token_operation_response.dart';
import '../models/token_update_request.dart';
import '../models/sync_response.dart';
import '../models/token_restore_response.dart';

class OTPTokenService {
  final Dio _dio = DioClient().dio;

  Future<TokenOperationResponse> syncTokens(
      List<OTPToken> tokens, DateTime? lastSyncAt) async {
    try {
      final response = await _dio.put('/otp/sync', data: {
        'tokens': tokens.map((t) => t.toJson()).toList(),
        'lastSyncAt': lastSyncAt?.toIso8601String(),
      });
      return TokenOperationResponse.fromJson(response.data);
    } on DioException {
      rethrow;
    }
  }

  Future<TokenListResponse> getTokens() async {
    try {
      final response = await _dio.get('/otp/tokens');
      return TokenListResponse.fromJson(response.data);
    } on DioException {
      rethrow;
    }
  }

  Future<TokenOperationResponse> createTokens(List<OTPToken> tokens) async {
    try {
      final response = await _dio.post('/otp/tokens', data: {
        'tokens': tokens.map((t) => t.toJson()).toList(),
      });
      return TokenOperationResponse.fromJson(response.data);
    } on DioException {
      rethrow;
    }
  }

  Future<TokenOperationResponse> updateTokens(
      List<TokenUpdateRequest> tokens) async {
    try {
      final response = await _dio.put('/otp/tokens/sync', data: {
        'tokens': tokens.map((t) => t.toJson()).toList(),
      });
      return TokenOperationResponse.fromJson(response.data);
    } on DioException {
      rethrow;
    }
  }

  Future<TokenOperationResponse> pinToken(String id) async {
    try {
      final response = await _dio.put('/otp/tokens/pin/$id', data: {});
      return TokenOperationResponse.fromJson(response.data);
    } on DioException {
      rethrow;
    }
  }

  Future<SyncResponse> deleteToken(String id) async {
    try {
      final response = await _dio.delete('/otp/tokens/$id');
      return SyncResponse.fromJson(response.data);
    } on DioException {
      rethrow;
    }
  }

  Future<List<OTPToken>> getDeletedTokens() async {
    try {
      final response = await _dio.get('/otp/tokens/deleted');
      final data = response.data as Map<String, dynamic>;
      return (data['tokens'] as List)
          .map((item) => OTPToken.fromJson(item as Map<String, dynamic>))
          .toList();
    } on DioException {
      rethrow;
    }
  }

  Future<TokenRestoreResponse> restoreTokens(List<String> ids) async {
    try {
      final response =
          await _dio.post('/otp/tokens/restore', data: {'ids': ids});
      return TokenRestoreResponse.fromJson(response.data);
    } on DioException {
      rethrow;
    }
  }

  Future<SyncResponse> deleteHistory() async {
    try {
      final response = await _dio.delete('/otp/tokens/history');
      return SyncResponse.fromJson(response.data);
    } on DioException {
      rethrow;
    }
  }
}
