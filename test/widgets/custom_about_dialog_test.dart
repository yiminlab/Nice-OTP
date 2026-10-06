import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:two_factor_authentication/widgets/custom_about_dialog.dart';
import 'package:two_factor_authentication/services/localization_service.dart';

class MockLocalizationService extends LocalizationService {
  MockLocalizationService() : super(const Locale('en'));

  @override
  String translate(String key, {Map<String, String>? args}) {
    if (key == 'version') {
      return 'Version ${args?['version']}';
    }
    return key;
  }
}

void main() {
  setUp(() {
    LocalizationService.instance = MockLocalizationService();
  });

  group('CustomAboutDialog Tests', () {
    testWidgets('renders all elements correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Material(
            child: CustomAboutDialog(),
          ),
        ),
      );

      expect(find.text('app_name'), findsOneWidget);
      expect(find.text('Version 2.0.0'), findsOneWidget);
      expect(find.text('© ${DateTime.now().year} Nice OTP'), findsOneWidget);
      expect(find.text('disclaimer'), findsOneWidget);
      expect(find.text('close'), findsOneWidget);
    });

    testWidgets('close button works', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Material(
            child: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => const CustomAboutDialog(),
                  );
                },
                child: const Text('Show Dialog'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      expect(find.byType(CustomAboutDialog), findsOneWidget);

      await tester.tap(find.text('close'));
      await tester.pumpAndSettle();

      expect(find.byType(CustomAboutDialog), findsNothing);
    });
  });
}
