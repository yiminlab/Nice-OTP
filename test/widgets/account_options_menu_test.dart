import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:two_factor_authentication/api/models/otp_token.dart';
import 'package:two_factor_authentication/widgets/account_options_menu.dart';
import 'package:two_factor_authentication/services/localization_service.dart';

class MockLocalizationService extends LocalizationService {
  MockLocalizationService() : super(const Locale('en'));

  @override
  String translate(String key, {Map<String, String>? args}) => key;
}

void main() {
  setUp(() {
    LocalizationService.instance = MockLocalizationService();
  });

  group('AccountOptionsMenu Widget Tests', () {
    late OTPToken testAccount;

    setUp(() {
      testAccount = OTPToken(
        name: 'Test',
        secret: 'SECRET',
        issuer: 'Issuer',
      );
    });

    testWidgets('shows menu and handles callbacks correctly',
        (WidgetTester tester) async {
      bool copyPressed = false;
      bool editPressed = false;
      bool pinPressed = false;
      bool deletePressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (BuildContext context) {
              return TextButton(
                onPressed: () {
                  AccountOptionsMenu.show(
                    context: context,
                    position: const RelativeRect.fromLTRB(0, 0, 0, 0),
                    account: testAccount,
                    onDelete: (_) => deletePressed = true,
                    onEdit: (_) => editPressed = true,
                    onPin: (_) => pinPressed = true,
                    onCopy: () => copyPressed = true,
                    isPinned: false,
                  );
                },
                child: const Text('Show Menu'),
              );
            },
          ),
        ),
      );

      // Show the menu
      await tester.tap(find.text('Show Menu'));
      await tester.pumpAndSettle();

      // Now we can interact with the menu items
      await tester.tap(find.text('copy'));
      await tester.pumpAndSettle();
      expect(copyPressed, true);

      // Show menu again for next action
      await tester.tap(find.text('Show Menu'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('edit'));
      await tester.pumpAndSettle();
      expect(editPressed, true);

      // Show menu again for next action
      await tester.tap(find.text('Show Menu'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('pin'));
      await tester.pumpAndSettle();
      expect(pinPressed, true);

      // Show menu again for next action
      await tester.tap(find.text('Show Menu'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('delete'));
      await tester.pumpAndSettle();
      expect(deletePressed, true);
    });

    testWidgets('renders correct pin/unpin text based on isPinned state',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (BuildContext context) {
              return TextButton(
                onPressed: () {
                  AccountOptionsMenu.show(
                    context: context,
                    position: const RelativeRect.fromLTRB(0, 0, 0, 0),
                    account: testAccount,
                    onDelete: (_) {},
                    onEdit: (_) {},
                    onPin: (_) {},
                    onCopy: () {},
                    isPinned: true,
                  );
                },
                child: const Text('Show Menu'),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Show Menu'));
      await tester.pumpAndSettle();

      expect(find.text('unpin'), findsOneWidget);
    });
  });
}
