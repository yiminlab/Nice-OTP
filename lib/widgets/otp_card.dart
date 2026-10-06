import 'package:flutter/material.dart';
import 'package:two_factor_authentication/api/models/otp_token.dart';
import 'package:two_factor_authentication/screens/tabs/home_tab.dart';
import 'package:two_factor_authentication/services/localization_service.dart';
import '../services/otp_service.dart';
import '../services/clipboard_service.dart';
import 'account_options_menu.dart';
import 'press_animation_widget.dart';
import 'copy_animated_text.dart';
import 'service_icon.dart';
import 'otp_countdown_timer.dart';

class OTPCard extends StatefulWidget {
  final OTPToken account;
  final Function(OTPToken) onDelete;
  final Function(OTPToken) onEdit;
  final Function(OTPToken) onPin;

  const OTPCard({
    super.key,
    required this.account,
    required this.onDelete,
    required this.onEdit,
    required this.onPin,
  });

  @override
  State<OTPCard> createState() => _OTPCardState();
}

class _OTPCardState extends State<OTPCard> {
  late String _otp;
  final GlobalKey<CopyAnimatedTextState> _copyTextKey = GlobalKey();
  @override
  void initState() {
    super.initState();
    _updateOTP();
  }

  void _updateOTP() {
    final otpData = OTPService.generateOTP(
      widget.account.secret,
      now: OTPService.getNow(),
    );
    setState(() {
      _otp = _formatOTP(otpData.otp);
    });
  }

  String _formatOTP(String otp) {
    return '${otp.substring(0, 3)} ${otp.substring(3)}';
  }

  void _copyOTPToClipboard() async {
    await ClipboardService.copyOTP(_otp);
    _copyTextKey.currentState?.triggerCopy();
  }

  void _handleDelete(BuildContext context) {
    final l10n = LocalizationService.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.translate('delete_account')),
        content: Text(l10n.translate('delete_account_confirm')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.translate('cancel')),
          ),
          TextButton(
            onPressed: () {
              widget.onDelete(widget.account);
              Navigator.pop(context);
            },
            child: Text(l10n.translate('delete')),
          ),
        ],
      ),
    );
  }

  void _showOptionsMenu(BuildContext context, LongPressStartDetails details) {
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;

    final position = RelativeRect.fromRect(
      details.globalPosition & const Size(40, 40),
      Offset.zero & overlay.size,
    );

    AccountOptionsMenu.show(
      context: context,
      position: position,
      account: widget.account,
      onDelete: (account) => _handleDelete(context),
      onEdit: widget.onEdit,
      onPin: widget.onPin,
      onCopy: _copyOTPToClipboard,
      isPinned: widget.account.isPinned,
    );
  }

  void _handleRemainingSecondsChange(int remainingSeconds) {
    if (remainingSeconds <= 1) {
      Future.delayed(const Duration(seconds: 1), () {
        _updateOTP();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    const iconSize = 28.0;

    return RemainingSecondsConsumer(
      builder: (context, RemainingSecondsProvider provider) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _handleRemainingSecondsChange(provider.remainingSeconds);
        });

        return PressAnimationWidget(
          onTap: _copyOTPToClipboard,
          onLongPressStart: (details) => _showOptionsMenu(context, details),
          child: Card(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (widget.account.isPinned)
                    const Padding(
                      padding: EdgeInsets.only(right: 8),
                      child:
                          Icon(Icons.push_pin, size: 16, color: Colors.amber),
                    ),
                  ServiceIcon(
                    issuer: widget.account.issuer ?? '',
                    size: iconSize,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CopyAnimatedText(
                          key: _copyTextKey,
                          text: _otp,
                          onCopy: () {},
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.account.toString(),
                          style: textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  OTPCountdownTimer(
                    remainingSeconds: provider.remainingSeconds,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
