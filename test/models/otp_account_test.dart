import 'package:flutter_test/flutter_test.dart';
import 'package:two_factor_authentication/api/models/otp_token.dart';

void main() {
  group('OTPAccount', () {
    test('creates instance with required parameters', () {
      final account = OTPToken(
        name: 'Test User',
        secret: 'TESTSECRET',
        issuer: 'Test Issuer',
      );

      expect(account.name, 'Test User');
      expect(account.secret, 'TESTSECRET');
      expect(account.issuer, 'Test Issuer');
    });

    test('fromJson creates instance correctly', () {
      final json = {
        'name': 'Test User',
        'secret': 'TESTSECRET',
        'issuer': 'Test Issuer',
      };

      final account = OTPToken.fromJson(json);

      expect(account.name, 'Test User');
      expect(account.secret, 'TESTSECRET');
      expect(account.issuer, 'Test Issuer');
    });

    test('toJson converts instance to map correctly', () {
      final account = OTPToken(
        name: 'Test User',
        secret: 'TESTSECRET',
        issuer: 'Test Issuer',
      );

      final json = account.toJson();

      expect(json['name'], 'Test User');
      expect(json['secret'], 'TESTSECRET');
      expect(json['issuer'], 'Test Issuer');
    });

    test('fromUri parses otpauth URI correctly', () {
      final uri = Uri.parse(
          'otpauth://totp/Test%20Issuer:Test%20User?secret=TESTSECRET&issuer=Test%20Issuer');

      final account = OTPToken.fromUri(uri);

      expect(account.name, 'Test User');
      expect(account.secret, 'TESTSECRET');
      expect(account.issuer, 'Test Issuer');
    });

    test('fromUri handles URI without issuer in parameters', () {
      final uri = Uri.parse(
          'otpauth://totp/Test%20Issuer:Test%20User?secret=TESTSECRET');

      final account = OTPToken.fromUri(uri);

      expect(account.name, 'Test User');
      expect(account.secret, 'TESTSECRET');
      expect(account.issuer, 'Test Issuer');
    });

    test('fromUri handles URI without issuer in label', () {
      final uri = Uri.parse(
          'otpauth://totp/Test%20User?secret=TESTSECRET&issuer=Test%20Issuer');

      final account = OTPToken.fromUri(uri);

      expect(account.name, 'Test User');
      expect(account.secret, 'TESTSECRET');
      expect(account.issuer, 'Test Issuer');
    });

    test('fromUri throws FormatException for invalid URI', () {
      final invalidUri = Uri.parse('invalid://uri');

      expect(
        () => OTPToken.fromUri(invalidUri),
        throwsA(isA<FormatException>()),
      );
    });

    test('fromUri throws FormatException for missing secret', () {
      final uriWithoutSecret =
          Uri.parse('otpauth://totp/Test%20Issuer:Test%20User');

      expect(
        () => OTPToken.fromUri(uriWithoutSecret),
        throwsA(isA<FormatException>()),
      );
    });

    test('toString returns formatted string', () {
      final account = OTPToken(
        name: 'Test User',
        secret: 'TESTSECRET',
        issuer: 'Test Issuer',
      );

      expect(account.toString(), 'Test Issuer: Test User');
    });

    test('== operator compares correctly', () {
      final account1 = OTPToken(
        name: 'Test User',
        secret: 'TESTSECRET',
        issuer: 'Test Issuer',
      );

      final account2 = OTPToken(
        name: 'Test User',
        secret: 'TESTSECRET',
        issuer: 'Test Issuer',
      );

      final account3 = OTPToken(
        name: 'Different User',
        secret: 'TESTSECRET',
        issuer: 'Test Issuer',
      );

      expect(account1 == account2, true);
      expect(account1 == account3, false);
    });

    test('hashCode is consistent', () {
      final account1 = OTPToken(
        name: 'Test User',
        secret: 'TESTSECRET',
        issuer: 'Test Issuer',
      );

      final account2 = OTPToken(
        name: 'Test User',
        secret: 'TESTSECRET',
        issuer: 'Test Issuer',
      );

      expect(account1.hashCode == account2.hashCode, true);
    });
  });
}
