import 'dart:async';

import 'package:flutter/material.dart';
import 'package:two_factor_authentication/api/models/otp_token.dart';
import 'package:two_factor_authentication/api/models/token_update_request.dart';
import 'package:two_factor_authentication/manager/cloud_sync_manager.dart';
import 'package:two_factor_authentication/screens/edit_account_screen.dart';
import 'package:two_factor_authentication/services/otp_service.dart';
import 'package:two_factor_authentication/store/otp_token_store.dart';
import 'package:two_factor_authentication/store/user_store.dart';
import 'package:two_factor_authentication/widgets/info_dialog.dart';
import 'package:two_factor_authentication/widgets/sync_status_card.dart';
import '../../widgets/otp_card.dart';
import '../../widgets/empty_state_widget.dart';

class HomeTab extends StatelessWidget {
  final VoidCallback onAddPressed;

  const HomeTab({
    super.key,
    required this.onAddPressed,
  });

  @override
  Widget build(BuildContext context) {
    final CloudSyncManager cloudSync = CloudSyncManager();
    final OTPTokenStore otpTokenStore = OTPTokenStore();
    final UserStore userStore = UserStore();

    void editAccount(OTPToken account) async {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EditAccountScreen(account: account),
        ),
      );

      if (result != null && result is OTPToken) {
        cloudSync.updateToken(TokenUpdateRequest(
          id: result.id,
          name: result.name,
          issuer: result.issuer ?? '',
        ));
      }
    }

    return AnimatedBuilder(
      animation: Listenable.merge([
        otpTokenStore.tokens,
        userStore.userNotifier,
      ]),
      builder: (context, child) {
        final sortedAccounts = otpTokenStore.sortedTokens;
        final isSyncEnabled = userStore.isSyncEnabled;

        return sortedAccounts.isEmpty
            ? EmptyStateWidget(
                onAddPressed: onAddPressed,
                onAccountAdded: () {
                  var account = OTPService.addRandomAccount();
                  cloudSync.createToken(account);
                },
                canAddMoreTokens: otpTokenStore.canAddMoreTokens,
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isSyncEnabled == false)
                    SyncStatusCard(
                      onSync: () async {
                        await InfoDialog.show(context: context);
                      },
                    ),
                  Expanded(
                    child: RemainingSecondsContainer(
                      child: ListView.builder(
                        itemCount: sortedAccounts.length,
                        itemBuilder: (context, index) {
                          return OTPCard(
                            account: sortedAccounts[index],
                            onEdit: editAccount,
                            onPin: (account) {
                              cloudSync.pinToken(account.id);
                            },
                            onDelete: (account) {
                              cloudSync.deleteToken(account.id);
                            },
                          );
                        },
                      ),
                    ),
                  )
                ],
              );
      },
    );
  }
}

class RemainingSecondsContainer extends StatefulWidget {
  final Widget child;

  const RemainingSecondsContainer({super.key, required this.child});

  @override
  State<RemainingSecondsContainer> createState() =>
      _RemainingSecondsContainerState();
}

class _RemainingSecondsContainerState extends State<RemainingSecondsContainer> {
  late Timer _timer;
  late int _remainingSeconds =
      OTPService.getRemainingSeconds(now: OTPService.getNow());
  late Function update = (int now) {};

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _remainingSeconds--;
        if (_remainingSeconds <= 0) {
          _remainingSeconds = 30;
          update(OTPService.getNow());
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return RemainingSecondsProvider(
        remainingSeconds: _remainingSeconds,
        update: update,
        child: widget.child);
  }
}

class RemainingSecondsProvider extends InheritedWidget {
  final int remainingSeconds;
  final Function update;
  const RemainingSecondsProvider({
    super.key,
    required this.remainingSeconds,
    required this.update,
    required super.child,
  });

  static RemainingSecondsProvider of(BuildContext context) {
    return context
            .dependOnInheritedWidgetOfExactType<RemainingSecondsProvider>() ??
        RemainingSecondsProvider(
          remainingSeconds: 30,
          update: (int now) {},
          child: const SizedBox(),
        );
  }

  @override
  bool updateShouldNotify(RemainingSecondsProvider oldWidget) {
    return oldWidget.remainingSeconds != remainingSeconds;
  }
}

class RemainingSecondsConsumer<T extends RemainingSecondsProvider>
    extends StatelessWidget {
  const RemainingSecondsConsumer({
    super.key,
    required this.builder,
  });

  final Widget Function(BuildContext context, T value) builder;

  @override
  Widget build(BuildContext context) {
    return builder(
      context,
      RemainingSecondsProvider.of(context) as T,
    );
  }
}
