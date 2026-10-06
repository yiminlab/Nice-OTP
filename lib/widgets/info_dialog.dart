import 'package:flutter/material.dart';
import 'package:two_factor_authentication/store/user_store.dart';
import '../services/localization_service.dart';
import '../manager/cloud_sync_manager.dart';

class InfoDialog extends StatefulWidget {
  const InfoDialog({super.key});

  @override
  State<InfoDialog> createState() => _InfoDialogState();

  static Future<void> show({
    required BuildContext context,
  }) {
    return showDialog(
      context: context,
      builder: (context) => const InfoDialog(),
    );
  }
}

class _InfoDialogState extends State<InfoDialog> {
  bool _isLoading = false;
  final cloudSync = CloudSyncManager();
  final userStore = UserStore();
  Future<void> _handleSync() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    try {
      await cloudSync.toggleSync();
      if (userStore.isSyncEnabled) {
        cloudSync.sync();
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text(LocalizationService.of(context).translate('sync_started')),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              LocalizationService.of(context).translate(
                'sync_start_failed',
                args: {'error': e.toString()},
              ),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = LocalizationService.of(context);

    return AlertDialog(
      title: Text(l10n.translate('cloud_sync')),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.translate('cloud_sync_description')),
          const SizedBox(height: 16),
          // Text(l10n.translate('coming_soon_message')),
          if (_isLoading) ...[
            const SizedBox(height: 16),
            const Center(child: CircularProgressIndicator()),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: Text(l10n.translate('cancel')),
        ),
        TextButton(
          onPressed: _isLoading ? null : _handleSync,
          child: Text(l10n.translate('sync')),
        ),
      ],
    );
  }
}
