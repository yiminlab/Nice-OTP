import 'package:flutter/material.dart';
import 'package:two_factor_authentication/manager/cloud_sync_manager.dart';
import 'package:two_factor_authentication/screens/language_screen.dart';
import 'package:two_factor_authentication/store/user_store.dart';
import 'package:two_factor_authentication/widgets/custom_about_dialog.dart';
import '../../services/localization_service.dart';

class ProfileTab extends StatelessWidget {
  final Function(Locale) onLocaleChanged;
  final Locale currentLocale;

  const ProfileTab({
    super.key,
    required this.onLocaleChanged,
    required this.currentLocale,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = LocalizationService.of(context);
    final cloudSync = CloudSyncManager();
    final userStore = UserStore();

    return ValueListenableBuilder(
        valueListenable: userStore.userNotifier,
        builder: (context, user, child) {
          var recordText = userStore.isSyncEnabled
              ? '${l10n.translate('latest_sync')}${userStore.lastSyncTimeString ?? l10n.translate('no_sync_record')}'
              : l10n.translate('not_enabled');
          return ListView(
            children: [
              ListTile(
                leading: const Icon(Icons.cloud_sync),
                title: Text(l10n.translate('cloud_sync')),
                subtitle: Text(
                  recordText,
                  style: const TextStyle(
                    fontSize: 12,
                  ),
                ),
                trailing: Transform.scale(
                  scale: 0.8,
                  child: Switch(
                    value: userStore.isSyncEnabled,
                    onChanged: (bool newValue) async {
                      try {
                        await cloudSync.toggleSync();
                        if (userStore.isSyncEnabled) {
                          cloudSync.sync();
                        }
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(l10n.translate('operation_success')),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      } catch (e) {
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(l10n.translate('operation_failed')),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      }
                    },
                  ),
                ),
                visualDensity: VisualDensity.compact,
                onTap: () {},
              ),
              ListTile(
                leading: const Icon(Icons.restore),
                title: Text(l10n.translate('account_recovery')),
                subtitle: Text(
                  l10n.translate('coming_soon'),
                ),
                onTap: () {},
              ),
              ListTile(
                leading: const Icon(Icons.language),
                title: Text(l10n.translate('language')),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LanguageScreen(
                        onLanguageSelected: onLocaleChanged,
                        currentLocale: currentLocale,
                      ),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: Text(l10n.translate('about')),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => const CustomAboutDialog(),
                  );
                },
              ),
            ],
          );
        });
  }
}
