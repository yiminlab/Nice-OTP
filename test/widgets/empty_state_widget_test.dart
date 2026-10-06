import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:two_factor_authentication/widgets/empty_state_widget.dart';
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

  group('EmptyStateWidget Tests', () {
    testWidgets('renders correctly and handles button press',
        (WidgetTester tester) async {
      bool buttonPressed = false;
      bool randomAccountAdded = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyStateWidget(
              onAddPressed: () => buttonPressed = true,
              onAccountAdded: () => randomAccountAdded = true,
              canAddMoreTokens: true,
            ),
          ),
        ),
      );

      expect(find.text('no_accounts'), findsOneWidget);
      expect(find.text('add_account'), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);

      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      expect(buttonPressed, true);

      await tester.tap(find.text('add_random_account'));
      await tester.pumpAndSettle();
      expect(randomAccountAdded, true);
    });

    testWidgets('does not add a random account when the limit is reached',
        (WidgetTester tester) async {
      bool randomAccountAdded = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyStateWidget(
              onAddPressed: () {},
              onAccountAdded: () => randomAccountAdded = true,
              canAddMoreTokens: false,
            ),
          ),
        ),
      );

      expect(find.text('no_accounts'), findsOneWidget);
      expect(find.text('add_account'), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);

      await tester.tap(find.text('add_random_account'));
      await tester.pumpAndSettle();
      expect(randomAccountAdded, false);
    });
  });
}
